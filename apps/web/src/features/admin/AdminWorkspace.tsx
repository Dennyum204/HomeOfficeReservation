import { useEffect, useRef, useState } from "react";
import type {
  InvitationProfile,
  ProvisionMemberRequest,
  UpdateMemberRequest,
} from "../../../../../contracts/typescript";
import { accessApi, statusOf } from "../auth/api";
import { useMember } from "../auth/session";
import { Dialog } from "../planning/shared";
import { a } from "../../i18n/admin.pt-PT";
import { useRead } from "../planning/useRead";
import { useAdminCommand } from "./useAdminCommand";
import type { Intent } from "./api";
import "./admin.css";

const date = (value?: Date | null) =>
  value
    ? new Intl.DateTimeFormat("pt-PT", {
        dateStyle: "short",
        timeStyle: "short",
      }).format(value)
    : a.timestampNone;
const roleNames = (
  member: Pick<
    InvitationProfile,
    "isEmployee" | "isManager" | "isAccountAdministrator"
  >,
) =>
  [
    member.isEmployee && a.employee,
    member.isManager && a.manager,
    member.isAccountAdministrator && a.admin,
  ]
    .filter(Boolean)
    .join(" · ") || a.noRoles;
type Confirmation = {
  intent: Intent;
  title: string;
  name: string;
  impact: string;
  summary?: string;
};

async function readMembers(signal: AbortSignal) {
  const result: InvitationProfile[] = [];
  let after: string | undefined;
  do {
    const page = await accessApi.listInvitations(
      { after, limit: 100 },
      { signal },
    );
    result.push(...page.members);
    after = page.nextAfter ?? undefined;
  } while (after);
  return result.sort((x, y) =>
    x.displayName.localeCompare(y.displayName, "pt"),
  );
}

export function AdminWorkspace() {
  const actor = useMember();
  return actor?.active && actor.isAccountAdministrator ? (
    <Administration key={actor.memberId} actorId={actor.memberId} />
  ) : (
    <p role="alert">{a.forbidden}</p>
  );
}

