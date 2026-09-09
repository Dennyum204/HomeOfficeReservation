import {
  DayInputFromJSON,
  type DayInput,
} from "../../../../../contracts/typescript";
import { EDITOR_KEY } from "../auth/session";
export interface EditorSpec {
  id: string;
  mode: "new" | "edit" | "revision" | "proposal";
  requestId?: string;
  proposalId?: string;
  affectedIds?: string[];
  parentRevisionId?: string | null;
  days: DayInput[];
  note: string;
}
export function restoreEditor(
  actorId: string,
  employeeId?: string,
): EditorSpec | undefined {
  try {
    const stored = JSON.parse(sessionStorage.getItem(EDITOR_KEY) ?? "null");
    if (
      stored?.actorId === actorId &&
      (!employeeId || stored.employeeId === employeeId)
    )
      return {
        ...stored.editor,
        days: stored.editor.days.map(DayInputFromJSON),
      };
  } catch {
    /* An unavailable or invalid journal is never restored. */
  }
}
