import { useState } from "react";
import { useMember, WORK_DRAFT_KEY } from "../auth/session";

type DraftStore = { actorId: string; fields: Record<string, unknown> };
function read(actorId: string): DraftStore {
  try {
    const saved: DraftStore = JSON.parse(
      sessionStorage.getItem(WORK_DRAFT_KEY) ?? "null",
    );
    if (saved?.actorId === actorId && saved.fields) return saved;
  } catch {
    /* In-memory form input still works if storage is unavailable. */
  }
  return { actorId, fields: {} };
}
// UI fields only. Exact submitted commands use the separate generated-wire journal.
export function useWorkField<T extends string | boolean>(
  employeeId: string,
  context: string,
  field: string,
  initial: T,
) {
  const actorId = useMember()!.memberId;
  const key = `${employeeId}:${context}:${field}`;
  const [value, setValue] = useState<T>(() => {
    const saved = read(actorId).fields[key];
    return typeof saved === typeof initial ? (saved as T) : initial;
  });
  return [
    value,
    (next: T) => {
      setValue(next);
      try {
        const saved = read(actorId);
        saved.fields[key] = next;
        sessionStorage.setItem(WORK_DRAFT_KEY, JSON.stringify(saved));
      } catch {
        /* Retain the in-memory draft. */
      }
    },
  ] as const;
}
export function clearWorkDraft(employeeId: string, context: string) {
  try {
    const saved: DraftStore = JSON.parse(
      sessionStorage.getItem(WORK_DRAFT_KEY) ?? "null",
    );
    if (!saved?.fields) return;
    for (const key of Object.keys(saved.fields))
      if (key.startsWith(`${employeeId}:${context}:`)) delete saved.fields[key];
    sessionStorage.setItem(WORK_DRAFT_KEY, JSON.stringify(saved));
  } catch {
    /* Nothing readable to clear. */
  }
}
