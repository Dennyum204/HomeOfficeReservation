import { test, expect } from "@playwright/test";
import { signIn } from "./support";

for (const language of ["pt", "en", "de"] as const) {
  test(`account actions live in settings and calendar has no header in ${language}`, async ({
    page,
  }, info) => {
    await signIn(page);
    await page.evaluate(
      (value) => localStorage.setItem("homeoffice.language", value),
      language,
    );
    const nav = page.locator("#workspace-navigation");
    for (const mode of ["light", "dark"] as const) {
      await page.emulateMedia({ colorScheme: mode, reducedMotion: "reduce" });
      await page.goto("/calendar");
      await expect(page.getByRole("heading", { level: 1 })).toHaveText(
        { pt: "Calendário", en: "Calendar", de: "Kalender" }[language],
      );
      await expect(page.locator(".account-bar, .topbar")).toHaveCount(0);
      await expect(page.locator(".account-settings")).toHaveCount(0);
      await expect(page.locator(".calendar-grid")).toBeVisible();
      await page.screenshot({
        path: `test-results/account-${info.project.name}-${language}-${mode}-calendar.png`,
        scale: "css",
      });
      await nav.getByRole("button").nth(5).click();
      const account = page.locator(".account-settings");
      await expect(account.getByRole("heading")).toHaveText(
        {
          pt: "Conta e sessão",
          en: "Account and session",
          de: "Konto und Sitzung",
        }[language],
      );
      await account.scrollIntoViewIfNeeded();
      await expect(account.getByRole("button")).toHaveCount(2);
      for (const button of await account.getByRole("button").all()) {
        expect((await button.boundingBox())!.height).toBeGreaterThanOrEqual(44);
      }
      const checked = page.waitForResponse((r) =>
        r.url().endsWith("/api/v1/me"),
      );
      await account.getByRole("button").first().click();
      expect((await checked).status()).toBe(200);
      await expect(account).toBeVisible();
      expect(
        await page.evaluate(
          () => document.documentElement.scrollWidth <= innerWidth,
        ),
      ).toBe(true);
      await page.screenshot({
        path: `test-results/account-${info.project.name}-${language}-${mode}-settings.png`,
        scale: "css",
      });
      await page.evaluate(() =>
        window.scrollTo(0, document.documentElement.scrollHeight),
      );
      expect(
        await account.evaluate((el) => getComputedStyle(el).position),
      ).toBe("static");
    }
    // A failed logout must not claim success or erase the current session.
    await page.route("**/api/v1/auth/logout", (route) =>
      route.fulfill({ status: 503, body: "" }),
    );
    await page.locator(".account-settings").getByRole("button").last().click();
    await expect(
      page.locator(".account-settings").getByRole("alert"),
    ).toBeVisible();
    await expect(nav).toBeVisible();
    await page.unroute("**/api/v1/auth/logout");
    await page.evaluate(() =>
      sessionStorage.setItem(
        "homeoffice:planning-editor",
        "synthetic private draft",
      ),
    );
    await page.locator(".account-settings").getByRole("button").last().click();
    await expect(page.locator('input[name="email"]')).toBeVisible();
    expect(
      await page.evaluate(() =>
        sessionStorage.getItem("homeoffice:planning-editor"),
      ),
    ).toBeNull();
    await page.reload();
    await expect(page.locator('input[name="email"]')).toBeVisible();
    // Return to Portuguese for the existing synthetic account helper.
    await page.evaluate(() =>
      localStorage.setItem("homeoffice.language", "pt"),
    );
    await signIn(page, "manager");
    await nav.getByRole("button").first().click();
    await expect(
      page.getByLabel("Colaborador selecionado", { exact: true }),
    ).toBeVisible();
    await expect(nav.getByRole("button")).toHaveCount(6);
    // Automatic session validation still runs outside settings.
    await page.context().clearCookies();
    await page.evaluate(() => window.dispatchEvent(new Event("focus")));
    await expect(
      page.getByText("A sessão expirou. Inicie sessão novamente."),
    ).toBeVisible();
    await expect(nav).toHaveCount(0);
  });
}
