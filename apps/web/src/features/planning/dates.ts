export function dateKey(date: Date): string {
  return `${date.getFullYear()}-${String(date.getMonth() + 1).padStart(2, "0")}-${String(date.getDate()).padStart(2, "0")}`;
}
export function dateValue(key: string): Date {
  const [y, m, d] = key.split("-").map(Number);
  const value = new Date(y, m - 1, d, 12);
  if (!/^\d{4}-\d{2}-\d{2}$/.test(key) || dateKey(value) !== key)
    throw new Error("invalid_date");
  return value;
}
export function addDays(key: string, days: number): string {
  const value = dateValue(key);
  value.setDate(value.getDate() + days);
  return dateKey(value);
}
export function addMonths(key: string, months: number): string {
  const value = dateValue(key);
  const day = value.getDate();
  value.setDate(1);
  value.setMonth(value.getMonth() + months);
  const last = new Date(value.getFullYear(), value.getMonth() + 1, 0).getDate();
  value.setDate(Math.min(day, last));
  return dateKey(value);
}
export function todayInZone(zone = "Europe/Zurich"): string {
  const parts = new Intl.DateTimeFormat("en-CA", {
    timeZone: zone,
    year: "numeric",
    month: "2-digit",
    day: "2-digit",
  }).formatToParts(new Date());
  const part = (type: Intl.DateTimeFormatPartTypes) =>
    parts.find((p) => p.type === type)!.value;
  return `${part("year")}-${part("month")}-${part("day")}`;
}
export const dayLabel = (key: string) =>
  new Intl.DateTimeFormat("pt-PT", {
    day: "numeric",
    month: "short",
    year: "numeric",
  }).format(dateValue(key));
export const longDayLabel = (key: string) =>
  new Intl.DateTimeFormat("pt-PT", {
    weekday: "long",
    day: "numeric",
    month: "long",
    year: "numeric",
  }).format(dateValue(key));
export const instantLabel = (value: Date) =>
  new Intl.DateTimeFormat("pt-PT", {
    dateStyle: "short",
    timeStyle: "short",
  }).format(value);
export function period(anchor: string, view: "month" | "week") {
  const value = dateValue(anchor);
  const from =
    view === "month"
      ? `${anchor.slice(0, 7)}-01`
      : addDays(anchor, -((value.getDay() + 6) % 7));
  const to =
    view === "month"
      ? dateKey(new Date(value.getFullYear(), value.getMonth() + 1, 0, 12))
      : addDays(from, 6);
  const gridFrom =
    view === "month"
      ? addDays(from, -((dateValue(from).getDay() + 6) % 7))
      : from;
  const gridTo = view === "month" ? addDays(gridFrom, 41) : to;
  const days: string[] = [];
  for (let date = gridFrom; date <= gridTo; date = addDays(date, 1))
    days.push(date);
  const label =
    view === "month"
      ? new Intl.DateTimeFormat("pt-PT", {
          month: "long",
          year: "numeric",
        }).format(value)
      : `${dayLabel(from)} – ${dayLabel(to)}`;
  return { from, to, gridFrom, gridTo, days, label };
}
