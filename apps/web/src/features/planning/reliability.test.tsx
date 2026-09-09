import { act, renderHook, waitFor } from "@testing-library/react";
import { afterEach, expect, it, vi } from "vitest";
import {
  ResponseError,
  type MemberProfile,
} from "../../../../../contracts/typescript";
import { accessApi, authApi } from "../auth/api";
import { prepareCommand, sendCommand } from "./api";
import { addDays, addMonths, dateValue, period } from "./dates";
import { useRead } from "./useRead";

afterEach(() => {
  vi.unstubAllGlobals();
  vi.unstubAllEnvs();
});
it("generated retry preserves the wire payload, date and idempotency header while renewing CSRF (simulated HTTP)", async () => {
  vi.spyOn(accessApi, "getCurrentMember").mockResolvedValue({
    memberId: "actor",
  } as MemberProfile);
  vi.spyOn(authApi, "getCsrfToken")
    .mockResolvedValueOnce({ requestToken: "synthetic-first" })
    .mockResolvedValueOnce({ requestToken: "synthetic-second" });
  const fetchMock = vi.fn(
    async () =>
      new Response(
        JSON.stringify({
          contextId: "request",
          calendarVersion: 1,
          version: 1,
          eventId: "synthetic-event",
        }),
        { status: 200 },
      ),
  );
  vi.stubGlobal("fetch", fetchMock);
  const command = await prepareCommand(
    "actor",
    "createPlanningDraft",
    {
      employeeId: "employee",
      draftInput: {
        expectedRequestVersion: null,
        parentRevisionId: null,
        expectedCalendarVersion: 0,
        days: [
          {
            localDate: dateValue("2026-10-25"),
            location: "RemotePortugal",
            availability: "Working",
          },
        ],
        note: "Synthetic",
      },
    },
    "Save",
  );
  const persisted = JSON.parse(JSON.stringify(command));
  await sendCommand(command, new AbortController().signal);
  await sendCommand(persisted, new AbortController().signal);
  const calls = vi.mocked(fetch).mock.calls;
  expect(calls).toHaveLength(2);
  expect(calls[1][1]?.body).toEqual(calls[0][1]?.body);
  expect(JSON.parse(String(calls[0][1]?.body)).days[0].localDate).toBe(
    "2026-10-25",
  );
  const first = new Headers(calls[0][1]?.headers),
    second = new Headers(calls[1][1]?.headers);
  expect(first.get("Idempotency-Key")).toBeTruthy();
  expect(second.get("Idempotency-Key")).toBe(first.get("Idempotency-Key"));
  expect(second.get("X-CSRF-TOKEN")).toBe("synthetic-second");
  expect(JSON.stringify(persisted)).not.toContain("synthetic-first");
  const changed = await prepareCommand(
    "actor",
    "createPlanningDraft",
    {
      employeeId: "employee",
      draftInput: {
        expectedRequestVersion: null,
        parentRevisionId: null,
        expectedCalendarVersion: 1,
        days: [],
        note: "Changed",
      },
    },
    "Save",
  );
  expect(changed.request.headers["Idempotency-Key"]).not.toBe(
    first.get("Idempotency-Key"),
  );
});

it("out-of-order planning reads cannot restore another employee or a forbidden view (simulated HTTP)", async () => {
  let late!: (value: string) => void;
  const read = vi
    .fn()
    .mockImplementationOnce(
      () =>
        new Promise<string>((resolve) => {
          late = resolve;
        }),
    )
    .mockResolvedValueOnce("employee B")
    .mockRejectedValueOnce(
      new ResponseError(new Response("", { status: 403 })),
    );
  const { result, rerender } = renderHook(
    ({ key }) => useRead(key, read, key.split(":")[0]),
    { initialProps: { key: "A:1" } },
  );
  rerender({ key: "B:1" });
  await waitFor(() => expect(result.current.data).toBe("employee B"));
  await act(async () => late("employee A"));
  expect(result.current.data).toBe("employee B");
  rerender({ key: "B:2" });
  await waitFor(() => expect(result.current.error).toBeTruthy());
  expect(result.current.data).toBeUndefined();
});

it.each(["Europe/Lisbon", "Europe/Zurich", "America/New_York"])(
  "calendar navigation keeps date-only days across DST and month ends in %s",
  (zone) => {
    vi.stubEnv("TZ", zone);
    expect(addDays("2026-10-25", 1)).toBe("2026-10-26");
    expect(addDays("2027-03-28", -1)).toBe("2027-03-27");
    expect(addMonths("2027-01-31", 1)).toBe("2027-02-28");
    expect(period("2026-10-25", "week").days).toEqual([
      "2026-10-19",
      "2026-10-20",
      "2026-10-21",
      "2026-10-22",
      "2026-10-23",
      "2026-10-24",
      "2026-10-25",
    ]);
  },
);