function Administration({ actorId }: { actorId: string }) {
  const [revision, setRevision] = useState(0);
  const snapshot = useRead(`${actorId}:${revision}`, readMembers, actorId);
  const members = snapshot.data ?? [];
  const loading = snapshot.loading;
  const error = snapshot.error
    ? statusOf(snapshot.error) === 403
      ? a.forbidden
      : a.readError
    : "";
  const [query, setQuery] = useState("");
  const [visible, setVisible] = useState(20);
  const [selectedId, setSelectedId] = useState<string>();
  const [selection, setSelection] = useState(0);
  const [invite, setInvite] = useState(false);
  const [inviteDraft, setInviteDraft] = useState<ProvisionMemberRequest>({
    displayName: "",
    email: "",
    isEmployee: true,
    isManager: false,
    isAccountAdministrator: false,
  });
  const [confirmation, setConfirmation] = useState<Confirmation>();
  const heading = useRef<HTMLHeadingElement>(null);
  const load = () => setRevision((v) => v + 1);
  const command = useAdminCommand(actorId, () => {
    setInvite(false);
    void load();
  });
  const selected = members.find((m) => m.memberId === selectedId);
  const filtered = members.filter((m) =>
    `${m.displayName} ${m.email}`
      .toLocaleLowerCase("pt")
      .includes(query.toLocaleLowerCase("pt")),
  );
  function ask(
    intent: Intent,
    title: string,
    name: string,
    impact: string,
    summary?: string,
  ) {
    setConfirmation({ intent, title, name, impact, summary });
  }
  function closeDetail() {
    setSelectedId(undefined);
    requestAnimationFrame(() => heading.current?.focus());
  }
  return (
    <section className="admin-workspace" aria-label={a.title}>
      <div className="admin-toolbar">
        <h2 ref={heading} tabIndex={-1}>
          {a.members}
        </h2>
        <div className="admin-actions">
          <button
            className="primary"
            disabled={command.locked || loading || !!error}
            onClick={() => setInvite(true)}
          >
            {a.invite}
          </button>
          <button
            disabled={loading || command.busy}
            onClick={() => void load()}
          >
            {a.refresh}
          </button>
        </div>
      </div>
      {command.message && (
        <p role="status" className="admin-notice">
          {command.message}
        </p>
      )}
      {command.journal && (
        <div role="alert" className="admin-notice">
          <p>{a.uncertain}</p>
          <p>{command.journal.label}</p>
          <button
            disabled={command.busy}
            onClick={() => void command.recover()}
          >
            {command.busy ? a.busy : a.recover}
          </button>
        </div>
      )}
      {loading && <p role="status">{a.loading}</p>}
      {error && <p role="alert">{error}</p>}
      {!loading && !error && (
        <>
          <label className="admin-search">
            {a.search}
            <input
              type="search"
              value={query}
              onChange={(e) => {
                setQuery(e.target.value);
                setVisible(20);
              }}
            />
          </label>
          <div className="admin-layout">
            {selected && (
              <section className="admin-detail" aria-label={a.selected}>
                <button onClick={closeDetail}>{a.close}</button>
                <MemberDetails
                  key={`${selected.memberId}:${selected.accessVersion}:${selected.version}:${selection}`}
                  member={selected}
                  members={members}
                  self={selected.memberId === actorId}
                  locked={command.locked}
                  ask={ask}
                />
              </section>
            )}
            <div className="admin-list">
              {!filtered.length && <p>{a.empty}</p>}
              {filtered.slice(0, visible).map((member) => (
                <article className="admin-card" key={member.memberId}>
                  <h3>
                    {member.displayName}
                    {member.memberId === actorId && <small> · {a.you}</small>}
                  </h3>
                  <p>{member.email}</p>
                  <p>{roleNames(member)}</p>
                  <div className="admin-badges">
                    <span>{member.active ? a.enabled : a.suspended}</span>
                    <span>{a.state[member.state] ?? a.unknown}</span>
                  </div>
                  <p>
                    <strong>{a.currentManager}: </strong>
                    {members.find((m) => m.memberId === member.managerId)
                      ?.displayName ?? a.none}
                  </p>
                  <button
                    aria-label={`${a.detail}: ${member.displayName}`}
                    onClick={() => {
                      setSelectedId(member.memberId);
                      setSelection((v) => v + 1);
                    }}
                  >
                    {a.detail}
                  </button>
                </article>
              ))}
              {filtered.length > visible && (
                <button onClick={() => setVisible((v) => v + 20)}>
                  {a.more}
                </button>
              )}
            </div>
          </div>
        </>
      )}
      {invite && (
        <Dialog
          title={a.invite}
          onClose={() => setInvite(false)}
          locked={command.busy}
        >
          <InviteForm
            locked={command.locked}
            initial={inviteDraft}
            onDraft={setInviteDraft}
            onReview={(input) =>
              ask(
                {
                  operation: "provisionMember",
                  input: { provisionMemberRequest: input },
                },
                a.invite,
                `${input.displayName} · ${input.email}`,
                a.inviteImpact,
                roleNames(input),
              )
            }
          />
        </Dialog>
      )}
      {confirmation && (
        <Dialog
          title={a.confirmTitle}
          onClose={() => setConfirmation(undefined)}
        >
          <h3>{confirmation.title}</h3>
          <p>{confirmation.name}</p>
          <p>{confirmation.summary}</p>
          <p>{confirmation.impact}</p>
          <div className="admin-actions">
            <button onClick={() => setConfirmation(undefined)}>{a.back}</button>
            <button
              className="primary"
              onClick={() => {
                const current = confirmation;
                setConfirmation(undefined);
                setInvite(false);
                void command.run(
                  current.intent,
                  `${current.title}: ${current.name}`,
                );
              }}
            >
              {a.confirm}
            </button>
          </div>
        </Dialog>
      )}
    </section>
  );
}

