import {
  Configuration,
  NotificationsApi,
} from "../../../../../contracts/typescript";
export const notificationsApi = new NotificationsApi(
  new Configuration({ basePath: "", credentials: "same-origin" }),
);
