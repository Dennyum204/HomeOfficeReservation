import { render, screen, waitFor } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { beforeEach, describe, expect, it, vi } from "vitest";
import { WorkspaceShell } from "./App";
import { workspaceApi } from "./features/workspace/api";

const metadata = {
  productName: "HomeOfficeReservation",
  apiVersion: "v1",
  serverTimeUtc: new Date("2026-09-08T10:15:00Z"),
  planningTimeZones: ["Europe/Lisbon", "Europe/Zurich"],
};

describe("workspace shell", () => {
  beforeEach(() => window.history.replaceState(null, "", "/"));
  it("restores a direct client route and follows browser back", async () => {
    window.history.replaceState(null, "", "/tasks");
    render(<WorkspaceShell />);
    expect(screen.getByRole("button", { name: "Tarefas" })).toHaveAttribute(
      "aria-current",
      "page",
    );
    await userEvent.click(screen.getByRole("button", { name: "Pedidos" }));
    expect(window.location.pathname).toBe("/requests");
    window.history.back();
    await waitFor(() =>
      expect(screen.getByRole("button", { name: "Tarefas" })).toHaveAttribute(
        "aria-current",
        "page",
      ),
    );
  });
  it("recovers from an API failure through the real retry control", async () => {
    const call = vi
      .spyOn(workspaceApi, "getWorkspaceInfo")
      .mockRejectedValueOnce(new Error("offline"))
      .mockResolvedValue(metadata);
    render(<WorkspaceShell />);
    await userEvent.click(screen.getByRole("button", { name: "Definições" }));
    expect(
      await screen.findByText("Não foi possível ligar ao serviço."),
    ).toBeVisible();
    await userEvent.click(
      screen.getByRole("button", { name: /Tentar novamente/ }),
    );
    expect(await screen.findByText("Serviço ligado")).toBeVisible();
    expect(screen.getByText("Europe/Lisbon · Europe/Zurich")).toBeVisible();
    expect(call).toHaveBeenCalledTimes(2);
  });

  it("labels planned areas honestly and navigates by keyboard", async () => {
    vi.spyOn(workspaceApi, "getWorkspaceInfo").mockResolvedValue(metadata);
    render(<WorkspaceShell />);
    await userEvent.click(screen.getByRole("button", { name: "Definições" }));
    const requests = screen.getByRole("button", { name: "Pedidos" });
    requests.focus();
    await userEvent.keyboard("{Enter}");
    expect(screen.getByRole("button", { name: "Tarefas" })).toBeVisible();
    expect(screen.getByRole("button", { name: "Presenças" })).toBeVisible();
    expect(requests).toHaveAttribute("aria-current", "page");
    expect(
      screen.queryByRole("button", { name: /Aprovar|Submeter/ }),
    ).not.toBeInTheDocument();
    await userEvent.click(screen.getByRole("button", { name: "Definições" }));
    await waitFor(() =>
      expect(screen.getByText("Serviço ligado")).toBeVisible(),
    );
  });
});
