import { useCallback, useState } from "react";
import type {
  AssignedTaskState,
  OnsiteInput,
  OnsitePreview,
  OnsiteState,
  OnsiteView,
  TaskView,
  WorkContext,
  WorkEntryView,
} from "../../../../../contracts/typescript";
import { p } from "../../i18n/planning.pt-PT";
import { w } from "../../i18n/work.pt-PT";
import { planningApi, sessionFailure } from "./api";
import { dateKey, dateValue, dayLabel, todayInZone } from "./dates";
import { commandError, readError } from "./errors";
import { useRead } from "./useRead";
import type { RunCommand } from "./useCommand";
import { Dialog } from "./shared";
import { clearWorkDraft, useWorkField } from "./workDraft";

export type WorkFocus = {
  kind: WorkContext;
  id?: string;
  seed?: string[];
  creating?: boolean;
};
interface Props {
  employeeId: string;
  own: boolean;
  section: "onsite" | "tasks";
  focus?: WorkFocus;
  onFocus: (focus?: WorkFocus) => void;
  nonce: number;
  version: number;
  disabled: boolean;
  run: RunCommand;
  onRequest: (id: string) => void;
  onResolve: (requirement: OnsiteView, requestId: string) => void;
}
export function WorkPanel(props: Props) {
  const { section, employeeId, nonce, own, focus, onFocus } = props;
  const kind = section === "onsite" ? "Requirement" : "Task";
  const [filter, setFilter] = useState<OnsiteState | AssignedTaskState | "">(
    "",
  );
  const [offset, setOffset] = useState(0);
  const load = useCallback(
    async (signal: AbortSignal) =>
      kind === "Requirement"
        ? planningApi.listOnsiteRequirements(
            {
              employeeId,
              offset,
              limit: 25,
              state: (filter || undefined) as OnsiteState | undefined,
            },
            { signal },
          )
        : planningApi.listAssignedTasks(
            {
              employeeId,
              offset,
              limit: 25,
              state: (filter || undefined) as AssignedTaskState | undefined,
            },
            { signal },
          ),
    [kind, employeeId, offset, filter],
  );
  const list = useRead(
    `${employeeId}:${kind}:${filter}:${offset}:${nonce}`,
    load,
    `${employeeId}:${kind}:${filter}:${offset}`,
  );
  return (
    <div className="work-layout">
      <section className="request-list" aria-label={w[section]}>
        <div className="section-heading">
          <h2>{w[section]}</h2>
          {!own && (
            <button
              className="primary"
              disabled={props.disabled}
              onClick={() => onFocus({ kind, creating: true })}
            >
              + {kind === "Requirement" ? w.newOnsite : w.newTask}
            </button>
          )}
        </div>
        <p className="muted">
          {kind === "Requirement" ? w.onsiteIntro : w.taskIntro}
        </p>
        <label>
          {w.filter}
          <select
            value={filter}
            onChange={(e) => {
              setFilter(e.target.value as typeof filter);
              setOffset(0);
            }}
          >
            <option value="">{p.all}</option>
            {Object.entries(kind === "Requirement" ? w.state : w.taskState).map(
              ([v, label]) => (
                <option key={v} value={v}>
                  {label}
                </option>
              ),
            )}
          </select>
        </label>
        {list.loading && <p role="status">{p.loading}</p>}
        {!!list.error && <p role="alert">{readError(list.error)}</p>}
        {list.data?.items.length === 0 && (
          <p className="empty-state">
            {kind === "Requirement" ? w.emptyOnsite : w.emptyTasks}
          </p>
        )}
        {list.data?.items.map((item) => (
          <button
            className={`request-list-item ${focus?.id === item.id ? "selected" : ""}`}
            key={item.id}
            onClick={() => onFocus({ kind, id: item.id })}
          >
            <span className={`status-badge ${item.state.toLowerCase()}`}>
              {kind === "Requirement"
                ? w.state[item.state as OnsiteState]
                : w.taskState[item.state as AssignedTaskState]}
            </span>
            <strong>{"reason" in item ? item.reason : item.title}</strong>
            <span>
              {"from" in item
                ? `${dayLabel(dateKey(item.from))} — ${dayLabel(dateKey(item.to))}`
                : `${w.deadline}: ${dayLabel(dateKey(item.deadline))}`}
            </span>
          </button>
        ))}
        <div className="pagination">
          <button
            disabled={!offset || list.loading}
            onClick={() => setOffset((x) => x - 25)}
          >
            {p.previousPage}
          </button>
          <span>
            {p.page} {1 + offset / 25}
          </span>
          <button
            disabled={list.data?.nextOffset == null || list.loading}
            onClick={() => setOffset(list.data!.nextOffset!)}
          >
            {p.nextPage}
          </button>
        </div>
      </section>
      {focus?.kind === kind ? (
        <WorkDetail
          key={`${kind}:${focus.id ?? "new"}:${focus.seed?.join()}`}
          {...props}
          focus={focus}
        />
      ) : (
        <p className="empty-state">{w.choose}</p>
      )}
    </div>
  );
}

