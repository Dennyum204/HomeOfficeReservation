import { randomUUID } from "node:crypto";
import { readFileSync, readdirSync } from "node:fs";
import { join } from "node:path";
import { test, expect, type Page } from "@playwright/test";
import { signIn } from "./support";
import type {
  InvitationPage,
  InvitationProfile,
} from "../../../contracts/typescript";

test.setTimeout(120000);
const accounts = JSON.parse(readFileSync(process.env.HO_DEV_ACCOUNTS!, "utf8"));
const settings = JSON.parse(
  readFileSync(
    new URL(
      "../../api/src/HomeOffice.Api/appsettings.Local.json",
      import.meta.url,
    ),
    "utf8",
  ),
);
async function openAdmin(page: Page) {
  await page
    .getByRole("button", { name: "Administração", exact: true })
    .click();
  await expect(
    page.getByRole("button", { name: "Atualizar membros", exact: true }),
  ).toBeEnabled();
}
async function confirm(page: Page) {
  await page
    .getByRole("dialog")
    .last()
    .getByRole("button", { name: "Confirmar operação", exact: true })
    .click();
}
async function confirmed(page: Page) {
  await expect(page.getByText(/^Operação confirmada pela API/)).toBeVisible();
  await expect(
    page.getByRole("button", { name: "Atualizar membros", exact: true }),
  ).toBeEnabled();
}
async function invite(
  page: Page,
  name: string,
  email: string,
  admin = false,
  manager = false,
) {
  await page
    .getByRole("button", { name: "Convidar membro", exact: true })
    .click();
  const form = page.getByRole("dialog");
  await form.getByLabel("Nome", { exact: true }).fill(name);
  await form.getByLabel("Email do convite", { exact: true }).fill(email);
  await form.getByLabel("Administrador", { exact: true }).setChecked(admin);
  await form.getByLabel("Gestor", { exact: true }).setChecked(manager);
  await form
    .getByRole("button", { name: "Rever convite", exact: true })
    .click();
  await expect(
    page
      .getByRole("dialog")
      .last()
      .getByText(/Não é um convite para instalar o APK/),
  ).toBeVisible();
  await confirm(page);
}
async function select(page: Page, name: string) {
  await page.getByRole("searchbox").fill(name);
  await page
    .getByRole("button", { name: `Gerir membro: ${name}`, exact: true })
    .click();
  await expect(
    page
      .getByRole("region", { name: "Membro selecionado" })
      .getByRole("heading", { name, exact: true }),
  ).toBeFocused();
}
async function list(page: Page) {
  return (await (
    await page.request.get("/api/v1/admin/invitations?limit=100")
  ).json()) as InvitationPage;
}
async function mutation(page: Page, path: string, data: unknown) {
  const { requestToken } = await (
    await page.request.get("/api/v1/auth/csrf")
  ).json();
  return page.request.put(path, {
    data,
    headers: { "X-CSRF-TOKEN": requestToken },
  });
}
function captured(email: string) {
  return readdirSync(settings.Email.CaptureDirectory)
    .filter((f) => f.endsWith(".json"))
    .map((f) =>
      JSON.parse(
        readFileSync(join(settings.Email.CaptureDirectory, f), "utf8"),
      ),
    )
    .filter((m) => m.email === email);
}
async function accept(page: Page, email: string, password: string) {
  await expect.poll(() => captured(email).length).toBeGreaterThan(0);
  const code = captured(email).at(-1).code as string;
  if (process.env.GITHUB_ACTIONS === "true") console.log(`::add-mask::${code}`);
  await page.goto("/");
  await page.getByRole("button", { name: "Ainda não ativei a conta" }).click();
  await page.getByRole("button", { name: "Já tenho um código" }).click();
  await page.getByLabel("Email", { exact: true }).fill(email);
  await page.getByLabel("Código recebido").fill(code);
  await page.getByLabel("Palavra-passe", { exact: true }).fill(password);
  await page.getByRole("button", { name: "Ativar conta", exact: true }).click();
  await expect(
    page.getByText("Palavra-passe definida. Pode iniciar sessão."),
  ).toBeVisible();
  await page.getByLabel("Palavra-passe", { exact: true }).fill(password);
  await page.getByRole("button", { name: "Entrar", exact: true }).click();
  await expect(
    page.getByRole("region", { name: "Conta", exact: true }),
  ).toBeVisible();
}

