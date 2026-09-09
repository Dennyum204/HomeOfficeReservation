import { useEffect, useState } from "react";
import { useMember } from "../auth/session";
import { sessionFailure } from "../planning/api";
import { notificationsApi } from "./api";

export function useNotificationPolling() {
  const memberId = useMember()?.memberId;
  const [nonce, setNonce] = useState(0);
  const [state, setState] = useState<{
    actor?: string;
    count: number;
    tick: number;
    error?: unknown;
  }>({ count: 0, tick: 0 });
  useEffect(() => {
    if (!memberId) return;
    let disposed = false;
    let timer: ReturnType<typeof setTimeout> | undefined;
    let pending: AbortController | undefined;
    async function refresh() {
      clearTimeout(timer);
      pending?.abort();
      if (
        document.visibilityState === "hidden" ||
        !navigator.onLine ||
        disposed
      )
        return;
      const controller = new AbortController();
      pending = controller;
      try {
        const result = await notificationsApi.getNotificationUnreadCount({
          signal: controller.signal,
        });
        if (!disposed && !controller.signal.aborted)
          setState((old) => ({
            actor: memberId,
            count: result.unreadCount,
            tick: old.tick + 1,
          }));
      } catch (error) {
        if (!disposed && !controller.signal.aborted) {
          sessionFailure(error);
          setState((old) => ({
            actor: memberId,
            count: old.actor === memberId ? old.count : 0,
            tick: old.tick,
            error,
          }));
        }
      } finally {
        if (!disposed && !controller.signal.aborted)
          timer = setTimeout(() => void refresh(), 15000);
      }
    }
    const handle = () => void refresh();
    handle();
    document.addEventListener("visibilitychange", handle);
    window.addEventListener("online", handle);
    window.addEventListener("offline", handle);
    return () => {
      disposed = true;
      clearTimeout(timer);
      pending?.abort();
      document.removeEventListener("visibilitychange", handle);
      window.removeEventListener("online", handle);
      window.removeEventListener("offline", handle);
    };
  }, [memberId, nonce]);
  return {
    count: state.actor === memberId ? state.count : 0,
    tick: state.tick,
    error: state.actor === memberId ? state.error : undefined,
    refresh: () => setNonce((value) => value + 1),
  };
}
