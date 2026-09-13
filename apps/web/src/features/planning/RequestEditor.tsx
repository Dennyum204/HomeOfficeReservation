import { localizedFeedback } from "../../i18n/locale";
import { Select } from "../../theme/Select";
import { useEffect, useRef, useState, type ReactNode } from "react";
import {
  DayInputToJSON,
  type DayInput,
  type RequestView,
  type WorkLocation,
  type Availability,
} from "../../../../../contracts/typescript";
import { p } from "../../i18n/locale";
import { appearance as v } from "../../i18n/locale";
import { EDITOR_KEY } from "../auth/session";
import { planningApi, sessionFailure } from "./api";
import { dateKey, dateValue, dayLabel, todayInZone } from "./dates";
import { Dialog } from "./shared";
import { readError } from "./errors";

import { type EditorSpec } from "./editorState";
export function RequestEditor({
  editor,
  request,
  actorId,
  employeeId,
  locked,
  disabled,
  notice,
  onSave,
  onClose,
}: {
  editor: EditorSpec;
  request?: RequestView;
  actorId: string;
  employeeId: string;
  locked: boolean;
  disabled: boolean;
  notice: ReactNode;
  onSave: (days: DayInput[], note: string) => Promise<void>;
  onClose: () => void;
}) {
  const [days, setDays] = useState(editor.days);
  const [note, setNote] = useState(editor.note);
  const [from, setFrom] = useState(todayInZone());
  const [to, setTo] = useState(todayInZone());
  const [single, setSingle] = useState(todayInZone());
  const [dateMode, setDateMode] = useState<"range" | "single">("range");
  const [weekends, setWeekends] = useState(false);
  const [preview, setPreview] = useState<string[]>([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState("");
  const previewController = useRef<AbortController | undefined>(undefined);
  useEffect(() => () => previewController.current?.abort(), []);
  const [location, setLocation] = useState<WorkLocation>("RemotePortugal");
  const [availability, setAvailability] = useState<Availability>("Working");
  useEffect(() => {
    try {
      sessionStorage.setItem(
        EDITOR_KEY,
        JSON.stringify({
          actorId,
          employeeId,
          editor: { ...editor, days: days.map(DayInputToJSON), note },
        }),
      );
    } catch {
      /* In-memory input survives recoverable errors; command preparation enforces durable retry storage. */
    }
  }, [actorId, employeeId, editor, days, note]);
  const update = (index: number, value: Partial<DayInput>) =>
    setDays((current) =>
      current.map((d, i) => (i === index ? { ...d, ...value } : d)),
    );
  function add(dates: string[]) {
    setError("");
    setDays((current) => {
      const result = new Map(current.map((d) => [dateKey(d.localDate), d]));
      for (const date of dates)
        if (!result.has(date))
          result.set(date, {
            localDate: dateValue(date),
            location: availability === "Working" ? location : "Unplanned",
            availability,
            cancel: false,
          });
      return [...result.values()].sort((a, b) =>
        dateKey(a.localDate).localeCompare(dateKey(b.localDate)),
      );
    });
    setPreview([]);
  }
  async function previewRange() {
    previewController.current?.abort();
    const controller = new AbortController();
    previewController.current = controller;
    setLoading(true);
    setError("");
    setPreview([]);
    try {
      const result = await planningApi.previewPlanningDates(
        {
          from: dateValue(from),
          to: dateValue(to),
          includeWeekends: weekends,
        },
        { signal: controller.signal },
      );
      if (controller.signal.aborted) return;
      setPreview(result.days.map((d) => dateKey(d.localDate)));
      if (result.days.length === 0) setError(p.emptyPreview);
    } catch (e) {
      if (!controller.signal.aborted) {
        sessionFailure(e);
        setError(readError(e));
      }
    } finally {
      if (!controller.signal.aborted) setLoading(false);
    }
  }
  const title =
    editor.mode === "proposal"
      ? editor.proposalId
        ? p.reviseProposal
        : p.counterpropose
      : editor.mode === "revision"
        ? p.proposeChange
        : editor.mode === "edit"
          ? p.editDraft
          : p.newRequest;
  return (
    <Dialog title={title} onClose={onClose} locked={locked}>
      {notice}
      {(editor.mode === "revision" || editor.parentRevisionId) && (
        <p className="detail-note">{p.revisionHint}</p>
      )}
      {editor.mode === "proposal" && request && (
        <div className="affected-summary">
          <strong>{p.affected}</strong>
          <ul>
            {request.days
              .filter((d) => editor.affectedIds?.includes(d.id))
              .map((d) => (
                <li key={d.id}>
                  {dayLabel(dateKey(d.localDate))} · {p.decision[d.decision]}
                </li>
              ))}
          </ul>
          <p>{p.acceptHint}</p>
        </div>
      )}
      <form
        onSubmit={(event) => {
          event.preventDefault();
          if (!days.length) {
            setError(p.emptyDates);
            return;
          }
          void onSave(days, note);
        }}
      >
        <fieldset disabled={locked || loading} className="editor-fields">
          <legend className="sr-only">{p.chooseDates}</legend>
          <fieldset className="editor-section">
            <legend>{v.context}</legend>
            <p className="muted">{v.contextHint}</p>
            <div className="form-row">
              <label>
                {p.workLocation}
                <Select
                  value={location}
                  disabled={availability !== "Working"}
                  onChange={(e) => setLocation(e.target.value as WorkLocation)}
                >
                  <option value="RemotePortugal">
                    {p.location.RemotePortugal}
                  </option>
                  <option value="OfficeSwitzerland">
                    {p.location.OfficeSwitzerland}
                  </option>
                </Select>
              </label>
              <label>
                {p.availabilityLabel}
                <Select
                  value={availability}
                  onChange={(e) =>
                    setAvailability(e.target.value as Availability)
                  }
                >
                  {Object.entries(p.availability).map(([value, label]) => (
                    <option value={value} key={value}>
                      {label}
                    </option>
                  ))}
                </Select>
              </label>
            </div>
          </fieldset>
          <fieldset className="editor-section">
            <legend>{v.selection}</legend>
            <div className="date-method" role="group" aria-label={v.mode}>
              <button
                type="button"
                aria-pressed={dateMode === "range"}
                onClick={() => setDateMode("range")}
              >
                {v.range}
              </button>
              <button
                type="button"
                aria-pressed={dateMode === "single"}
                onClick={() => setDateMode("single")}
              >
                {v.single}
              </button>
            </div>
            <p className="muted">
              {dateMode === "range" ? v.rangeHint : v.singleHint}
            </p>
            {dateMode === "range" ? (
              <>
                <div className="form-row">
                  <label>
                    {p.from}
                    <input
                      type="date"
                      value={from}
                      onChange={(e) => {
                        setFrom(e.target.value);
                        setPreview([]);
                      }}
                    />
                  </label>
                  <label>
                    {p.to}
                    <input
                      type="date"
                      value={to}
                      onChange={(e) => {
                        setTo(e.target.value);
                        setPreview([]);
                      }}
                    />
                  </label>
                </div>
                <div className="button-row">
                  <label className="check-label">
                    <input
                      type="checkbox"
                      checked={weekends}
                      onChange={(e) => {
                        setWeekends(e.target.checked);
                        setPreview([]);
                      }}
                    />
                    {p.includeWeekends}
                  </label>
                  <button
                    type="button"
                    disabled={!from || !to}
                    onClick={() => {
                      void previewRange();
                    }}
                  >
                    {p.addRange}
                  </button>
                </div>
                {preview.length > 0 && (
                  <div className="range-preview">
                    <strong>
                      {p.included} · {p.countDays(preview.length)}
                    </strong>
                    <ul>
                      {preview.map((date) => (
                        <li key={date}>{dayLabel(date)}</li>
                      ))}
                    </ul>
                    <button type="button" onClick={() => add(preview)}>
                      {p.addIncluded}
                    </button>
                  </div>
                )}
              </>
            ) : (
              <div className="form-row">
                <label>
                  {p.date}
                  <input
                    type="date"
                    value={single}
                    onChange={(e) => setSingle(e.target.value)}
                  />
                </label>
                <button
                  type="button"
                  disabled={!single}
                  onClick={() => add([single])}
                >
                  {p.addDate}
                </button>
              </div>
            )}
          </fieldset>
          <fieldset className="editor-section">
            <legend>{v.summary}</legend>
            <p className="muted">{v.summaryHint}</p>
            <h3>
              {p.selectedDates} · {p.countDays(days.length)}
            </h3>
            {days.length === 0 && <p className="muted">{p.emptyDates}</p>}
            <div className="editor-days">
              {days.map((day, index) => (
                <div className="editor-day" key={dateKey(day.localDate)}>
                  <strong>{dayLabel(dateKey(day.localDate))}</strong>
                  <label>
                    <span>{p.availabilityLabel}</span>
                    <Select
                      aria-label={`${p.availabilityLabel} ${dateKey(day.localDate)}`}
                      disabled={day.cancel}
                      value={day.availability}
                      onChange={(e) => {
                        const next = e.target.value as Availability;
                        update(index, {
                          availability: next,
                          location:
                            next === "Working" ? "RemotePortugal" : "Unplanned",
                        });
                      }}
                    >
                      {Object.entries(p.availability).map(([value, label]) => (
                        <option value={value} key={value}>
                          {label}
                        </option>
                      ))}
                    </Select>
                  </label>
                  {day.availability === "Working" && !day.cancel && (
                    <label>
                      <span>{p.workLocation}</span>
                      <Select
                        aria-label={`${p.workLocation} ${dateKey(day.localDate)}`}
                        value={day.location}
                        onChange={(e) =>
                          update(index, {
                            location: e.target.value as WorkLocation,
                          })
                        }
                      >
                        <option value="RemotePortugal">
                          {p.location.RemotePortugal}
                        </option>
                        <option value="OfficeSwitzerland">
                          {p.location.OfficeSwitzerland}
                        </option>
                      </Select>
                    </label>
                  )}
                  {day.baseDayId && (
                    <label className="check-label">
                      <input
                        type="checkbox"
                        checked={day.cancel ?? false}
                        onChange={(e) =>
                          update(index, {
                            cancel: e.target.checked,
                            availability: "Working",
                            location: e.target.checked
                              ? "Unplanned"
                              : "RemotePortugal",
                          })
                        }
                      />
                      {p.cancelDay}
                    </label>
                  )}
                  <button
                    type="button"
                    aria-label={p.removeDate}
                    className="remove-day"
                    onClick={() =>
                      setDays((current) =>
                        current.filter((_, i) => i !== index),
                      )
                    }
                  >
                    <svg
                      aria-hidden="true"
                      viewBox="0 0 24 24"
                      width="20"
                      height="20"
                      fill="none"
                      stroke="currentColor"
                      strokeWidth="1.8"
                    >
                      <path d="M3 6h18M9 6V3h6v3M6 6l1 15h10l1-15M10 10v7m4-7v7" />
                    </svg>
                  </button>
                </div>
              ))}
            </div>
          </fieldset>
          <fieldset className="editor-section">
            <legend>{v.comment}</legend>
            <p className="muted">{p.manualHint}</p>
            <label>
              {editor.mode === "proposal" ? p.reason : p.note}
              <textarea
                maxLength={editor.mode === "proposal" ? 1000 : 2000}
                required={editor.mode === "proposal"}
                rows={3}
                value={note}
                onChange={(e) => setNote(e.target.value)}
              />
            </label>
          </fieldset>
        </fieldset>
        {error && (
          <p role="alert" className="notice error">
            {localizedFeedback(error)}
          </p>
        )}
        <div className="dialog-actions">
          <button type="button" disabled={locked} onClick={onClose}>
            {p.close}
          </button>
          <button
            className="primary"
            disabled={disabled || locked || loading || !days.length}
          >
            {editor.mode === "proposal"
              ? p.counterpropose
              : editor.mode === "revision"
                ? p.changeDraft
                : p.saveDraft}
          </button>
        </div>
      </form>
    </Dialog>
  );
}