test("admin UI invites owner and chief, accepts, preserves dual roles, suspends and denies ordinary access", async ({
  page,
  browser,
}, info) => {
  await signIn(page, "admin");
  await openAdmin(page);
  const name = `Titular HO015 ${randomUUID().slice(0, 8)}`,
    email = `owner-${randomUUID()}@homeoffice.example`;
  await invite(page, name, email, true);
  await confirmed(page);
  const ownerContext = await browser.newContext({
    ...info.project.use,
    baseURL: "http://127.0.0.1:5174",
  });
  const owner = await ownerContext.newPage();
  await accept(owner, email, accounts.employee.password);
  await openAdmin(owner);
  await select(owner, name);
  await expect(owner.getByText(/^Esta é a sua conta/)).toBeVisible();
  await expect(
    owner.getByRole("checkbox", { name: "Administrador", exact: true }),
  ).toBeDisabled();
  await expect(
    owner.getByRole("checkbox", { name: "Colaborador", exact: true }),
  ).toBeChecked();
  const chief = `Chefe HO015 ${randomUUID().slice(0, 8)}`,
    chiefEmail = `chief-${randomUUID()}@homeoffice.example`;
  await invite(owner, chief, chiefEmail, false, true);
  await confirmed(owner);
  const chiefRow = (await list(owner)).members.find(
    (m) => m.email === chiefEmail,
  )!;
  await select(owner, name);
  await owner
    .getByLabel("Chefe associado", { exact: true })
    .selectOption(chiefRow.memberId);
  await owner
    .getByRole("button", { name: "Rever associação", exact: true })
    .click();
  await expect(
    owner.getByRole("dialog").getByText(/Mudar ou retirar a chefia/),
  ).toBeVisible();
  await confirm(owner);
  await confirmed(owner);
  const ownerRow = (await list(owner)).members.find((m) => m.email === email)!;
  expect(ownerRow.managerId).toBe(chiefRow.memberId);
  expect(ownerRow.managerRelationshipValid).toBe(true);
  const chiefContext = await browser.newContext({
    ...info.project.use,
    baseURL: "http://127.0.0.1:5174",
  });
  const chiefPage = await chiefContext.newPage();
  await accept(chiefPage, chiefEmail, accounts.employee.password);
  await owner.getByRole("button", { name: "Pedidos", exact: true }).click();
  await expect(
    owner.getByRole("button", { name: "Atualizar dados", exact: true }),
  ).toBeEnabled();
  await owner
    .getByRole("button", {
      name: "+ Pedir os meus dias de trabalho",
      exact: true,
    })
    .click();
  const day = new Date();
  day.setDate(day.getDate() + 40);
  while ([0, 6].includes(day.getDay())) day.setDate(day.getDate() + 1);
  const date = day.toISOString().slice(0, 10),
    note = `Pedido titular HO015 ${randomUUID().slice(0, 8)}`;
  const dialog = owner.getByRole("dialog");
  await dialog.getByLabel("De", { exact: true }).fill(date);
  await dialog.getByLabel("Até", { exact: true }).fill(date);
  await dialog
    .getByRole("button", { name: "Pré-visualizar intervalo" })
    .click();
  await dialog.getByRole("button", { name: "Adicionar estes dias" }).click();
  await dialog.getByLabel("Comentário do pedido", { exact: true }).fill(note);
  await dialog
    .getByRole("button", { name: "Guardar rascunho", exact: true })
    .click();
  await expect(
    owner.getByRole("button", { name: "Atualizar dados", exact: true }),
  ).toBeEnabled();
  await owner
    .getByRole("region", { name: "Detalhe do pedido", exact: true })
    .getByRole("button", { name: "Submeter pedido", exact: true })
    .click();
  await owner
    .getByRole("dialog")
    .getByRole("button", { name: "Confirmar envio", exact: true })
    .click();
  await expect(
    owner
      .getByRole("region", { name: "Detalhe do pedido", exact: true })
      .getByText("0 dias aprovados · 1 dia pendente", { exact: true }),
  ).toBeVisible();
  await chiefPage
    .getByLabel("Colaborador selecionado", { exact: true })
    .selectOption(ownerRow.memberId);
  await chiefPage.getByRole("button", { name: "Pedidos", exact: true }).click();
  await expect(
    chiefPage.getByRole("button", { name: "Atualizar dados", exact: true }),
  ).toBeEnabled();
  await chiefPage
    .getByRole("region", { name: "Pedidos", exact: true })
    .getByRole("button")
    .filter({ has: chiefPage.getByText(note, { exact: true }) })
    .click();
  await chiefPage
    .getByRole("region", { name: "Detalhe do pedido", exact: true })
    .getByRole("button", { name: "Aprovar dias", exact: true })
    .click();
  await chiefPage
    .getByRole("dialog")
    .getByRole("button", { name: "Confirmar envio", exact: true })
    .click();
  await expect(
    chiefPage
      .getByRole("region", { name: "Detalhe do pedido", exact: true })
      .getByText("1 dia aprovado · 0 dias pendentes", { exact: true }),
  ).toBeVisible();
  await owner
    .getByRole("button", { name: "Atualizar dados", exact: true })
    .click();
  await expect(
    owner
      .getByRole("region", { name: "Detalhe do pedido", exact: true })
      .getByText("1 dia aprovado · 0 dias pendentes", { exact: true }),
  ).toBeVisible();
  await chiefContext.close();
  await openAdmin(owner);
  const extra = `Pessoa HO015 ${randomUUID().slice(0, 8)}`,
    extraEmail = `extra-${randomUUID()}@homeoffice.example`;
  await invite(owner, extra, extraEmail);
  await confirmed(owner);
  const extraContext = await browser.newContext({
    ...info.project.use,
    baseURL: "http://127.0.0.1:5174",
  });
  const extraPage = await extraContext.newPage();
  await accept(extraPage, extraEmail, accounts.employee.password);
  await expect(
    extraPage.getByRole("button", { name: "Administração", exact: true }),
  ).toHaveCount(0);
  expect(
    (await extraPage.request.get("/api/v1/admin/invitations")).status(),
  ).toBe(403);
  await select(owner, extra);
  await owner.getByLabel("Acesso ativo", { exact: true }).uncheck();
  await owner
    .getByRole("button", { name: "Rever papéis e acesso", exact: true })
    .click();
  await confirm(owner);
  await confirmed(owner);
  expect((await extraPage.request.get("/api/v1/me")).status()).toBe(403);
  await extraPage
    .getByRole("button", { name: "Verificar sessão", exact: true })
    .click();
  await expect(
    extraPage.getByRole("heading", { name: "Entre no seu espaço" }),
  ).toBeVisible();
  await owner.screenshot({
    path: `test-results/admin-${info.project.name}.png`,
    fullPage: true,
  });
  expect(
    await owner.evaluate(
      () => document.documentElement.scrollWidth <= window.innerWidth,
    ),
  ).toBe(true);
  await extraContext.close();
  await ownerContext.close();
});

