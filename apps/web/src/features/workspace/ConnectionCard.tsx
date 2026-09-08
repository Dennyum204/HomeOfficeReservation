import { useEffect, useState } from "react";
import type { WorkspaceInfo } from "../../../../../contracts/typescript";
import { workspaceApi } from "./api";
import { strings as s } from "../../i18n/pt-PT";

export function ConnectionCard() {
  const [attempt, setAttempt] = useState(0);
  const [state, setState] = useState<{
    status: "loading" | "error" | "success";
    data?: WorkspaceInfo;
  }>({ status: "loading" });
  useEffect(() => {
    const controller = new AbortController();
    const timeout = setTimeout(() => controller.abort(), 8000);
    let active = true;
    workspaceApi
      .getWorkspaceInfo({ signal: controller.signal })
      .then((data) => {
        if (active) setState({ status: "success", data });
      })
      .catch(() => {
        if (active) setState({ status: "error" });
      })
      .finally(() => clearTimeout(timeout));
    return () => {
      active = false;
      clearTimeout(timeout);
      controller.abort();
    };
  }, [attempt]);
  return (
    <section className="connection-card" aria-labelledby="connection-title">
      <div className="card-heading">
        <span className="connection-icon" aria-hidden="true">
          ↗
        </span>
        <h2 id="connection-title">{s.connectionTitle}</h2>
      </div>
      <div role="status" aria-live="polite">
        <p className={`connection-state ${state.status}`}>
          <span aria-hidden="true" className="status-dot" />
          {state.status === "loading"
            ? s.connecting
            : state.status === "error"
              ? s.offline
              : s.connected}
        </p>
        {state.status === "error" && <p className="muted">{s.offlineHelp}</p>}
        {state.data && (
          <dl>
            <dt>{s.received}</dt>
            <dd>
              <time dateTime={state.data.serverTimeUtc.toISOString()}>
                {new Intl.DateTimeFormat("pt-PT", {
                  dateStyle: "short",
                  timeStyle: "medium",
                }).format(state.data.serverTimeUtc)}
              </time>
            </dd>
            <dt>{s.timeZones}</dt>
            <dd>{state.data.planningTimeZones.join(" · ")}</dd>
          </dl>
        )}
      </div>
      <button
        className="connection-button"
        disabled={state.status === "loading"}
        onClick={() => {
          setState({ status: "loading" });
          setAttempt(attempt + 1);
        }}
      >
        {state.status === "error" ? s.retry : s.refresh}
        <span aria-hidden="true">↻</span>
      </button>
    </section>
  );
}
