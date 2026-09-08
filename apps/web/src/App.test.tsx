import { render, screen, waitFor } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { describe, expect, it, vi } from "vitest";
import { App } from "./App";
import { workspaceApi } from "./features/workspace/api";

const metadata = {
  productName: "HomeOfficeReservation",
  apiVersion: "v1",
  serverTimeUtc: new Date("2026-09-08T10:15:00Z"),
  planningTimeZones: ["Europe/Lisbon", "Europe/Zurich"],
};

describe("workspace shell", () => {
  it("recovers from an API failure through the real retry control", async () => {
    const call = vi
      .spyOn(workspaceApi, "getWorkspaceInfo")
      .mockRejectedValueOnce(new Error("offline"))
      .mockResolvedValue(metadata);
    render(<App />);
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
    render(<App />);
    const requests = screen.getByRole("button", { name: "Pedidos" });
    requests.focus();
    await userEvent.keyboard("{Enter}");
    expect(
      screen.getByText(
        "A submissão e a aprovação de pedidos ainda não estão disponíveis.",
      ),
    ).toBeVisible();
    expect(requests).toHaveAttribute("aria-current", "page");
    expect(
      screen.queryByRole("button", { name: /Aprovar|Submeter/ }),
    ).not.toBeInTheDocument();
    await waitFor(() =>
      expect(screen.getByText("Serviço ligado")).toBeVisible(),
    );
  });
});
