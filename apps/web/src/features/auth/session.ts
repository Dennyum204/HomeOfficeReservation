import { createContext, useContext } from "react";
import type { MemberProfile } from "../../../../../contracts/typescript";
export const MemberContext = createContext<MemberProfile | undefined>(
  undefined,
);
export const useMember = () => useContext(MemberContext);
export const SESSION_EVENT = "homeoffice:check-session";
export const JOURNAL_KEY = "homeoffice:planning-command";
export const OWNER_KEY = "homeoffice:planning-owner";
export const EDITOR_KEY = "homeoffice:planning-editor";
export const WORK_DRAFT_KEY = "homeoffice:work-drafts";
export function clearPlanningSession() {
  try {
    for (const key of [
      JOURNAL_KEY,
      OWNER_KEY,
      EDITOR_KEY,
      WORK_DRAFT_KEY,
      "homeoffice:admin-command",
    ])
      sessionStorage.removeItem(key);
  } catch {
    /* No readable browser storage. */
  }
}
