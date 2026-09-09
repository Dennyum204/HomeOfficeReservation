import { ResponseError } from "../../../../../contracts/typescript";
import { statusOf } from "../auth/api";
import { p } from "../../i18n/planning.pt-PT";
import { w } from "../../i18n/work.pt-PT";
export function readError(error: unknown): string {
  const status = statusOf(error);
  return status === 401
    ? p.expired
    : status === 403
      ? p.forbidden
      : status === 429
        ? p.limited
        : p.error;
}
export async function commandError(error: unknown) {
  const status = statusOf(error);
  if (error instanceof ResponseError) {
    const body = (await error.response
      .clone()
      .json()
      .catch(() => ({}))) as { code?: string };
    if (body.code && body.code in p.errors)
      return p.errors[body.code as keyof typeof p.errors];
    if (body.code && body.code in w.errors)
      return w.errors[body.code as keyof typeof w.errors];
  }
  return status === 412 || status === 428
    ? p.stale
    : status === 409
      ? p.conflict
      : status === 400
        ? p.invalid
        : readError(error);
}
