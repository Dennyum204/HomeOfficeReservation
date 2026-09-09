import { useCallback, useState } from "react";
import type {
  NotificationDestination,
  NotificationView,
} from "../../../../../contracts/typescript";
import { n } from "../../i18n/notifications.pt-PT";
import { csrf } from "../auth/api";
import { useMember } from "../auth/session";
import { sessionFailure } from "../planning/api";
import { useRead } from "../planning/useRead";
import { notificationsApi } from "./api";
import "./notifications.css";

export function NotificationCentre({
  tick,
  refresh,
  onOpen,
}: {
  tick: number;
  refresh: () => void;
  onOpen: (destination: NotificationDestination) => void;
}) {
  const actor = useMember()!.memberId;
  const [filter, setFilter] = useState("all");
  const [offset, setOffset] = useState(0);
  const [version, setVersion] = useState(0);
  const [busy, setBusy] = useState<string>();
  const [error, setError] = useState("");
  const [message, setMessage] = useState("");
  const load = useCallback(
    (signal: AbortSignal) =>
      notificationsApi.listNotifications(
        {
          offset,
          limit: 20,
          unreadOnly: filter === "unread",
          historical: filter === "archive",
        },
        { signal },
      ),
    [offset, filter],
  );
  const list = useRead(
    `${actor}:${filter}:${offset}:${tick}:${version}`,
    load,
    `${actor}:${filter}:${offset}`,
  );
  async function act(item: NotificationView, open: boolean) {
    if (busy) return;
    setBusy(item.id);
    setError("");
    setMessage("");
    try {
      if (open) {
        // Resolve again at click time; a notification is never authorization to the linked resource.
        const current = await notificationsApi.getNotification({
          notificationId: item.id,
        });
        if (current.destination) onOpen(current.destination);
        else setError(n.unavailable);
      } else {
        await notificationsApi.setNotificationRead(
          {
            notificationId: item.id,
            notificationReadInput: { read: item.readAt === null },
          },
          await csrf(),
        );
        setMessage(n.updated);
        setVersion((v) => v + 1);
        refresh();
      }
    } catch (failure) {
      sessionFailure(failure);
      setError(n.error);
    } finally {
      setBusy(undefined);
    }
  }
  return (
    <section className="notification-centre" aria-label={n.title}>
      <div className="notification-toolbar">
        <label>
          {n.filter}
          <select
            value={filter}
            onChange={(event) => {
              setFilter(event.target.value);
              setOffset(0);
            }}
          >
            <option value="all">{n.all}</option>
            <option value="unread">{n.unread}</option>
            <option value="archive">{n.archive}</option>
          </select>
        </label>
        <button
          onClick={() => {
            setVersion((v) => v + 1);
            refresh();
          }}
        >
          {n.refresh}
        </button>
      </div>
      <p className="muted">
        {filter === "archive" ? n.archiveHint : n.automatic}
      </p>
      {message && (
        <p className="notice success" role="status">
          {message}
        </p>
      )}
      {!!(error || list.error) && (
        <p className="notice error" role="alert">
          {error || n.error}
        </p>
      )}
      {list.loading && <p role="status">{n.loading}</p>}
      {list.data?.items.length === 0 && <p>{n.empty}</p>}
      <ul className="notification-list">
        {list.data?.items.map((item) => (
          <li
            key={item.id}
            data-notification-id={item.id}
            className={item.readAt ? "" : "unread"}
          >
            <div>
              <span className="notification-state">
                {item.readAt ? n.read : n.unreadLabel}
              </span>
              <h2>
                {n.events[item.eventType] ?? n.events["context.unavailable"]}
              </h2>
              <time dateTime={item.createdAt.toISOString()}>
                {item.createdAt.toLocaleString("pt-PT")}
              </time>
            </div>
            <div className="notification-actions">
              <button disabled={!!busy} onClick={() => void act(item, true)}>
                {n.open}
              </button>
              <button disabled={!!busy} onClick={() => void act(item, false)}>
                {item.readAt ? n.markUnread : n.markRead}
              </button>
            </div>
          </li>
        ))}
      </ul>
      <div className="notification-toolbar">
        <button
          disabled={offset === 0 || !!busy}
          onClick={() => setOffset(Math.max(0, offset - 20))}
        >
          {n.back}
        </button>
        <button
          disabled={list.data?.nextOffset == null || !!busy}
          onClick={() => setOffset(list.data!.nextOffset!)}
        >
          {n.more}
        </button>
      </div>
    </section>
  );
}
