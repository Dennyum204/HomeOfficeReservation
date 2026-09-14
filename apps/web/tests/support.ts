import { readFileSync } from "node:fs";
import { expect, type Locator, type Page } from "@playwright/test";

const file = process.env.HO_DEV_ACCOUNTS;
if (!file)
  throw new Error(
    "Set HO_DEV_ACCOUNTS to the private accounts.json created by scripts/init_auth.py.",
  );
const accounts = JSON.parse(readFileSync(file, "utf8"));
export async function signIn(
  page: Page,
  role: "employee" | "manager" | "admin" = "employee",
) {
  await page.goto("/");
  await page.getByLabel("Email", { exact: true }).fill(accounts[role].email);
  await page
    .getByLabel("Palavra-passe", { exact: true })
    .fill(accounts[role].password);
  await page.getByRole("button", { name: "Entrar", exact: true }).click();
  await expect(page.locator("#workspace-navigation")).toBeVisible();
}

// Exercise the visible combobox, including its open list and selection.
export async function choose(
  control: Locator,
  value: string | { label: string },
) {
  await control.click();
  if (typeof value === "string") {
    await control
      .page()
      .locator('[role="option"]')
      .locator(`:scope[data-value="${value}"]`)
      .click();
  } else {
    await control
      .page()
      .getByRole("option", { name: value.label, exact: true })
      .click();
  }
}
