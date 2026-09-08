import {
  AccessApi,
  AuthApi,
  Configuration,
  ResponseError,
} from "../../../../../contracts/typescript";

const config = new Configuration({ basePath: "", credentials: "same-origin" });
export const authApi = new AuthApi(config);
export const accessApi = new AccessApi(config);
export const statusOf = (error: unknown) =>
  error instanceof ResponseError ? error.response.status : 0;
export async function csrf() {
  const token = await authApi.getCsrfToken();
  return {
    headers: {
      "Content-Type": "application/json",
      "X-CSRF-TOKEN": token.requestToken,
    },
  };
}
