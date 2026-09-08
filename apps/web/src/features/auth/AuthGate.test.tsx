import { render, screen } from "@testing-library/react";
import { describe, it, vi, expect } from "vitest";
import { ResponseError } from "../../../../../contracts/typescript";
import { AuthGate } from "./AuthGate";
import { accessApi } from "./api";

describe("session guard with simulated responses", () => {
  it("removes protected content and explains forbidden membership", async () => {
    vi.spyOn(accessApi, "getCurrentMember").mockRejectedValue(
      new ResponseError(new Response("", { status: 403 })),
    );
    render(
      <AuthGate>
        <div>Private account data</div>
      </AuthGate>,
    );
    expect(
      await screen.findByText(
        "Acesso não autorizado. Contacte o administrador da organização.",
      ),
    ).toBeVisible();
    expect(screen.queryByText("Private account data")).not.toBeInTheDocument();
  });
});
