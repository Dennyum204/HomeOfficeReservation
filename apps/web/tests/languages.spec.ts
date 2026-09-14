import { test, expect, type Page } from "@playwright/test";
import { choose, signIn } from "./support";
import { addDays, todayInZone } from "../src/features/planning/dates";

async function changeLanguage(page: Page, from: string, to: string) {
  await page
    .getByRole("navigation")
    .getByRole("button", { name: new RegExp(`^${from}`) })
    .click();
  await choose(
    page.getByRole("combobox", { name: /^(Idioma|Language|Sprache)$/ }),
    to,
  );
}
test("language selection persists, German forms fit, and user content survives draft writes", async ({
  page,
}, info) => {
  await signIn(page);
  await changeLanguage(page, "Definições", "de");
  await expect(page.locator("html")).toHaveAttribute("lang", "de-CH");
  await page.reload();
  await expect(
    page.getByRole("button", { name: "Abmelden", exact: true }),
  ).toBeVisible();
  for (const mode of ["light", "dark"]) {
    await page
      .locator("#workspace-navigation")
      .getByRole("button")
      .nth(5)
      .click();
    await choose(
      page.locator(".appearance-card").getByRole("combobox", {
        name: /^(Tema da interface|Interface theme|Oberflächendesign)$/,
      }),
      mode,
    );
    await page
      .getByRole("navigation")
      .getByRole("button", { name: /^Kalender/ })
      .click();
    await expect(page.locator(".calendar-grid")).toBeVisible();
    await page.locator(".calendar-day").nth(15).scrollIntoViewIfNeeded();
    await page.screenshot({
      path: `test-results/ho021-${info.project.name}-de-${mode}-calendar.png`,
      animations: "disabled",
      scale: "css",
    });
    await page
      .getByRole("button", { name: "Meine Arbeitstage beantragen" })
      .click();
    const dialog = page.getByRole("dialog");
    await dialog
      .getByRole("button", { name: "Einzelne Tage", exact: true })
      .click();
    const date = addDays(
      todayInZone(),
      info.project.name === "desktop" ? 310 : 315,
    );
    await dialog.getByLabel("Datum", { exact: true }).fill(date);
    await dialog
      .getByRole("button", { name: "Tag hinzufügen", exact: true })
      .click();
    const note = `Texto original / eigener Text ${info.project.name} ${mode}`;
    await dialog.getByLabel("Kommentar zum Antrag", { exact: true }).fill(note);
    expect(
      await dialog.evaluate((el) => el.scrollWidth <= el.clientWidth + 1),
    ).toBe(true);
    await dialog.locator(".editor-day").scrollIntoViewIfNeeded();
    await page.screenshot({
      path: `test-results/ho021-${info.project.name}-de-${mode}-editor.png`,
      animations: "disabled",
      scale: "css",
    });
    const saved = page.waitForResponse(
      (r) => r.url().endsWith("/requests") && r.request().method() === "POST",
    );
    await dialog
      .getByRole("button", { name: "Entwurf speichern", exact: true })
      .click();
    const response = await saved;
    expect(response.ok()).toBe(true);
    const receipt = await response.json();
    const loaded = await page.request.get(
      `${response.url()}/${receipt.contextId}`,
    );
    expect(loaded.ok()).toBe(true);
    const result = await loaded.json();
    expect(result.state).toBe("Draft");
    expect(result.days[0].localDate).toBe(date);
    expect(result.note).toBe(note);
    await expect(dialog).not.toBeVisible();
  }
  await changeLanguage(page, "Einstellungen", "en");
  for (const mode of ["light", "dark"]) {
    await page
      .locator("#workspace-navigation")
      .getByRole("button")
      .nth(5)
      .click();
    await choose(
      page.locator(".appearance-card").getByRole("combobox", {
        name: /^(Tema da interface|Interface theme|Oberflächendesign)$/,
      }),
      mode,
    );
    await page
      .getByRole("combobox", { name: "Language" })
      .scrollIntoViewIfNeeded();
    await page.screenshot({
      path: `test-results/ho021-${info.project.name}-en-${mode}-settings.png`,
      animations: "disabled",
      scale: "css",
    });
  }

  await page
    .getByRole("navigation")
    .getByRole("button", { name: /^Notifications/ })
    .click();
  await expect(
    page.getByRole("combobox", { name: "Filter notifications" }),
  ).toHaveText(/Unread/);
  await page
    .locator("#workspace-navigation")
    .getByRole("button")
    .nth(5)
    .click();
  await page.getByRole("button", { name: "Sign out", exact: true }).click();
  await expect(page.getByLabel("Password", { exact: true })).toBeVisible();
  await expect(page.getByRole("combobox", { name: "Language" })).toHaveText(
    /English/,
  );
  await choose(page.getByRole("combobox", { name: "Language" }), "pt");
  await expect(
    page.getByRole("button", { name: "Entrar", exact: true }),
  ).toBeVisible();
});

test("German administration labels and invitation review remain usable on narrow screens", async ({
  page,
}, info) => {
  await signIn(page, "admin");
  await changeLanguage(page, "Definições", "de");
  for (const mode of ["light", "dark"]) {
    await page
      .locator("#workspace-navigation")
      .getByRole("button")
      .nth(5)
      .click();
    await choose(
      page.locator(".appearance-card").getByRole("combobox", {
        name: /^(Tema da interface|Interface theme|Oberflächendesign)$/,
      }),
      mode,
    );
    await page
      .getByRole("navigation")
      .getByRole("button", { name: /^Administration/ })
      .click();
    await page
      .getByRole("button", { name: "Mitglied einladen", exact: true })
      .click();
    const dialog = page.getByRole("dialog");
    await dialog
      .getByLabel("Name", { exact: true })
      .fill("Synthetischer Name / nome original");
    await dialog
      .getByLabel("Einladungs-E-Mail", { exact: true })
      .fill("language-test@example.invalid");
    await expect(
      dialog.getByRole("checkbox", {
        name: "Mitarbeitende Person",
        exact: true,
      }),
    ).toBeChecked();
    await page.screenshot({
      path: `test-results/ho021-${info.project.name}-de-${mode}-invite.png`,
      animations: "disabled",
      scale: "css",
    });
    expect(
      await dialog.evaluate((el) => el.scrollWidth <= el.clientWidth + 1),
    ).toBe(true);
    await dialog
      .getByRole("button", { name: "Einladung prüfen", exact: true })
      .click();
    await expect(
      page
        .getByRole("dialog", { name: "Änderung prüfen", exact: true })
        .getByText(
          "Synthetischer Name / nome original · language-test@example.invalid",
          { exact: true },
        ),
    ).toBeVisible();
    // Review only; the existing administration suite covers durable delivery and permissions.
    await dialog
      .getByRole("button", { name: "Zurück ohne Senden", exact: true })
      .click();
    await dialog
      .getByRole("button", { name: "Schliessen", exact: true })
      .first()
      .click();
  }
});
