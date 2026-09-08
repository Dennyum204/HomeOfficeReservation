import { test, expect } from "@playwright/test";
import { signIn } from "./support";

test("real cookie login restores on reload, expires, and logout removes the session", async ({
  page,
}) => {
  await signIn(page, "manager");
  await expect(
    page.getByText("Chefia de teste", { exact: true }),
  ).toBeVisible();
  await page.reload();
  await expect(
    page.getByRole("button", { name: "Terminar sessão", exact: true }),
  ).toBeVisible();
  await page.waitForTimeout(5200); // Real server cookie expiry, short Development-only lifetime.
  await page
    .getByRole("button", { name: "Verificar sessão", exact: true })
    .click();
  await expect(
    page.getByText("A sessão expirou. Inicie sessão novamente."),
  ).toBeVisible();
  await expect(page.getByText("Chefia de teste", { exact: true })).toHaveCount(
    0,
  );
  await signIn(page);
  await page
    .getByRole("button", { name: "Terminar sessão", exact: true })
    .click();
  await expect(
    page.getByRole("heading", { name: "Entre no seu espaço" }),
  ).toBeVisible();
  await page.reload();
  await expect(
    page.getByRole("heading", { name: "Entre no seu espaço" }),
  ).toBeVisible();
  expect(await page.evaluate(() => Object.keys(localStorage))).toEqual([]);
});

test("invalid credentials and recovery form use real API responses", async ({
  page,
}) => {
  await page.goto("/");
  await page
    .getByLabel("Email", { exact: true })
    .fill("absent@homeoffice.example");
  await page
    .getByLabel("Palavra-passe", { exact: true })
    .fill("Deliberately-wrong9!");
  await page.getByRole("button", { name: "Entrar", exact: true }).click();
  await expect(page.getByText(/Não foi possível entrar/)).toBeVisible();
  await page
    .getByRole("button", { name: "Esqueci-me da palavra-passe" })
    .click();
  await page
    .getByRole("button", { name: "Pedir código de recuperação" })
    .click();
  await expect(page.getByText(/Se a conta for elegível/)).toBeVisible();
  await page.getByLabel("Código recebido").fill("invalid");
  await page.getByLabel("Palavra-passe", { exact: true }).fill("New-example9!");
  await page.getByRole("button", { name: "Guardar palavra-passe" }).click();
  await expect(page.getByText(/Não foi possível concluir/)).toBeVisible();
});
