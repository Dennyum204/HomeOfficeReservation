import { Select } from "../theme/Select";
import {
  languageStorageFailed,
  selectLanguage,
  useLanguage,
  validLanguage,
} from "./locale";

const languageCopy = {
  pt: {
    title: "Idioma",
    help: "Idioma guardado neste dispositivo. O idioma inicial é português.",
    error:
      "O idioma foi aplicado, mas não foi possível guardá-lo neste dispositivo.",
  },
  en: {
    title: "Language",
    help: "Language is saved on this device. The initial language is Portuguese.",
    error: "Language applied, but it could not be saved on this device.",
  },
  de: {
    title: "Sprache",
    help: "Die Sprache wird auf diesem Gerät gespeichert. Die Anfangssprache ist Portugiesisch.",
    error:
      "Sprache angewendet, konnte aber auf diesem Gerät nicht gespeichert werden.",
  },
};
export function LanguagePicker({ compact = false }: { compact?: boolean }) {
  const language = useLanguage();
  const s = languageCopy[language];
  return (
    <section
      className={compact ? "appearance-compact" : "appearance-card"}
      aria-label={s.title}
    >
      {!compact && (
        <>
          <h2>{s.title}</h2>
          <p className="muted">{s.help}</p>
        </>
      )}
      <label>
        <span>{s.title}</span>
        <Select
          value={language}
          onChange={(event) =>
            selectLanguage(validLanguage(event.target.value))
          }
        >
          <option value="pt">Português</option>
          <option value="en">English</option>
          <option value="de">Deutsch</option>
        </Select>
      </label>
      {languageStorageFailed() && <p role="status">{s.error}</p>}
    </section>
  );
}