function WorkDetail(props: Props & { focus: WorkFocus }) {
  const { employeeId, focus, nonce, own, disabled, run, version, onFocus } =
    props;
  const kind = focus.kind;
  const [editing, setEditing] = useState(!!focus.creating);
  const [cancel, setCancel] = useState(false);
  const load = useCallback(
    async (signal: AbortSignal) =>
      !focus.id
        ? undefined
        : kind === "Requirement"
          ? planningApi.getOnsiteRequirement(
              { employeeId, requirementId: focus.id },
              { signal },
            )
          : planningApi.getAssignedTask(
              { employeeId, taskId: focus.id },
              { signal },
            ),
    [employeeId, focus.id, kind],
  );
  const detail = useRead(
    `${employeeId}:${kind}:${focus.id}:${nonce}`,
    load,
    `${employeeId}:${kind}:${focus.id}`,
  );
  const requirement =
    detail.data && "reason" in detail.data ? detail.data : undefined;
  const task = detail.data && "title" in detail.data ? detail.data : undefined;
  const loadConflicts = useCallback(
    (signal: AbortSignal) =>
      requirement && requirement.state !== "Cancelled"
        ? planningApi.previewOnsiteRequirement(
            {
              employeeId,
              from: requirement.from,
              to: requirement.to,
              location: requirement.location,
              excludes: requirement.id,
            },
            { signal },
          )
        : Promise.resolve(undefined),
    [employeeId, requirement],
  );
  const conflicts = useRead(
    `${employeeId}:${focus.id}:conflicts:${nonce}`,
    loadConflicts,
    `${employeeId}:${focus.id}:conflicts`,
  );
  const locked = disabled || detail.loading || !!detail.error;
  async function read() {
    if (!requirement) return;
    await run(
      "acknowledgeOnsiteRequirement",
      {
        employeeId,
        requirementId: requirement.id,
        onsiteAcknowledgeInput: {
          expectedCalendarVersion: version,
          expectedVersion: requirement.version,
          revision: requirement.revision,
        },
      },
      w.read,
    );
  }
  return (
    <section
      className="work-detail"
      aria-label={kind === "Requirement" ? w.onsite : w.tasks}
    >
      <div className="section-heading">
        <h2>
          {requirement?.reason ??
            task?.title ??
            (kind === "Requirement" ? w.newOnsite : w.newTask)}
        </h2>
        <button onClick={() => onFocus(undefined)} disabled={disabled}>
          {w.close}
        </button>
      </div>
      {detail.loading && <p role="status">{p.loading}</p>}
      {!!detail.error && <p role="alert">{readError(detail.error)}</p>}
      {requirement && (
        <>
          <div className="button-row">
            <span className={`status-badge ${requirement.state.toLowerCase()}`}>
              {w.state[requirement.state]}
            </span>
            <span>
              {w.revision} {requirement.revision}
            </span>
            <span>{requirement.readAt ? w.readDone : w.unread}</span>
          </div>
          <p>
            {dayLabel(dateKey(requirement.from))} —{" "}
            {dayLabel(dateKey(requirement.to))} · {requirement.location}
          </p>
          <p>{requirement.reference}</p>
          <p className="notice">{w.readHint}</p>
          {requirement.state === "NeedsResolution" && (
            <p className="notice conflict">{w.conflict}</p>
          )}
          <div className="button-row">
            {own &&
              !requirement.readAt &&
              requirement.state !== "Cancelled" && (
                <button
                  className="primary"
                  disabled={locked}
                  onClick={() => void read()}
                >
                  {w.read}
                </button>
              )}
            {!own && requirement.state !== "Cancelled" && (
              <>
                <button disabled={locked} onClick={() => setEditing(true)}>
                  {w.edit}
                </button>
                <button disabled={locked} onClick={() => setCancel(true)}>
                  {w.cancelOnsite}
                </button>
                <button
                  disabled={locked}
                  onClick={() =>
                    onFocus({
                      kind: "Task",
                      creating: true,
                      seed: [requirement.id],
                    })
                  }
                >
                  {w.newTask}
                </button>
              </>
            )}
          </div>
          {conflicts.loading && <p role="status">{p.loading}</p>}
          {!!conflicts.error && (
            <p role="alert">{readError(conflicts.error)}</p>
          )}
          {conflicts.data && (
            <>
              <ConflictList
                preview={conflicts.data}
                onRequest={props.onRequest}
              />
              {requirement.state === "NeedsResolution" && (
                <>
                  <p>{w.resolveHint}</p>
                  {!own &&
                    [
                      ...new Set(
                        conflicts.data.conflicts
                          .filter((c) => c.code.startsWith("approved_"))
                          .map((c) => c.requestId)
                          .filter((id): id is string => !!id),
                      ),
                    ].map((id) => (
                      <button
                        key={id}
                        disabled={locked}
                        onClick={() => props.onResolve(requirement, id)}
                      >
                        {w.resolve} · {id.slice(0, 8)}
                      </button>
                    ))}
                </>
              )}
            </>
          )}
        </>
      )}
      {task && (
        <>
          <span className={`status-badge ${task.state.toLowerCase()}`}>
            {w.taskState[task.state]}
          </span>
          <p>{task.description}</p>
          <p>
            {w.deadline}: {dayLabel(dateKey(task.deadline))}
          </p>
          {task.requiresOnsite && (
            <p className="notice">
              {w.requiresOnsite}. {w.requiresHint}
            </p>
          )}
          {task.requirementId && (
            <div className="notice">
              <button
                onClick={() =>
                  onFocus({ kind: "Requirement", id: task.requirementId! })
                }
              >
                {w.link} ·{" "}
                {task.requirementState && w.state[task.requirementState]}
              </button>
              <p>
                {w.revision} {task.requirementRevision} · {w.linkHint}
              </p>
            </div>
          )}
          <p>{task.progressNote}</p>
          {!own && (
            <button disabled={locked} onClick={() => setEditing(true)}>
              {w.edit}
            </button>
          )}
          {own && <TaskProgress task={task} {...props} disabled={locked} />}
        </>
      )}
      {editing &&
        !own &&
        (kind === "Requirement" ? (
          <OnsiteForm
            employeeId={employeeId}
            original={requirement}
            seed={focus.seed}
            version={version}
            disabled={locked}
            run={run}
            onSaved={(id) => {
              setEditing(false);
              onFocus({ kind, id });
            }}
            onClose={() => setEditing(false)}
          />
        ) : (
          <TaskForm
            employeeId={employeeId}
            original={task}
            seed={focus.seed?.[0]}
            version={version}
            disabled={locked}
            run={run}
            onSaved={() => {
              setEditing(false);
              onFocus(undefined);
            }}
            onClose={() => setEditing(false)}
          />
        ))}
      {cancel && requirement && (
        <Dialog
          title={w.cancelOnsite}
          locked={locked}
          onClose={() => setCancel(false)}
        >
          <p>{w.cancelHint}</p>
          <button
            className="primary"
            disabled={locked}
            onClick={async () => {
              if (
                (await run(
                  "cancelOnsiteRequirement",
                  {
                    employeeId,
                    requirementId: requirement.id,
                    workVersionInput: {
                      expectedCalendarVersion: version,
                      expectedVersion: requirement.version,
                    },
                  },
                  w.cancelOnsite,
                )) === "success"
              )
                setCancel(false);
            }}
          >
            {w.confirmCancel}
          </button>
        </Dialog>
      )}
      {focus.id && !detail.error && (
        <WorkHistory
          employeeId={employeeId}
          kind={kind}
          id={focus.id}
          nonce={nonce}
          version={version}
          disabled={locked}
          run={run}
        />
      )}
    </section>
  );
}

