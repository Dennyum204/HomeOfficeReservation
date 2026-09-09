import { useCallback, useState } from "react";
import type {
  DayInput,
  MemberProfile,
  MutationReceipt,
  ProposalView,
  RequestedDayView,
  RequestState,
  RequestView,
  WorkLocation,
} from "../../../../../contracts/typescript";
import { p } from "../../i18n/planning.pt-PT";
import { accessApi, statusOf } from "../auth/api";
import { EDITOR_KEY, useMember } from "../auth/session";
import { planningApi, readJournal, sessionFailure, type Journal } from "./api";
import { CalendarPanel } from "./CalendarPanel";
import { dateKey, dateValue, dayLabel, period, todayInZone } from "./dates";
import { RequestDetails } from "./RequestDetails";
import { requestCounts } from "./requestCounts";
import { RequestEditor } from "./RequestEditor";
import { restoreEditor } from "./editorState";
import { readError } from "./errors";
import { useCommand } from "./useCommand";
import { CommandNotice } from "./CommandNotice";
import { useRead } from "./useRead";

export type PlanningSection = "calendar" | "requests" | "settings";
export function PlanningWorkspace({
  section,
  onSection,
}: {
  section: PlanningSection;
  onSection: (section: PlanningSection) => void;
}) {
  const member = useMember();
  const [chosen, setChosen] = useState<string>();
  const [directoryVersion, setDirectoryVersion] = useState(0);
  const readMembers = useCallback(
    async (signal: AbortSignal) => {
      if (!member) return [];
      const own = member.isEmployee ? [member] : [];
      if (!member.isManager) return own;
      const listed = await accessApi.listMembers({ signal });
      const verified = await Promise.all(
        listed.members
          .filter(
            (m) => m.active && m.isEmployee && m.memberId !== member.memberId,
          )
          .map(async (m) => {
            try {
              return await accessApi.checkManagementAccess(
                { memberId: m.memberId },
                { signal },
              );
            } catch (error) {
              if (statusOf(error) === 403) return undefined;
              throw error;
            }
          }),
      );
      return [...own, ...verified.filter((m): m is MemberProfile => !!m)];
    },
    [member],
  );
  const choices = useRead(
    `${member?.memberId}:members:${directoryVersion}`,
    readMembers,
    `${member?.memberId}:members`,
  );
  const initial = member ? readJournal(member.memberId)?.employeeId : undefined;
  const target =
    choices.data?.find((m) => m.memberId === (chosen ?? initial)) ??
    choices.data?.[0];
  const refreshDirectory = useCallback(
    () => setDirectoryVersion((n) => n + 1),
    [],
  );
  if (choices.loading && !target) return <p role="status">{p.loading}</p>;
  if (choices.error)
    return (
      <div className="notice error" role="alert">
        <p>{readError(choices.error)}</p>
        <button onClick={refreshDirectory}>{p.retry}</button>
      </div>
    );
  if (!member || !target)
    return (
      <p className="notice">
        {member?.isManager ? p.noEmployees : p.noPlanning}
      </p>
    );
  return (
    <EmployeePlanning
      key={`${member.memberId}:${target.memberId}`}
      member={member}
      target={target}
      choices={choices.data!}
      section={section}
      onSection={onSection}
      onTarget={setChosen}
      onDirectoryRefresh={refreshDirectory}
    />
  );
}

