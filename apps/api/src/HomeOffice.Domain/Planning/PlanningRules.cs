namespace HomeOffice.Domain.Planning;

public sealed class PlanningException(int status, string code) : Exception(code)
{
    public int Status { get; } = status;
    public string Code { get; } = code;
}

public static class PlanningRules
{
    public static void Require([System.Diagnostics.CodeAnalysis.DoesNotReturnIf(false)] bool condition, string code, int status = 409)
    {
        if (!condition) throw new PlanningException(status, code);
    }
    public static void Version(long? expected, long actual)
    {
        Require(expected is not null, "version_required", 428);
        Require(expected == actual, "stale_version", 412);
    }
    public static DateOnly Today(DateTimeOffset now, string zone) =>
        DateOnly.FromDateTime(TimeZoneInfo.ConvertTime(now, TimeZoneInfo.FindSystemTimeZoneById(zone)).DateTime);
    public static void Dates(DateOnly[] dates, DateOnly today)
    {
        Require(dates.Length is > 0 and <= 366, "invalid_day_count", 400);
        Require(dates.Distinct().Count() == dates.Length, "duplicate_dates", 400);
        Require(dates.All(d => d >= today && d <= today.AddDays(730)), "date_outside_planning_window", 400);
        Require(dates.Max().DayNumber - dates.Min().DayNumber < 366, "range_too_large", 400);
    }
    public static DateOnly[] Expand(DateOnly from, DateOnly to, bool includeWeekends)
    {
        Require(to >= from && to.DayNumber - from.DayNumber < 366, "invalid_range", 400);
        return Enumerable.Range(0, to.DayNumber - from.DayNumber + 1).Select(from.AddDays)
            .Where(d => includeWeekends || d.DayOfWeek is not (DayOfWeek.Saturday or DayOfWeek.Sunday)).ToArray();
    }
    public static void Dimensions(WorkLocation location, Availability availability, bool cancel)
    {
        Require(Enum.IsDefined(location) && Enum.IsDefined(availability), "invalid_dimensions", 400);
        Require(cancel ? location == WorkLocation.Unplanned && availability == Availability.Working :
            availability == Availability.Working ? location != WorkLocation.Unplanned : location == WorkLocation.Unplanned,
            "incompatible_dimensions", 400);
    }
    public static RequestState Summary(IEnumerable<RequestedDay> days) =>
        days.Any(d => d.Decision == DayDecision.Pending) ? RequestState.Submitted :
        days.All(d => d.Decision == DayDecision.Withdrawn) ? RequestState.Withdrawn : RequestState.Closed;
    public static WorkLocation DefaultLocation(DateOnly date) =>
        date.DayOfWeek is DayOfWeek.Saturday or DayOfWeek.Sunday ? WorkLocation.Unplanned : WorkLocation.OfficeSwitzerland;
}
