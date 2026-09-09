import type {
  Availability,
  WorkLocation,
} from "../../../../../contracts/typescript";
import { p } from "../../i18n/planning.pt-PT";
export function locationIcon(
  location: WorkLocation,
  availability?: Availability | null,
) {
  return availability === "Leave"
    ? "☀"
    : availability === "Unavailable"
      ? "−"
      : location === "RemotePortugal"
        ? "⌂"
        : location === "OfficeSwitzerland"
          ? "▣"
          : "·";
}
export function locationLabel(
  location: WorkLocation,
  availability?: Availability | null,
) {
  return availability && availability !== "Working"
    ? p.availability[availability]
    : location === "Unplanned"
      ? p.neutral
      : p.location[location];
}
