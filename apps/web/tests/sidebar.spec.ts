import { test, expect } from "@playwright/test";
import { signIn } from "./support";

for (const language of ["pt", "en", "de"]) {
  test(`navigation stays contained and collapses accessibly in ${language}`, async ({
    page,
  }, info) => {
    await signIn(page, "admin");
    await page.evaluate(
      (value) => localStorage.setItem("homeoffice.language", value),
      language,
    );
    await page.reload();
    const sidebar = page.locator(".sidebar");
    const toggle = sidebar.locator(".sidebar-toggle");
    const nav = sidebar.getByRole("navigation");
    await expect(toggle).toHaveAttribute("aria-expanded", "true");
    await expect(nav.getByRole("button")).toHaveCount(7);
    for (const mode of ["light", "dark"] as const) {
      await page.emulateMedia({ colorScheme: mode, reducedMotion: "reduce" });
      await page.evaluate(() =>
        localStorage.removeItem("homeoffice.appearance"),
      );
      await page.reload();
      await nav.getByRole("button").nth(5).click();
      await expect(nav.getByRole("button").nth(5)).toHaveAttribute(
        "aria-current",
        "page",
      );
      expect(await page.locator("body").innerText()).not.toMatch(
        /â€|Â·|\uFFFD/,
      );
      const boxes = await nav.evaluate((el) => {
        const bounds = el.getBoundingClientRect();
        return [...el.querySelectorAll("button")].map((button) => {
          const b = button.getBoundingClientRect();
          const label = button
            .querySelector(".nav-label")!
            .getBoundingClientRect();
          return {
            contained: b.left >= bounds.left - 1 && b.right <= bounds.right + 1,
            labelContained: label.left >= b.left && label.right <= b.right + 1,
            overflow: button.scrollWidth > button.clientWidth + 1,
          };
        });
      });
      expect(
        boxes.every((b) => b.contained && b.labelContained && !b.overflow),
      ).toBe(true);
      await page.screenshot({
        path: `test-results/sidebar-${info.project.name}-${language}-${mode}-open.png`,
        scale: "css",
      });
      await toggle.focus();
      await page.keyboard.press("Enter");
      await expect(toggle).toBeFocused();
      await expect(toggle).toHaveAttribute("aria-expanded", "false");
      await expect(sidebar.locator(".brand-mark")).toBeVisible();
      await expect(sidebar.locator(".brand-copy")).toBeHidden();
      for (const button of await nav.getByRole("button").all()) {
        await expect(button).toHaveAccessibleName(/\S/);
        await expect(button.locator(".nav-label")).toBeHidden();
        const centered = await button.evaluate((el) => {
          const b = el.getBoundingClientRect();
          const icon = el.querySelector(".nav-icon")!.getBoundingClientRect();
          return (
            Math.abs((b.left + b.right) / 2 - (icon.left + icon.right) / 2) < 1
          );
        });
        expect(centered).toBe(true);
      }
      await nav.getByRole("button").nth(1).click();
      await expect(nav.getByRole("button").nth(1)).toHaveAttribute(
        "aria-current",
        "page",
      );
      expect(
        await page.evaluate(
          () => document.documentElement.scrollWidth <= innerWidth,
        ),
      ).toBe(true);
      await page.screenshot({
        path: `test-results/sidebar-${info.project.name}-${language}-${mode}-closed.png`,
        scale: "css",
      });
      await toggle.focus();
      await page.keyboard.press("Space");
      await expect(toggle).toHaveAttribute("aria-expanded", "true");
      await expect(toggle).toBeFocused();
      await expect(nav.getByRole("button").nth(1)).toHaveAttribute(
        "aria-current",
        "page",
      );
    }
  });
}
