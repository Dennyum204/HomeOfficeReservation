import {
  Configuration,
  WorkspaceApi,
} from "../../../../../contracts/typescript";

// Same-origin /api in production; Vite proxies /api to localhost:5080 in development.
export const workspaceApi = new WorkspaceApi(
  new Configuration({ basePath: "", credentials: "same-origin" }),
);
