import { test, expect } from "@playwright/test";
import { signIn, choose } from "./support";
import { addDays, todayInZone } from "../src/features/planning/dates";

test("invitation labels and checkboxes fit, and editor selects retain keyboard focus in both themes", async ({
  page,
}, info) => {
  await signIn(page, "admin");
  for (const mode of ["light", "dark"]) {
    await page
      .locator("#workspace-navigation")
      .getByRole("button", { name: /Definições/ })
      .click();
    await choose(
      page.locator(".appearance-card").getByRole("combobox", {
        name: /^(Tema da interface|Interface theme|Oberflächendesign)$/,
      }),
      mode,
    );
    await page
      .getByRole("navigation")
      .getByRole("button", { name: /Administração/ })
      .click();
    await page
      .getByRole("button", { name: "Convidar membro", exact: true })
      .click();
    const modal = page.getByRole("dialog");
    for (const role of ["Colaborador", "Gestor", "Administrador"]) {
      const checkbox = modal.getByRole("checkbox", { name: role, exact: true });
      await expect(checkbox).toBeVisible();
      const box = await checkbox.boundingBox();
      expect(box!.width).toBeLessThanOrEqual(24);
      expect(box!.height).toBeLessThanOrEqual(24);
    }
    expect(
      await modal.evaluate((el) => el.scrollWidth <= el.clientWidth + 1),
    ).toBe(true);
    await page.screenshot({
      path: `test-results/ho020-${info.project.name}-${mode}-invite.png`,
      fullPage: false,
      animations: "disabled",
      scale: "css",
    });
    await modal
      .getByRole("button", { name: "Fechar", exact: true })
      .first()
      .click();
  }
  await page
    .locator("#workspace-navigation")
    .getByRole("button", { name: /Definições/ })
    .click();
  await page
    .getByRole("button", { name: "Terminar sessão", exact: true })
    .click();
  await expect(page.getByLabel("Email", { exact: true })).toBeVisible();
  await signIn(page);
  for (const mode of ["light", "dark"]) {
    await page
      .locator("#workspace-navigation")
      .getByRole("button", { name: /Definições/ })
      .click();
    await choose(
      page.locator(".appearance-card").getByRole("combobox", {
        name: /^(Tema da interface|Interface theme|Oberflächendesign)$/,
      }),
      mode,
    );
    await page
      .getByRole("navigation")
      .getByRole("button", { name: /^Calendário/ })
      .click();
    await expect(page.locator(".calendar-grid")).toBeVisible();
    const remote = page
      .locator('.calendar-day:not(.outside)[data-location="RemotePortugal"]')
      .first();
    await (
      (await remote.count()) ? remote : page.locator(".calendar-day").nth(15)
    ).scrollIntoViewIfNeeded();
    await page.screenshot({
      path: `test-results/ho020-${info.project.name}-${mode}-calendar.png`,
      fullPage: false,
      animations: "disabled",
      scale: "css",
    });
    await page.getByRole("button", { name: /Pedir os meus dias/ }).click();
    const modal = page.getByRole("dialog");
    await modal
      .getByRole("button", { name: "Dias individuais", exact: true })
      .click();
    const date = addDays(todayInZone(), 66);
    await modal.getByLabel("Data", { exact: true }).fill(date);
    await modal
      .getByRole("button", { name: "Adicionar dia", exact: true })
      .click();
    const field = modal.getByRole("combobox", {
      name: `Disponibilidade ${date}`,
      exact: true,
    });
    await field.focus();
    await page.keyboard.press("ArrowDown");
    await expect(page.getByRole("listbox")).toBeVisible();
    expect(
      await page.getByRole("listbox").evaluate((el) => !!el.closest("dialog")),
    ).toBe(true);
    await page.screenshot({
      path: `test-results/ho020-${info.project.name}-${mode}-dropdown.png`,
      fullPage: false,
      animations: "disabled",
      scale: "css",
    });
    await page.keyboard.press("End");
    await expect(
      page.getByRole("option", { name: "Indisponível", exact: true }),
    ).toBeFocused();
    await page.keyboard.press("Enter");
    await expect(field).toBeFocused();
    await expect(field).toHaveText(/Indisponível/);
    await choose(field, "Working");
    expect(
      await modal.evaluate((el) => el.scrollWidth <= el.clientWidth + 1),
    ).toBe(true);
    await page.screenshot({
      path: `test-results/ho020-${info.project.name}-${mode}-editor.png`,
      fullPage: false,
      animations: "disabled",
      scale: "css",
    });
    const remove = modal.getByRole("button", {
      name: "Remover dia",
      exact: true,
    });
    const box = await remove.boundingBox();
    expect(box!.width).toBeGreaterThanOrEqual(44);
    expect(box!.height).toBeGreaterThanOrEqual(44);
    await remove.click();
    await expect(modal.locator(".editor-day")).toHaveCount(0);
    await expect(modal).toBeVisible();
    await modal
      .getByRole("button", { name: "Fechar", exact: true })
      .first()
      .click();
    await page
      .getByRole("navigation")
      .getByRole("button", { name: /^Notificações/ })
      .click();
    await expect(
      page.getByRole("combobox", { name: "Filtrar notificações" }),
    ).toHaveText(/Por ler/);
    await page.screenshot({
      path: `test-results/ho020-${info.project.name}-${mode}-notifications.png`,
      fullPage: false,
      animations: "disabled",
      scale: "css",
    });
  }
});