test("lost create response and reload recover one invitation; cancellation is explicit and terminal", async ({
  page,
}) => {
  await signIn(page, "admin");
  await openAdmin(page);
  const name = `Resposta HO015 ${randomUUID().slice(0, 8)}`,
    email = `lost-${randomUUID()}@homeoffice.example`;
  await page.route(
    "**/api/v1/admin/members",
    async (route) => {
      await route.fetch();
      await route.abort("failed");
    },
    { times: 1 },
  );
  await invite(page, name, email);
  await expect(
    page.getByRole("button", { name: "Recuperar a mesma operação" }),
  ).toBeVisible();
  await page.reload();
  await openAdmin(page);
  await page
    .getByRole("button", { name: "Recuperar a mesma operação" })
    .click();
  await confirmed(page);
  expect(
    (await list(page)).members.filter((m) => m.email === email),
  ).toHaveLength(1);
  expect(captured(email)).toHaveLength(1);
  await select(page, name);
  await page
    .getByRole("button", { name: "Cancelar convite", exact: true })
    .click();
  await page.keyboard.press("Escape");
  await expect(
    page.getByRole("button", { name: "Cancelar convite", exact: true }),
  ).toBeFocused();
  await page
    .getByRole("button", { name: "Cancelar convite", exact: true })
    .click();
  await confirm(page);
  await confirmed(page);
  const row = (await list(page)).members.find((m) => m.email === email)!;
  expect(row.state).toBe("Cancelled");
  expect(row.active).toBe(false);
  const result = await page.request.post("/api/v1/auth/activation/complete", {
    data: {
      email,
      code: captured(email)[0].code,
      password: accounts.employee.password,
    },
  });
  expect(result.status()).toBe(400);
});

