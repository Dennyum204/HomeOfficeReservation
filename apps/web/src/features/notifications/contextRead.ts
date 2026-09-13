import { createContext } from "react";
export const ContextRead = createContext<(id: string) => void>(() => {});
