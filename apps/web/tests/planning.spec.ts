import { randomUUID } from "node:crypto";
import {
  test,
  expect,
  type Page,
  type APIRequestContext,
} from "@playwright/test";
import { signIn } from "./support";
import { addDays, todayInZone } from "../src/features/planning/dates";
import type { CalendarView, RequestPage } from "../../../contracts/typescript";

// HTTP assertions use the generated types with their date-only wire representation.
type Wire<T> = T extends Date
  ? string
  : T extends object
    ? { [K in keyof T]: Wire<T[K]> }
    : T;

test.setTimeout(120000);
const details = (page: Page) =>
  page.getByRole("region", { name: "Detalhe do pedido", exact: true });
const dialog = (page: Page) => page.getByRole("dialog");
async function ready(page: Page) {
  await expect(
    page.getByRole("button", { name: "Atualizar dados", exact: true }),
  ).toBeEnabled();
}
async function refresh(page: Page) {
  await ready(page);
  await page
    .getByRole("button", { name: "Atualizar dados", exact: true })
    .click();
  await ready(page);
}
async function calendar(
  api: APIRequestContext,
  employeeId: string,
  from: string,
  to: string,
) {
  const response = await api.get(
    `/api/v1/planning/${employeeId}/calendar?from=${from}&to=${to}`,
  );
  expect(response.ok()).toBeTruthy();
  return (await response.json()) as Wire<CalendarView>;
}
async function freeWeek(page: Page, employeeId: string) {
  const start = addDays(todayInZone(), 28);
  const end = addDays(start, 335);
  // Read in bounded windows; retain all previous synthetic and user data.
  const windows = await Promise.all(
    [0, 84, 168, 252].map(async (offset) =>
      calendar(
        page.request,
        employeeId,
        addDays(start, offset),
        addDays(start, offset + 83),
      ),
    ),
  );
  const occupied = new Set(
    windows.flatMap((c) => [
      ...c.effectiveDays
        .filter((d) => d.origin !== "WeeklyPattern")
        .map((d) => d.localDate),
      ...c.pendingDays.map((d) => d.day.localDate),
    ]),
  );
  for (let date = start; date < end; date = addDays(date, 1)) {
    if (new Date(`${date}T12:00:00`).getDay() !== 1) continue;
    const days = Array.from({ length: 5 }, (_, i) => addDays(date, i));
    if (days.every((d) => !occupied.has(d))) return days;
  }
  throw new Error(
    "No unoccupied synthetic test week; existing data was preserved.",
  );
}
async function openRequest(page: Page, note: string) {
  await page.getByRole("button", { name: "Pedidos", exact: true }).click();
  await refresh(page);
  await page
    .getByRole("region", { name: "Pedidos", exact: true })
    .getByRole("button")
    .filter({ has: page.getByText(note, { exact: true }) })
    .click();
  await expect(
    details(page).getByRole("heading", { name: note, exact: true }),
  ).toBeVisible();
  await ready(page);
}
async function newDraft(
  page: Page,
  dates: string[],
  note: string,
  availability = "Working",
) {
  await page.getByRole("button", { name: "Pedidos", exact: true }).click();
  await ready(page);
  await page
    .getByRole("button", {
      name: "+ Pedir os meus dias de trabalho",
      exact: true,
    })
    .click();
  await dialog(page)
    .getByRole("combobox", { name: "Disponibilidade", exact: true })
    .selectOption(availability);
  await dialog(page).getByLabel("De", { exact: true }).fill(dates[0]);
  await dialog(page).getByLabel("Até", { exact: true }).fill(dates.at(-1)!);
  await dialog(page)
    .getByRole("button", { name: "Pré-visualizar intervalo" })
    .click();
  await expect(
    dialog(page).getByText(`Dias incluídos · ${dates.length} dias`),
  ).toBeVisible();
  await dialog(page)
    .getByRole("button", { name: "Adicionar estes dias" })
    .click();
  await dialog(page)
    .getByRole("textbox", { name: "Comentário do pedido", exact: true })
    .fill(note);
  const saved = page.waitForResponse(
    (r) => r.url().endsWith("/requests") && r.request().method() === "POST",
  );
  await dialog(page)
    .getByRole("button", { name: "Guardar rascunho", exact: true })
    .click();
  expect((await saved).status()).toBe(200);
  await expect(
    details(page).getByRole("heading", { name: note, exact: true }),
  ).toBeVisible();
  await ready(page);
}
async function action(page: Page, name: string) {
  await details(page).getByRole("button", { name, exact: true }).click();
  await expect(
    dialog(page).getByRole("heading", { name: "Rever operação" }),
  ).toBeVisible();
  await dialog(page).getByRole("button", { name: "Confirmar envio" }).click();
  await expect(dialog(page)).toHaveCount(0);
  await ready(page);
}
async function counts(page: Page, approved: number, pending: number) {
  await expect(details(page).locator(".request-counts")).toHaveText(
    `${approved} ${approved === 1 ? "dia aprovado" : "dias aprovados"} · ${pending} ${pending === 1 ? "dia pendente" : "dias pendentes"}`,
  );
}
async function select(page: Page, dates: string[]) {
  await details(page)
    .getByRole("button", { name: "Limpar seleção", exact: true })
    .click();
  for (const date of dates)
    await details(page)
      .getByRole("checkbox", { name: `Dias selecionados ${date}`, exact: true })
      .check();
}
async function mutation(page: Page, path: string, data: unknown) {
  const csrf = await page.request.get("/api/v1/auth/csrf");
  expect(csrf.ok()).toBeTruthy();
  const { requestToken } = await csrf.json();
  return page.request.post(path, {
    data,
    headers: { "X-CSRF-TOKEN": requestToken, "Idempotency-Key": randomUUID() },
  });
}