function EmployeePlanning({
  member,
  target,
  choices,
  section,
  onSection,
  onTarget,
  onDirectoryRefresh,
}: {
  member: MemberProfile;
  target: MemberProfile;
  choices: MemberProfile[];
  section: PlanningSection;
  onSection: (section: PlanningSection) => void;
  onTarget: (id: string) => void;
  onDirectoryRefresh: () => void;
}) {
  const own = member.memberId === target.memberId;
  const employeeId = target.memberId;
  const [anchor, setAnchor] = useState(todayInZone());
  const [active, setActive] = useState(todayInZone());
  const [view, setView] = useState<"month" | "week">("month");
  const [selecting, setSelecting] = useState(false);
  const [selected, setSelected] = useState<string[]>([]);
  const [editor, setEditor] = useState(() =>
    restoreEditor(member.memberId, employeeId),
  );
  const [requestId, setRequestId] = useState<string | undefined>(
    () => restoreEditor(member.memberId, employeeId)?.requestId,
  );
  const [filter, setFilter] = useState<RequestState | "">("");
  const [offset, setOffset] = useState(0);
  const [nonce, setNonce] = useState(0);
  const [successVersion, setSuccessVersion] = useState(0);
  const [message, setMessage] = useState("");
  const [preparing, setPreparing] = useState(false);
  const [prepareError, setPrepareError] = useState("");
  const [effectiveFrom, setEffectiveFrom] = useState(todayInZone());
  const [locations, setLocations] = useState<WorkLocation[]>([
    "OfficeSwitzerland",
    "OfficeSwitzerland",
    "OfficeSwitzerland",
    "OfficeSwitzerland",
    "OfficeSwitzerland",
    "Unplanned",
    "Unplanned",
  ]);
  const range = period(anchor, view);
  const readCalendar = useCallback(
    (signal: AbortSignal) =>
      planningApi.getCalendar(
        {
          employeeId,
          from: dateValue(range.gridFrom),
          to: dateValue(range.gridTo),
        },
        { signal },
      ),
    [employeeId, range.gridFrom, range.gridTo],
  );
  const calendar = useRead(
    `${employeeId}:calendar:${range.gridFrom}:${range.gridTo}:${nonce}`,
    readCalendar,
    `${employeeId}:calendar`,
  );
  const readRequests = useCallback(
    (signal: AbortSignal) =>
      planningApi.listPlanningRequests(
        { employeeId, offset, limit: 25, state: filter || undefined },
        { signal },
      ),
    [employeeId, offset, filter],
  );
  const requests = useRead(
    `${employeeId}:requests:${offset}:${filter}:${nonce}`,
    readRequests,
    `${employeeId}:requests:${offset}:${filter}`,
  );
  const contextId = editor?.requestId ?? requestId;
  const readRequest = useCallback(
    (signal: AbortSignal) =>
      contextId
        ? planningApi.getPlanningRequest(
            { employeeId, requestId: contextId },
            { signal },
          )
        : Promise.resolve(undefined),
    [employeeId, contextId],
  );
  const request = useRead(
    `${employeeId}:request:${contextId}:${nonce}`,
    readRequest,
    `${employeeId}:request:${contextId}`,
  );
  const readPatterns = useCallback(
    (signal: AbortSignal) =>
      planningApi.listWeeklyPatterns(
        { employeeId, offset: 0, limit: 25 },
        { signal },
      ),
    [employeeId],
  );
  const patterns = useRead(
    `${employeeId}:patterns:${nonce}`,
    readPatterns,
    `${employeeId}:patterns`,
  );
  const refresh = useCallback(() => {
    setNonce((n) => n + 1);
    onDirectoryRefresh();
  }, [onDirectoryRefresh]);
  const completed = useCallback(
    (receipt: MutationReceipt, journal: Journal) => {
      setMessage(
        journal.operation === "createPlanningDraft" ||
          journal.operation === "editPlanningDraft"
          ? p.draftSaved
          : p.success,
      );
      setSuccessVersion((n) => n + 1);
      setNonce((n) => n + 1);
      setEditor(undefined);
      sessionStorage.removeItem(EDITOR_KEY);
      if (journal.operation !== "setWeeklyPattern") {
        const id = [
          "createCounterproposal",
          "reviseCounterproposal",
          "addPlanningComment",
        ].includes(journal.operation)
          ? journal.requestId
          : receipt.contextId;
        setRequestId(id);
        onSection("requests");
        setFilter("");
        setOffset(0);
      }
      setSelected([]);
      setSelecting(false);
    },
    [onSection],
  );
  const command = useCommand(member.memberId, completed, refresh);
  const refreshing =
    calendar.loading || requests.loading || (!!contextId && request.loading);
  const disabled =
    command.locked ||
    command.stale ||
    refreshing ||
    preparing ||
    !calendar.data ||
    !!calendar.error ||
    !!request.error;
  const notice = <CommandNotice command={command} refreshing={refreshing} />;
  const names = Object.fromEntries(
    [member, ...choices].map((m) => [m.memberId, m.displayName]),
  );
  function openRequest(id: string) {
    setRequestId(id);
    onSection("requests");
    setMessage("");
  }
  function closeEditor() {
    setEditor(undefined);
    sessionStorage.removeItem(EDITOR_KEY);
  }
  function newRequest() {
    setPrepareError("");
    setEditor({
      id: crypto.randomUUID(),
      mode: "new",
      note: "",
      days: selected.map((date) => ({
        localDate: dateValue(date),
        location: "RemotePortugal",
        availability: "Working",
        cancel: false,
      })),
    });
  }
  async function openEditor(
    mode: "edit" | "revision" | "proposal",
    source: RequestView,
    chosenDays: RequestedDayView[],
    cancellation = false,
    proposal?: ProposalView,
  ) {
    setPreparing(true);
    setPrepareError("");
    try {
      let days: DayInput[] = (proposal?.days ?? chosenDays).map((d) => ({
        localDate: d.localDate,
        location: d.location,
        availability: d.availability,
        cancel: d.cancel,
        baseDayId: d.baseDayId,
        basePlanVersion: d.basePlanVersion,
      }));
      const approved = chosenDays.filter((d) => d.decision === "Approved");
      if (mode !== "edit" && !proposal && approved.length) {
        const dates = approved.map((d) => dateKey(d.localDate)).sort();
        const current = await planningApi.getCalendar({
          employeeId,
          from: dateValue(dates[0]),
          to: dateValue(dates.at(-1)!),
        });
        days = days.map((d) => {
          const original = approved.find(
            (a) => dateKey(a.localDate) === dateKey(d.localDate),
          );
          if (!original) return d;
          const plan = current.effectiveDays.find(
            (a) => a.sourceDayId === original.id,
          );
          if (!plan) throw new Error("stale_base");
          return {
            ...d,
            baseDayId: original.id,
            basePlanVersion: plan.version,
            cancel: cancellation,
            location: cancellation ? "Unplanned" : d.location,
            availability: cancellation ? "Working" : d.availability,
          };
        });
      }
      setEditor({
        id: crypto.randomUUID(),
        mode,
        requestId: source.id,
        proposalId: proposal?.id,
        parentRevisionId: source.parentRevisionId,
        affectedIds: chosenDays.map((d) => d.id),
        days,
        note: proposal?.reason ?? (mode === "edit" ? source.note : ""),
      });
    } catch (error) {
      sessionFailure(error);
      setPrepareError(
        error instanceof Error && error.message === "stale_base"
          ? p.errors.stale_plan_base
          : readError(error),
      );
    } finally {
      setPreparing(false);
    }
  }
  async function fromCalendar(id: string, dayId: string, cancel: boolean) {
    setPreparing(true);
    setPrepareError("");
    try {
      const source = await planningApi.getPlanningRequest({
        employeeId,
        requestId: id,
      });
      await openEditor(
        "revision",
        source,
        source.days.filter((d) => d.id === dayId),
        cancel,
      );
    } catch (error) {
      sessionFailure(error);
      setPrepareError(readError(error));
    } finally {
      setPreparing(false);
    }
  }
  async function saveEditor(days: DayInput[], note: string) {
    if (!editor || disabled || (editor.requestId && !request.data)) return;
    const calendarVersion = calendar.data!.calendarVersion;
    if (editor.mode === "proposal") {
      const proposalInput = {
        expectedCalendarVersion: calendarVersion,
        expectedRequestVersion: request.data!.version,
        reason: note,
        days,
        affectedDays: request
          .data!.days.filter((d) => editor.affectedIds?.includes(d.id))
          .map((d) => ({ dayId: d.id, expectedVersion: d.version })),
      };
      if (editor.proposalId)
        await command.run(
          "reviseCounterproposal",
          {
            employeeId,
            requestId: editor.requestId!,
            proposalId: editor.proposalId,
            proposalInput,
          },
          p.reviseProposal,
        );
      else
        await command.run(
          "createCounterproposal",
          { employeeId, requestId: editor.requestId!, proposalInput },
          p.counterpropose,
        );
    } else {
      const draftInput = {
        expectedCalendarVersion: calendarVersion,
        expectedRequestVersion:
          editor.mode === "edit" ? request.data!.version : null,
        parentRevisionId:
          (editor.mode === "revision"
            ? editor.requestId
            : editor.parentRevisionId) ?? null,
        days,
        note,
      };
      if (editor.mode === "edit")
        await command.run(
          "editPlanningDraft",
          { employeeId, requestId: editor.requestId!, draftInput },
          p.editDraft,
        );
      else
        await command.run(
          "createPlanningDraft",
          { employeeId, draftInput },
          p.saveDraft,
        );
    }
  }
  return (
    <div className="planning-workspace">
      <div className="planning-controls">
        <label>
          {p.employee}
          <select
            aria-label={p.employee}
            disabled={command.locked || preparing || !!editor}
            value={employeeId}
            onChange={(event) => onTarget(event.target.value)}
          >
            {choices.map((choice) => (
              <option key={choice.memberId} value={choice.memberId}>
                {choice.memberId === member.memberId
                  ? `${p.own} · ${choice.displayName}`
                  : choice.displayName}
              </option>
            ))}
          </select>
        </label>
        <button disabled={command.busy || refreshing} onClick={refresh}>
          {p.refresh}
        </button>
      </div>
      {notice}
      {message && (
        <p className="notice success" role="status">
          {message}
        </p>
      )}
      {prepareError && (
        <p className="notice error" role="alert">
          {prepareError}
        </p>
      )}
      {!!(calendar.error || requests.error || request.error) && (
        <p className="notice error" role="alert">
          {readError(calendar.error ?? requests.error ?? request.error)}
        </p>
      )}
      {!calendar.data && !refreshing && (
        <button
          onClick={() => {
            setAnchor(todayInZone());
            refresh();
          }}
        >
          {p.today}
        </button>
      )}
      {refreshing && (
        <p role="status" className="loading-line">
          {p.loading}
        </p>
      )}
      {section === "calendar" && calendar.data && (
        <CalendarPanel
          calendar={calendar.data}
          anchor={anchor}
          view={view}
          active={active}
          selecting={selecting}
          selected={selected}
          canRequest={own}
          disabled={disabled}
          onAnchor={setAnchor}
          onView={(next) => {
            setView(next);
            setAnchor(active);
          }}
          onActive={setActive}
          onSelect={(date) =>
            setSelected((dates) =>
              dates.includes(date)
                ? dates.filter((d) => d !== date)
                : [...dates, date].sort(),
            )
          }
          onSelecting={() => setSelecting((value) => !value)}
          onNew={newRequest}
          onRequest={openRequest}
          onChange={(id, day, cancel) => {
            void fromCalendar(id, day, cancel);
          }}
        />
      )}
      {section === "requests" && (
        <div className={`request-layout ${requestId ? "has-detail" : ""}`}>
          <section className="request-list" aria-label={p.requests}>
            <div className="section-heading">
              <h2>{p.requests}</h2>
              {own && (
                <button
                  className="primary"
                  disabled={disabled}
                  onClick={newRequest}
                >
                  + {p.newRequest}
                </button>
              )}
            </div>
            <label>
              {p.filter}
              <select
                value={filter}
                disabled={command.locked}
                onChange={(e) => {
                  setFilter(e.target.value as RequestState | "");
                  setOffset(0);
                }}
              >
                <option value="">{p.all}</option>
                {Object.entries(p.requestState)
                  .filter(([state]) => own || state !== "Draft")
                  .map(([state, label]) => (
                    <option key={state} value={state}>
                      {label}
                    </option>
                  ))}
              </select>
            </label>
            {requests.data?.items.length === 0 && (
              <p className="empty-state">{p.noRequests}</p>
            )}
            {requests.data?.items.map((item) => (
              <button
                className={`request-list-item ${item.id === requestId ? "selected" : ""}`}
                key={item.id}
                aria-current={item.id === requestId ? "true" : undefined}
                onClick={() => openRequest(item.id)}
              >
                <span className={`status-badge ${item.state.toLowerCase()}`}>
                  {p.requestState[item.state]}
                </span>
                <strong>
                  {item.note ||
                    `${p.request} · ${dayLabel(dateKey(item.days[0].localDate))}`}
                </strong>
                <span>{requestCounts(item)}</span>
                <small>
                  {p.revision} {item.revision} · {p.countDays(item.days.length)}
                </small>
              </button>
            ))}
            <div className="pagination">
              <button
                disabled={offset === 0 || requests.loading}
                onClick={() => setOffset((value) => value - 25)}
              >
                {p.previousPage}
              </button>
              <span>
                {p.page} {Math.floor(offset / 25) + 1}
              </span>
              <button
                disabled={requests.data?.nextOffset == null || requests.loading}
                onClick={() => setOffset(requests.data!.nextOffset!)}
              >
                {p.nextPage}
              </button>
            </div>
          </section>
          {requestId && request.data && calendar.data && (
            <RequestDetails
              key={`${requestId}:${successVersion}`}
              request={request.data}
              employeeId={employeeId}
              calendarVersion={calendar.data.calendarVersion}
              own={own}
              manager={!own && member.isManager}
              disabled={disabled}
              locked={command.locked}
              nonce={nonce}
              notice={notice}
              names={names}
              run={command.run}
              onEditor={(...args) => {
                void openEditor(...args);
              }}
              onRequest={openRequest}
            />
          )}
        </div>
      )}
      {section === "settings" && (
        <section className="settings-card">
          <h2>{p.pattern}</h2>
          <p>{p.patternSettingsHint}</p>
          {!!patterns.error && <p role="alert">{readError(patterns.error)}</p>}
          {patterns.data?.items.length === 0 && (
            <p className="muted">{p.noPatterns}</p>
          )}
          <ul>
            {patterns.data?.items.map((pattern) => (
              <li key={dateKey(pattern.effectiveFrom)}>
                {dayLabel(dateKey(pattern.effectiveFrom))} ·{" "}
                {pattern.locations
                  .map(
                    (location, i) =>
                      `${p.weekdayShort[i]}: ${p.location[location]}`,
                  )
                  .join("; ")}
              </li>
            ))}
          </ul>
          {own && (
            <form
              onSubmit={(e) => {
                e.preventDefault();
                void command.run(
                  "setWeeklyPattern",
                  {
                    employeeId,
                    patternInput: {
                      expectedCalendarVersion: calendar.data!.calendarVersion,
                      effectiveFrom: dateValue(effectiveFrom),
                      locations,
                    },
                  },
                  p.savePattern,
                );
              }}
            >
              <fieldset disabled={command.locked}>
                <legend>{p.patternHistory}</legend>
                <label>
                  {p.patternFrom}
                  <input
                    type="date"
                    required
                    value={effectiveFrom}
                    onChange={(e) => setEffectiveFrom(e.target.value)}
                  />
                </label>
                <div className="pattern-fields">
                  {locations.map((location, i) => (
                    <label key={p.weekdays[i]}>
                      {p.weekdays[i]}
                      <select
                        value={location}
                        onChange={(e) =>
                          setLocations((values) =>
                            values.map((v, n) =>
                              n === i ? (e.target.value as WorkLocation) : v,
                            ),
                          )
                        }
                      >
                        {Object.entries(p.location).map(([value, label]) => (
                          <option key={value} value={value}>
                            {label}
                          </option>
                        ))}
                      </select>
                    </label>
                  ))}
                </div>
              </fieldset>
              <button className="primary" disabled={disabled}>
                {p.savePattern}
              </button>
            </form>
          )}
          <p className="muted">{p.accountSettings}</p>
        </section>
      )}
      {editor && (
        <RequestEditor
          key={editor.id}
          editor={editor}
          request={request.data}
          actorId={member.memberId}
          employeeId={employeeId}
          locked={command.locked}
          disabled={disabled}
          notice={notice}
          onSave={saveEditor}
          onClose={closeEditor}
        />
      )}
    </div>
  );
}
