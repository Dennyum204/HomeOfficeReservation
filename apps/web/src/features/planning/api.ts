import {
  Configuration,
  PlanningApi,
  MutationReceiptFromJSON,
  type RequestOpts,
  type MutationReceipt,
} from "../../../../../contracts/typescript";
import { accessApi, csrf, statusOf } from "../auth/api";
import { JOURNAL_KEY, SESSION_EVENT } from "../auth/session";

export type WriteOperation =
  | "createPlanningDraft"
  | "editPlanningDraft"
  | "submitPlanningRequest"
  | "decidePlanningDays"
  | "withdrawPlanningDays"
  | "createCounterproposal"
  | "reviseCounterproposal"
  | "acceptCounterproposal"
  | "addPlanningComment"
  | "setWeeklyPattern";
// RequestOpts are serialized by generated methods, including date-only DTOs. Persist only this wire command, never CSRF/cookies.
class PlanningTransport extends PlanningApi {
  async send(
    command: RequestOpts,
    signal: AbortSignal,
  ): Promise<MutationReceipt> {
    const csrfOptions = await csrf();
    const response = await this.request(command, {
      headers: { ...command.headers, ...csrfOptions.headers },
      signal,
    });
    return MutationReceiptFromJSON(await response.json());
  }
}
export const planningApi = new PlanningTransport(
  new Configuration({ basePath: "", credentials: "same-origin" }),
);
export interface Journal {
  actorId: string;
  employeeId: string;
  operation: WriteOperation;
  request: RequestOpts;
  requestId?: string;
  label: string;
}
export function readJournal(actorId: string): Journal | undefined {
  try {
    const value: Journal = JSON.parse(
      sessionStorage.getItem(JOURNAL_KEY) ?? "null",
    );
    if (!value) return undefined;
    if (
      value.actorId === actorId &&
      ["POST", "PUT"].includes(value.request.method) &&
      value.request.path.startsWith(`/api/v1/planning/${value.employeeId}/`) &&
      value.request.headers["Idempotency-Key"]
    )
      return value;
    sessionStorage.removeItem(JOURNAL_KEY);
  } catch {
    // Unavailable storage cannot contain a command that can be safely recovered.
  }
}
export async function prepareCommand<K extends WriteOperation>(
  actorId: string,
  operation: K,
  input: Omit<Parameters<PlanningApi[K]>[0], "idempotencyKey">,
  label: string,
): Promise<Journal> {
  const parameters = { ...input, idempotencyKey: crypto.randomUUID() };
  const prepare = planningApi[`${operation}RequestOpts`] as (
    args: typeof parameters,
  ) => Promise<RequestOpts>;
  const request = await prepare.call(planningApi, parameters);
  return {
    actorId,
    employeeId: input.employeeId,
    operation,
    request,
    label,
    requestId: "requestId" in input ? String(input.requestId) : undefined,
  };
}
export async function sendCommand(command: Journal, signal: AbortSignal) {
  const member = await accessApi.getCurrentMember({ signal });
  if (member.memberId !== command.actorId) {
    sessionStorage.removeItem(JOURNAL_KEY);
    window.dispatchEvent(new Event(SESSION_EVENT));
    throw new Error("account_changed");
  }
  return planningApi.send(command.request, signal);
}
export function sessionFailure(error: unknown) {
  if (statusOf(error) === 401) window.dispatchEvent(new Event(SESSION_EVENT));
}
