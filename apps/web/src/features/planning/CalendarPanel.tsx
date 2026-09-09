import { useEffect, useRef } from "react";
import type { CalendarView } from "../../../../../contracts/typescript";
import { p } from "../../i18n/planning.pt-PT";
import { w } from "../../i18n/work.pt-PT";
import {
  addDays,
  addMonths,
  dateKey,
  dateValue,
  dayLabel,
  longDayLabel,
  period,
  todayInZone,
} from "./dates";
import { DayChip } from "./shared";
import { locationLabel } from "./labels";

interface Props {
  calendar: CalendarView;
  anchor: string;
  view: "month" | "week";
  active: string;
  selecting: boolean;
  selected: string[];
  canRequest: boolean;
  canManage?: boolean;
  onNewOnsite?: () => void;
  onRequirement?: (id: string) => void;
  disabled: boolean;
  onAnchor: (date: string) => void;
  onView: (view: "month" | "week") => void;
  onActive: (date: string) => void;
  onSelect: (date: string) => void;
  onSelecting: () => void;
  onNew: () => void;
  onRequest: (id: string) => void;
  onChange: (requestId: string, sourceDayId: string, cancel: boolean) => void;
}
export function CalendarPanel(props: Props) {
  const { calendar, anchor, view, active, selecting, selected, disabled } =
    props;
  const range = period(anchor, view);
  const today = todayInZone(calendar.planningTimeZone);
  const focusNext = useRef<string | null>(null);
  const grid = useRef<HTMLDivElement>(null);
  useEffect(() => {
    if (focusNext.current) {
      grid.current
        ?.querySelector<HTMLButtonElement>(
          `button[data-date="${focusNext.current}"]`,
        )
        ?.focus();
      focusNext.current = null;
    }
  }, [active, range.gridFrom]);
  const plans = new Map(
    calendar.effectiveDays.map((day) => [dateKey(day.localDate), day]),
  );
  const pending = calendar.pendingDays;
  const included = calendar.effectiveDays.filter(
    (day) =>
      dateKey(day.localDate) >= range.from &&
      dateKey(day.localDate) <= range.to,
  );
  const totals = [
    [
      p.remoteTotal,
      included.filter(
        (d) =>
          d.origin === "ApprovedRequest" &&
          d.location === "RemotePortugal" &&
          d.availability === "Working",
      ).length,
    ],
    [
      p.officeTotal,
      included.filter(
        (d) =>
          (d.origin === "ApprovedRequest" ||
            d.origin === "OnsiteRequirement") &&
          d.location === "OfficeSwitzerland" &&
          d.availability === "Working",
      ).length,
    ],
    [
      p.pendingTotal,
      new Set(
        pending
          .filter(
            (d) =>
              dateKey(d.day.localDate) >= range.from &&
              dateKey(d.day.localDate) <= range.to,
          )
          .map((d) => dateKey(d.day.localDate)),
      ).size,
    ],
    [
      p.awayTotal,
      included.filter(
        (d) => d.availability === "Leave" || d.availability === "Unavailable",
      ).length,
    ],
    [
      p.patternTotal,
      included.filter(
        (d) => d.origin === "WeeklyPattern" && d.availability === "Working",
      ).length,
    ],
  ];
  function keyboard(event: React.KeyboardEvent, date: string) {
    const weekday = (dateValue(date).getDay() + 6) % 7;
    const key = event.key;
    const target =
      key === "ArrowLeft"
        ? addDays(date, -1)
        : key === "ArrowRight"
          ? addDays(date, 1)
          : key === "ArrowUp"
            ? addDays(date, -7)
            : key === "ArrowDown"
              ? addDays(date, 7)
              : key === "Home"
                ? addDays(date, -weekday)
                : key === "End"
                  ? addDays(date, 6 - weekday)
                  : key === "PageUp"
                    ? addMonths(date, -1)
                    : key === "PageDown"
                      ? addMonths(date, 1)
                      : undefined;
    if (!target) return;
    event.preventDefault();
    focusNext.current = target;
    props.onActive(target);
    if (target < range.gridFrom || target > range.gridTo)
      props.onAnchor(target);
  }
  const detail = plans.get(active);
  const dayPending = pending.filter((d) => dateKey(d.day.localDate) === active);
  const move = (amount: number) => {
    const date =
      view === "month"
        ? addMonths(anchor, amount)
        : addDays(anchor, amount * 7);
    props.onAnchor(date);
    props.onActive(date);
  };
  return (
    <>
      <section className="period-summary" aria-label={p.period}>
        <div className="summary-caption">
          <span>{p.period}</span>
          <strong>
            {dayLabel(range.from)} — {dayLabel(range.to)}
          </strong>
        </div>
        <div className="summary-grid">
          {totals.map(([label, count]) => (
            <div className="summary-item" key={label}>
              <strong>{count}</strong>
              <span>{label}</span>
            </div>
          ))}
        </div>
        <p className="muted">{p.countedDays}</p>
      </section>
      <div className="calendar-layout">
        <section className="calendar-card" aria-label={p.calendar}>
          <div className="calendar-toolbar">
            <div className="calendar-heading">
              <h2 aria-live="polite">{range.label}</h2>
              <span className="muted">{calendar.planningTimeZone}</span>
            </div>
            <div className="button-row">
              <button aria-label={p.previous} onClick={() => move(-1)}>
                ‹
              </button>
              <button
                onClick={() => {
                  props.onAnchor(today);
                  props.onActive(today);
                }}
              >
                {p.today}
              </button>
              <button aria-label={p.next} onClick={() => move(1)}>
                ›
              </button>
            </div>
            <div className="segmented" aria-label={p.view}>
              <button
                aria-pressed={view === "month"}
                onClick={() => props.onView("month")}
              >
                {p.month}
              </button>
              <button
                aria-pressed={view === "week"}
                onClick={() => props.onView("week")}
              >
                {p.week}
              </button>
            </div>
          </div>
          {(props.canRequest || props.canManage) && (
            <div className="calendar-selection">
              <button
                disabled={disabled}
                aria-pressed={selecting}
                onClick={props.onSelecting}
              >
                {p.selectDates}
              </button>
              <span>
                {selected.length > 0
                  ? `${selected.length} ${p.days}`
                  : p.selectHelp}
              </span>
              <button
                className="primary"
                disabled={disabled}
                onClick={props.canManage ? props.onNewOnsite : props.onNew}
              >
                + {props.canManage ? w.newOnsite : p.newRequest}
              </button>
            </div>
          )}
          <div
            className={`calendar-grid ${view}`}
            ref={grid}
            role="grid"
            aria-label={`${p.calendar}: ${range.label}`}
          >
            <div role="row" className="weekday-row">
              {p.weekdayShort.map((day, index) => (
                <div
                  role="columnheader"
                  aria-label={p.weekdays[index]}
                  key={day}
                >
                  {day}
                </div>
              ))}
            </div>
            {Array.from({ length: range.days.length / 7 }, (_, row) => (
              <div role="row" className="calendar-week" key={row}>
                {range.days.slice(row * 7, row * 7 + 7).map((date) => {
                  const plan = plans.get(date);
                  const proposals = pending.filter(
                    (d) => dateKey(d.day.localDate) === date,
                  );
                  const obligations = (calendar.requirements ?? []).filter(
                    (r) => dateKey(r.from) <= date && dateKey(r.to) >= date,
                  );
                  const label = `${longDayLabel(date)}. ${plan ? `${locationLabel(plan.location, plan.availability)}, ${plan.origin === "WeeklyPattern" ? p.pattern : p.confirmed}` : p.neutral}${proposals.length ? `. ${p.pending}` : ""}`;
                  return (
                    <div role="gridcell" key={date}>
                      <button
                        data-date={date}
                        className={`calendar-day ${date < range.from || date > range.to ? "outside" : ""} ${date === active ? "active" : ""}`}
                        aria-label={`${label}${obligations.length ? `. ${obligations.map((r) => `${w.mandatory}: ${w.state[r.state]}`).join(". ")}` : ""}`}
                        aria-pressed={
                          selecting ? selected.includes(date) : date === active
                        }
                        aria-current={date === today ? "date" : undefined}
                        tabIndex={
                          active === date ||
                          (!range.days.includes(active) && date === range.from)
                            ? 0
                            : -1
                        }
                        onKeyDown={(event) => keyboard(event, date)}
                        onClick={() => {
                          props.onActive(date);
                          if (selecting) props.onSelect(date);
                        }}
                      >
                        <span className="day-number">
                          {dateValue(date).getDate()}
                          <span className="week-day-name">
                            {" "}
                            {p.weekdayShort[(dateValue(date).getDay() + 6) % 7]}
                          </span>
                          {selected.includes(date) && selecting && (
                            <span aria-hidden="true"> ✓</span>
                          )}
                        </span>
                        {plan &&
                          (plan.location !== "Unplanned" ||
                            plan.availability) && (
                            <DayChip
                              compact
                              location={plan.location}
                              availability={plan.availability}
                              pattern={plan.origin === "WeeklyPattern"}
                            />
                          )}
                        {proposals.map((d) => (
                          <DayChip
                            compact
                            key={d.day.id}
                            location={d.day.location}
                            availability={d.day.availability}
                            pending
                            cancel={d.day.cancel}
                          />
                        ))}
                        {obligations.length > 0 && (
                          <span
                            className={`onsite-chip ${obligations.some((r) => r.state === "NeedsResolution") ? "conflict" : ""}`}
                          >
                            ▣{" "}
                            {obligations.some(
                              (r) => r.state === "NeedsResolution",
                            )
                              ? w.state.NeedsResolution
                              : w.onsite}
                          </span>
                        )}
                      </button>
                    </div>
                  );
                })}
              </div>
            ))}
          </div>
          <div className="calendar-legend" aria-label={p.legend}>
            <strong>{p.legend}</strong>
            <span>⌂ {p.location.RemotePortugal}</span>
            <span>▣ {p.location.OfficeSwitzerland}</span>
            <span>◷ {p.pending}</span>
            <span>☀ {p.availability.Leave}</span>
            <span>− {p.availability.Unavailable}</span>
            <span className="legend-pattern">· {p.pattern}</span>
            <span>▣ {w.mandatory}</span>
          </div>
        </section>
        <aside className="day-detail" aria-label={p.dayDetails}>
          <p className="eyebrow">{p.dayDetails}</p>
          <h2>{longDayLabel(active)}</h2>
          <h3>{p.effective}</h3>
          {detail ? (
            <>
              <DayChip
                location={detail.location}
                availability={detail.availability}
                pattern={detail.origin === "WeeklyPattern"}
              />
              <p className="muted">
                {detail.origin === "WeeklyPattern"
                  ? p.patternHint
                  : detail.origin === "OnsiteRequirement"
                    ? w.mandatory
                    : p.confirmed}
              </p>
            </>
          ) : (
            <p>{p.neutral}</p>
          )}
          {detail?.sourceRequestId && (
            <div className="stacked-actions">
              <button onClick={() => props.onRequest(detail.sourceRequestId!)}>
                {p.viewRequest}
              </button>
              {props.canRequest && (
                <>
                  <button
                    disabled={disabled}
                    onClick={() =>
                      props.onChange(
                        detail.sourceRequestId!,
                        detail.sourceDayId!,
                        false,
                      )
                    }
                  >
                    {p.proposeChange}
                  </button>
                  <button
                    disabled={disabled}
                    onClick={() =>
                      props.onChange(
                        detail.sourceRequestId!,
                        detail.sourceDayId!,
                        true,
                      )
                    }
                  >
                    {p.proposeCancellation}
                  </button>
                </>
              )}
            </div>
          )}
          <hr />
          <h3>{p.proposed}</h3>
          {dayPending.length ? (
            dayPending.map((d) => (
              <div className="pending-detail" key={d.day.id}>
                <DayChip
                  location={d.day.location}
                  availability={d.day.availability}
                  pending
                  cancel={d.day.cancel}
                />
                <button onClick={() => props.onRequest(d.requestId)}>
                  {p.viewRequest}
                </button>
              </div>
            ))
          ) : (
            <p className="muted">{p.noPending}</p>
          )}
          <p className="detail-note">{p.pendingHint}</p>
          {(calendar.requirements ?? [])
            .filter((r) => dateKey(r.from) <= active && dateKey(r.to) >= active)
            .map((r) => (
              <div className="onsite-day-detail" key={r.id}>
                <h3>{w.mandatory}</h3>
                <strong>{r.reason}</strong>
                <p>
                  {w.state[r.state]} · {r.location}
                </p>
                {r.state === "NeedsResolution" && (
                  <p className="notice conflict">{w.conflict}</p>
                )}
                <button onClick={() => props.onRequirement?.(r.id)}>
                  {w.onsite} · {w.revision} {r.revision}
                </button>
              </div>
            ))}
        </aside>
      </div>
    </>
  );
}
