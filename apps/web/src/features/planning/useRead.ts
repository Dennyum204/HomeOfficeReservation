import { useEffect, useState } from "react";
import { sessionFailure } from "./api";
import { statusOf } from "../auth/api";
export function useRead<T>(
  key: string,
  read: (signal: AbortSignal) => Promise<T>,
  scope = key,
) {
  const [snapshot, setSnapshot] = useState<{
    key: string;
    scope: string;
    data?: T;
    error?: unknown;
  }>();
  useEffect(() => {
    const controller = new AbortController();
    void read(controller.signal)
      .then((data) => {
        if (!controller.signal.aborted) setSnapshot({ key, scope, data });
      })
      .catch((error: unknown) => {
        if (!controller.signal.aborted) {
          sessionFailure(error);
          setSnapshot((previous) => ({
            key,
            scope,
            error,
            data:
              ![401, 403].includes(statusOf(error)) && previous?.scope === scope
                ? previous.data
                : undefined,
          }));
        }
      });
    return () => controller.abort();
  }, [key, read, scope]);
  return snapshot?.key === key
    ? { ...snapshot, loading: false }
    : {
        key,
        loading: true,
        data: snapshot?.scope === scope ? snapshot.data : undefined,
        error: undefined,
      };
}
