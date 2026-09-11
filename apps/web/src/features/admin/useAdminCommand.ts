import { useEffect, useRef, useState } from "react";
import { statusOf } from "../auth/api";
import { a } from "../../i18n/admin.pt-PT";
import {
  ADMIN_JOURNAL,
  errorMessage,
  readJournal,
  send,
  type Intent,
  type Journal,
} from "./api";

export function useAdminCommand(actorId: string, refresh: () => void) {
  const [journal, setJournal] = useState(() => readJournal(actorId));
  const pending = useRef(journal);
  const running = useRef(false);
  const alive = useRef(true);
  const [busy, setBusy] = useState(false);
  const [message, setMessage] = useState("");
  useEffect(() => {
    alive.current = true;
    return () => {
      alive.current = false;
    };
  }, []);
  async function execute(command: Journal) {
    if (running.current) return;
    running.current = true;
    setBusy(true);
    setMessage("");
    try {
      // Persist before sending. Exact replay is available after reload, without tokens or codes.
      sessionStorage.setItem(ADMIN_JOURNAL, JSON.stringify(command));
    } catch {
      running.current = false;
      setBusy(false);
      setMessage(a.storage);
      return;
    }
    pending.current = command;
    setJournal(command);
    try {
      await send(command);
      if (!alive.current) return;
      sessionStorage.removeItem(ADMIN_JOURNAL);
      pending.current = undefined;
      setJournal(undefined);
      setMessage(a.success);
      refresh();
    } catch (error) {
      if (!alive.current) return;
      const status = statusOf(error);
      if (
        (status >= 400 && status < 500) ||
        (error instanceof Error && error.message === "account_changed")
      ) {
        sessionStorage.removeItem(ADMIN_JOURNAL);
        pending.current = undefined;
        setJournal(undefined);
        setMessage(await errorMessage(error));
        refresh();
      } else setMessage(a.uncertain);
    } finally {
      if (alive.current) {
        running.current = false;
        setBusy(false);
      }
    }
  }
  return {
    busy,
    journal,
    message,
    locked: busy || !!journal,
    run: (intent: Intent, label: string) => {
      if (pending.current || running.current) return;
      return execute({ actorId, label, intent });
    },
    recover: () => pending.current && execute(pending.current),
  };
}
