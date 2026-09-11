import {
  ResponseError,
  type AccessApi,
} from "../../../../../contracts/typescript";
import { accessApi, csrf, statusOf } from "../auth/api";
import { SESSION_EVENT } from "../auth/session";
import { a } from "../../i18n/admin.pt-PT";

export const ADMIN_JOURNAL = "homeoffice:admin-command";
export type Operation =
  | "provisionMember"
  | "updateMember"
  | "assignManager"
  | "resendInvitation"
  | "cancelInvitation";
export type Intent = {
  [K in Operation]: { operation: K; input: Parameters<AccessApi[K]>[0] };
}[Operation];
export type Journal = { actorId: string; label: string; intent: Intent };
export function readJournal(actorId: string): Journal | undefined {
  try {
    const value = JSON.parse(
      sessionStorage.getItem(ADMIN_JOURNAL) ?? "null",
    ) as Journal | null;
    if (value?.actorId === actorId) return value;
    sessionStorage.removeItem(ADMIN_JOURNAL);
  } catch {
    /* Storage failure prevents writes, but does not prevent reads. */
  }
}
export async function send(journal: Journal) {
  const current = await accessApi.getCurrentMember();
  if (
    current.memberId !== journal.actorId ||
    !current.active ||
    !current.isAccountAdministrator
  ) {
    window.dispatchEvent(new Event(SESSION_EVENT));
    throw new Error("account_changed");
  }
  const options = await csrf();
  const { intent } = journal;
  switch (intent.operation) {
    case "provisionMember":
      return accessApi.provisionMember(intent.input, options);
    case "updateMember":
      return accessApi.updateMember(intent.input, options);
    case "assignManager":
      return accessApi.assignManager(intent.input, options);
    case "resendInvitation":
      return accessApi.resendInvitation(intent.input, options);
    case "cancelInvitation":
      return accessApi.cancelInvitation(intent.input, options);
  }
}
export async function errorMessage(error: unknown) {
  const status = statusOf(error);
  if (status === 401 || status === 403)
    window.dispatchEvent(new Event(SESSION_EVENT));
  if (status === 409 || status === 412) return a.stale;
  if (error instanceof ResponseError) {
    const problem = (await error.response
      .clone()
      .json()
      .catch(() => ({}))) as { title?: string };
    if (problem.title && a.errors[problem.title])
      return a.errors[problem.title];
  }
  if (
    status === 403 ||
    (error instanceof Error && error.message === "account_changed")
  )
    return a.forbidden;
  return a.error;
}
