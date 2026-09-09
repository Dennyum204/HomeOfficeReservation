import { useEffect, useRef, useState } from "react";
import type {
  MutationReceipt,
  PlanningApi,
} from "../../../../../contracts/typescript";
import { p } from "../../i18n/planning.pt-PT";
import { statusOf } from "../auth/api";
import { JOURNAL_KEY } from "../auth/session";
import {
  prepareCommand,
  readJournal,
  sendCommand,
  sessionFailure,
  type Journal,
  type WriteOperation,
} from "./api";
import { commandError } from "./errors";

export type CommandResult =
  "success" | "error" | "stale" | "uncertain" | "busy";
export type RunCommand = <K extends WriteOperation>(
  operation: K,
  input: Omit<Parameters<PlanningApi[K]>[0], "idempotencyKey">,
  label: string,
) => Promise<CommandResult>;
export function useCommand(
  actorId: string,
  onSuccess: (receipt: MutationReceipt, journal: Journal) => void,
  onRefresh: () => void,
) {
  const [journal, setJournal] = useState(() => readJournal(actorId));
  const pending = useRef(journal);
  const busyRef = useRef(false);
  const alive = useRef(true);
  const controller = useRef<AbortController | undefined>(undefined);
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState("");
  const [stale, setStale] = useState(false);
  useEffect(() => {
    alive.current = true;
    return () => {
      alive.current = false;
      controller.current?.abort();
    };
  }, []);
  async function execute(command: Journal): Promise<CommandResult> {
    controller.current = new AbortController();
    try {
      sessionStorage.setItem(JOURNAL_KEY, JSON.stringify(command));
      pending.current = command;
      setJournal(command);
      const receipt = await sendCommand(command, controller.current.signal);
      if (!alive.current) return "error";
      sessionStorage.removeItem(JOURNAL_KEY);
      pending.current = undefined;
      setJournal(undefined);
      setError("");
      setStale(false);
      onSuccess(receipt, command);
      return "success";
    } catch (cause) {
      if (!alive.current) return "error";
      sessionFailure(cause);
      const status = statusOf(cause);
      if (
        (status >= 400 && status < 500) ||
        (cause instanceof Error && cause.message === "account_changed")
      ) {
        sessionStorage.removeItem(JOURNAL_KEY);
        pending.current = undefined;
        setJournal(undefined);
        setError(await commandError(cause));
        if ([409, 412, 428].includes(status)) {
          setStale(true);
          onRefresh();
          return "stale";
        }
        if (status === 403) onRefresh();
        return "error";
      }
      setError(p.uncertain);
      return "uncertain";
    } finally {
      if (alive.current) {
        busyRef.current = false;
        setBusy(false);
      }
    }
  }
  const run: RunCommand = async (operation, input, label) => {
    if (busyRef.current || pending.current || stale) return "busy";
    busyRef.current = true;
    setBusy(true);
    setError("");
    try {
      const command = await prepareCommand(actorId, operation, input, label);
      if (!alive.current) return "error";
      // Fail before sending if the browser cannot retain the exact replay command.
      sessionStorage.setItem(JOURNAL_KEY, JSON.stringify(command));
      return await execute(command);
    } catch {
      if (alive.current) {
        setError(p.storage);
        busyRef.current = false;
        setBusy(false);
      }
      return "error";
    }
  };
  async function recover() {
    if (!pending.current || busyRef.current) return;
    busyRef.current = true;
    setBusy(true);
    setError("");
    await execute(pending.current);
  }
  return {
    run,
    journal,
    busy,
    locked: busy || !!journal,
    stale,
    error,
    recover,
    reviewed: () => {
      setStale(false);
      setError("");
    },
  };
}
