import {
  act,
  fireEvent,
  render,
  screen,
  waitFor,
} from "@testing-library/react";
import { describe, it, vi, expect } from "vitest";
import {
  ResponseError,
  type MemberProfile,
} from "../../../../../contracts/typescript";
import { AuthGate } from "./AuthGate";
import { accessApi, authApi } from "./api";

const profile: MemberProfile = {
  active: true,
  displayName: "Colaborador de teste",
  email: "employee@test.example",
  isAccountAdministrator: false,
  isEmployee: true,
  isManager: false,
  memberId: "synthetic-member",
  organizationId: "synthetic-organization",
  organizationName: "Organização de teste",
};
function deferred<T>() {
  let resolve!: (value: T) => void;
  const promise = new Promise<T>((complete) => {
    resolve = complete;
  });
  return { promise, resolve };
}

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

  it("does not restore account data from a focus check started during logout", async () => {
    const lateProfile = deferred<MemberProfile>();
    const logout = deferred<void>();
    const getProfile = vi
      .spyOn(accessApi, "getCurrentMember")
      .mockResolvedValueOnce(profile)
      .mockReturnValueOnce(lateProfile.promise);
    vi.spyOn(authApi, "getCsrfToken").mockResolvedValue({
      requestToken: "synthetic-csrf",
    });
    const signOut = vi.spyOn(authApi, "logout").mockReturnValue(logout.promise);
    render(
      <AuthGate>
        <div>Private account data</div>
      </AuthGate>,
    );
    await screen.findByText("Private account data");
    fireEvent.click(screen.getByText("Terminar sessão"));
    await waitFor(() => expect(signOut).toHaveBeenCalled());
    fireEvent.focus(window);
    await waitFor(() => expect(getProfile).toHaveBeenCalledTimes(2));
    await act(async () => {
      logout.resolve();
    });
    expect(screen.queryByText("Private account data")).not.toBeInTheDocument();
    await act(async () => {
      lateProfile.resolve(profile);
    });
    expect(screen.queryByText("Private account data")).not.toBeInTheDocument();
  });

  it("ignores an older successful check after a newer check denies the session", async () => {
    const lateProfile = deferred<MemberProfile>();
    const getProfile = vi
      .spyOn(accessApi, "getCurrentMember")
      .mockResolvedValueOnce(profile)
      .mockReturnValueOnce(lateProfile.promise)
      .mockRejectedValueOnce(
        new ResponseError(new Response("", { status: 403 })),
      );
    render(
      <AuthGate>
        <div>Private account data</div>
      </AuthGate>,
    );
    await screen.findByText("Private account data");
    fireEvent.focus(window);
    await waitFor(() => expect(getProfile).toHaveBeenCalledTimes(2));
    fireEvent.focus(window);
    await screen.findByText(
      "Acesso não autorizado. Contacte o administrador da organização.",
    );
    await act(async () => {
      lateProfile.resolve(profile);
    });
    expect(screen.queryByText("Private account data")).not.toBeInTheDocument();
  });
});
