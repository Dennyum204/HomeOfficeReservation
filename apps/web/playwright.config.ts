import { defineConfig, devices } from "@playwright/test";

export default defineConfig({
  testDir: "./tests",
  fullyParallel: false,
  retries: process.env.CI ? 1 : 0,
  reporter: [["list"]],
  use: { baseURL: "http://127.0.0.1:5174", trace: "off" },
  webServer: [
    {
      command:
        "dotnet run --project ../api/src/HomeOffice.Api -c Release --no-build --no-launch-profile --urls http://localhost:5083",
      url: "http://localhost:5083/health/live",
      reuseExistingServer: false,
      env: {
        ASPNETCORE_ENVIRONMENT: "Development",
        Auth__CookieSeconds: "4",
        Auth__RequestsPerMinute: "300",
      },
    },
    {
      command: "npm run dev -- --port 5174",
      env: { API_PROXY_TARGET: "http://localhost:5083" },
      url: "http://127.0.0.1:5174",
      reuseExistingServer: false,
    },
  ],
  projects: [
    { name: "desktop", use: { ...devices["Desktop Chrome"] } },
    {
      name: "small-screen",
      use: { ...devices["iPhone 13"], defaultBrowserType: "chromium" },
    },
  ],
});
