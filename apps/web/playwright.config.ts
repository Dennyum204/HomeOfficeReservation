import { defineConfig, devices } from "@playwright/test";

export default defineConfig({
  testDir: "./tests",
  fullyParallel: true,
  retries: process.env.CI ? 1 : 0,
  reporter: [["list"], ["html", { open: "never" }]],
  use: { baseURL: "http://127.0.0.1:5173", trace: "retain-on-failure" },
  webServer: [
    {
      command:
        "dotnet run --project ../api/src/HomeOffice.Api -c Release --no-build --no-launch-profile --urls http://localhost:5080",
      url: "http://localhost:5080/health/live",
      reuseExistingServer: !process.env.CI,
      env: { ASPNETCORE_ENVIRONMENT: "Development" },
    },
    {
      command: "npm run dev",
      url: "http://127.0.0.1:5173",
      reuseExistingServer: !process.env.CI,
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
