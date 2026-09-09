import { useState } from "react";
import { strings as s } from "./i18n/pt-PT";
import { p } from "./i18n/planning.pt-PT";
import { w } from "./i18n/work.pt-PT";
import { ConnectionCard } from "./features/workspace/ConnectionCard";
import { AuthGate } from "./features/auth/AuthGate";
import { useMember } from "./features/auth/session";
import {
  PlanningWorkspace,
  type PlanningSection,
} from "./features/planning/PlanningWorkspace";
import "./features/planning/planning.css";
import "./features/planning/work.css";

export function App() {
  return (
    <AuthGate>
      <WorkspaceShell />
    </AuthGate>
  );
}
const icons: Record<PlanningSection, string> = {
  calendar: "▦",
  requests: "↗",
  onsite: "▣",
  tasks: "☑",
  settings: "⚙",
};
export function WorkspaceShell() {
  const [section, setSection] = useState<PlanningSection>("calendar");
  const member = useMember();
  return (
    <div className="app-shell">
      <a href="#content" className="skip-link">
        {s.skip}
      </a>
      <aside className="sidebar">
        <a href="#content" className="brand">
          <span className="brand-mark" aria-hidden="true">
            h<span>o</span>
          </span>
          <span>
            {s.brand}
            <small>{s.brandCaption}</small>
          </span>
        </a>
        <p className="nav-caption">{s.workspace}</p>
        <nav aria-label={s.navigation}>
          {(Object.keys(icons) as PlanningSection[]).map((key) => (
            <button
              key={key}
              aria-current={section === key ? "page" : undefined}
              onClick={() => setSection(key)}
            >
              <span className="nav-icon" aria-hidden="true">
                {icons[key]}
              </span>
              {key === "onsite" || key === "tasks" ? w[key] : p[key]}
              <span className="nav-arrow" aria-hidden="true">
                ›
              </span>
            </button>
          ))}
        </nav>
        <div className="sidebar-note">
          <div aria-hidden="true" className="route-line">
            PT <span>············</span> CH
          </div>
          <p>{s.independent}</p>
        </div>
      </aside>
      <div className="main-wrap">
        <header className="topbar">
          <span>
            {s.workspace}
            <span className="breadcrumb">
              {" "}
              /{" "}
              {section === "onsite" || section === "tasks"
                ? w[section]
                : p[section]}
            </span>
          </span>
          <span className="stage">{s.locations}</span>
        </header>
        <main id="content" tabIndex={-1}>
          <div className="intro">
            <p className="eyebrow">{s.brandCaption}</p>
            <h1>
              {section === "calendar"
                ? p.title
                : section === "requests"
                  ? p.requests
                  : section === "onsite" || section === "tasks"
                    ? w[section]
                    : p.settingsTitle}
            </h1>
            <p>
              {section === "onsite"
                ? w.onsiteIntro
                : section === "tasks"
                  ? w.taskIntro
                  : member?.isManager
                    ? p.teamIntro
                    : p.intro}
            </p>
          </div>
          <PlanningWorkspace section={section} onSection={setSection} />
          {section === "settings" && (
            <div className="settings-connection">
              <ConnectionCard />
            </div>
          )}
          <p className="scope-note">{p.plannedFeatures}</p>
        </main>
        <footer>
          {s.footer}
          <span>HomeOffice · 0.1</span>
        </footer>
      </div>
    </div>
  );
}
