import { randomUUID } from "node:crypto";
import {
  test,
  expect,
  type Page,
  type APIRequestContext,
} from "@playwright/test";
import { signIn } from "./support";
import { addDays, todayInZone } from "../src/features/planning/dates";
import type {
  CalendarView,
  MutationReceipt,
  OnsiteView,
  RequestView,
} from "../../../contracts/typescript";
type Wire<T> = T extends Date
  ? string
  : T extends object
    ? { [K in keyof T]: Wire<T[K]> }
    : T;
test.setTimeout(150000);
const work = (page: Page) => page.locator(".work-detail");
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
async function cal(
  api: APIRequestContext,
  employee: string,
  from: string,
  to = from,
): Promise<Wire<CalendarView>> {
  const res = await api.get(
    `/api/v1/planning/${employee}/calendar?from=${from}&to=${to}`,
  );
  expect(res.status()).toBe(200);
  return res.json();
}
async function mutate(
  page: Page,
  path: string,
  data: unknown,
): Promise<MutationReceipt> {
  const csrf = await (await page.request.get("/api/v1/auth/csrf")).json();
  const res = await page.request.post(path, {
    data,
    headers: {
      "X-CSRF-TOKEN": csrf.requestToken,
      "Idempotency-Key": randomUUID(),
    },
  });
  expect(res.status()).toBe(200);
  return res.json();
}
async function freeDates(page: Page, employee: string) {
  const from = addDays(todayInZone(), 35);
  const calendar = await cal(page.request, employee, from, addDays(from, 330));
  const occupied = new Set([
    ...calendar.effectiveDays
      .filter((d) => d.origin !== "WeeklyPattern")
      .map((d) => d.localDate),
    ...calendar.pendingDays.map((d) => d.day.localDate),
  ]);
  for (let i = 0; i < 327; i++) {
    const date = addDays(from, i);
    if ([0, 6].includes(new Date(`${date}T12:00:00`).getDay())) continue;
    const dates = [date, addDays(date, 1), addDays(date, 2)];
    if (
      dates.every(
        (d) =>
          !occupied.has(d) &&
          !calendar.requirements.some((r) => r.from <= d && r.to >= d),
      )
    )
      return dates;
  }
  throw new Error("No free synthetic dates; existing data preserved.");
}
async function navigate(page: Page, name: "Presenças" | "Tarefas") {
  await page
    .getByRole("navigation")
    .getByRole("button", { name, exact: true })
    .click();
  await ready(page);
}
async function openOnsite(page: Page, title: string) {
  await navigate(page, "Presenças");
  await refresh(page);
  await openListedWork(page, title);
  await expect(
    work(page).getByRole("heading", { name: title, exact: true }),
  ).toBeVisible();
  await ready(page);
  await expect(work(page)).toBeFocused();
  if ((page.viewportSize()?.width ?? 1366) <= 1000) {
    const detailBounds = await work(page).boundingBox();
    const listBounds = await page
      .locator(".work-layout > .request-list")
      .boundingBox();
    expect(detailBounds!.y).toBeLessThan(listBounds!.y);
  }
}
async function openListedWork(page: Page, title: string) {
  const list = page.locator(".work-layout > .request-list");
  for (let pageNumber = 0; pageNumber < 100; pageNumber++) {
    await expect(list.getByRole("status")).toHaveCount(0);
    const item = list
      .locator(".request-list-item")
      .filter({ has: page.getByText(title, { exact: true }) });
    if (await item.count()) {
      await item.click();
      return;
    }
    const next = list.getByRole("button", {
      name: "Página seguinte",
      exact: true,
    });
    await expect(
      next,
      "The new synthetic item must exist on a real result page",
    ).toBeEnabled();
    await next.click();
  }
  throw new Error(
    "Synthetic item was not found; existing records were preserved.",
  );
}
async function createOnsite(
  page: Page,
  title: string,
  date: string,
  expected: "Ativa" | "Por resolver",
  fromCalendar = false,
) {
  if (fromCalendar) {
    await showDate(page, date);
    await page
      .getByRole("button", { name: "Selecionar datas", exact: true })
      .click();
    await page.locator(`button[data-date="${date}"]`).click();
  } else await navigate(page, "Presenças");
  await page
    .getByRole("button", {
      name: "+ Exigir presença do colaborador",
      exact: true,
    })
    .click();
  const form = page.getByRole("form", {
    name: "Exigir presença do colaborador",
    exact: true,
  });
  if (fromCalendar) {
    await expect(form.getByLabel("Primeiro dia")).toHaveValue(date);
    await expect(form.getByLabel("Último dia")).toHaveValue(date);
  }
  await form.getByLabel("Motivo", { exact: true }).fill(title);
  await form.getByLabel("Primeiro dia").fill(date);
  await form.getByLabel("Último dia").fill(date);
  await form.getByLabel("Local", { exact: true }).fill("Oficina de Zurique");
  await form
    .getByLabel("Máquina / projeto (opcional)")
    .fill("XPTO · ensaio sintético");
  await form
    .getByRole("button", { name: "Pré-visualizar conflitos", exact: true })
    .click();
  await expect(
    form.locator(".conflict-preview").getByText(expected, { exact: true }),
  ).toBeVisible();
  const response = page.waitForResponse(
    (r) => r.url().endsWith("/requirements") && r.request().method() === "POST",
  );
  await form
    .getByRole("button", { name: "Confirmar presença", exact: true })
    .click();
  expect((await response).status()).toBe(200);
  const receipt: MutationReceipt = await (await response).json();
  await openOnsite(page, title);
  return receipt.contextId;
}
async function showDate(page: Page, date: string) {
  await page
    .getByRole("navigation")
    .getByRole("button", { name: "Calendário", exact: true })
    .click();
  await refresh(page);
  while (!(await page.locator(`button[data-date="${date}"]`).count())) {
    await page
      .getByRole("button", { name: "Período seguinte", exact: true })
      .click();
    await ready(page);
  }
  await page.locator(`button[data-date="${date}"]`).click();
}

