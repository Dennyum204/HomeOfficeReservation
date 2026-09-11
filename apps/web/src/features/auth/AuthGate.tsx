import { useCallback, useEffect, useRef, useState } from "react";
import type { ReactNode } from "react";
import type { MemberProfile } from "../../../../../contracts/typescript";
import { strings as s } from "../../i18n/pt-PT";
import { Appearance } from "../../theme/Appearance";
import { accessApi, authApi, csrf, statusOf } from "./api";
import {
  clearPlanningSession,
  MemberContext,
  OWNER_KEY,
  SESSION_EVENT,
} from "./session";

type Mode = "login" | "activation" | "recovery" | "activate" | "reset";
export function AuthGate({ children }: { children: ReactNode }) {
  const [member, setMember] = useState<MemberProfile>();
  const [loading, setLoading] = useState(true);
  const [busy, setBusy] = useState(false);
  const [mode, setMode] = useState<Mode>("login");
  const [message, setMessage] = useState("");
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [code, setCode] = useState("");
  const generation = useRef(0);
  const check = useCallback(async (initial = false) => {
    // Only the latest session read may update private views, even if HTTP responses arrive out of order.
    const current = ++generation.current;
    try {
      const profile = await accessApi.getCurrentMember();
      if (current === generation.current) {
        try {
          const previous = sessionStorage.getItem(OWNER_KEY);
          if (previous && previous !== profile.memberId) clearPlanningSession();
          sessionStorage.setItem(OWNER_KEY, profile.memberId);
        } catch {
          /* Auth remains usable when browser storage is unavailable. */
        }
        setMember(profile);
        setMessage("");
      }
    } catch (error) {
      if (current !== generation.current) return;
      const status = statusOf(error);
      // Remove account-specific views on any unverifiable session. Offline is explicit.
      setMember(undefined);
      setMessage(
        status === 401
          ? initial
            ? ""
            : s.auth.expired
          : status === 403
            ? s.auth.forbidden
            : s.auth.network,
      );
    } finally {
      if (current === generation.current) setLoading(false);
    }
  }, []);
  useEffect(() => {
    // Synchronize with the remote session; all state updates happen after the HTTP response.
    // eslint-disable-next-line react-hooks/set-state-in-effect
    void check(true);
    const sessionGeneration = generation;
    const focus = () => {
      void check();
    };
    window.addEventListener("focus", focus);
    window.addEventListener(SESSION_EVENT, focus);
    return () => {
      sessionGeneration.current++;
      window.removeEventListener("focus", focus);
      window.removeEventListener(SESSION_EVENT, focus);
    };
  }, [check]);
  async function submit(event: React.FormEvent) {
    event.preventDefault();
    setBusy(true);
    setMessage("");
    generation.current++;
    try {
      if (mode === "login") {
        await authApi.loginWeb(
          { credentials: { email, password } },
          await csrf(),
        );
        setPassword("");
        setCode("");
        await check();
      } else if (mode === "activation" || mode === "recovery") {
        const operation =
          mode === "activation" ? "requestActivation" : "requestRecovery";
        await authApi[operation]({ emailRequest: { email } });
        setMessage(s.auth.sent);
        setMode(mode === "activation" ? "activate" : "reset");
      } else {
        const operation =
          mode === "activate" ? "activateAccount" : "resetPassword";
        await authApi[operation]({
          completeAccountRequest: { email, code, password },
        });
        setPassword("");
        setCode("");
        setMode("login");
        setMessage(s.auth.completed);
      }
    } catch (error) {
      const status = statusOf(error);
      setMessage(
        status === 429
          ? s.auth.limited
          : status === 0 || status >= 500
            ? s.auth.network
            : mode === "login"
              ? s.auth.invalid
              : s.auth.invalidCode,
      );
    } finally {
      setBusy(false);
    }
  }
  async function logout() {
    setBusy(true);
    generation.current++;
    try {
      await authApi.logout(await csrf());
      // Also invalidate reads started while the logout request was in flight.
      generation.current++;
      clearPlanningSession();
      setMember(undefined);
      setPassword("");
      setCode("");
      setMessage("");
    } catch {
      setMessage(s.auth.logoutFailed);
    } finally {
      setBusy(false);
    }
  }
  const switchMode = (next: Mode) => {
    setMode(next);
    setPassword("");
    setCode("");
    setMessage("");
  };
  if (loading)
    return (
      <main className="auth-page" role="status">
        {s.auth.loading}
      </main>
    );
  if (member)
    return (
      <>
        <section className="account-bar" aria-label={s.auth.account}>
          <div>
            <span>{s.auth.signedInAs}</span>
            <strong>{member.displayName}</strong>
            <span>
              {member.organizationName} ·{" "}
              {[
                member.isEmployee && s.auth.employee,
                member.isManager && s.auth.manager,
                member.isAccountAdministrator && s.auth.admin,
              ]
                .filter(Boolean)
                .join(" · ")}
            </span>
          </div>
          <button
            disabled={busy}
            onClick={() => {
              void check();
            }}
          >
            {s.auth.check}
          </button>
          <button
            disabled={busy}
            onClick={() => {
              void logout();
            }}
          >
            {s.auth.logout}
          </button>
          {message && <p role="alert">{message}</p>}
        </section>
        <MemberContext.Provider key={member.memberId} value={member}>
          {children}
        </MemberContext.Provider>
      </>
    );
  return (
    <main className="auth-page">
      <section className="auth-card">
        <Appearance compact />
        <p className="eyebrow">HOME OFFICE · PORTUGAL / SUÍÇA</p>
        <h1>{s.auth.titles[mode]}</h1>
        <p>{s.auth.intro}</p>
        {message && (
          <p role="status" className="auth-message">
            {message}
          </p>
        )}
        <form
          onSubmit={(event) => {
            void submit(event);
          }}
        >
          <label>
            {s.auth.email}
            <input
              name="email"
              type="email"
              autoComplete="username"
              required
              maxLength={254}
              value={email}
              onChange={(event) => setEmail(event.target.value)}
            />
          </label>
          {(mode === "activate" || mode === "reset") && (
            <label>
              {s.auth.code}
              <textarea
                name="code"
                required
                autoComplete="off"
                value={code}
                onChange={(event) => setCode(event.target.value)}
              />
            </label>
          )}
          {(mode === "login" || mode === "activate" || mode === "reset") && (
            <label>
              {s.auth.password}
              <input
                name="password"
                type="password"
                autoComplete={
                  mode === "login" ? "current-password" : "new-password"
                }
                required
                maxLength={256}
                value={password}
                onChange={(event) => setPassword(event.target.value)}
              />
            </label>
          )}
          {(mode === "activate" || mode === "reset") && (
            <p>{s.auth.passwordHelp}</p>
          )}
          <button className="primary" disabled={busy}>
            {busy ? s.auth.wait : s.auth.submit[mode]}
          </button>
        </form>
        <nav className="auth-links" aria-label={s.auth.account}>
          {mode === "activation" && (
            <button disabled={busy} onClick={() => switchMode("activate")}>
              {s.auth.haveCode}
            </button>
          )}
          {mode !== "login" && (
            <button disabled={busy} onClick={() => switchMode("login")}>
              {s.auth.back}
            </button>
          )}
          {mode === "login" && (
            <>
              <button onClick={() => switchMode("activation")}>
                {s.auth.activateLink}
              </button>
              <button onClick={() => switchMode("recovery")}>
                {s.auth.recoverLink}
              </button>
            </>
          )}
        </nav>
        <p className="muted">{s.auth.controlled}</p>
      </section>
    </main>
  );
}
