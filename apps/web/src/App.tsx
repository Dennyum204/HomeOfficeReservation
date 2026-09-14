import { useLanguage } from "./i18n/locale";
import { LanguagePicker } from "./i18n/LanguagePicker";
import { sidebarCopy } from "./i18n/sidebar";
import { ContextRead } from "./features/notifications/contextRead";
import { notificationsApi } from "./features/notifications/api";
import { csrf } from "./features/auth/api";
import { sessionFailure } from "./features/planning/api";
import { AdminWorkspace } from "./features/admin/AdminWorkspace";
import { a } from "./i18n/locale";
import { Appearance, AppearanceProvider } from "./theme/Appearance";
import { AppIcon } from "./theme/AppIcon";
import { useCallback, useEffect, useRef, useState } from "react";
import { strings as s } from "./i18n/locale";
import { p } from "./i18n/locale";
import { w } from "./i18n/locale";
import { n } from "./i18n/locale";
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
import "./theme/theme.css";
import "./theme/sidebar.css";

export function App() {
  useLanguage();
  return (
    <AppearanceProvider>
      <AuthGate>
        <WorkspaceShell />
      </AuthGate>
    </AppearanceProvider>
  );
}
type ShellSection = PlanningSection | "notifications" | "administration";
const sections: ShellSection[] = [
  "calendar",
  "requests",
  "onsite",
  "tasks",
  "notifications",
  "settings",
  "administration",
];
export function WorkspaceShell() {
  const language = useLanguage();
  const [collapsed, setCollapsed] = useState(false);
  const navigationCopy = sidebarCopy[language];
  const currentSection = (): ShellSection => {
    const path = window.location.pathname.slice(1);
    return sections.includes(path as ShellSection)
      ? (path as ShellSection)
      : "calendar";
  };
  const [section, updateSection] = useState<ShellSection>(currentSection);
  useEffect(() => {
    const onPopState = () => updateSection(currentSection());
    window.addEventListener("popstate", onPopState);
    return () => window.removeEventListener("popstate", onPopState);
  }, []);
  function setSection(value: ShellSection) {
    if (window.location.pathname !== `/${value}`)
      window.history.pushState(null, "", `/${value}`);
    updateSection(value);
  }
  const [launch, setLaunch] = useState<{
    key: number;
    destination: NotificationDestination;
    notificationId: string;
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
  const reading = useRef<string | null>(null);
  const [readError, setReadError] = useState(false);
  const contextOpened = useCallback(
    (id: string) => {
      if (
        !launch ||
        launch.destination.resourceId !== id ||
        reading.current === launch.notificationId
      )
        return;
      const notificationId = launch.notificationId;
      reading.current = notificationId;
      void (async () => {
        try {
          await notificationsApi.setNotificationRead(
            { notificationId, notificationReadInput: { read: true } },
            await csrf(),
          );
          if (reading.current !== notificationId) return;
          setReadError(false);
          inbox.refresh();
        } catch (error) {
          if (reading.current !== notificationId) return;
          sessionFailure(error);
          setReadError(true);
        }
      })();
    },
    [launch, inbox],
  );
  function openNotification(
    destination: NotificationDestination,
    notificationId: string,
  ) {
    reading.current = null;
    setReadError(false);
    setLaunch((old) => ({
      key: (old?.key ?? 0) + 1,
      destination,
      notificationId,
    }));
    setSection(
      destination.kind === "Requirement"
        ? "onsite"
        : destination.kind === "Task"
          ? "tasks"
          : "requests",
    );
  }
  return (
    <div className={`app-shell${collapsed ? " sidebar-collapsed" : ""}`}>
      <a href="#content" className="skip-link">
        {s.skip}
      </a>
      <aside className="sidebar">
        <div className="sidebar-heading">
          <a href="#content" className="brand" aria-label={s.brand}>
            <span className="brand-mark" aria-hidden="true">
              h<span>o</span>
            </span>
            <span className="brand-copy">
              {s.brand}
              <small>{s.brandCaption}</small>
            </span>
          </a>
          <button
            type="button"
            className="sidebar-toggle"
            aria-expanded={!collapsed}
            aria-controls="workspace-navigation"
            aria-label={
              collapsed ? navigationCopy.expand : navigationCopy.collapse
            }
            title={collapsed ? navigationCopy.expand : navigationCopy.collapse}
            onClick={() => setCollapsed((value) => !value)}
          >
            <svg
              viewBox="0 0 24 24"
              width="20"
              height="20"
              fill="none"
              stroke="currentColor"
              strokeWidth="2"
              aria-hidden="true"
            >
              <path d="m14 6-6 6 6 6" />
            </svg>
          </button>
        </div>
        <p className="nav-caption">{s.workspace}</p>
        <nav id="workspace-navigation" aria-label={s.navigation}>
          {sections
            .filter(
              (key) =>
                key !== "administration" ||
                (member?.active && member.isAccountAdministrator),
            )
            .map((key) => (
              <button
                key={key}
                aria-label={collapsed ? label(key) : undefined}
                aria-describedby={
                  collapsed && key === "notifications"
                    ? "navigation-unread-count"
                    : undefined
                }
                title={collapsed ? label(key) : undefined}
                aria-current={section === key ? "page" : undefined}
                onClick={() => setSection(key)}
              >
                <span className="nav-icon" aria-hidden="true">
                  <AppIcon name={key} />
                </span>
                <span className="nav-label">{label(key)}</span>
                {key === "notifications" && (
                  <span
                    id="navigation-unread-count"
                    className="notification-badge"
                    aria-label={n.unread}
                  >
                    {inbox.count}
                  </span>
                )}
              </button>
            ))}
        </nav>
        <div className="sidebar-note">
          <div aria-hidden="true" className="route-line">
            PT <span /> CH
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
          <Appearance compact />
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
            <ContextRead.Provider
              value={
                section === "notifications" || section === "administration"
                  ? () => {}
                  : contextOpened
              }
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
            </ContextRead.Provider>
          </div>
          {readError && (
            <p role="alert">
              {n.readFailed}{" "}
              <button
                onClick={() => {
                  reading.current = null;
                  if (launch) contextOpened(launch.destination.resourceId);
                }}
              >
                {n.retryRead}
              </button>
            </p>
          )}
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
              <LanguagePicker />
              <Appearance />
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
