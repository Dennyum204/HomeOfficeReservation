import type { RequestView } from "../../../../../contracts/typescript";
import { p } from "../../i18n/planning.pt-PT";
export function requestCounts(request: RequestView) {
  if (request.state === "Draft") return p.draftCount(request.days.length);
  return p.counts(
    request.days.filter((d) => d.decision === "Approved").length,
    request.days.filter((d) => d.decision === "Pending").length,
  );
}
