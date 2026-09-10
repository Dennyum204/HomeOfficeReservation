// Manual cross-platform evidence against running local Web/API services.
// No reset, credential export, or mock: create in Web, decide in Android, verify in Web.
import { chromium, expect } from "@playwright/test";
import { readFileSync, writeFileSync, mkdirSync } from "node:fs";
import { randomUUID } from "node:crypto";
import { resolve, relative, isAbsolute } from "node:path";

const action = process.argv[2];
const statePath = process.env.HO_CROSS_STATE;
const accountsPath = process.env.HO_DEV_ACCOUNTS;
if (!["create", "verify"].includes(action) || !statePath || !accountsPath) {
  throw new Error(
    "Use create|verify with private HO_DEV_ACCOUNTS and HO_CROSS_STATE paths.",
  );
}
const repo = resolve(import.meta.dirname, "../../..");
const inside = relative(repo, resolve(statePath));
if (!inside.startsWith("..") && !isAbsolute(inside))
  throw new Error("Keep handoff state outside Git.");
const { employee } = JSON.parse(readFileSync(accountsPath, "utf8"));
const browser = await chromium.launch();
const page = await browser.newPage({
  baseURL: process.env.HO_WEB_URL ?? "http://127.0.0.1:5173",
});
const details = page.getByRole("region", {
  name: "Detalhe do pedido",
  exact: true,
});
const dialog = page.getByRole("dialog");
const ready = () =>
  expect(
    page.getByRole("button", { name: "Atualizar dados", exact: true }),
  ).toBeEnabled();
try {
  await page.goto("/");
  await page.getByLabel("Email", { exact: true }).fill(employee.email);
  await page
    .getByLabel("Palavra-passe", { exact: true })
    .fill(employee.password);
  await page.getByRole("button", { name: "Entrar", exact: true }).click();
  await expect(
    page.getByRole("region", { name: "Conta", exact: true }),
  ).toBeVisible();
  await ready();
  const employeeId = await page
    .getByLabel("Colaborador selecionado", { exact: true })
    .inputValue();
  let state;
  if (action === "create") {
    // Explicitly new synthetic work only; an existing state must be verified first.
    const start = new Date();
    start.setUTCDate(start.getUTCDate() + 60);
    const from = start.toISOString().slice(0, 10);
    const end = new Date(start);
    end.setUTCDate(end.getUTCDate() + 200);
    const response = await page.request.get(
      `/api/v1/planning/${employeeId}/calendar?from=${from}&to=${end.toISOString().slice(0, 10)}`,
    );
    expect(response.ok()).toBe(true);
    const calendar = await response.json();
    const occupied = new Set([
      ...calendar.effectiveDays
        .filter((d) => d.origin !== "WeeklyPattern")
        .map((d) => d.localDate),
      ...calendar.pendingDays.map((d) => d.day.localDate),
    ]);
    let date;
    for (let n = 0; n < 190; n++) {
      const d = new Date(start);
      d.setUTCDate(d.getUTCDate() + n);
      const value = d.toISOString().slice(0, 10);
      if (
        d.getUTCDay() !== 0 &&
        d.getUTCDay() !== 6 &&
        !occupied.has(value) &&
        !calendar.requirements.some((r) => r.from <= value && r.to >= value)
      ) {
        date = value;
        break;
      }
    }
    if (!date) throw new Error("No free test date. Existing plans preserved.");
    const note = `Ensaio Web → Android HO-010 ${randomUUID().slice(0, 8)}`;
    await page.getByRole("button", { name: "Pedidos", exact: true }).click();
    await ready();
    await page
      .getByRole("button", {
        name: "+ Pedir os meus dias de trabalho",
        exact: true,
      })
      .click();
    await dialog.getByLabel("De", { exact: true }).fill(date);
    await dialog.getByLabel("Até", { exact: true }).fill(date);
    await dialog
      .getByRole("button", { name: "Pré-visualizar intervalo" })
      .click();
    await expect(dialog.getByText("Dias incluídos · 1 dias")).toBeVisible();
    await dialog.getByRole("button", { name: "Adicionar estes dias" }).click();
    await dialog
      .getByRole("textbox", { name: "Comentário do pedido", exact: true })
      .fill(note);
    const saved = page.waitForResponse(
      (r) => r.url().endsWith("/requests") && r.request().method() === "POST",
    );
    await dialog
      .getByRole("button", { name: "Guardar rascunho", exact: true })
      .click();
    const result = await saved;
    expect(result.status()).toBe(200);
    const receipt = await result.json();
    await ready();
    await details
      .getByRole("button", { name: "Submeter pedido", exact: true })
      .click();
    await dialog.getByRole("button", { name: "Confirmar envio" }).click();
    await expect(dialog).toHaveCount(0);
    await ready();
    await expect(details.locator(".request-counts")).toHaveText(
      "0 dias aprovados · 1 dia pendente",
    );
    state = {
      TEST_WEB_REQUEST: receipt.contextId,
      TEST_WEB_EMPLOYEE: employeeId,
      TEST_WEB_DATE: date,
      note,
    };
    writeFileSync(statePath, JSON.stringify(state, null, 2));
  } else {
    state = JSON.parse(readFileSync(statePath, "utf8"));
    expect(employeeId).toBe(state.TEST_WEB_EMPLOYEE);
    await page.getByRole("button", { name: "Pedidos", exact: true }).click();
    await ready();
    await page
      .getByRole("region", { name: "Pedidos", exact: true })
      .getByRole("button")
      .filter({ has: page.getByText(state.note, { exact: true }) })
      .click();
    await ready();
    await expect(details.locator(".request-counts")).toHaveText(
      "1 dia aprovado · 0 dias pendentes",
    );
    const response = await page.request.get(
      `/api/v1/planning/${employeeId}/calendar?from=${state.TEST_WEB_DATE}&to=${state.TEST_WEB_DATE}`,
    );
    expect(response.ok()).toBe(true);
    const calendar = await response.json();
    expect(calendar.pendingDays).toHaveLength(0);
    expect(calendar.effectiveDays).toHaveLength(1);
    expect(calendar.effectiveDays[0]).toMatchObject({
      localDate: state.TEST_WEB_DATE,
      origin: "ApprovedRequest",
      location: "RemotePortugal",
      sourceRequestId: state.TEST_WEB_REQUEST,
    });
  }
  mkdirSync("test-results", { recursive: true });
  await page.screenshot({
    path: `test-results/ho010-web-${action}.png`,
    fullPage: true,
  });
  console.log(
    `HO-010 Web ${action}: passed; actual browser/API/PostgreSQL, synthetic data only.`,
  );
} finally {
  await browser.close();
}
