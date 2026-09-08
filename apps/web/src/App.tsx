import { useState } from "react";
import { strings as s } from "./i18n/pt-PT";
import { ConnectionCard } from "./features/workspace/ConnectionCard";

import { AuthGate } from "./features/auth/AuthGate";

export function App() {
  return (
    <AuthGate>
      <WorkspaceShell />
    </AuthGate>
  );
}

type Section = keyof typeof s.nav;
const icons: Record<Section, string> = {
  calendar: "▦",
  requests: "↗",
  tasks: "☑",
  notifications: "◉",
  settings: "⚙",
};

export function WorkspaceShell() {
  const [section, setSection] = useState<Section>("calendar");
  const current = s.sections[section];
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
          {(Object.keys(s.nav) as Section[]).map((key) => (
            <button
              key={key}
              aria-current={section === key ? "page" : undefined}
              onClick={() => setSection(key)}
            >
              <span className="nav-icon" aria-hidden="true">
                {icons[key]}
              </span>
              {s.nav[key]}
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
            <span className="breadcrumb"> / {s.nav[section]}</span>
          </span>
          <span className="stage">
            <span aria-hidden="true" />
            {s.foundation}
          </span>
        </header>
        <main id="content" tabIndex={-1}>
          <div className="intro">
            <p className="eyebrow">HOME OFFICE RESERVATION</p>
            <h1>{s.welcome}</h1>
            <p>{s.introduction}</p>
          </div>
          <div className="workspace-grid">
            <section className="feature-card" aria-labelledby="section-title">
              <p className="eyebrow">{current.eyebrow}</p>
              <h2 id="section-title">{current.title}</h2>
              <p className="feature-description">{current.description}</p>
              <div className="location-illustration" aria-hidden="true">
                <div className="sun" />
                <div className="hill hill-back" />
                <div className="hill hill-front" />
                <div className="house">
                  <div className="roof" />
                  <div className="window" />
                  <div className="door" />
                </div>
                <div className="mountain mountain-back" />
                <div className="mountain" />
                <div className="illustration-line" />
                <span className="place place-pt">PT</span>
                <span className="place place-ch">CH</span>
              </div>
              <div className="unfinished">
                <span className="unfinished-icon" aria-hidden="true">
                  ◷
                </span>
                <div>
                  <h3>{current.step}</h3>
                  <p>{current.detail}</p>
                </div>
              </div>
            </section>
            <div className="right-column">
              <ConnectionCard />
              <section className="location-card">
                <p className="eyebrow">PORTUGAL ↔ SUÍÇA</p>
                <h2>{s.locations}</h2>
                <div className="location-label">
                  <span className="country-symbol" aria-hidden="true">
                    ⌂
                  </span>
                  {s.remote}
                </div>
                <div className="location-label">
                  <span className="country-symbol swiss" aria-hidden="true">
                    +
                  </span>
                  {s.onsite}
                </div>
                <p className="muted">{s.locationsDetail}</p>
              </section>
            </div>
          </div>
          <p className="scope-note">
            <span aria-hidden="true">ⓘ</span>
            {s.scope}
          </p>
        </main>
        <footer>
          {s.footer}
          <span>HomeOffice · 0.1</span>
        </footer>
      </div>
    </div>
  );
}
