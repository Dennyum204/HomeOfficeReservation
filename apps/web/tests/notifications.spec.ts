import { randomUUID } from "node:crypto";
import { test, expect, type Page } from "@playwright/test";
import { signIn } from "./support";
import { addDays, todayInZone } from "../src/features/planning/dates";
import type {
  CalendarView,
  MutationReceipt,
  RequestView,
  NotificationPage,
} from "../../../contracts/typescript";
type Wire<T> = T extends Date
  ? string
  : T extends object
    ? { [K in keyof T]: Wire<T[K]> }
    : T;
test.setTimeout(120000);
async function get<T>(page: Page, path: string): Promise<Wire<T>> {
  const response = await page.request.get(path);
  expect(response.status()).toBe(200);
  return response.json();
}
async function write(
  page: Page,
  path: string,
  data: unknown,
): Promise<MutationReceipt> {
  const csrf = await (await page.request.get("/api/v1/auth/csrf")).json();
  const response = await page.request.post(path, {
    data,
    headers: {
      "X-CSRF-TOKEN": csrf.requestToken,
      "Idempotency-Key": randomUUID(),
    },
  });
  expect(response.status()).toBe(200);
  return response.json();
}
async function inbox(page: Page) {
  await page
    .getByRole("navigation")
    .getByRole("button", { name: /^Notificações/ })
    .click();
  await expect(page.getByLabel("Filtrar notificações")).toBeVisible();
}
async function waitNotification(page: Page, resourceId: string) {
  let result: Wire<NotificationPage>["items"][number] | undefined;
  await expect
    .poll(
      async () => {
        const data = await get<NotificationPage>(
          page,
          "/api/v1/notifications?limit=100",
        );
        result = data.items.find(
          (n) => n.destination?.resourceId === resourceId,
        );
        return result?.id;
      },
      { timeout: 20000 },
    )
    .toBeTruthy();
  await page
    .getByRole("button", { name: "Atualizar notificações", exact: true })
    .click();
  const row = page.locator(`[data-notification-id="${result!.id}"]`);
  await expect(row).toBeVisible();
  return { row, item: result! };
}
test("real worker delivers submission, decision, onsite and task; read state never decides", async ({
  page,
  browser,
}, testInfo) => {
  const managerContext = await browser.newContext({
    baseURL: "http://127.0.0.1:5174",
    viewport: page.viewportSize(),
  });
  const manager = await managerContext.newPage();
  try {
    await signIn(page);
    await signIn(manager, "manager");
    const profile = await (await page.request.get("/api/v1/me")).json();
    const employee = profile.memberId;
    const base = `/api/v1/planning/${employee}`;
    const from = addDays(todayInZone(), 40);
    const calendar = await get<CalendarView>(
      page,
      `${base}/calendar?from=${from}&to=${addDays(from, 320)}`,
    );
    const occupied = new Set([
      ...calendar.effectiveDays
        .filter((d) => d.origin !== "WeeklyPattern")
        .map((d) => d.localDate),
      ...calendar.pendingDays.map((d) => d.day.localDate),
    ]);
    let date: string | undefined;
    for (let i = 0; i < 320; i++) {
      const d = addDays(from, i);
      if (
        !occupied.has(d) &&
        !calendar.requirements.some((r) => r.from <= d && r.to >= d) &&
        ![0, 6].includes(new Date(`${d}T12:00:00`).getDay())
      ) {
        date = d;
        break;
      }
    }
    expect(date).toBeTruthy();
    const note = `Notificação sintética ${randomUUID().slice(0, 8)}`;
    const draft = await write(page, `${base}/requests`, {
      expectedCalendarVersion: calendar.calendarVersion,
      note,
      days: [
        {
          localDate: date,
          location: "RemotePortugal",
          availability: "Working",
        },
      ],
    });
    // The actual Web inbox is open before submission; its bounded polling must notice the event.
    await inbox(manager);
    await write(page, `${base}/requests/${draft.contextId}/submit`, {
      expectedCalendarVersion: draft.calendarVersion,
      expectedRequestVersion: draft.version,
    });
    const incoming = await waitNotification(manager, draft.contextId);
    await expect(
      incoming.row.getByText("Por ler", { exact: true }),
    ).toBeVisible();
    const countBefore = await get<{ unreadCount: number }>(
      manager,
      "/api/v1/notifications/unread-count",
    );
    const before = await get<RequestView>(
      manager,
      `${base}/requests/${draft.contextId}`,
    );
    await incoming.row
      .getByRole("button", { name: "Marcar como lida", exact: true })
      .click();
    await expect
      .poll(
        async () =>
          (
            await get<{ unreadCount: number }>(
              manager,
              "/api/v1/notifications/unread-count",
            )
          ).unreadCount,
      )
      .toBe(countBefore.unreadCount - 1);
    expect(
      await get<RequestView>(manager, `${base}/requests/${draft.contextId}`),
    ).toEqual(before);
    await incoming.row
      .getByRole("button", { name: "Abrir contexto", exact: true })
      .click();
    await expect(
      manager
        .locator(".request-detail")
        .getByRole("heading", { name: note, exact: true }),
    ).toBeVisible();
    const current = await get<CalendarView>(
      manager,
      `${base}/calendar?from=${date}&to=${date}`,
    );
    await write(manager, `${base}/requests/${draft.contextId}/decide`, {
      expectedCalendarVersion: current.calendarVersion,
      expectedRequestVersion: before.version,
      days: before.days.map((d) => ({
        dayId: d.id,
        expectedVersion: d.version,
      })),
      approve: false,
      reason: "Ensaio sintético de notificação",
    });
    await inbox(page);
    const decision = await waitNotification(page, draft.contextId);
    expect(decision.item.eventType).toBe("planning.decided");
    await decision.row
      .getByRole("button", { name: "Abrir contexto", exact: true })
      .click();
    await expect(
      page
        .locator(".request-detail")
        .getByRole("heading", { name: note, exact: true }),
    ).toBeVisible();
    const updated = await get<CalendarView>(
      manager,
      `${base}/calendar?from=${date}&to=${date}`,
    );
    const onsite = await write(manager, `${base}/requirements`, {
      expectedCalendarVersion: updated.calendarVersion,
      from: date,
      to: date,
      reason: note,
      location: "Zurique",
      reference: "",
    });
    const task = await write(manager, `${base}/tasks`, {
      expectedCalendarVersion: onsite.calendarVersion,
      title: note,
      description: "",
      deadline: date,
      state: "Todo",
      requiresOnsite: true,
      requirementId: onsite.contextId,
    });
    await inbox(page);
    const presence = await waitNotification(page, onsite.contextId);
    await presence.row
      .getByRole("button", { name: "Marcar como lida", exact: true })
      .click();
    expect(
      (
        await get<{ readAt: string | null }>(
          page,
          `${base}/requirements/${onsite.contextId}`,
        )
      ).readAt,
    ).toBeNull();
    await presence.row
      .getByRole("button", { name: "Abrir contexto", exact: true })
      .click();
    await expect(
      page
        .locator(".work-detail")
        .getByRole("heading", { name: note, exact: true }),
    ).toBeVisible();
    await inbox(page);
    const assigned = await waitNotification(page, task.contextId);
    await assigned.row
      .getByRole("button", { name: "Abrir contexto", exact: true })
      .click();
    await expect(
      page
        .locator(".work-detail")
        .getByRole("heading", { name: note, exact: true }),
    ).toBeVisible();
    await inbox(page);
    await page.screenshot({
      path: `test-results/notifications-${testInfo.project.name}.png`,
      fullPage: true,
    });
    expect(
      await page.evaluate(
        () => document.documentElement.scrollWidth <= window.innerWidth,
      ),
    ).toBe(true);
  } finally {
    await managerContext.close();
  }
});