test("five days, partial decision, withdrawal, revision and stale recovery use real PostgreSQL", async ({
  page,
  browser,
}, info) => {
  await signIn(page);
  await ready(page);
  const employeeId = await page
    .getByLabel("Colaborador selecionado", { exact: true })
    .inputValue();
  const dates = await freeWeek(page, employeeId);
  const note = `Ensaio HO-005 · ${info.project.name} · ${randomUUID().slice(0, 8)}`;
  await newDraft(page, dates, note);
  await action(page, "Submeter pedido");
  await counts(page, 0, 5);

  const managerContext = await browser.newContext({
    ...info.project.use,
    baseURL: "http://127.0.0.1:5174",
  });
  const manager = await managerContext.newPage();
  try {
    await signIn(manager, "manager");
    await manager
      .getByLabel("Colaborador selecionado", { exact: true })
      .selectOption(employeeId);
    await openRequest(manager, note);
    await select(manager, dates.slice(0, 3));
    await details(manager)
      .getByRole("textbox", { name: "Motivo", exact: true })
      .fill("Três dias acordados; os restantes aguardam decisão.");
    await details(manager)
      .getByRole("button", { name: "Aprovar dias", exact: true })
      .click();
    // A real concurrent comment advances the employee calendar after the review froze its versions.
    const list = (await (
      await page.request.get(
        `/api/v1/planning/${employeeId}/requests?limit=100`,
      )
    ).json()) as Wire<RequestPage>;
    const current = list.items.find((r) => r.note === note)!;
    const before = await calendar(page.request, employeeId, dates[0], dates[4]);
    const comment = await mutation(
      page,
      `/api/v1/planning/${employeeId}/requests/${current.id}/comments`,
      {
        expectedCalendarVersion: before.calendarVersion,
        text: "Comentário sintético concorrente para testar revisão de versões.",
      },
    );
    expect(comment.ok()).toBeTruthy();
    const staleResponse = manager.waitForResponse(
      (r) => r.url().endsWith("/decide") && r.request().method() === "POST",
    );
    await dialog(manager)
      .getByRole("button", { name: "Confirmar envio" })
      .click();
    expect((await staleResponse).status()).toBe(412);
    await expect(dialog(manager)).toHaveCount(0);
    await expect(
      details(manager).getByRole("textbox", { name: "Motivo", exact: true }),
    ).toHaveValue("Três dias acordados; os restantes aguardam decisão.");
    await expect(
      manager.getByRole("button", { name: "Já revi os dados atualizados" }),
    ).toBeEnabled();
    await manager
      .getByRole("button", { name: "Já revi os dados atualizados" })
      .click();
    await action(manager, "Aprovar dias");
    await counts(manager, 3, 2);
    await refresh(page);
    await counts(page, 3, 2);
    await page.screenshot({
      path: `test-results/partial-${info.project.name}.png`,
      fullPage: true,
    });
    await select(page, dates.slice(3));
    await action(page, "Retirar dias pendentes");
    await counts(page, 3, 0);
    let plan = await calendar(page.request, employeeId, dates[0], dates[4]);
    expect(
      plan.effectiveDays.filter((d) => d.origin === "ApprovedRequest"),
    ).toHaveLength(3);
    expect(plan.pendingDays).toHaveLength(0);

    // A normal manual absence draft cannot overwrite the approved remote plan.
    await newDraft(page, [dates[0]], `${note} · conflito manual`, "Leave");
    await details(page)
      .getByRole("button", { name: "Submeter pedido", exact: true })
      .click();
    const conflict = page.waitForResponse(
      (r) => r.url().endsWith("/submit") && r.request().method() === "POST",
    );
    await dialog(page).getByRole("button", { name: "Confirmar envio" }).click();
    expect((await conflict).status()).toBe(409);
    await expect(
      page.getByText(/Há um plano aprovado nestas datas/),
    ).toBeVisible();
    await page
      .getByRole("button", { name: "Já revi os dados atualizados" })
      .click();
    plan = await calendar(page.request, employeeId, dates[0], dates[4]);
    expect(plan.effectiveDays[0].location).toBe("RemotePortugal");
    await expect(
      details(page).getByRole("button", { name: "Editar rascunho" }),
    ).toBeEnabled();

    await openRequest(page, note);
    await select(page, [dates[0]]);
    await details(page)
      .getByRole("button", { name: "Propor alteração", exact: true })
      .click();
    await dialog(page)
      .getByLabel(`Localização ${dates[0]}`, { exact: true })
      .selectOption("OfficeSwitzerland");
    await dialog(page)
      .getByRole("textbox", { name: "Comentário do pedido", exact: true })
      .fill(`${note} · revisão`);
    await dialog(page)
      .getByRole("button", { name: "Guardar revisão como rascunho" })
      .click();
    await expect(
      details(page).getByRole("heading", {
        name: `${note} · revisão`,
        exact: true,
      }),
    ).toBeVisible();
    await ready(page);
    await action(page, "Submeter pedido");
    plan = await calendar(page.request, employeeId, dates[0], dates[4]);
    expect(plan.effectiveDays[0].location).toBe("RemotePortugal");
    expect(plan.pendingDays[0].day.location).toBe("OfficeSwitzerland");
    // Navigate the actual calendar to the pending revision and inspect both layers.
    await page.getByRole("button", { name: "Calendário", exact: true }).click();
    for (
      let i = 0;
      i < 13 &&
      (await page.locator(`button[data-date="${dates[0]}"]`).count()) === 0;
      i++
    ) {
      await page.getByRole("button", { name: "Período seguinte" }).click();
      await ready(page);
    }
    const day = page.locator(`button[data-date="${dates[0]}"]`);
    await expect(day).toContainText("Remoto PT");
    await expect(day).toContainText("Presencial CH");
    await day.click();
    await day.focus();
    await page.keyboard.press("ArrowRight");
    await expect(page.locator(`button[data-date="${dates[1]}"]`)).toBeFocused();
    await page.keyboard.press("ArrowLeft");
    await page.keyboard.press("Enter");
    await expect(day).toBeFocused();
    expect(
      await page.evaluate(
        () => document.documentElement.scrollWidth <= innerWidth,
      ),
    ).toBeTruthy();
    await page.screenshot({
      path: `test-results/calendar-${info.project.name}.png`,
      fullPage: true,
    });
    await page.getByRole("button", { name: "Semana", exact: true }).click();
    await ready(page);
    await page.screenshot({
      path: `test-results/week-${info.project.name}.png`,
      fullPage: true,
    });
    await openRequest(manager, `${note} · revisão`);
    await action(manager, "Aprovar dias");
    plan = await calendar(page.request, employeeId, dates[0], dates[4]);
    expect(plan.effectiveDays[0].location).toBe("OfficeSwitzerland");
    expect(
      plan.effectiveDays.filter((d) => d.origin === "ApprovedRequest"),
    ).toHaveLength(3);
    expect(plan.pendingDays).toHaveLength(0);
  } finally {
    await manager.screenshot({
      path: `test-results/manager-${info.project.name}.png`,
      fullPage: true,
    });
    await managerContext.close();
  }
});

