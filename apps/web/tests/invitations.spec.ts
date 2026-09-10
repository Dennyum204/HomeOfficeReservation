import { readFileSync, readdirSync } from "node:fs";
import { join } from "node:path";
import { randomUUID } from "node:crypto";
import { test, expect } from "@playwright/test";
import type {
  AccessTokenResponse,
  InvitationPage,
  ProvisionMemberRequest,
} from "../../../contracts/typescript";

test("administratively invited member accepts through the existing Web screen and logs in", async ({
  page,
  request: http,
}) => {
  const accounts = JSON.parse(
    readFileSync(process.env.HO_DEV_ACCOUNTS!, "utf8"),
  );
  const settings = JSON.parse(
    readFileSync(
      new URL(
        "../../api/src/HomeOffice.Api/appsettings.Local.json",
        import.meta.url,
      ),
      "utf8",
    ),
  );
  const login = await http.post("/api/v1/auth/token/login", {
    data: {
      email: accounts.admin.email,
      password: accounts.admin.password,
    },
  });
  expect(login.status()).toBe(200);
  const token = (await login.json()) as AccessTokenResponse;
  const headers = { Authorization: `Bearer ${token.accessToken}` };
  const email = `web-ho014-${randomUUID()}@homeoffice.example`;
  const request: ProvisionMemberRequest = {
    email,
    displayName: "Convite Web sintético",
    isEmployee: true,
    isManager: false,
    isAccountAdministrator: false,
  };
  expect(
    (
      await http.post("/api/v1/admin/members", { headers, data: request })
    ).status(),
  ).toBe(204);
  expect(
    (
      await http.post("/api/v1/admin/members", { headers, data: request })
    ).status(),
  ).toBe(204); // Lost response recovery sends no second email.
  const folder = settings.Email.CaptureDirectory;
  let code = "";
  await expect
    .poll(() => {
      const captures = readdirSync(folder)
        .filter((f) => f.endsWith(".json"))
        .map((f) => JSON.parse(readFileSync(join(folder, f), "utf8")))
        .filter((m) => m.email === email);
      code = captures[0]?.code ?? "";
      return captures.length;
    })
    .toBe(1);
  if (process.env.GITHUB_ACTIONS === "true") console.log(`::add-mask::${code}`);
  await page.goto("/");
  await page.getByRole("button", { name: "Ainda não ativei a conta" }).click();
  await page.getByRole("button", { name: "Já tenho um código" }).click();
  await page.getByLabel("Email", { exact: true }).fill(email);
  await page.getByLabel("Código recebido").fill(code);
  await page
    .getByLabel("Palavra-passe", { exact: true })
    .fill(accounts.employee.password);
  await page.getByRole("button", { name: "Ativar conta", exact: true }).click();
  await expect(
    page.getByText("Palavra-passe definida. Pode iniciar sessão."),
  ).toBeVisible();
  await page
    .getByLabel("Palavra-passe", { exact: true })
    .fill(accounts.employee.password);
  await page.getByRole("button", { name: "Entrar", exact: true }).click();
  await expect(
    page.getByRole("region", { name: "Conta", exact: true }),
  ).toContainText("Convite Web sintético");
  const listing = await http.get("/api/v1/admin/invitations", { headers });
  expect(listing.status()).toBe(200);
  const invited = ((await listing.json()) as InvitationPage).members.filter(
    (m) => m.email === email,
  );
  expect(invited).toHaveLength(1);
  expect(invited[0].state).toBe("Accepted");
  expect(invited[0].emailConfirmed).toBe(true);
  expect(invited[0].isAccountAdministrator).toBe(false);
});