function ConflictList({
  preview,
  onRequest,
}: {
  preview: OnsitePreview;
  onRequest?: (id: string) => void;
}) {
  return (
    <div className="conflict-preview">
      <strong>{w.state[preview.result]}</strong>
      {!preview.conflicts.length ? (
        <p>{w.noConflicts}</p>
      ) : (
        <ul>
          {preview.conflicts.map((c, i) => (
            <li key={`${c.contextId}:${i}`}>
              {dayLabel(dateKey(c.localDate))} ·{" "}
              {w.conflictCode[c.code as keyof typeof w.conflictCode] ??
                p.conflict}
              {c.requestId && onRequest && (
                <>
                  {" "}
                  <button onClick={() => onRequest(c.requestId!)}>
                    {p.viewRequest}
                  </button>
                </>
              )}
            </li>
          ))}
        </ul>
      )}
    </div>
  );
}
interface FormProps {
  employeeId: string;
  version: number;
  disabled: boolean;
  run: RunCommand;
  onClose: () => void;
}
function OnsiteForm({
  employeeId,
  original,
  seed,
  version,
  disabled,
  run,
  onSaved,
  onClose,
}: FormProps & {
  original?: OnsiteView;
  seed?: string[];
  onSaved: (id?: string) => void;
}) {
  const draftKey = `onsite:${original?.id ?? "new"}`;
  const [from, setFrom] = useWorkField(
    employeeId,
    draftKey,
    "from",
    original ? dateKey(original.from) : (seed?.[0] ?? todayInZone()),
  );
  const [to, setTo] = useWorkField(
    employeeId,
    draftKey,
    "to",
    original ? dateKey(original.to) : (seed?.at(-1) ?? from),
  );
  const [reason, setReason] = useWorkField(
    employeeId,
    draftKey,
    "reason",
    original?.reason ?? "",
  );
  const [location, setLocation] = useWorkField(
    employeeId,
    draftKey,
    "location",
    original?.location ?? "",
  );
  const [reference, setReference] = useWorkField(
    employeeId,
    draftKey,
    "reference",
    original?.reference ?? "",
  );
  const [preview, setPreview] = useState<{
    input: OnsiteInput;
    result: OnsitePreview;
  }>();
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState("");
  async function inspect(event: React.FormEvent) {
    event.preventDefault();
    setBusy(true);
    setError("");
    setPreview(undefined);
    try {
      const result = await planningApi.previewOnsiteRequirement({
        employeeId,
        from: dateValue(from),
        to: dateValue(to),
        location,
        excludes: original?.id,
      });
      setPreview({
        result,
        input: {
          expectedCalendarVersion: result.calendarVersion,
          expectedVersion: original?.version ?? null,
          from: dateValue(from),
          to: dateValue(to),
          reason,
          location,
          reference,
        },
      });
    } catch (error) {
      sessionFailure(error);
      setError(await commandError(error));
    } finally {
      setBusy(false);
    }
  }
  return (
    <form
      className="work-form"
      aria-label={original ? w.edit : w.newOnsite}
      onSubmit={inspect}
      onChange={() => setPreview(undefined)}
    >
      <h3>{original ? w.edit : w.newOnsite}</h3>
      <label>
        {w.reason}
        <input
          required
          maxLength={1000}
          value={reason}
          onChange={(e) => setReason(e.target.value)}
        />
      </label>
      <div className="form-grid">
        <label>
          {w.from}
          <input
            type="date"
            required
            value={from}
            onChange={(e) => setFrom(e.target.value)}
          />
        </label>
        <label>
          {w.to}
          <input
            type="date"
            required
            min={from}
            value={to}
            onChange={(e) => setTo(e.target.value)}
          />
        </label>
      </div>
      <p className="muted">{w.inclusive}</p>
      <label>
        {w.location}
        <input
          required
          maxLength={200}
          value={location}
          onChange={(e) => setLocation(e.target.value)}
        />
      </label>
      <label>
        {w.reference}
        <input
          maxLength={200}
          value={reference}
          onChange={(e) => setReference(e.target.value)}
        />
      </label>
      <div className="button-row">
        <button type="submit" disabled={disabled || busy}>
          {w.preview}
        </button>
        <button type="button" disabled={disabled || busy} onClick={onClose}>
          {p.close}
        </button>
      </div>
      {error && <p role="alert">{error}</p>}
      {busy && <p role="status">{p.loading}</p>}
      {preview && (
        <section aria-label={w.previewTitle}>
          <h4>{w.previewTitle}</h4>
          <p>
            {reason} · {dayLabel(from)} — {dayLabel(to)}
          </p>
          <ConflictList preview={preview.result} />
          <p>{w.previewHint}</p>
          <button
            type="button"
            className="primary"
            disabled={
              disabled || busy || version !== preview.result.calendarVersion
            }
            onClick={async () => {
              const result = original
                ? await run(
                    "editOnsiteRequirement",
                    {
                      employeeId,
                      requirementId: original.id,
                      onsiteInput: preview.input,
                    },
                    w.confirm,
                  )
                : await run(
                    "createOnsiteRequirement",
                    { employeeId, onsiteInput: preview.input },
                    w.confirm,
                  );
              if (result === "success") {
                clearWorkDraft(employeeId, draftKey);
                onSaved(original?.id);
              }
            }}
          >
            {w.confirm}
          </button>
          {version !== preview.result.calendarVersion && (
            <p role="alert">{p.stale}</p>
          )}
        </section>
      )}
    </form>
  );
}

