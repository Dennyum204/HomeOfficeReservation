import { test, expect, type Page } from "@playwright/test";
import { signIn } from "./support";
import { addDays, todayInZone } from "../src/features/planning/dates";

async function contrast(page: Page, scope = "main") {
  const failures = await page.locator(scope).evaluate((root) => {
    const rgb = (value: string) => (value.match(/[\d.]+/g) ?? []).map(Number);
    const light = (values: number[]) =>
      values.slice(0, 3).reduce((sum, value, i) => {
        const c = value / 255;
        return (
          sum +
          (c <= 0.04045 ? c / 12.92 : ((c + 0.055) / 1.055) ** 2.4) *
            [0.2126, 0.7152, 0.0722][i]
        );
      }, 0);
    const result: string[] = [];
    for (const element of root.querySelectorAll<HTMLElement>(
      "h1,h2,h3,p,label,button,input,select,textarea,.status-badge,.chip-location,.chip-state,.muted,.notification-state,.admin-badge",
    )) {
      if (
        !element.getClientRects().length ||
        element.closest(":disabled,[hidden]")
      )
        continue;
      if (
        ![...element.childNodes].some(
          (node) =>
            node.nodeType === Node.TEXT_NODE && node.textContent?.trim(),
        ) &&
        !element.matches("input,select,textarea")
      )
        continue;
      const style = getComputedStyle(element);
      let parent: Element | null = element;
      let background = "";
      let disabled = false;
      while (parent) {
        const parentStyle = getComputedStyle(parent);
        if (Number(parentStyle.opacity) < 1 || parent.matches(":disabled"))
          disabled = true;
        const c = rgb(parentStyle.backgroundColor);
        if (!background && c.length >= 3 && (c.length < 4 || c[3] === 1))
          background = parentStyle.backgroundColor;
        parent = parent.parentElement;
      }
      if (disabled || !background) continue;
      const a = light(rgb(style.color)),
        b = light(rgb(background));
      const ratio = (Math.max(a, b) + 0.05) / (Math.min(a, b) + 0.05);
      const large =
        parseFloat(style.fontSize) >= 24 ||
        (parseFloat(style.fontSize) >= 18.66 &&
          Number(style.fontWeight) >= 700);
      if (ratio < (large ? 3 : 4.5))
        result.push(
          `${element.tagName}.${element.className}: ${ratio.toFixed(2)} (${style.color} on ${background})`,
        );
    }
    return result;
  });
  expect(
    failures,
    "Rendered text has WCAG AA contrast against its actual surface",
  ).toEqual([]);
}

test("theme follows system, persists explicit choice and keeps real screens accessible", async ({
  page,
}) => {
  await page.emulateMedia({ colorScheme: "dark", reducedMotion: "reduce" });
  await signIn(page);
  const theme = page
    .getByRole("banner")
    .getByRole("combobox", { name: "Tema da interface" });
  await expect(page.locator("html")).toHaveAttribute("data-theme", "dark");
  await theme.selectOption("light");
  await page.reload();
  await expect(theme).toHaveValue("light");
  await expect(page.locator("html")).toHaveAttribute("data-theme", "light");
  await theme.selectOption("system");
  await expect(page.locator("html")).toHaveAttribute("data-theme", "dark");
  await page.emulateMedia({ colorScheme: "light" });
  await expect(page.locator("html")).toHaveAttribute("data-theme", "light");
  for (const mode of ["light", "dark"]) {
    await theme.selectOption(mode);
    for (const label of [
      "Calendário",
      "Pedidos",
      "Presenças",
      "Tarefas",
      "Notificações",
      "Definições",
    ]) {
      await page
        .getByRole("navigation")
        .getByRole("button", { name: new RegExp(`^${label}`) })
        .click();
      await expect(page.locator("main h1")).toBeVisible();
      await expect(
        page
          .locator("main [role=status]")
          .filter({ hasText: /A carregar|A atualizar|A verificar/ }),
      ).toHaveCount(0);
      await contrast(page);
      expect(
        await page.evaluate(
          () => document.documentElement.scrollWidth <= innerWidth + 1,
        ),
      ).toBe(true);
    }
  }
});

test("editor distinguishes range and individual days, preserves selection and returns focus", async ({
  page,
}) => {
  await signIn(page);
  await page.emulateMedia({ reducedMotion: "reduce" });
  const open = page.getByRole("button", {
    name: /Pedir os meus dias de trabalho/,
  });
  await open.click();
  const dialog = page.getByRole("dialog");
  await expect(dialog.getByRole("heading", { level: 2 })).toBeFocused();
  await expect(
    dialog.getByRole("group", { name: "Contexto e localização" }),
  ).toBeVisible();
  await expect(
    dialog.getByRole("group", { name: "Resumo dos dias" }),
  ).toBeVisible();
  const mode = dialog.getByRole("group", {
    name: "Como quer escolher os dias?",
  });
  await mode.getByRole("button", { name: "Dias individuais" }).click();
  await expect(dialog.getByLabel("De", { exact: true })).toHaveCount(0);
  const date = addDays(todayInZone(), 65);
  await dialog.getByLabel("Data", { exact: true }).fill(date);
  await dialog
    .getByRole("button", { name: "Adicionar dia", exact: true })
    .click();
  await mode.getByRole("button", { name: "Intervalo", exact: true }).click();
  await expect(dialog.getByLabel("Data", { exact: true })).toHaveCount(0);
  await expect(
    dialog.getByRole("heading", { name: /Datas selecionadas · 1/ }),
  ).toBeVisible();
  await contrast(page, "dialog");
  expect(await dialog.evaluate((e) => getComputedStyle(e).animationName)).toBe(
    "none",
  );
  await page.keyboard.press("Tab");
  expect(await dialog.evaluate((e) => e.contains(document.activeElement))).toBe(
    true,
  );
  await page.keyboard.press("Escape");
  await expect(dialog).toHaveCount(0);
  await expect(open).toBeFocused();
});
