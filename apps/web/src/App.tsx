import { AdminWorkspace } from "./features/admin/AdminWorkspace";
import { a } from "./i18n/admin.pt-PT";
import { useState } from "react";
import { strings as s } from "./i18n/pt-PT";
import { p } from "./i18n/planning.pt-PT";
import { w } from "./i18n/work.pt-PT";
import { n } from "./i18n/notifications.pt-PT";
import type { NotificationDestination } from "../../../contracts/typescript";
import { NotificationCentre } from "./features/notifications/NotificationCentre";
import { useNotificationPolling } from "./features/notifications/useNotificationPolling";
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
type ShellSection = PlanningSection | "notifications" | "administration";
const icons: Record<ShellSection, string> = {
  administration: "♧",
  calendar: "▦",
  requests: "↗",
  onsite: "▣",
  tasks: "☑",
  notifications: "🔔",
  settings: "⚙",
};
export function WorkspaceShell() {
  const [section, setSection] = useState<ShellSection>("calendar");
  const [launch, setLaunch] = useState<{
    key: number;
    destination: NotificationDestination;
  }>();
  const inbox = useNotificationPolling();
  const member = useMember();
  const label = (key: ShellSection) =>
    key === "administration"
      ? a.title
      : key === "notifications"
        ? n.title
        : key === "onsite" || key === "tasks"
          ? w[key]
          : p[key];
  function openNotification(destination: NotificationDestination) {
    setLaunch((old) => ({ key: (old?.key ?? 0) + 1, destination }));
    setSection(
      destination.kind === "Requirement"
        ? "onsite"
        : destination.kind === "Task"
          ? "tasks"
          : "requests",
    );
  }
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
          {(Object.keys(icons) as ShellSection[])
            .filter(
              (key) =>
                key !== "administration" ||
                (member?.active && member.isAccountAdministrator),
            )
            .map((key) => (
              <button
                key={key}
                aria-current={section === key ? "page" : undefined}
                onClick={() => setSection(key)}
              >
                <span className="nav-icon" aria-hidden="true">
                  {icons[key]}
                </span>
                {label(key)}
                {key === "notifications" && (
                  <span className="notification-badge" aria-label={n.unread}>
                    {inbox.count}
                  </span>
                )}
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
            <span className="breadcrumb"> / {label(section)}</span>
          </span>
          <span className="stage">{s.locations}</span>
        </header>
        <main id="content" tabIndex={-1}>
          <div className="intro">
            <p className="eyebrow">{s.brandCaption}</p>
            <h1>
              {section === "administration"
                ? a.title
                : section === "notifications"
                  ? n.title
                  : section === "calendar"
                    ? p.title
                    : section === "requests"
                      ? p.requests
                      : section === "onsite" || section === "tasks"
                        ? w[section]
                        : p.settingsTitle}
            </h1>
            <p>
              {section === "administration"
                ? a.intro
                : section === "notifications"
                  ? n.intro
                  : section === "onsite"
                    ? w.onsiteIntro
                    : section === "tasks"
                      ? w.taskIntro
                      : member?.isManager
                        ? p.teamIntro
                        : p.intro}
            </p>
          </div>
          <div
            hidden={section === "notifications" || section === "administration"}
          >
            <PlanningWorkspace
              key={launch?.key ?? 0}
              initialDestination={launch?.destination}
              section={
                section === "notifications" || section === "administration"
                  ? "calendar"
                  : section
              }
              onSection={setSection}
            />
          </div>
          {section === "administration" && <AdminWorkspace />}
          {section === "notifications" && (
            <NotificationCentre
              tick={inbox.tick}
              refresh={inbox.refresh}
              onOpen={openNotification}
            />
          )}
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