function TaskForm({
  employeeId,
  original,
  seed,
  version,
  disabled,
  run,
  onSaved,
  onClose,
}: FormProps & { original?: TaskView; seed?: string; onSaved: () => void }) {
  const draftKey = `task:${original?.id ?? "new"}`;
  const [title, setTitle] = useWorkField(
    employeeId,
    draftKey,
    "title",
    original?.title ?? "",
  );
  const [description, setDescription] = useWorkField(
    employeeId,
    draftKey,
    "description",
    original?.description ?? "",
  );
  const [deadline, setDeadline] = useWorkField(
    employeeId,
    draftKey,
    "deadline",
    original ? dateKey(original.deadline) : todayInZone(),
  );
  const [state, setState] = useWorkField<AssignedTaskState>(
    employeeId,
    draftKey,
    "state",
    original?.state ?? "Todo",
  );
  const [requires, setRequires] = useWorkField(
    employeeId,
    draftKey,
    "requires",
    original?.requiresOnsite ?? !!seed,
  );
  const [link, setLink] = useWorkField(
    employeeId,
    draftKey,
    "link",
    original?.requirementId ?? seed ?? "",
  );
  const [linkOffset, setLinkOffset] = useState(0);
  const load = useCallback(
    (signal: AbortSignal) =>
      planningApi.listOnsiteRequirements(
        { employeeId, offset: linkOffset, limit: 100 },
        { signal },
      ),
    [employeeId, linkOffset],
  );
  const options = useRead(`${employeeId}:links:${linkOffset}`, load);
  return (
    <form
      className="work-form"
      aria-label={w.saveTask}
      onSubmit={async (event) => {
        event.preventDefault();
        const taskInput = {
          expectedCalendarVersion: version,
          expectedVersion: original?.version ?? null,
          title,
          description,
          deadline: dateValue(deadline),
          state,
          requiresOnsite: requires,
          requirementId: link || null,
        };
        const result = original
          ? await run(
              "editAssignedTask",
              { employeeId, taskId: original.id, taskInput },
              w.saveTask,
            )
          : await run(
              "createAssignedTask",
              { employeeId, taskInput },
              w.newTask,
            );
        if (result === "success") {
          clearWorkDraft(employeeId, draftKey);
          onSaved();
        }
      }}
    >
      <h3>{original ? w.edit : w.newTask}</h3>
      <label>
        {w.title}
        <input
          required
          maxLength={200}
          value={title}
          onChange={(e) => setTitle(e.target.value)}
        />
      </label>
      <label>
        {w.description}
        <textarea
          maxLength={2000}
          value={description}
          onChange={(e) => setDescription(e.target.value)}
        />
      </label>
      <div className="form-grid">
        <label>
          {w.deadline}
          <input
            type="date"
            required
            value={deadline}
            onChange={(e) => setDeadline(e.target.value)}
          />
        </label>
        <label>
          {w.taskStatus}
          <select
            value={state}
            onChange={(e) => setState(e.target.value as AssignedTaskState)}
          >
            {Object.entries(w.taskState).map(([v, label]) => (
              <option key={v} value={v}>
                {label}
              </option>
            ))}
          </select>
        </label>
      </div>
      <label className="checkbox-label">
        <input
          type="checkbox"
          checked={requires}
          onChange={(e) => setRequires(e.target.checked)}
        />
        {w.requiresOnsite}
      </label>
      <p className="muted">{w.requiresHint}</p>
      <label>
        {w.link}
        <select value={link} onChange={(e) => setLink(e.target.value)}>
          <option value="">{w.noLink}</option>
          {link && !options.data?.items.some((x) => x.id === link) && (
            <option value={link}>
              {w.link} · {link.slice(0, 8)}
            </option>
          )}
          {options.data?.items
            .filter((x) => x.state !== "Cancelled" || x.id === link)
            .map((x) => (
              <option key={x.id} value={x.id}>
                {x.reason} · {w.state[x.state]}
              </option>
            ))}
        </select>
      </label>
      {options.loading && <p role="status">{p.loading}</p>}
      {!!options.error && <p role="alert">{readError(options.error)}</p>}
      <div className="button-row">
        {linkOffset > 0 && (
          <button type="button" onClick={() => setLinkOffset((x) => x - 100)}>
            {p.previousPage}
          </button>
        )}
        {options.data?.nextOffset != null && (
          <button
            type="button"
            onClick={() => setLinkOffset(options.data!.nextOffset!)}
          >
            {w.more}
          </button>
        )}
      </div>
      <p className="muted">{w.linkHint}</p>
      <div className="button-row">
        <button className="primary" disabled={disabled} type="submit">
          {w.saveTask}
        </button>
        <button disabled={disabled} type="button" onClick={onClose}>
          {p.close}
        </button>
      </div>
    </form>
  );
}

