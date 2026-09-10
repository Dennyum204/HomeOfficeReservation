// Real cross-platform handoff. Writes use the visible Web forms; JSON stays private.
import { chromium, expect } from "@playwright/test";
import { readFileSync, writeFileSync, existsSync, mkdirSync } from "node:fs";
import { randomUUID } from "node:crypto";
import { resolve, relative, isAbsolute } from "node:path";
const phase = process.argv[2];
if (
  !["create", "onsite", "proposal", "task", "verify", "capture"].includes(phase)
)
  throw new Error("Select create|onsite|proposal|task|verify|capture.");
const statePath = process.env.HO_CROSS_STATE,
  accountsPath = process.env.HO_DEV_ACCOUNTS;
if (!statePath || !accountsPath)
  throw new Error("Private HO_CROSS_STATE and HO_DEV_ACCOUNTS paths required.");
const inside = relative(
  resolve(import.meta.dirname, "../../.."),
  resolve(statePath),
);
if (!inside.startsWith("..") && !isAbsolute(inside))
  throw new Error("Handoff state must stay outside Git.");
const accounts = JSON.parse(readFileSync(accountsPath, "utf8"));
let state = existsSync(statePath)
  ? JSON.parse(readFileSync(statePath, "utf8"))
  : {};
const browser = await chromium.launch();
const page = await browser.newPage({
  baseURL: process.env.HO_WEB_URL ?? "http://127.0.0.1:5173",
  viewport: { width: 1366, height: 900 },
});
const dialog = page.getByRole("dialog"),
  details = page.getByRole("region", {
    name: "Detalhe do pedido",
    exact: true,
  }),
  work = page.locator(".work-detail");
