import { describe, expect, it, vi } from "vitest";
import {
  DayInputFromJSON,
  DayInputToJSON,
} from "../../../contracts/typescript/models/DayInput";
import { Configuration, PlanningApi } from "../../../contracts/typescript";

describe("generated date-only planning contract (simulated HTTP)", () => {
  it.each(["Europe/Lisbon", "Europe/Zurich", "America/New_York"])(
    "preserves date-only bodies, queries and responses in %s",
    async (zone) => {
      vi.stubEnv("TZ", zone);
      try {
        for (const iso of ["2026-10-25", "2027-03-28"]) {
          const input = DayInputFromJSON({
            localDate: iso,
            location: "RemotePortugal",
            availability: "Working",
          });
          expect(DayInputToJSON(input).localDate).toBe(iso);
          const fetchApi = vi.fn(async (url: RequestInfo | URL) => {
            const query = new URL(String(url)).searchParams;
            expect(query.get("from")).toBe(iso);
            expect(query.get("to")).toBe(iso);
            return new Response(
              JSON.stringify({ days: [{ localDate: iso, isWeekend: true }] }),
              {
                status: 200,
                headers: { "content-type": "application/json" },
              },
            );
          });
          const api = new PlanningApi(
            new Configuration({
              basePath: "https://example.invalid",
              fetchApi,
            }),
          );
          const result = await api.previewPlanningDates({
            from: input.localDate,
            to: input.localDate,
          });
          expect(result.days[0].localDate.getDate()).toBe(
            input.localDate.getDate(),
          );
          expect(fetchApi).toHaveBeenCalledOnce();
        }
      } finally {
        vi.unstubAllEnvs();
      }
    },
  );
});
