import { afterEach, describe, expect, it, vi } from "vitest";
import {
  act,
  fireEvent,
  render,
  screen,
  cleanup,
} from "@testing-library/react";
import { LanguagePicker } from "./LanguagePicker";
import {
  localizedFeedback,
  catalogs,
  languageKey,
  locale,
  numberLabel,
  p,
  selectLanguage,
  useLanguage,
  validLanguage,
} from "./locale";
import {
  dateKey,
  dateValue,
  longDayLabel,
  todayInZone,
} from "../features/planning/dates";

afterEach(() => {
  cleanup();
  vi.restoreAllMocks();
  selectLanguage("pt");
});
function Draft() {
  useLanguage();
  return (
    <>
      <LanguagePicker />
      <label>
        {p.comment}
        <input
          aria-label="draft"
          defaultValue="Comentário do utilizador — Zürich"
        />
      </label>
      <p>{p.counts(1, 2)}</p>
    </>
  );
}
describe("language preference", () => {
  it("updates previously stored UI feedback without altering unknown text", () => {
    const feedback = catalogs.pt.p.uncertain;
    selectLanguage("de");
    expect(localizedFeedback(feedback)).toBe(catalogs.de.p.uncertain);
    expect(localizedFeedback("Texto pessoal independente")).toBe(
      "Texto pessoal independente",
    );
  });
  it("changes labels without remounting the draft or translating user content", () => {
    render(<Draft />);
    const input = screen.getByLabelText("draft");
    fireEvent.change(input, {
      target: { value: "Mein eigener Text / meu texto" },
    });
    act(() => selectLanguage("de"));
    expect(screen.getByLabelText("draft")).toBe(input);
    expect(input).toHaveValue("Mein eigener Text / meu texto");
    expect(
      screen.getByText("1 genehmigter Tag · 2 ausstehende Tage"),
    ).toBeVisible();
    expect(document.documentElement.lang).toBe("de-CH");
    expect(localStorage.getItem(languageKey)).toBe("de");
    act(() => selectLanguage("en"));
    expect(screen.getByText("1 approved day · 2 pending days")).toBeVisible();
  });
  it("uses Portuguese for invalid preferences, syncs other tabs and reports storage failure", () => {
    expect(validLanguage("fr")).toBe("pt");
    render(<Draft />);
    localStorage.setItem(languageKey, "de");
    act(() =>
      window.dispatchEvent(new StorageEvent("storage", { key: languageKey })),
    );
    expect(screen.getByRole("combobox")).toHaveTextContent("Deutsch");
    vi.spyOn(Storage.prototype, "setItem").mockImplementation(() => {
      throw new Error("Unavailable");
    });
    act(() => selectLanguage("en"));
    expect(screen.getByRole("status")).toHaveTextContent("could not be saved");
    expect(locale()).toBe("en-GB");
  });
  it("formats display dates/numbers but preserves date-only values and domain timezone", () => {
    for (const language of ["pt", "en", "de"] as const) {
      selectLanguage(language);
      expect(dateKey(dateValue("2026-10-25"))).toBe("2026-10-25");
      expect(todayInZone("Europe/Zurich")).toMatch(/^\d{4}-\d{2}-\d{2}$/);
      expect(numberLabel(12345)).toBe(
        new Intl.NumberFormat(locale()).format(12345),
      );
    }
    expect(longDayLabel("2026-10-25")).toContain("Oktober");
    selectLanguage("en");
    expect(longDayLabel("2026-10-25")).toContain("October");
  });
  it("has matching keys/types throughout all catalogs and nonempty translations", () => {
    function compare(base: unknown, translated: unknown) {
      expect(typeof translated).toBe(typeof base);
      if (typeof base === "string") expect(translated).not.toBe("");
      if (base && typeof base === "object") {
        expect(Object.keys(translated as object).sort()).toEqual(
          Object.keys(base).sort(),
        );
        for (const key of Object.keys(base))
          compare(
            (base as Record<string, unknown>)[key],
            (translated as Record<string, unknown>)[key],
          );
      }
    }
    compare(catalogs.pt, catalogs.en);
    compare(catalogs.pt, catalogs.de);
    expect(catalogs.en.p.countDays(1)).toBe("1 day");
    expect(catalogs.de.p.countDays(0)).toBe("0 Tage");
  });
});