const button = (name) => page.getByRole("button", { name, exact: true });
const ready = () => expect(button("Atualizar dados")).toBeEnabled();
async function login(role) {
  await page.goto("/");
  await expect(
    button("Terminar sessão").or(page.getByLabel("Email", { exact: true })),
  ).toBeVisible();
  if (await button("Terminar sessão").count())
    await button("Terminar sessão").click();
  await page.getByLabel("Email", { exact: true }).fill(accounts[role].email);
  await page
    .getByLabel("Palavra-passe", { exact: true })
    .fill(accounts[role].password);
  await button("Entrar").click();
  await expect(
    page.getByRole("region", { name: "Conta", exact: true }),
  ).toBeVisible();
  await ready();
  if (state.TEST_CORE_EMPLOYEE) {
    await page
      .getByLabel("Colaborador selecionado", { exact: true })
      .selectOption(state.TEST_CORE_EMPLOYEE);
    await ready();
  }
}
async function nav(name) {
  await page
    .getByRole("navigation")
    .getByRole("button", { name, exact: true })
    .click();
  await ready();
}
async function get(path) {
  const r = await page.request.get(
    `/api/v1/planning/${state.TEST_CORE_EMPLOYEE}/${path}`,
  );
  expect(r.status()).toBe(200);
  return r.json();
}
async function captured(suffix, action) {
  const r = page.waitForResponse(
    (r) => r.url().endsWith(suffix) && r.request().method() === "POST",
  );
  await action();
  const response = await r;
  expect(response.status()).toBe(200);
  return response.json();
}
async function openWork(kind, title) {
  await nav(kind);
  await button("Atualizar dados").click();
  await ready();
  const list = page.locator(".work-layout > .request-list");
  for (let index = 0; index < 100; index++) {
    await expect(list.getByRole("status")).toHaveCount(0);
    const item = list
      .locator(".request-list-item")
      .filter({ has: page.getByText(title, { exact: true }) });
    if (await item.count()) {
      await item.click();
      break;
    }
    const next = list.getByRole("button", {
      name: "Página seguinte",
      exact: true,
    });
    await expect(
      next,
      "The synthetic resource must exist on a result page",
    ).toBeEnabled();
    await next.click();
  }
  await expect(
    work.getByRole("heading", { name: title, exact: true }),
  ).toBeVisible();
  await ready();
}
async function calendarEvidence(resolved = false) {
  const v = await get(
    `calendar?from=${state.TEST_CORE_FROM}&to=${state.TEST_CORE_TO}`,
  );
  expect(v.pendingDays).toHaveLength(0);
  expect(
    v.effectiveDays.filter((d) => d.origin === "ApprovedRequest"),
  ).toHaveLength(3);
  const first = v.effectiveDays.find(
    (d) => d.localDate === state.TEST_CORE_FROM,
  );
  expect(first.location).toBe(
    resolved ? "OfficeSwitzerland" : "RemotePortugal",
  );
  expect(
    v.effectiveDays.filter(
      (d) => d.origin === "ApprovedRequest" && d.location === "RemotePortugal",
    ),
  ).toHaveLength(resolved ? 2 : 3);
  return v;
}
async function capture(name) {
  expect(
    await page.evaluate(
      () =>
        document.documentElement.scrollWidth <=
        document.documentElement.clientWidth,
    ),
  ).toBe(true);
  mkdirSync("test-results", { recursive: true });
  if (name.endsWith("linked-task")) {
    await work.screenshot({
      path: `test-results/ho011-web-${name}-detail.png`,
    });
  }
  await page.screenshot({
    path: `test-results/ho011-web-${name}.png`,
    fullPage: true,
  });
}
try {
  await login(phase === "create" ? "employee" : "manager");
  if (phase === "create") {
    if (state.TEST_CORE_REQUEST)
      throw new Error(
        "Existing handoff must be finished before starting another.",
      );
    state.TEST_CORE_EMPLOYEE = await page
      .getByLabel("Colaborador selecionado", { exact: true })
      .inputValue();
    const add = (date, n) =>
      new Date(new Date(`${date}T12:00:00Z`).getTime() + n * 86400000)
        .toISOString()
        .slice(0, 10);
    const from = add(new Date().toISOString().slice(0, 10), 60),
      to = add(from, 300);
    const v = await get(`calendar?from=${from}&to=${to}`),
      occupied = new Set([
        ...v.effectiveDays
          .filter((d) => d.origin !== "WeeklyPattern")
          .map((d) => d.localDate),
        ...v.pendingDays.map((d) => d.day.localDate),
      ]);
    for (let n = 0; n < 290; n++) {
      const date = add(from, n);
      if (new Date(`${date}T12:00:00Z`).getUTCDay() !== 1) continue;
      const days = Array.from({ length: 5 }, (_, i) => add(date, i));
      if (
        days.every(
          (d) =>
            !occupied.has(d) &&
            !v.requirements.some((r) => r.from <= d && r.to >= d),
        )
      ) {
        state.TEST_CORE_FROM = days[0];
        state.TEST_CORE_TO = days[4];
        break;
      }
    }
    if (!state.TEST_CORE_FROM)
      throw new Error("No free week; existing plans preserved.");
    state.note = `Ensaio Web ↔ Android HO-011 ${randomUUID().slice(0, 8)}`;
    state.onsiteTitle = `${state.note} — presença`;
    state.taskTitle = `${state.note} — tarefa`;
    await nav("Pedidos");
    await button("+ Pedir os meus dias de trabalho").click();
    await dialog.getByLabel("De", { exact: true }).fill(state.TEST_CORE_FROM);
    await dialog.getByLabel("Até", { exact: true }).fill(state.TEST_CORE_TO);
    await dialog
      .getByRole("button", { name: "Pré-visualizar intervalo" })
      .click();
    await expect(dialog.getByText("Dias incluídos · 5 dias")).toBeVisible();
    await dialog.getByRole("button", { name: "Adicionar estes dias" }).click();
    await dialog
      .getByRole("textbox", { name: "Comentário do pedido", exact: true })
      .fill(state.note);
    const receipt = await captured("/requests", () =>
      dialog
        .getByRole("button", { name: "Guardar rascunho", exact: true })
        .click(),
    );
    state.TEST_CORE_REQUEST = receipt.contextId;
    await ready();
    await details
      .getByRole("button", { name: "Submeter pedido", exact: true })
      .click();
    await dialog
      .getByRole("button", { name: "Confirmar envio", exact: true })
      .click();
    await expect(dialog).toHaveCount(0);
    await ready();
    await expect(details.locator(".request-counts")).toHaveText(
      "0 dias aprovados · 5 dias pendentes",
    );
    await capture("employee-five-days");
  } else {
    if (phase !== "capture")
      await calendarEvidence(phase === "task" || phase === "verify");
    if (phase === "onsite") {
      await nav("Presenças");
      await button("+ Exigir presença do colaborador").click();
      const form = page.getByRole("form", {
        name: "Exigir presença do colaborador",
        exact: true,
      });
      await form.getByLabel("Motivo", { exact: true }).fill(state.onsiteTitle);
      await form.getByLabel("Primeiro dia").fill(state.TEST_CORE_FROM);
      await form.getByLabel("Último dia").fill(state.TEST_CORE_FROM);
      await form
        .getByLabel("Local", { exact: true })
        .fill("Oficina de Zurique");
      await form
        .getByLabel("Máquina / projeto (opcional)")
        .fill("Equipamento sintético");
      await form
        .getByRole("button", { name: "Pré-visualizar conflitos", exact: true })
        .click();
      await expect(
        form
          .locator(".conflict-preview")
          .getByText("Por resolver", { exact: true }),
      ).toBeVisible();
      state.TEST_CORE_ONSITE = (
        await captured("/requirements", () =>
          form
            .getByRole("button", { name: "Confirmar presença", exact: true })
            .click(),
        )
      ).contextId;
      await openWork("Presenças", state.onsiteTitle);
      await capture("manager-conflict");
      await calendarEvidence();
    } else if (phase === "proposal") {
      expect(
        (await get(`requirements/${state.TEST_CORE_ONSITE}`)).readAt,
      ).not.toBeNull();
      await openWork("Presenças", state.onsiteTitle);
      await work
        .getByRole("button", { name: /Propor resolução do plano/ })
        .click();
      state.TEST_CORE_PROPOSAL = (
        await captured("/proposals", () =>
          dialog
            .getByRole("button", { name: "Criar contraproposta", exact: true })
            .click(),
        )
      ).contextId;
      await ready();
      await calendarEvidence();
    } else if (phase === "task") {
      expect((await get(`requirements/${state.TEST_CORE_ONSITE}`)).state).toBe(
        "Active",
      );
      await openWork("Presenças", state.onsiteTitle);
      await work
        .getByRole("button", { name: "Atribuir tarefa", exact: true })
        .click();
      const form = page.getByRole("form", {
        name: "Guardar tarefa",
        exact: true,
      });
      await form.getByLabel("Título", { exact: true }).fill(state.taskTitle);
      await form
        .getByLabel("Descrição", { exact: true })
        .fill("Ensaio partilhado: verificar equipamento.");
      await form.getByLabel("Prazo", { exact: true }).fill(state.TEST_CORE_TO);
      await expect(
        form.getByLabel("Requer trabalho presencial (informativo)"),
      ).toBeChecked();
      state.TEST_CORE_TASK = (
        await captured("/tasks", () =>
          form
            .getByRole("button", { name: "Guardar tarefa", exact: true })
            .click(),
        )
      ).contextId;
      await ready();
      await calendarEvidence(true);
    } else {
      for (const role of ["manager", "employee"]) {
        if (role === "employee") await login(role);
        // Capture revisits only the current synthetic task. Other authorized
        // tests may since have used the withdrawn dates; it is not a replay of
        // the five-day acceptance assertion, which remains required by verify.
        if (phase !== "capture") await calendarEvidence(true);
        const task = await get(`tasks/${state.TEST_CORE_TASK}`);
        expect(task.state).toBe("InProgress");
        expect(task.progressNote).toBe("Progresso confirmado no Android");
        expect(task.requirementState).toBe("Active");
        await openWork("Tarefas", state.taskTitle);
        await expect(
          work
            .getByText("Progresso confirmado no Android", { exact: true })
            .first(),
        ).toBeVisible();
        await page.setViewportSize({
          width: role === "manager" ? 1366 : 390,
          height: 900,
        });
        await capture(`${role}-linked-task`);
      }
    }
  }
  state.completedWebPhases = [
    ...new Set([...(state.completedWebPhases ?? []), phase]),
  ];
  writeFileSync(statePath, JSON.stringify(state, null, 2));
  console.log(
    `PASS real Web phase: ${phase}; private handoff retained; existing plans preserved.`,
  );
} finally {
  await browser.close();
}
