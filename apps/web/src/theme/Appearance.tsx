import {
  createContext,
  useContext,
  useEffect,
  useState,
  type ReactNode,
} from "react";
import { appearance as s } from "../i18n/appearance.pt-PT";

export type ThemePreference = "light" | "dark" | "system";
const key = "homeoffice.appearance";
function readPreference(): ThemePreference {
  try {
    const saved = localStorage.getItem(key);
    return saved === "light" || saved === "dark" ? saved : "system";
  } catch {
    return "system";
  }
}
function apply(preference: ThemePreference) {
  const dark =
    preference === "dark" ||
    (preference === "system" &&
      window.matchMedia?.("(prefers-color-scheme: dark)").matches);
  document.documentElement.dataset.theme = dark ? "dark" : "light";
  document
    .querySelector('meta[name="theme-color"]')
    ?.setAttribute("content", dark ? "#262624" : "#faf9f5");
}

const Context = createContext<{
  preference: ThemePreference;
  storageError: boolean;
  select: (value: ThemePreference) => void;
}>({ preference: "system", storageError: false, select: () => {} });
export function AppearanceProvider({ children }: { children: ReactNode }) {
  const [preference, setPreference] = useState(readPreference);
  const [storageError, setStorageError] = useState(false);
  useEffect(() => {
    apply(preference);
    const media = window.matchMedia?.("(prefers-color-scheme: dark)");
    const changed = () => apply(preference);
    media?.addEventListener("change", changed);
    return () => media?.removeEventListener("change", changed);
  }, [preference]);
  useEffect(() => {
    const changed = () => setPreference(readPreference());
    window.addEventListener("storage", changed);
    return () => window.removeEventListener("storage", changed);
  }, []);
  function select(next: ThemePreference) {
    setPreference(next);
    try {
      localStorage.setItem(key, next);
      setStorageError(false);
    } catch {
      setStorageError(true);
    }
  }
  return (
    <Context value={{ preference, storageError, select }}>{children}</Context>
  );
}
export function Appearance({ compact = false }: { compact?: boolean }) {
  const { preference, storageError, select } = useContext(Context);
  return (
    <section
      className={compact ? "appearance-compact" : "appearance-card"}
      aria-label={s.title}
    >
      {!compact && (
        <>
          <h2>{s.title}</h2>
          <p className="muted">{s.description}</p>
        </>
      )}
      <label>
        <span className={compact ? "sr-only" : undefined}>{s.label}</span>
        <select
          value={preference}
          onChange={(event) => {
            const next = event.target.value as ThemePreference;
            select(next);
          }}
        >
          <option value="system">{s.system}</option>
          <option value="light">{s.light}</option>
          <option value="dark">{s.dark}</option>
        </select>
      </label>
      {storageError && <p role="status">{s.storage}</p>}
    </section>
  );
}