test("onsite reading, preserved remote conflict, explicit resolution and linked task use real API/PostgreSQL", async ({
  page,
  browser,
}, info) => {
  await signIn(page);
  await ready(page);
  const employee = await page
    .getByLabel("Colaborador selecionado", { exact: true })
    .inputValue();
  const dates = await freeDates(page, employee);
  const tag = `${info.project.name} ${randomUUID().slice(0, 6)}`;
  const title = `Instalação da máquina XPTO · ${tag}`;
  const conflictTitle = `Intervenção presencial · ${tag}`;
  const managerContext = await browser.newContext({
    ...info.project.use,
    baseURL: "http://127.0.0.1:5174",
  });
  const manager = await managerContext.newPage();
  try {
    await signIn(manager, "manager");
    await ready(manager);
    await manager
      .getByLabel("Colaborador selecionado", { exact: true })
      .selectOption(employee);
    await ready(manager);
    await createOnsite(manager, title, dates[0], "Ativa", true);
    await openOnsite(page, title);
    await expect(
      work(page).getByText(/Confirmar leitura não significa/),
    ).toBeVisible();
    await work(page)
      .getByRole("button", {
        name: "Confirmar leitura desta revisão",
        exact: true,
      })
      .click();
    await expect(
      work(page).getByText("Leitura confirmada", { exact: true }).first(),
    ).toBeVisible();
    const root = `/api/v1/planning/${employee}`;
    let calendar = await cal(page.request, employee, dates[1]);
    const draft = await mutate(page, root + "/requests", {
      expectedCalendarVersion: calendar.calendarVersion,
      expectedRequestVersion: null,
      parentRevisionId: null,
      note: `Remoto acordado · ${tag}`,
      days: [
        {
          localDate: dates[1],
          location: "RemotePortugal",
          availability: "Working",
          cancel: false,
        },
      ],
    });
    const submitted = await mutate(
      page,
      root + `/requests/${draft.contextId}/submit`,
      {
        expectedCalendarVersion: draft.calendarVersion,
        expectedRequestVersion: draft.version,
      },
    );
    const request: Wire<RequestView> = await (
      await page.request.get(root + `/requests/${draft.contextId}`)
    ).json();
    await mutate(manager, root + `/requests/${request.id}/decide`, {
      expectedCalendarVersion: submitted.calendarVersion,
      expectedRequestVersion: request.version,
      days: request.days.map((d) => ({
        dayId: d.id,
        expectedVersion: d.version,
      })),
      approve: true,
      reason: "Plano acordado no ensaio",
    });
    await refresh(manager);
    const requirementId = await createOnsite(
      manager,
      conflictTitle,
      dates[1],
      "Por resolver",
    );
    for (const client of [page, manager]) {
      calendar = await cal(client.request, employee, dates[1]);
      expect(calendar.effectiveDays[0].location).toBe("RemotePortugal");
      expect(calendar.requirements[0].state).toBe("NeedsResolution");
      await showDate(client, dates[1]);
      const detail = client.getByRole("complementary", {
        name: "Detalhe do dia",
        exact: true,
      });
      await expect(
        detail.getByText(/O plano aprovado mantém-se/),
      ).toBeVisible();
      await expect(
        detail.getByText("Remoto · Portugal", { exact: false }).first(),
      ).toBeVisible();
      expect(
        await client.evaluate(
          () =>
            document.documentElement.scrollWidth <=
            document.documentElement.clientWidth,
        ),
      ).toBe(true);
      await client.screenshot({
        path: `test-results/ho006-${info.project.name}-${client === page ? "employee" : "manager"}-conflict.png`,
        fullPage: true,
      });
    }
    await openOnsite(manager, conflictTitle);
    await work(manager)
      .getByRole("button", { name: /Propor resolução do plano/ })
      .click();
    await manager
      .getByRole("dialog")
      .getByRole("button", { name: "Criar contraproposta", exact: true })
      .scrollIntoViewIfNeeded();
    await manager.screenshot({
      path: `test-results/ho006-${info.project.name}-resolution-dialog.png`,
      fullPage: false,
    });
    const proposalResponse = manager.waitForResponse(
      (r) => r.url().endsWith("/proposals") && r.request().method() === "POST",
    );
    await manager
      .getByRole("dialog")
      .getByRole("button", { name: "Criar contraproposta", exact: true })
      .click();
    expect((await proposalResponse).status()).toBe(200);
    await page
      .getByRole("navigation")
      .getByRole("button", { name: "Pedidos", exact: true })
      .click();
    await refresh(page);
    await page
      .locator(".request-list-item")
      .filter({
        has: page.getByText(`Remoto acordado · ${tag}`, { exact: true }),
      })
      .click();
    await page
      .getByRole("button", { name: "Aceitar contraproposta", exact: true })
      .click();
    await page
      .getByRole("dialog")
      .getByRole("button", { name: "Confirmar envio", exact: true })
      .click();
    await ready(page);
    calendar = await cal(page.request, employee, dates[1]);
    expect(calendar.effectiveDays[0].location).toBe("RemotePortugal");
    await manager
      .getByRole("navigation")
      .getByRole("button", { name: "Pedidos", exact: true })
      .click();
    await refresh(manager);
    await manager
      .locator(".request-list-item")
      .filter({ has: manager.getByText(conflictTitle, { exact: true }) })
      .click();
    await manager
      .getByRole("button", { name: "Aprovar dias", exact: true })
      .click();
    await manager
      .getByRole("dialog")
      .getByRole("button", { name: "Confirmar envio", exact: true })
      .click();
    await ready(manager);
    calendar = await cal(page.request, employee, dates[1]);
    expect(calendar.effectiveDays[0].location).toBe("OfficeSwitzerland");
    expect(calendar.requirements[0].state).toBe("Active");
    const final: Wire<OnsiteView> = await (
      await page.request.get(root + `/requirements/${requirementId}`)
    ).json();
    expect(final.readAt).toBeNull(); // Proposal agreement is not a reading receipt.
    await openOnsite(manager, conflictTitle);
    await work(manager)
      .getByRole("button", { name: "Atribuir tarefa", exact: true })
      .click();
    const form = manager.getByRole("form", {
      name: "Guardar tarefa",
      exact: true,
    });
    await form
      .getByLabel("Título", { exact: true })
      .fill(`Preparar instalação · ${tag}`);
    await form
      .getByLabel("Descrição", { exact: true })
      .fill("Verificar material de ensaio e registar progresso.");
    await form.getByLabel("Prazo", { exact: true }).fill(dates[2]);
    await expect(
      form.getByLabel("Requer trabalho presencial (informativo)"),
    ).toBeChecked();
    await form
      .getByRole("button", { name: "Guardar tarefa", exact: true })
      .click();
    await ready(manager);
    await navigate(page, "Tarefas");
    await refresh(page);
    await openListedWork(page, `Preparar instalação · ${tag}`);
    const progress = page.getByRole("form", {
      name: "Atualizar progresso",
      exact: true,
    });
    await progress
      .getByLabel("Nota de progresso")
      .fill("Material preparado; aguarda instalação.");
    await progress
      .getByRole("button", { name: "Atualizar progresso", exact: true })
      .click();
    await expect(
      work(page).getByText("Em curso", { exact: true }).first(),
    ).toBeVisible();
    await expect(
      work(page)
        .getByText("Material preparado; aguarda instalação.", { exact: true })
        .first(),
    ).toBeVisible();
    expect(
      await page.evaluate(
        () =>
          document.documentElement.scrollWidth <=
          document.documentElement.clientWidth,
      ),
    ).toBe(true);
    await page.screenshot({
      path: `test-results/ho006-${info.project.name}-task.png`,
      fullPage: true,
    });
  } finally {
    await managerContext.close();
  }
});

