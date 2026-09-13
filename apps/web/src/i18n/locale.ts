import { useSyncExternalStore } from "react";
import { strings as ptStrings } from "./pt-PT";
import { p as ptPlanning } from "./planning.pt-PT";
import { w as ptWork } from "./work.pt-PT";
import { n as ptNotifications } from "./notifications.pt-PT";
import { a as ptAdmin } from "./admin.pt-PT";
import { appearance as ptAppearance } from "./appearance.pt-PT";
import * as en from "./en";
import * as de from "./de";

export type Language = "pt" | "en" | "de";
export const languageKey = "homeoffice.language";
export const catalogs = {
  pt: {
    strings: ptStrings,
    p: ptPlanning,
    w: ptWork,
    n: ptNotifications,
    a: ptAdmin,
    appearance: ptAppearance,
  },
  en,
  de,
};
export function validLanguage(value: unknown): Language {
  return value === "en" || value === "de" ? value : "pt";
}
function readLanguage(): Language {
  try {
    return validLanguage(localStorage.getItem(languageKey));
  } catch {
    return "pt";
  }
}
let language = readLanguage();
let storageFailed = false;
let revision = 0;
const listeners = new Set<() => void>();
// Live bindings let existing pure label/error helpers use the same catalog as React.
// Changing language never remounts the workspace or discards an unsent form.
export let { strings, p, w, n, a, appearance } = catalogs[language];
export const locale = () =>
  ({ pt: "pt-PT", en: "en-GB", de: "de-CH" })[language];
export const numberLabel = (value: number) =>
  new Intl.NumberFormat(locale()).format(value);
export const currentLanguage = () => language;
const subscribe = (listener: () => void) => {
  listeners.add(listener);
  return () => {
    listeners.delete(listener);
  };
};
export function useLanguage() {
  useSyncExternalStore(
    subscribe,
    () => revision,
    () => 0,
  );
  return language;
}
export const languageStorageFailed = () => storageFailed;
function apply(next: Language) {
  language = next;
  revision += 1;
  ({ strings, p, w, n, a, appearance } = catalogs[next]);
  if (typeof document !== "undefined") document.documentElement.lang = locale();
  listeners.forEach((listener) => listener());
}
export function selectLanguage(next: Language) {
  storageFailed = false;
  try {
    localStorage.setItem(languageKey, next);
  } catch {
    storageFailed = true;
  }
  apply(next);
}
if (typeof window !== "undefined") {
  window.addEventListener("storage", (event) => {
    if (event.key === languageKey || event.key === null) {
      storageFailed = false;
      apply(readLanguage());
    }
  });
  document.documentElement.lang = locale();
}

// Only for feedback and command labels originally selected from these catalogs.
// Never apply to names, notes, comments, server payloads or other user content.
const feedback = new Map<string, Record<Language, string>>();
function indexFeedback(pt: unknown, en: unknown, de: unknown) {
  if (
    typeof pt === "string" &&
    typeof en === "string" &&
    typeof de === "string"
  ) {
    for (const value of [pt, en, de]) feedback.set(value, { pt, en, de });
  } else if (pt && en && de && typeof pt === "object") {
    for (const key of Object.keys(pt))
      indexFeedback(
        (pt as Record<string, unknown>)[key],
        (en as Record<string, unknown>)[key],
        (de as Record<string, unknown>)[key],
      );
  }
}
indexFeedback(catalogs.pt, catalogs.en, catalogs.de);
export const localizedFeedback = (message: string) =>
  feedback.get(message)?.[language] ?? message;
