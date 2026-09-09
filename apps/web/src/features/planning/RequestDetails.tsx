import {
  useCallback,
  useEffect,
  useRef,
  useState,
  type ReactNode,
} from "react";
import type {
  ProposalView,
  RequestedDayView,
  RequestView,
  SelectedDay,
} from "../../../../../contracts/typescript";
import { p } from "../../i18n/planning.pt-PT";
import { planningApi } from "./api";
import { dateKey, dayLabel, instantLabel } from "./dates";
import { DayChip, Dialog } from "./shared";
import { readError } from "./errors";
import { useRead } from "./useRead";
import type { RunCommand } from "./useCommand";

import { requestCounts } from "./requestCounts";
interface Review {
  action: "submit" | "approve" | "reject" | "withdraw" | "accept";
  title: string;
  calendarVersion: number;
  requestVersion: number;
  selection: SelectedDay[];
  days: RequestedDayView[];
  reason: string;
  proposal?: ProposalView;
}
interface Props {
  request: RequestView;
  employeeId: string;
  calendarVersion: number;
  own: boolean;
  manager: boolean;
  disabled: boolean;
  locked: boolean;
  nonce: number;
  notice: ReactNode;
  names: Record<string, string>;
  run: RunCommand;
  onEditor: (
    mode: "edit" | "revision" | "proposal",
    request: RequestView,
    days: RequestedDayView[],
    cancellation?: boolean,
    proposal?: ProposalView,
  ) => void;
  onRequest: (id: string) => void;
}
export function RequestDetails(props: Props) {
  const { request, employeeId, disabled, locked, own, manager, nonce } = props;
  const [selection, setSelection] = useState(
    request.days.filter((d) => d.decision === "Pending").map((d) => d.id),
  );
  const [reason, setReason] = useState("");
  const [text, setText] = useState("");
  const [error, setError] = useState("");
  const [review, setReview] = useState<Review>();
  const [commentPage, setCommentPage] = useState(0);
  const [proposalPage, setProposalPage] = useState(0);
  const heading = useRef<HTMLHeadingElement>(null);
  useEffect(() => {
    heading.current?.focus();
  }, []);
  const readComments = useCallback(
    (signal: AbortSignal) =>
      planningApi.listPlanningComments(
        { employeeId, requestId: request.id, offset: commentPage, limit: 25 },
        { signal },
      ),
    [employeeId, request.id, commentPage],
  );
  const readProposals = useCallback(
    (signal: AbortSignal) =>
      planningApi.listCounterproposals(
        { employeeId, requestId: request.id, offset: proposalPage, limit: 25 },
        { signal },
      ),
    [employeeId, request.id, proposalPage],
  );
  const comments = useRead(
    `${request.id}:comments:${commentPage}:${nonce}`,
    readComments,
    `${request.id}:comments:${commentPage}`,
  );
  const proposals = useRead(
    `${request.id}:proposals:${proposalPage}:${nonce}`,
    readProposals,
    `${request.id}:proposals:${proposalPage}`,
  );
  const chosen = request.days.filter((d) => selection.includes(d.id));
  const pendingSelection =
    chosen.length > 0 && chosen.every((d) => d.decision === "Pending");
  const approvedSelection =
    chosen.length > 0 && chosen.every((d) => d.decision === "Approved");
  function openReview(
    action: Review["action"],
    title: string,
    proposal?: ProposalView,
  ) {
    setError("");
    if (action === "reject" && !reason.trim()) {
      setError(p.reasonHelp);
      return;
    }
    const days = action === "submit" ? request.days : chosen;
    setReview({
      action,
      title,
      calendarVersion: props.calendarVersion,
      requestVersion: request.version,
      days,
      selection: days.map((d) => ({ dayId: d.id, expectedVersion: d.version })),
      reason,
      proposal,
    });
  }
  async function confirm() {
    if (!review) return;
    const base = { employeeId, requestId: request.id };
    const version = {
      expectedCalendarVersion: review.calendarVersion,
      expectedRequestVersion: review.requestVersion,
    };
    const outcome =
      review.action === "submit"
        ? await props.run(
            "submitPlanningRequest",
            { ...base, submitInput: version },
            review.title,
          )
        : review.action === "withdraw"
          ? await props.run(
              "withdrawPlanningDays",
              {
                ...base,
                withdrawInput: { ...version, days: review.selection },
              },
              review.title,
            )
          : review.action === "accept"
            ? await props.run(
                "acceptCounterproposal",
                {
                  employeeId,
                  proposalId: review.proposal!.id,
                  acceptProposalInput: {
                    expectedCalendarVersion: review.calendarVersion,
                    expectedProposalRevision: review.proposal!.revision,
                  },
                },
                review.title,
              )
            : await props.run(
                "decidePlanningDays",
                {
                  ...base,
                  decisionInput: {
                    ...version,
                    days: review.selection,
                    approve: review.action === "approve",
                    reason: review.reason,
                  },
                },
                review.title,
              );
    if (outcome === "success" || outcome === "stale") setReview(undefined);
  }
  return (
    <section className="request-detail" aria-label={p.requestDetails}>
      <div className="detail-heading">
        <div>
          <p className="eyebrow">
            {p.request} · {p.revision} {request.revision}
          </p>
          <h2 tabIndex={-1} ref={heading}>
            {request.note || p.request}
          </h2>
        </div>
        <span className={`status-badge ${request.state.toLowerCase()}`}>
          {p.requestState[request.state]}
        </span>
      </div>
      <p className="request-counts">{requestCounts(request)}</p>
      <p className="muted">
        {p.created} {instantLabel(request.createdAt)}
        {request.submittedAt &&
          ` · ${p.submitted} ${instantLabel(request.submittedAt)}`}
      </p>
      {request.parentRevisionId && (
        <button
          className="text-button"
          onClick={() => props.onRequest(request.parentRevisionId!)}
        >
          {p.previousRevision}
        </button>
      )}
      <h3>{p.decisions}</h3>
      <div className="button-row">
        <button
          disabled={disabled}
          onClick={() =>
            setSelection(
              request.days
                .filter((d) => d.decision === "Pending")
                .map((d) => d.id),
            )
          }
        >
          {p.selectPending}
        </button>
        <button disabled={disabled} onClick={() => setSelection([])}>
          {p.clearSelection}
        </button>
      </div>
      <div className="decision-days">
        {request.days.map((day) => (
          <article
            className="decision-day"
            data-request-date={dateKey(day.localDate)}
            key={day.id}
          >
            <label className="check-label">
              <input
                type="checkbox"
                aria-label={`${p.selected} ${dateKey(day.localDate)}`}
                disabled={
                  disabled || !["Pending", "Approved"].includes(day.decision)
                }
                checked={selection.includes(day.id)}
                onChange={(event) =>
                  setSelection((ids) =>
                    event.target.checked
                      ? [...ids, day.id]
                      : ids.filter((id) => id !== day.id),
                  )
                }
              />
              <strong>{dayLabel(dateKey(day.localDate))}</strong>
            </label>
            <DayChip
              location={day.location}
              availability={day.availability}
              pending={request.state !== "Draft" && day.decision === "Pending"}
              cancel={day.cancel}
              plain
            />
            <span className={`status-badge ${day.decision.toLowerCase()}`}>
              {request.state === "Draft"
                ? p.requestState.Draft
                : p.decision[day.decision]}
            </span>
            {day.reason && <p>{day.reason}</p>}
            {day.decidedAt && (
              <p className="muted">
                {p.decidedAt} {instantLabel(day.decidedAt)} ·{" "}
                {props.names[day.decidedBy ?? ""] ?? p.member}
              </p>
            )}
          </article>
        ))}
      </div>
      <div className="decision-actions">
        {own && request.state === "Draft" && (
          <>
            <button
              disabled={disabled}
              onClick={() => props.onEditor("edit", request, request.days)}
            >
              {p.editDraft}
            </button>
            <button
              className="primary"
              disabled={disabled}
              onClick={() => openReview("submit", p.submit)}
            >
              {p.submit}
            </button>
          </>
        )}
        {request.state !== "Draft" && (
          <>
            {(manager || own) && (
              <p className="muted">
                {p.selected}: {p.countDays(chosen.length)}
              </p>
            )}
            {own && (
              <>
                <button
                  disabled={disabled || !pendingSelection}
                  onClick={() => openReview("withdraw", p.withdraw)}
                >
                  {p.withdraw}
                </button>
                <button
                  disabled={disabled || !approvedSelection}
                  onClick={() => props.onEditor("revision", request, chosen)}
                >
                  {p.proposeChange}
                </button>
                <button
                  disabled={disabled || !approvedSelection}
                  onClick={() =>
                    props.onEditor("revision", request, chosen, true)
                  }
                >
                  {p.proposeCancellation}
                </button>
              </>
            )}
            {manager && (
              <>
                <label className="full-width">
                  {p.reason}
                  <textarea
                    rows={2}
                    maxLength={1000}
                    value={reason}
                    disabled={locked}
                    onChange={(e) => {
                      setReason(e.target.value);
                      setError("");
                    }}
                  />
                </label>
                <span className="muted full-width">{p.reasonHelp}</span>
                <button
                  className="primary"
                  disabled={disabled || !pendingSelection}
                  onClick={() => openReview("approve", p.approve)}
                >
                  {p.approve}
                </button>
                <button
                  disabled={disabled || !pendingSelection}
                  onClick={() => openReview("reject", p.reject)}
                >
                  {p.reject}
                </button>
                <button
                  disabled={disabled || !chosen.length}
                  onClick={() => props.onEditor("proposal", request, chosen)}
                >
                  {p.counterpropose}
                </button>
              </>
            )}
          </>
        )}
      </div>
      {error && (
        <p className="notice error" role="alert">
          {error}
        </p>
      )}
      <section className="context-section" aria-label={p.proposals}>
        <h3>{p.proposals}</h3>
        {proposals.loading && <p role="status">{p.loading}</p>}
        {!!proposals.error && <p role="alert">{readError(proposals.error)}</p>}
        {proposals.data?.items.length === 0 && (
          <p className="muted">{p.noProposals}</p>
        )}
        {proposals.data?.items.map((proposal) => (
          <article className="proposal-card" key={proposal.id}>
            <span className="status-badge">
              {p.proposalState[proposal.state]}
            </span>
            <h4>
              {p.revision} {proposal.revision} · {proposal.reason}
            </h4>
            <p className="muted">
              {props.names[proposal.authorId] ?? p.manager} ·{" "}
              {instantLabel(proposal.createdAt)}
            </p>
            <strong>{p.affected}</strong>
            <ul>
              {request.days
                .filter((d) => proposal.affectedDayIds.includes(d.id))
                .map((d) => (
                  <li key={d.id}>{dayLabel(dateKey(d.localDate))}</li>
                ))}
            </ul>
            <strong>{p.alternative}</strong>
            <ul>
              {proposal.days.map((d) => (
                <li key={dateKey(d.localDate)}>
                  {dayLabel(dateKey(d.localDate))} ·{" "}
                  {d.cancel ? p.cancellation : p.location[d.location]} ·{" "}
                  {p.availability[d.availability]}
                </li>
              ))}
            </ul>
            {proposal.acknowledgedAt && (
              <p>
                {p.acknowledged} {instantLabel(proposal.acknowledgedAt)}
              </p>
            )}
            {own && proposal.state === "Open" && (
              <button
                disabled={disabled}
                onClick={() => openReview("accept", p.acceptProposal, proposal)}
              >
                {p.acceptProposal}
              </button>
            )}
            {manager && proposal.state !== "Superseded" && (
              <button
                disabled={disabled}
                onClick={() =>
                  props.onEditor(
                    "proposal",
                    request,
                    request.days.filter((d) =>
                      proposal.affectedDayIds.includes(d.id),
                    ),
                    false,
                    proposal,
                  )
                }
              >
                {p.reviseProposal}
              </button>
            )}
            {proposal.acceptedRequestId && (
              <button
                className="text-button"
                onClick={() => props.onRequest(proposal.acceptedRequestId!)}
              >
                {p.openAccepted}
              </button>
            )}
          </article>
        ))}
        <div className="button-row">
          <button
            disabled={proposalPage === 0 || proposals.loading}
            onClick={() => setProposalPage((n) => n - 25)}
          >
            {p.previousPage}
          </button>
          <button
            disabled={proposals.data?.nextOffset == null || proposals.loading}
            onClick={() => setProposalPage(proposals.data!.nextOffset!)}
          >
            {p.nextPage}
          </button>
        </div>
      </section>
      <section className="context-section" aria-label={p.comments}>
        <h3>{p.comments}</h3>
        {comments.loading && <p role="status">{p.loading}</p>}
        {!!comments.error && <p role="alert">{readError(comments.error)}</p>}
        {comments.data?.items.length === 0 && (
          <p className="muted">{p.noComments}</p>
        )}
        {comments.data?.items.map((comment) => (
          <article className="comment" key={comment.id}>
            <strong>{props.names[comment.authorId] ?? p.member}</strong>
            <time dateTime={comment.createdAt.toISOString()}>
              {instantLabel(comment.createdAt)}
            </time>
            <p>{comment.text}</p>
            {comment.proposalId && <span className="muted">{p.proposals}</span>}
          </article>
        ))}
        <div className="button-row">
          <button
            disabled={!commentPage || comments.loading}
            onClick={() => setCommentPage((n) => n - 25)}
          >
            {p.previousPage}
          </button>
          <button
            disabled={comments.data?.nextOffset == null || comments.loading}
            onClick={() => setCommentPage(comments.data!.nextOffset!)}
          >
            {p.nextPage}
          </button>
        </div>
        <form
          onSubmit={(event) => {
            event.preventDefault();
            void props.run(
              "addPlanningComment",
              {
                employeeId,
                requestId: request.id,
                commentInput: {
                  expectedCalendarVersion: props.calendarVersion,
                  text,
                },
              },
              p.addComment,
            );
          }}
        >
          <label>
            {p.comment}
            <textarea
              value={text}
              disabled={locked}
              maxLength={2000}
              rows={2}
              onChange={(e) => setText(e.target.value)}
              required
            />
          </label>
          <button disabled={disabled || !text.trim()}>{p.addComment}</button>
        </form>
      </section>
      {review && (
        <Dialog
          title={p.review}
          locked={locked}
          onClose={() => setReview(undefined)}
        >
          {props.notice}
          <h3>{review.title}</h3>
          <p className="detail-note">
            {review.action === "accept"
              ? p.acceptHint
              : review.action === "withdraw"
                ? p.pendingHint
                : p.revisionHint}
          </p>
          <ul className="review-days">
            {(review.proposal?.days ?? review.days).map((d) => (
              <li key={dateKey(d.localDate)}>
                <strong>{dayLabel(dateKey(d.localDate))}</strong>
                <span>
                  {d.cancel ? p.cancellation : p.location[d.location]} ·{" "}
                  {p.availability[d.availability]}
                </span>
              </li>
            ))}
          </ul>
          {review.reason && <blockquote>{review.reason}</blockquote>}
          <div className="dialog-actions">
            <button disabled={locked} onClick={() => setReview(undefined)}>
              {p.back}
            </button>
            <button
              className="primary"
              disabled={disabled}
              onClick={() => {
                void confirm();
              }}
            >
              {p.confirm}
            </button>
          </div>
        </Dialog>
      )}
    </section>
  );
}
