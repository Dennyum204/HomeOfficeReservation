-- Operator-only aggregates. No event payload, person, device address or token.
SELECT 'outbox' AS queue, "State", count(*) AS count, max("Attempts") AS max_attempts,
       COALESCE(EXTRACT(EPOCH FROM now()-min("CreatedAt") FILTER (WHERE "State" IN (0,1))),0)::bigint AS oldest_pending_seconds
FROM "PlanningOutbox" GROUP BY "State"
UNION ALL
SELECT 'push', "State", count(*), max("Attempts"),
       COALESCE(EXTRACT(EPOCH FROM now()-min("CreatedAt") FILTER (WHERE "State" IN (0,1))),0)::bigint
FROM "PushDelivery" GROUP BY "State";
