import { useEffect, useId, useRef, type ReactNode } from "react";
import type {
  Availability,
  WorkLocation,
} from "../../../../../contracts/typescript";
import { locationIcon, locationLabel } from "./labels";
import { p } from "../../i18n/planning.pt-PT";

export function Dialog({
  title,
  children,
  onClose,
  locked = false,
}: {
  title: string;
  children: ReactNode;
  onClose: () => void;
  locked?: boolean;
}) {
  const dialog = useRef<HTMLDialogElement>(null);
  const titleId = useId();
  useEffect(() => {
    const previous = document.activeElement as HTMLElement | null;
    const element = dialog.current!;
    const previousOverflow = document.body.style.overflow;
    document.body.style.overflow = "hidden";
    element.showModal();
    element.querySelector<HTMLElement>("h2")?.focus();
    return () => {
      element.close();
      document.body.style.overflow = previousOverflow;
      if (previous?.isConnected) previous.focus();
    };
  }, []);
  return (
    <dialog
      ref={dialog}
      className="planning-dialog"
      aria-labelledby={titleId}
      onCancel={(event) => {
        event.preventDefault();
        if (!locked) onClose();
      }}
    >
      <div className="dialog-heading">
        <h2 id={titleId} tabIndex={-1}>
          {title}
        </h2>
        <button
          type="button"
          className="icon-button"
          aria-label={p.close}
          disabled={locked}
          onClick={onClose}
        >
          ×
        </button>
      </div>
      {children}
    </dialog>
  );
}
export function DayChip({
  location,
  availability,
  pattern = false,
  pending = false,
  cancel = false,
  plain = false,
  compact = false,
}: {
  location: WorkLocation;
  availability?: Availability | null;
  pattern?: boolean;
  pending?: boolean;
  cancel?: boolean;
  plain?: boolean;
  compact?: boolean;
}) {
  return (
    <span
      className={`day-chip ${pattern ? "pattern" : pending && !plain ? "pending" : availability && availability !== "Working" ? "away" : location === "RemotePortugal" ? "remote" : "office"}`}
    >
      <span className="chip-location">
        <span aria-hidden="true">{locationIcon(location, availability)}</span>
        <span className="chip-text">
          {cancel
            ? p.cancellation
            : compact
              ? availability && availability !== "Working"
                ? p.availability[availability]
                : p.locationShort[location]
              : locationLabel(location, availability)}
        </span>
      </span>
      {!plain && (
        <span
          className="chip-state"
          aria-label={pattern ? p.pattern : pending ? p.pending : p.confirmed}
        >
          <span aria-hidden="true">{pattern ? "↻" : pending ? "◷" : "✓"}</span>
          {!compact &&
            (pattern ? p.pattern : pending ? p.pending : p.confirmed)}
        </span>
      )}
    </span>
  );
}

export function StatusBadge({
  state,
  children,
}: {
  state: string;
  children: ReactNode;
}) {
  const icon = ["Approved", "Closed", "Done", "Accepted"].includes(state)
    ? "✓"
    : ["Pending", "Submitted", "Open", "InProgress"].includes(state)
      ? "◷"
      : state === "NeedsResolution"
        ? "!"
        : ["Rejected", "Cancelled"].includes(state)
          ? "×"
          : state === "Draft"
            ? "✎"
            : "·";
  return (
    <span className={`status-badge ${state.toLowerCase()}`}>
      <span aria-hidden="true">{icon}</span>
      {children}
    </span>
  );
}