function Roles({
  value,
  onChange,
  disabled,
  access = false,
}: {
  value: UpdateMemberRequest;
  onChange: (value: UpdateMemberRequest) => void;
  disabled: boolean;
  access?: boolean;
}) {
  return (
    <fieldset disabled={disabled}>
      <legend>{a.roles}</legend>
      {(
        [
          ...(access ? [["active", a.active]] : []),
          ["isEmployee", a.employee],
          ["isManager", a.manager],
          ["isAccountAdministrator", a.admin],
        ] as [
          "active" | "isEmployee" | "isManager" | "isAccountAdministrator",
          string,
        ][]
      ).map(([key, label]) => (
        <label className="admin-check" key={key}>
          <input
            type="checkbox"
            checked={value[key]}
            onChange={(e) => onChange({ ...value, [key]: e.target.checked })}
          />
          {label}
        </label>
      ))}
    </fieldset>
  );
}
function InviteForm({
  locked,
  onReview,
  initial,
  onDraft,
}: {
  initial: ProvisionMemberRequest;
  onDraft: (input: ProvisionMemberRequest) => void;
  locked: boolean;
  onReview: (input: ProvisionMemberRequest) => void;
}) {
  const name = initial.displayName;
  const setName = (displayName: string) => onDraft({ ...initial, displayName });
  const email = initial.email;
  const setEmail = (email: string) => onDraft({ ...initial, email });
  const roles: UpdateMemberRequest = { active: true, ...initial };
  const setRoles = (value: UpdateMemberRequest) =>
    onDraft({
      ...initial,
      isEmployee: value.isEmployee,
      isManager: value.isManager,
      isAccountAdministrator: value.isAccountAdministrator,
    });
  return (
    <form
      className="admin-form"
      onSubmit={(e) => {
        e.preventDefault();
        onReview({
          displayName: name.trim(),
          email: email.trim(),
          isEmployee: roles.isEmployee,
          isManager: roles.isManager,
          isAccountAdministrator: roles.isAccountAdministrator,
        });
      }}
    >
      <fieldset disabled={locked}>
        <legend>{a.identity}</legend>
        <label>
          {a.name}
          <input
            required
            maxLength={120}
            value={name}
            onChange={(e) => setName(e.target.value)}
          />
        </label>
        <label>
          {a.email}
          <input
            required
            type="email"
            maxLength={254}
            value={email}
            onChange={(e) => setEmail(e.target.value)}
          />
        </label>
      </fieldset>
      <Roles value={roles} onChange={setRoles} disabled={locked} />
      <button className="primary" disabled={locked}>
        {a.sendInvite}
      </button>
    </form>
  );
}
function MemberDetails({
  member,
  members,
  self,
  locked,
  ask,
}: {
  member: InvitationProfile;
  members: InvitationProfile[];
  self: boolean;
  locked: boolean;
  ask: (
    intent: Intent,
    title: string,
    name: string,
    impact: string,
    summary?: string,
  ) => void;
}) {
  const heading = useRef<HTMLHeadingElement>(null);
  useEffect(() => {
    heading.current?.focus();
  }, [member.memberId]);
  const [roles, setRoles] = useState<UpdateMemberRequest>({
    active: member.active,
    isEmployee: member.isEmployee,
    isManager: member.isManager,
    isAccountAdministrator: member.isAccountAdministrator,
  });
  const [managerId, setManagerId] = useState(member.managerId ?? "");
  const [now, setNow] = useState(() => Date.now());
  useEffect(() => {
    const timer = window.setInterval(() => setNow(Date.now()), 10000);
    return () => window.clearInterval(timer);
  }, []);
  const manager = members.find((m) => m.memberId === member.managerId);
  return (
    <div className="admin-form">
      <h2 tabIndex={-1} ref={heading}>
        {member.displayName}
      </h2>
      <p>{member.email}</p>
      <section>
        <h3>{a.invitation}</h3>
        <p>
          <span className="admin-badge">
            {a.state[member.state] ?? a.unknown}
          </span>
        </p>
        <h4>{a.delivery}</h4>
        <p>{a.deliveries[member.deliveryState] ?? a.unknown}</p>
        <p>{a.deliveryHelp}</p>
        <p>
          {a.attempts}: {member.deliveryAttempts}
        </p>
        {(member.deliveryError || member.deliveryState === "Failed") && (
          <p role="status">{a.failureHelp}</p>
        )}
        {member.state === "Pending" && (
          <>
            <p>
              {member.codeExpiresAt && member.codeExpiresAt.getTime() <= now
                ? a.codeExpired
                : `${a.codeValid}: ${date(member.codeExpiresAt)}`}
            </p>
            <p>
              {a.resendAt}: {date(member.resendAvailableAt)}
            </p>
            <div className="admin-actions">
              <button
                disabled={
                  locked ||
                  self ||
                  !member.active ||
                  !member.resendAvailableAt ||
                  member.resendAvailableAt.getTime() > now
                }
                onClick={() =>
                  ask(
                    {
                      operation: "resendInvitation",
                      input: {
                        memberId: member.memberId,
                        invitationChangeRequest: {
                          commandId: crypto.randomUUID(),
                          expectedVersion: member.version,
                        },
                      },
                    },
                    a.resend,
                    member.displayName,
                    a.resendImpact,
                  )
                }
              >
                {a.resend}
              </button>
              <button
                disabled={locked || self}
                onClick={() =>
                  ask(
                    {
                      operation: "cancelInvitation",
                      input: {
                        memberId: member.memberId,
                        invitationChangeRequest: {
                          commandId: crypto.randomUUID(),
                          expectedVersion: member.version,
                        },
                      },
                    },
                    a.cancel,
                    member.displayName,
                    a.cancelImpact,
                  )
                }
              >
                {a.cancel}
              </button>
            </div>
          </>
        )}
      </section>
      {self && <p className="admin-notice">{a.self}</p>}
      <form
        onSubmit={(e) => {
          e.preventDefault();
          ask(
            {
              operation: "updateMember",
              input: {
                memberId: member.memberId,
                updateMemberRequest: {
                  ...roles,
                  expectedAccessVersion: member.accessVersion,
                  commandId: crypto.randomUUID(),
                },
              },
            },
            a.saveRoles,
            member.displayName,
            a.roleImpact +
              (member.state === "Pending" ? " " + a.pendingImpact : ""),
            `${roleNames(roles)} · ${roles.active ? a.enabled : a.suspended}`,
          );
        }}
      >
        <Roles
          value={roles}
          onChange={setRoles}
          disabled={locked || self}
          access
        />
        {!self && <button disabled={locked}>{a.saveRoles}</button>}
      </form>
      <section>
        <h3>{a.relationship}</h3>
        <p>
          {a.currentManager}: {manager?.displayName ?? a.none}
        </p>
        {member.managerId && !member.managerRelationshipValid && (
          <p role="status">{a.unavailableManager}</p>
        )}
        <p>{a.relationshipHelp}</p>
        <form
          onSubmit={(e) => {
            e.preventDefault();
            ask(
              {
                operation: "assignManager",
                input: {
                  employeeId: member.memberId,
                  setManagerRequest: {
                    managerId: managerId || null,
                    expectedAccessVersion: member.accessVersion,
                    commandId: crypto.randomUUID(),
                  },
                },
              },
              a.saveManager,
              member.displayName,
              a.relationImpact,
              `${manager?.displayName ?? a.none} → ${members.find((m) => m.memberId === managerId)?.displayName ?? a.none}`,
            );
          }}
        >
          <label>
            {a.selectManager}
            <select
              aria-label={a.selectManager}
              disabled={locked}
              value={managerId}
              onChange={(e) => setManagerId(e.target.value)}
            >
              <option value="">{a.none}</option>
              {members
                .filter(
                  (m) =>
                    (m.active &&
                      m.isManager &&
                      m.memberId !== member.memberId) ||
                    m.memberId === member.managerId,
                )
                .map((m) => (
                  <option key={m.memberId} value={m.memberId}>
                    {m.displayName}
                    {!m.active || !m.isManager
                      ? ` · ${a.unavailableManager}`
                      : ""}
                  </option>
                ))}
            </select>
          </label>
          <button disabled={locked}>{a.saveManager}</button>
        </form>
      </section>
    </div>
  );
}