test("stale role edit is rejected and uncertain exact replay cannot undo newer data", async ({
  page,
}) => {
  await signIn(page, "admin");
  await openAdmin(page);
  const name = `Versão HO015 ${randomUUID().slice(0, 8)}`,
    email = `version-${randomUUID()}@homeoffice.example`;
  await invite(page, name, email);
  await confirmed(page);
  await select(page, name);
  let row = (await list(page)).members.find((m) => m.email === email)!;
  const edit = (m: InvitationProfile, isManager: boolean) => ({
    active: m.active,
    isEmployee: m.isEmployee,
    isManager,
    isAccountAdministrator: m.isAccountAdministrator,
    expectedAccessVersion: m.accessVersion,
    commandId: randomUUID(),
  });
  await page.getByLabel("Gestor", { exact: true }).check();
  await page
    .getByRole("button", { name: "Rever papéis e acesso", exact: true })
    .click();
  expect(
    (
      await mutation(
        page,
        `/api/v1/admin/members/${row.memberId}`,
        edit(row, true),
      )
    ).status(),
  ).toBe(204);
  await confirm(page);
  await expect(
    page.getByText(/^Os dados foram alterados entretanto/),
  ).toBeVisible();
  await expect(
    page.getByRole("button", { name: "Atualizar membros", exact: true }),
  ).toBeEnabled();
  await page.getByLabel("Gestor", { exact: true }).uncheck();
  await page
    .getByRole("button", { name: "Rever papéis e acesso", exact: true })
    .click();
  await page.route(
    `**/api/v1/admin/members/${row.memberId}`,
    async (route) => {
      await route.fetch();
      await route.abort("failed");
    },
    { times: 1 },
  );
  await confirm(page);
  await expect(
    page.getByRole("button", { name: "Recuperar a mesma operação" }),
  ).toBeVisible();
  row = (await list(page)).members.find((m) => m.email === email)!;
  expect(
    (
      await mutation(
        page,
        `/api/v1/admin/members/${row.memberId}`,
        edit(row, true),
      )
    ).status(),
  ).toBe(204);
  await page
    .getByRole("button", { name: "Recuperar a mesma operação" })
    .click();
  await confirmed(page);
  expect(
    (await list(page)).members.find((m) => m.email === email)!.isManager,
  ).toBe(true);
});

test("resend rotates a real captured code, preserves the pending invitation and obeys cooldown", async ({
  page,
}) => {
  await signIn(page, "admin");
  await openAdmin(page);
  const name = `Reenvio HO015 ${randomUUID().slice(0, 8)}`,
    email = `resend-${randomUUID()}@homeoffice.example`;
  await invite(page, name, email);
  await confirmed(page);
  await select(page, name);
  await expect.poll(() => captured(email).length).toBe(1);
  const before = captured(email)[0].code;
  const button = page.getByRole("button", {
    name: "Reenviar convite",
    exact: true,
  });
  await expect(button).toBeDisabled();
  await expect(button).toBeEnabled({ timeout: 80000 }); // Real server cooldown; never move database time.
  await button.click();
  await confirm(page);
  await confirmed(page);
  await expect.poll(() => captured(email).length).toBe(2);
  const different = before !== captured(email).at(-1).code;
  expect(different).toBe(true);
  expect((await list(page)).members.find((m) => m.email === email)!.state).toBe(
    "Pending",
  );
  const denied = await page.request.post("/api/v1/auth/activation/complete", {
    data: { email, code: before, password: accounts.employee.password },
  });
  expect(denied.status()).toBe(400);
  await expect(
    page.getByRole("button", { name: "Reenviar convite", exact: true }),
  ).toBeDisabled();
});

test("admin read errors and empty search are explicit and retry preserves authorization", async ({
  page,
}) => {
  await signIn(page, "admin");
  await page.route(
    "**/api/v1/admin/invitations?*",
    (route) => route.abort("failed"),
    { times: 1 },
  );
  await openAdmin(page);
  await expect(
    page.getByText(/^Não foi possível consultar os membros/),
  ).toBeVisible();
  await page
    .getByRole("button", { name: "Atualizar membros", exact: true })
    .click();
  await expect(page.getByRole("searchbox")).toBeVisible();
  await page
    .getByRole("searchbox")
    .fill("No matching synthetic member " + randomUUID());
  await expect(page.getByText("Não foram encontrados membros.")).toBeVisible();
  await page
    .getByRole("button", { name: "Convidar membro", exact: true })
    .click();
  await page
    .getByRole("dialog")
    .getByLabel("Nome", { exact: true })
    .fill("Input retained");
  await page
    .getByRole("dialog")
    .getByLabel("Email do convite", { exact: true })
    .fill("admin@homeoffice.example");
  await page
    .getByRole("button", { name: "Rever convite", exact: true })
    .click();
  await confirm(page);
  await expect(page.getByText(/^Este email não está disponível/)).toBeVisible();
  await page
    .getByRole("button", { name: "Convidar membro", exact: true })
    .click();
  await expect(
    page.getByRole("dialog").getByLabel("Nome", { exact: true }),
  ).toHaveValue("Input retained");
  await page.keyboard.press("Escape");
});