test("onsite inputs survive stale versions and reauthentication; uncertain commit replays once", async ({
  page,
}, info) => {
  await signIn(page, "manager");
  await ready(page);
  await page
    .getByLabel("Colaborador selecionado", { exact: true })
    .selectOption({ label: "Colaborador de teste" });
  await ready(page);
  const employee = await page
    .getByLabel("Colaborador selecionado", { exact: true })
    .inputValue();
  const dates = await freeDates(page, employee);
  const tag = `${info.project.name} ${randomUUID().slice(0, 6)}`;
  const context = await createOnsite(
    page,
    `Contexto para recuperação · ${tag}`,
    dates[0],
    "Ativa",
  );
  await page
    .getByRole("button", {
      name: "+ Exigir presença do colaborador",
      exact: true,
    })
    .click();
  let form = page.getByRole("form", {
    name: "Exigir presença do colaborador",
    exact: true,
  });
  const title = `Texto conservado · ${tag}`;
  await form.getByLabel("Motivo", { exact: true }).fill(title);
  await form.getByLabel("Primeiro dia").fill(dates[1]);
  await form.getByLabel("Último dia").fill(dates[1]);
  await form.getByLabel("Local", { exact: true }).fill("Zurique");
  await form
    .getByRole("button", { name: "Pré-visualizar conflitos", exact: true })
    .click();
  await expect(
    form.getByRole("button", { name: "Confirmar presença", exact: true }),
  ).toBeEnabled();
  const root = `/api/v1/planning/${employee}`;
  const version = (await cal(page.request, employee, dates[1])).calendarVersion;
  await mutate(page, root + `/work/Requirement/${context}/comments`, {
    expectedCalendarVersion: version,
    text: "Alteração concorrente sintética",
  });
  const stale = page.waitForResponse(
    (r) => r.url().endsWith("/requirements") && r.request().method() === "POST",
  );
  await form
    .getByRole("button", { name: "Confirmar presença", exact: true })
    .click();
  expect((await stale).status()).toBe(412);
  await expect(form.getByLabel("Motivo", { exact: true })).toHaveValue(title);
  await page
    .getByRole("button", { name: "Já revi os dados atualizados", exact: true })
    .click();
  // Real server logout in this browser session simulates an interrupted/expired session without altering app data.
  const csrf = await (await page.request.get("/api/v1/auth/csrf")).json();
  expect(
    (
      await page.request.post("/api/v1/auth/logout", {
        headers: { "X-CSRF-TOKEN": csrf.requestToken },
      })
    ).status(),
  ).toBe(204);
  await form
    .getByRole("button", { name: "Pré-visualizar conflitos", exact: true })
    .click();
  await expect(
    page.getByRole("heading", { name: "Entre no seu espaço", exact: true }),
  ).toBeVisible();
  await signIn(page, "manager");
  await ready(page);
  await page
    .getByLabel("Colaborador selecionado", { exact: true })
    .selectOption(employee);
  await ready(page);
  await navigate(page, "Presenças");
  await page
    .getByRole("button", {
      name: "+ Exigir presença do colaborador",
      exact: true,
    })
    .click();
  form = page.getByRole("form", {
    name: "Exigir presença do colaborador",
    exact: true,
  });
  await expect(form.getByLabel("Motivo", { exact: true })).toHaveValue(title);
  await expect(form.getByLabel("Primeiro dia")).toHaveValue(dates[1]);
  await form
    .getByRole("button", { name: "Pré-visualizar conflitos", exact: true })
    .click();
  let originalKey = "";
  let originalBody = "";
  await page.route(
    `**${root}/requirements`,
    async (route) => {
      if (route.request().method() !== "POST") return route.continue();
      originalKey = route.request().headers()["idempotency-key"];
      originalBody = route.request().postData()!;
      const result = await route.fetch();
      expect(result.status()).toBe(200);
      await route.abort("failed");
    },
    { times: 1 },
  );
  await form
    .getByRole("button", { name: "Confirmar presença", exact: true })
    .click();
  await expect(
    page.getByRole("button", { name: "Recuperar o mesmo envio", exact: true }),
  ).toBeVisible();
  await page.reload();
  await ready(page);
  const replay = page.waitForRequest(
    (r) => r.url().endsWith("/requirements") && r.method() === "POST",
  );
  await page
    .getByRole("button", { name: "Recuperar o mesmo envio", exact: true })
    .click();
  const repeated = await replay;
  expect(repeated.headers()["idempotency-key"]).toBe(originalKey);
  expect(repeated.postData()).toBe(originalBody);
  await expect(
    page.getByRole("button", { name: "Recuperar o mesmo envio", exact: true }),
  ).toHaveCount(0);
  const rows = await (
    await page.request.get(root + "/requirements?limit=100")
  ).json();
  expect(
    rows.items.filter((r: Wire<OnsiteView>) => r.reason === title),
  ).toHaveLength(1);
});