test("lost response replays the exact command after reload; logout clears private drafts", async ({
  page,
}, info) => {
  await signIn(page);
  await ready(page);
  const employeeId = await page
    .getByLabel("Colaborador selecionado", { exact: true })
    .inputValue();
  const dates = await freeWeek(page, employeeId);
  const note = `Recuperação HO-005 · ${info.project.name} · ${randomUUID().slice(0, 8)}`;
  await newDraft(page, [dates[0]], note);
  const writes: { key: string | undefined; body: string | null }[] = [];
  await page.route("**/requests/*/submit", async (route) => {
    const request = route.request();
    writes.push({
      key: request.headers()["idempotency-key"],
      body: request.postData(),
    });
    const response = await route.fetch();
    expect(response.status()).toBe(200);
    if (writes.length === 1) await route.abort("failed");
    else await route.fulfill({ response });
  });
  await details(page)
    .getByRole("button", { name: "Submeter pedido", exact: true })
    .click();
  await dialog(page)
    .getByRole("button", { name: "Confirmar envio" })
    .dblclick();
  await expect(
    dialog(page).getByRole("button", { name: "Recuperar o mesmo envio" }),
  ).toBeVisible();
  expect(writes).toHaveLength(1);
  const before = await calendar(page.request, employeeId, dates[0], dates[0]);
  await page.reload();
  await expect(
    page.getByRole("button", { name: "Recuperar o mesmo envio" }),
  ).toBeVisible();
  await page.getByRole("button", { name: "Recuperar o mesmo envio" }).click();
  await expect(
    details(page).getByRole("heading", { name: note, exact: true }),
  ).toBeVisible();
  await counts(page, 0, 1);
  expect(writes).toHaveLength(2);
  expect(writes[1]).toEqual(writes[0]);
  const after = await calendar(page.request, employeeId, dates[0], dates[0]);
  expect(after.calendarVersion).toBe(before.calendarVersion);
  expect(after.pendingDays).toHaveLength(1);
  await action(page, "Retirar dias pendentes");
  await page
    .getByRole("button", {
      name: "+ Pedir os meus dias de trabalho",
      exact: true,
    })
    .click();
  await dialog(page)
    .getByLabel("Comentário do pedido")
    .fill("Rascunho privado sintético");
  await page.reload();
  await expect(dialog(page).getByLabel("Comentário do pedido")).toHaveValue(
    "Rascunho privado sintético",
  );
  await page.keyboard.press("Escape");
  await expect(dialog(page)).toHaveCount(0);
  await page
    .getByRole("button", { name: "Terminar sessão", exact: true })
    .click();
  await expect(
    page.getByRole("heading", { name: "Entre no seu espaço" }),
  ).toBeVisible();
  await signIn(page, "manager");
  await expect(page.getByText("Rascunho privado sintético")).toHaveCount(0);
  expect(
    await page.evaluate(() =>
      sessionStorage.getItem("homeoffice:planning-editor"),
    ),
  ).toBeNull();
  await expect(
    page.getByRole("button", {
      name: /Criar membro|Administrador de contas/,
      exact: true,
    }),
  ).toHaveCount(0);
});

