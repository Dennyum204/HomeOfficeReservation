import { useContext, useEffect } from "react";
import { ContextRead } from "./contextRead";

// Emitted by a rendered, authorized detail, never by the inbox or a push receipt.
export function ContextOpened({ id }: { id: string }) {
  const opened = useContext(ContextRead);
  useEffect(() => opened(id), [opened, id]);
  return null;
}
