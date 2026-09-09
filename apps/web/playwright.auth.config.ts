import { defineConfig } from "@playwright/test";
import base from "./playwright.config";
export default defineConfig({
  ...base,
  testIgnore: [],
  testMatch: "auth.spec.ts",
  webServer: (Array.isArray(base.webServer) ? base.webServer : []).map(
    (server, index) =>
      index === 0
        ? { ...server, env: { ...server.env, Auth__CookieSeconds: "4" } }
        : server,
  ),
});
