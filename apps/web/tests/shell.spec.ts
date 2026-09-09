import { signIn } from "./support";
import { test, expect } from "@playwright/test";

test("generated client reaches ASP.NET, navigation works, and the shell fits", async ({
  page,
}) => {
  await signIn(page);
  await expect(page.getByText("Serviço ligado", { exact: true })).toBeVisible();
  const timestamp = await page.locator("time").getAttribute("datetime");
  expect(Math.abs(Date.now() - Date.parse(timestamp!))).toBeLessThan(30000);
  await expect(page.getByText("Europe/Lisbon · Europe/Zurich")).toBeVisible();
  expect(
    await page.evaluate(
      () => document.documentElement.scrollWidth <= window.innerWidth,
    ),
  ).toBe(true);
  await page.screenshot({
    path: `test-results/shell-${test.info().project.name}.png`,
    fullPage: true,
  });
  await page.getByRole("button", { name: "Definições", exact: true }).click();
  await expect(
    page.getByText(
      "A sessão já está disponível. As preferências e o Outlook serão adicionados posteriormente.",
    ),
  ).toBeVisible();
  await page.getByRole("button", { name: "Atualizar ligação" }).click();
  await expect(page.getByText("Serviço ligado", { exact: true })).toBeVisible();
});

test("offline state does not imply an action was saved", async ({
  page,
  context,
}) => {
  await signIn(page);
  await expect(page.getByText("Serviço ligado", { exact: true })).toBeVisible();
  await context.setOffline(true);
  await page.getByRole("button", { name: "Atualizar ligação" }).click();
  await expect(
    page.getByText("Não foi possível ligar ao serviço."),
  ).toBeVisible();
  await context.setOffline(false);
  await page.getByRole("button", { name: "Tentar novamente" }).click();
  await expect(page.getByText("Serviço ligado", { exact: true })).toBeVisible();
});
