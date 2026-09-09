import type { useCommand } from "./useCommand";
import { p } from "../../i18n/planning.pt-PT";
export function CommandNotice({
  command,
  refreshing,
}: {
  command: ReturnType<typeof useCommand>;
  refreshing: boolean;
}) {
  return (
    <>
      {((command.error && !(command.stale && command.error === p.stale)) ||
        (command.journal && !command.busy)) && (
        <div className="notice warning" role="alert">
          <p>{command.error || p.uncertain}</p>
          {command.journal && (
            <>
              <strong>{command.journal.label}</strong>
              <button
                type="button"
                disabled={command.busy}
                onClick={() => {
                  void command.recover();
                }}
              >
                {command.busy ? p.recovering : p.recover}
              </button>
            </>
          )}
        </div>
      )}
      {command.stale && (
        <div className="notice warning">
          <p>{p.stale}</p>
          <button
            type="button"
            disabled={refreshing}
            onClick={command.reviewed}
          >
            {p.reviewed}
          </button>
        </div>
      )}
      {command.busy && <p role="status">{p.busy}</p>}
    </>
  );
}