function TaskProgress({
  task,
  employeeId,
  version,
  disabled,
  run,
}: Pick<Props, "employeeId" | "version" | "disabled" | "run"> & {
  task: TaskView;
}) {
  const [state, setState] = useWorkField<AssignedTaskState>(
    employeeId,
    `progress:${task.id}`,
    "state",
    "InProgress",
  );
  const [note, setNote] = useWorkField<string>(
    employeeId,
    `progress:${task.id}`,
    "note",
    "",
  );
  if (["Done", "Cancelled"].includes(task.state))
    return <p className="notice">{w.terminal}</p>;
  return (
    <form
      className="work-form"
      aria-label={w.progress}
      onSubmit={async (event) => {
        event.preventDefault();
        if (
          (await run(
            "updateTaskProgress",
            {
              employeeId,
              taskId: task.id,
              taskProgressInput: {
                expectedCalendarVersion: version,
                expectedVersion: task.version,
                state,
                note,
              },
            },
            w.progress,
          )) === "success"
        )
          setNote("");
      }}
    >
      <label>
        {w.progress}
        <select
          value={state}
          onChange={(e) => setState(e.target.value as AssignedTaskState)}
        >
          {Object.entries(w.taskState)
            .filter(([key]) => key !== "Cancelled")
            .map(([v, label]) => (
              <option key={v} value={v}>
                {label}
              </option>
            ))}
        </select>
      </label>
      <label>
        {w.progressNote}
        <textarea
          maxLength={1000}
          value={note}
          onChange={(e) => setNote(e.target.value)}
        />
      </label>
      <button className="primary" disabled={disabled}>
        {w.progress}
      </button>
    </form>
  );
}
function Snapshot({ entry }: { entry: WorkEntryView }) {
  const snapshot: Record<string, unknown> = JSON.parse(entry.snapshotJson);
  const states = typeof snapshot.title === "string" ? w.taskState : w.state;
  return (
    <>
      {typeof snapshot.state === "string" && snapshot.state in states && (
        <p>{states[snapshot.state as keyof typeof states]}</p>
      )}
      {typeof snapshot.deadline === "string" && (
        <p>
          {w.deadline}: {dayLabel(snapshot.deadline)}
        </p>
      )}
      {[
        snapshot.reason,
        snapshot.title,
        snapshot.description,
        snapshot.location,
        snapshot.reference,
        snapshot.progressNote,
      ]
        .filter((x) => typeof x === "string" && x)
        .map((x, i) => (
          <p key={i}>{String(x)}</p>
        ))}
      {typeof snapshot.from === "string" && typeof snapshot.to === "string" && (
        <p>
          {dayLabel(snapshot.from)} — {dayLabel(snapshot.to)}
        </p>
      )}
      {typeof snapshot.revision === "number" && (
        <small>
          {w.revision} {snapshot.revision}
        </small>
      )}
    </>
  );
}
function WorkHistory({
  employeeId,
  kind,
  id,
  nonce,
  version,
  disabled,
  run,
}: {
  employeeId: string;
  kind: WorkContext;
  id: string;
  nonce: number;
  version: number;
  disabled: boolean;
  run: RunCommand;
}) {
  const [offset, setOffset] = useState(0);
  const [text, setText] = useWorkField<string>(
    employeeId,
    `comment:${kind}:${id}`,
    "text",
    "",
  );
  const load = useCallback(
    (signal: AbortSignal) =>
      planningApi.listWorkEntries(
        { employeeId, kind, contextId: id, offset, limit: 25 },
        { signal },
      ),
    [employeeId, kind, id, offset],
  );
  const entries = useRead(
    `${employeeId}:${kind}:${id}:entries:${offset}:${nonce}`,
    load,
    `${employeeId}:${kind}:${id}:entries:${offset}`,
  );
  return (
    <section className="work-history" aria-label={w.history}>
      <h3>{w.history}</h3>
      <form
        onSubmit={async (event) => {
          event.preventDefault();
          if (
            (await run(
              "addWorkComment",
              {
                employeeId,
                kind,
                contextId: id,
                workCommentInput: { expectedCalendarVersion: version, text },
              },
              w.sendComment,
            )) === "success"
          )
            setText("");
        }}
      >
        <label>
          {w.comment}
          <textarea
            required
            maxLength={2000}
            value={text}
            onChange={(e) => setText(e.target.value)}
          />
        </label>
        <button disabled={disabled}>{w.sendComment}</button>
      </form>
      {entries.loading && <p role="status">{p.loading}</p>}
      {!!entries.error && <p role="alert">{readError(entries.error)}</p>}
      <ol>
        {entries.data?.items.map((entry) => (
          <li key={entry.id}>
            <strong>
              {w.entryActions[entry.action as keyof typeof w.entryActions] ??
                w.history}
            </strong>{" "}
            ·{" "}
            <time dateTime={entry.createdAt.toISOString()}>
              {entry.createdAt.toLocaleString("pt-PT")}
            </time>
            {entry.text && <p>{entry.text}</p>}
            <Snapshot entry={entry} />
          </li>
        ))}
      </ol>
      <div className="pagination">
        <button
          disabled={!offset || entries.loading}
          onClick={() => setOffset((x) => x - 25)}
        >
          {p.previousPage}
        </button>
        <button
          disabled={entries.data?.nextOffset == null || entries.loading}
          onClick={() => setOffset(entries.data!.nextOffset!)}
        >
          {p.nextPage}
        </button>
      </div>
    </section>
  );
}
