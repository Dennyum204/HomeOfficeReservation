import { useContext } from "react";
import { strings as s, useLanguage } from "../../i18n/locale";
import { sidebarCopy } from "../../i18n/sidebar";
import { SessionActionsContext, useMember } from "./session";

export function AccountSettings() {
  const language = useLanguage();
  const member = useMember();
  const actions = useContext(SessionActionsContext);
  if (!member || !actions) return null;
  return (
    <section className="account-settings" aria-label={s.auth.account}>
      <h2>{sidebarCopy[language].account}</h2>
      <p>{s.auth.signedInAs}</p>
      <strong>{member.displayName}</strong>
      <p>{member.email}</p>
      <p>{member.organizationName}</p>
      <p>
        {[
          member.isEmployee && s.auth.employee,
          member.isManager && s.auth.manager,
          member.isAccountAdministrator && s.auth.admin,
        ]
          .filter(Boolean)
          .join(" · ")}
      </p>
      <div className="account-actions">
        <button disabled={actions.busy} onClick={actions.check}>
          {s.auth.check}
        </button>
        <button disabled={actions.busy} onClick={actions.logout}>
          {s.auth.logout}
        </button>
      </div>
      {actions.message && <p role="alert">{actions.message}</p>}
    </section>
  );
}