test("real authorization denial exposes no planning or approval controls to an unassigned administrator", async ({
  page,
}) => {
  await signIn(page, "admin");
  await expect(
    page.getByText("Esta conta não tem acesso a um calendário de colaborador."),
  ).toBeVisible();
  const member = await (await page.request.get("/api/v1/me")).json();
  const date = todayInZone();
  const response = await page.request.get(
    `/api/v1/planning/${member.memberId}/calendar?from=${date}&to=${date}`,
  );
  expect(response.status()).toBe(403);
  await expect(
    page.getByRole("button", { name: "Aprovar dias", exact: true }),
  ).toHaveCount(0);
  await expect(
    page.getByLabel("Colaborador selecionado", { exact: true }),
  ).toHaveCount(0);
});

test("counterproposal acceptance still needs a final decision; cancellation and rejection preserve history", async ({
  page,
  browser,
}, info) => {
  await signIn(page);
  await ready(page);
  const employeeId = await page
    .getByLabel("Colaborador selecionado", { exact: true })
    .inputValue();
  const dates = await freeWeek(page, employeeId);
  const note = `Alternativa HO-005 · ${info.project.name} · ${randomUUID().slice(0, 8)}`;
  await newDraft(page, dates.slice(0, 2), note);
  await action(page, "Submeter pedido");
  const context = await browser.newContext({
    ...info.project.use,
    baseURL: "http://127.0.0.1:5174",
  });
  const manager = await context.newPage();
  try {
    await signIn(manager, "manager");
    await manager
      .getByLabel("Colaborador selecionado", { exact: true })
      .selectOption(employeeId);
    await openRequest(manager, note);
    await select(manager, [dates[0]]);
    await details(manager)
      .getByRole("button", { name: "Criar contraproposta", exact: true })
      .click();
    await dialog(manager)
      .getByLabel(`Localização ${dates[0]}`, { exact: true })
      .selectOption("OfficeSwitzerland");
    await dialog(manager)
      .getByRole("textbox", { name: "Motivo", exact: true })
      .fill(`${note} · alternativa`);
    await dialog(manager)
      .getByRole("button", { name: "Criar contraproposta", exact: true })
      .click();
    await expect(dialog(manager)).toHaveCount(0);
    await ready(manager);
    await refresh(page);
    await action(page, "Aceitar contraproposta");
    await counts(page, 0, 1);
    let plan = await calendar(page.request, employeeId, dates[0], dates[1]);
    expect(plan.effectiveDays[0].origin).toBe("WeeklyPattern");
    expect(plan.pendingDays).toHaveLength(2);
    await openRequest(manager, `${note} · alternativa`);
    await action(manager, "Aprovar dias");
    await refresh(page);
    await counts(page, 1, 0);
    await select(page, [dates[0]]);
    await details(page)
      .getByRole("button", { name: "Propor cancelamento", exact: true })
      .click();
    await dialog(page)
      .getByRole("textbox", { name: "Comentário do pedido", exact: true })
      .fill(`${note} · cancelamento`);
    await dialog(page)
      .getByRole("button", { name: "Guardar revisão como rascunho" })
      .click();
    await expect(dialog(page)).toHaveCount(0);
    await ready(page);
    await action(page, "Submeter pedido");
    plan = await calendar(page.request, employeeId, dates[0], dates[1]);
    expect(plan.effectiveDays[0].origin).toBe("ApprovedRequest");
    await openRequest(manager, `${note} · cancelamento`);
    await action(manager, "Aprovar dias");
    plan = await calendar(page.request, employeeId, dates[0], dates[1]);
    expect(plan.effectiveDays[0].origin).toBe("WeeklyPattern");
    await openRequest(manager, note);
    await select(manager, [dates[1]]);
    await details(manager)
      .getByRole("button", { name: "Rejeitar dias", exact: true })
      .click();
    await expect(details(manager).getByRole("alert")).toContainText(
      "Obrigatório na rejeição",
    );
    await details(manager)
      .getByRole("textbox", { name: "Motivo", exact: true })
      .fill(
        "Data alternativa já resolvida; segundo dia recusado neste ensaio.",
      );
    await action(manager, "Rejeitar dias");
    await openRequest(page, note);
    await expect(
      details(page).locator(`[data-request-date="${dates[1]}"]`),
    ).toContainText("Rejeitado");
    expect(
      (await calendar(page.request, employeeId, dates[0], dates[1]))
        .pendingDays,
    ).toHaveLength(0);
  } finally {
    await context.close();
  }
});
