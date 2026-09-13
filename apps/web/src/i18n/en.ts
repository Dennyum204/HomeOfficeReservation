import type { strings as stringsPt } from "./pt-PT";
export const strings: typeof stringsPt = {
  auth: {
    titles: {
      login: "Sign in to your workspace",
      activation: "Activate your account",
      recovery: "Recover access",
      activate: "Set password",
      reset: "New password",
    },
    submit: {
      login: "Sign in",
      activation: "Request activation code",
      recovery: "Request recovery code",
      activate: "Activate account",
      reset: "Save password",
    },
    intro: "Your HomeOffice account. No Microsoft or Outlook required.",
    email: "Email",
    password: "Password",
    code: "Code received",
    wait: "Please wait…",
    passwordHelp:
      "Use at least 12 characters, including an uppercase letter, lowercase letter, number and symbol.",
    controlled: "Accounts are created by your organisation's administrator.",
    invalid:
      "Unable to sign in. Check your details and account activation, or try again later.",
    invalidCode:
      "Unable to complete this action. Check the code, its validity and the password requirements.",
    sent: "If your account is eligible, you will receive a code. Check the activation or recovery message.",
    completed: "Password set. You can now sign in.",
    expired: "Your session expired. Please sign in again.",
    forbidden: "Access denied. Contact your organisation's administrator.",
    network:
      "Unable to verify your session. Check your connection and try again.",
    logoutFailed:
      "Unable to sign out on the server. Try again when you are connected.",
    limited: "Too many attempts. Wait a minute and try again.",
    loading: "Checking your session…",
    account: "Account",
    signedInAs: "Signed in as",
    employee: "Employee",
    manager: "Manager",
    admin: "Account administrator",
    check: "Check session",
    logout: "Sign out",
    back: "Back to sign in",
    activateLink: "I have not activated my account",
    haveCode: "I already have a code",
    recoverLink: "I forgot my password",
  },
  brand: "HomeOffice",
  brandCaption: "PORTUGAL / SWITZERLAND",
  navigation: "Main navigation",
  workspace: "Workspace",
  welcome: "Good work starts with a good plan.",
  introduction:
    "A place to organise your days, coordinate your team and work between Portugal and Switzerland.",
  foundation: "Initial version · under construction",
  scope:
    "The foundation is ready. Calendar and workflows will be available in the next stages.",
  nav: {
    calendar: "Calendar",
    requests: "Requests",
    tasks: "Tasks",
    notifications: "Notifications",
    settings: "Settings",
  },
  sections: {
    calendar: {
      eyebrow: "YOUR PLANNING",
      title: "Every day, in the right place.",
      description:
        "See remote days in Portugal, onsite days in Switzerland and pending requests in one calendar.",
      detail:
        "The calendar is not available yet. This version has no recorded days or approvals.",
      step: "Calendar in preparation",
    },
    requests: {
      eyebrow: "TEAM COORDINATION",
      title: "Plan together.",
      description:
        "Submit requests and track decisions, changes and conflicts in one place.",
      detail: "Request submission and approval are not available yet.",
      step: "Requests in preparation",
    },
    tasks: {
      eyebrow: "WORK WITH CONTEXT",
      title: "Know what needs your attention.",
      description:
        "Tasks assigned by your manager, deadlines and reasons for onsite work in Switzerland.",
      detail: "Tasks and required onsite days are not available yet.",
      step: "Tasks in preparation",
    },
    notifications: {
      eyebrow: "STAY INFORMED",
      title: "All your updates in one place.",
      description:
        "Decisions, requests and tasks will have in-app and mobile notifications.",
      detail: "In-app and push notifications are not available yet.",
      step: "Notifications in preparation",
    },
    settings: {
      eyebrow: "MADE FOR YOU",
      title: "Your workspace, your preferences.",
      description:
        "Your account works without Microsoft. Outlook integration will be an optional future feature.",
      detail:
        "Sessions are available. Preferences and Outlook will be added later.",
      step: "Settings in preparation",
    },
  },
  remote: "Remote in Portugal",
  onsite: "Onsite in Switzerland",
  locations: "Two countries. One shared plan.",
  locationsDetail: "Working dates belong to the application's calendar.",
  connectionTitle: "Service connection",
  connecting: "Connecting to the service…",
  connected: "Service connected",
  offline: "Unable to connect to the service.",
  offlineHelp: "Check that the API is running and try again.",
  refresh: "Refresh connection",
  retry: "Try again",
  received: "Server response",
  timeZones: "Planning time zones",
  independent: "No Microsoft account. No mandatory Outlook connection.",
  footer: "Built for a shared plan.",
  skip: "Skip to content",
};
import type { p as pPt } from "./planning.pt-PT";
export const p: typeof pPt = {
  draftCount: (count: number) =>
    `${count.toLocaleString("en-GB")} ${count === 1 ? "day in draft" : "days in draft"} · not submitted yet`,
  emptyPreview:
    "This range contains no working days. Review the dates or include weekends.",
  locationShort: {
    OfficeSwitzerland: "Onsite CH",
    RemotePortugal: "Remote PT",
    Unplanned: "No plan",
  },
  calendar: "Calendar",
  requests: "Requests",
  settings: "Settings",
  title: "Every day, in the right place.",
  intro:
    "Plan your days. Track what is confirmed and what still needs a decision.",
  teamIntro: "View plans and track requests for employees assigned to you.",
  activeTargets: "Web and Android",
  employee: "Selected employee",
  own: "My calendar",
  noEmployees: "You have no assigned employees to view.",
  noPlanning: "This account cannot access an employee calendar.",
  today: "Today",
  previous: "Previous period",
  next: "Next period",
  month: "Month",
  week: "Week",
  view: "Calendar view",
  weekdays: [
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
    "Saturday",
    "Sunday",
  ],
  weekdayShort: ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"],
  legend: "Legend",
  pattern: "Weekly pattern",
  confirmed: "Confirmed",
  pending: "Pending",
  proposed: "Proposed change",
  effective: "Current plan",
  location: {
    OfficeSwitzerland: "Onsite · Switzerland",
    RemotePortugal: "Remote · Portugal",
    Unplanned: "No location",
  },
  availability: {
    Working: "Working",
    Leave: "Leave",
    Unavailable: "Unavailable",
  },
  decision: {
    Pending: "Pending",
    Approved: "Approved",
    Rejected: "Rejected",
    Withdrawn: "Withdrawn",
    Superseded: "Superseded",
    Cancelled: "Cancelled",
  },
  requestState: {
    Draft: "Draft",
    Submitted: "Awaiting decision",
    Closed: "Completed",
    Withdrawn: "Withdrawn",
  },
  proposalState: {
    Open: "Awaiting response",
    Accepted: "Accepted · awaiting final decision",
    Superseded: "Alternative superseded",
  },
  neutral: "No plan",
  source: "Source",
  dayDetails: "Day details",
  noPending: "No pending requests for this day.",
  patternHint: "The pattern is a usual forecast, not an approval.",
  pendingHint:
    "A pending change preserves the approved plan until the final decision.",
  period: "Period summary",
  countedDays:
    "Totals are days in the selected period; requests are counted separately in the list.",
  remoteTotal: "Approved remote days",
  officeTotal: "Confirmed onsite days",
  pendingTotal: "Pending days",
  awayTotal: "Leave / unavailable",
  patternTotal: "Pattern days",
  loading: "Loading planning…",
  refresh: "Refresh data",
  retry: "Try again",
  error: "Unable to retrieve data. Check your connection and try again.",
  forbidden: "You are not authorised to view or change this plan.",
  expired: "Your session expired. Please sign in again.",
  stale:
    "The plan changed. Data was refreshed and your text was preserved. Review the dates and decisions before resending.",
  reviewed: "I have reviewed the updated data",
  conflict:
    "Unable to apply the operation. Review the plan and selected dates.",
  errors: {
    pending_overlap:
      "There is already a pending request for one of these dates. Review it before submitting another proposal.",
    approved_day_requires_revision:
      "These dates have an approved plan. Use “Propose change” on the approved day or request; the existing approval is preserved.",
    stale_plan_base:
      "The approved plan has changed. Reopen the revision from the current plan; your text remains in this form.",
    date_outside_planning_window:
      "Choose dates from today up to two years ahead. Retroactive changes are not allowed.",
    duplicate_dates: "A date appears more than once. Review your selection.",
    invalid_text: "Check the text and provide a reason when required.",
    day_not_pending:
      "One of the selected days is no longer pending. Review the updated selection.",
    accepted_proposal_already_resolved:
      "This alternative has already been decided. Create a new counterproposal based on the current plan.",
    proposal_superseded:
      "This counterproposal was superseded. View the latest alternative.",
    proposal_not_open:
      "This counterproposal has already received a response. View the updated status.",
    idempotency_payload_mismatch:
      "This submission does not match the original command. Refresh the data and review the operation.",
    pattern_effective_date_must_advance:
      "The new effective date must follow the last pattern change.",
  },
  invalid: "Check the fields and dates before continuing.",
  limited: "Too many requests. Wait a minute and try again.",
  busy: "Sending…",
  success: "Operation confirmed by the server.",
  uncertain:
    "The submission response did not arrive. The outcome is still unknown. Recover the same submission before making another change.",
  recover: "Recover the same submission",
  recovering: "Recovering submission…",
  storage:
    "Unable to prepare recovery in this browser. Check that session storage is available.",
  newRequest: "Request my working days",
  selectDates: "Select dates",
  selectedDates: "Selected dates",
  selectHelp:
    "Choose days in the calendar or add a range. Arrow keys move focus; Enter or Space selects the day.",
  chooseDates: "Choose dates",
  addDate: "Add day",
  date: "Date",
  from: "From",
  to: "To",
  addRange: "Preview range",
  includeWeekends: "Include weekends",
  addIncluded: "Add these days",
  included: "Included days",
  emptyDates: "Select at least one date.",
  removeDate: "Remove day",
  note: "Request comment",
  reason: "Reason",
  reasonHelp: "Required for rejection and counterproposals.",
  workLocation: "Location",
  availabilityLabel: "Availability",
  manualHint:
    "Leave and unavailability are planning entries subject to a decision; they do not replace HR authorisation.",
  saveDraft: "Save draft",
  editDraft: "Edit draft",
  draftSaved: "Draft saved. Review the days and submit when ready.",
  review: "Review operation",
  confirm: "Confirm submission",
  close: "Close",
  back: "Back",
  submit: "Submit request",
  withdraw: "Withdraw pending days",
  approve: "Approve days",
  reject: "Reject days",
  selected: "Selected days",
  selectPending: "Select pending days",
  clearSelection: "Clear selection",
  viewRequest: "Open request",
  requestDetails: "Request details",
  revision: "Revision",
  previousRevision: "Open previous revision",
  created: "Created on",
  submitted: "Submitted on",
  decisions: "Decisions by day",
  decidedAt: "Decided on",
  by: "by",
  partial: "Partial decision",
  days: "days",
  requestsUnit: "requests",
  all: "All",
  filter: "Filter requests",
  page: "Page",
  noRequests: "No requests match this filter.",
  more: "Load more",
  previousPage: "Previous page",
  nextPage: "Next page",
  proposeChange: "Propose change",
  proposeCancellation: "Propose cancellation",
  revisionHint:
    "This revision changes only the included dates after approval. Until then, the confirmed plan is preserved.",
  cancelDay: "Cancel this day's approval",
  cancellation: "Proposed cancellation",
  original: "Original approved date",
  changeDraft: "Save revision as draft",
  counterpropose: "Create counterproposal",
  reviseProposal: "Revise counterproposal",
  proposals: "Counterproposals",
  noProposals: "No counterproposals.",
  acceptProposal: "Accept counterproposal",
  acceptHint:
    "Accepting this exact revision creates a pending request. The manager must still make the final decision.",
  affected: "Original days affected",
  alternative: "Proposed alternative",
  acknowledged: "Accepted on",
  openAccepted: "Open request created by acceptance",
  comments: "Comments",
  noComments: "No comments yet.",
  comment: "New comment",
  addComment: "Add comment",
  member: "Organisation member",
  manager: "Manager",
  collaborator: "Employee",
  settingsTitle: "Account and usual pattern",
  patternFrom: "New pattern effective from",
  patternSettingsHint:
    "A new effective date preserves previous history. The pattern does not change confirmed days or constitute approval.",
  savePattern: "Save new effective date",
  patternHistory: "Pattern history",
  noPatterns: "Initial pattern: onsite on weekdays; weekends unplanned.",
  accountSettings:
    "Member management is restricted to account administrators. It is not available in this planning interface.",
  plannedFeatures:
    "Calendar, requests, onsite requirements and tasks share the same plan on Web and Android. Outlook is optional and not available yet.",
  selectedOnly: "Select days whose status allows this action.",
  cancelHint:
    "Cancellation removes approval only after the manager's decision. The pattern then becomes visible again.",
  request: "Request",
  countDays: (count: number) =>
    `${count.toLocaleString("en-GB")} ${count === 1 ? "day" : "days"}`,
  counts: (approved: number, pending: number) =>
    `${approved.toLocaleString("en-GB")} ${approved === 1 ? "approved day" : "approved days"} · ${pending.toLocaleString("en-GB")} ${pending === 1 ? "pending day" : "pending days"}`,
};
import type { w as wPt } from "./work.pt-PT";
export const w: typeof wPt = {
  filter: "Filter by status",
  onsite: "Onsite requirements",
  tasks: "Tasks",
  newOnsite: "Require employee onsite attendance",
  newTask: "Assign task",
  onsiteIntro:
    "The manager requires attendance with dates and a reason. The employee acknowledges reading; any change to the approved plan requires a separate decision.",
  taskIntro:
    "Assigned work, deadlines and progress. Onsite need is informational.",
  state: {
    Active: "Active",
    NeedsResolution: "Needs resolution",
    Cancelled: "Cancelled",
  },
  taskState: {
    Todo: "To do",
    InProgress: "In progress",
    Done: "Done",
    Cancelled: "Cancelled",
  },
  reason: "Reason",
  location: "Place",
  reference: "Machine / project (optional)",
  from: "First day",
  to: "Last day",
  inclusive:
    "The range includes both end dates and weekends. Review all dates before confirming.",
  preview: "Preview conflicts",
  previewTitle: "Review before publishing",
  confirm: "Confirm onsite requirement",
  previewHint:
    "Review the dates, reason and conflicts. The approved plan is preserved until the change is resolved.",
  noConflicts: "No blocking conflicts at this time.",
  conflict: "The approved plan is preserved until an explicit resolution.",
  conflictCode: {
    approved_remote: "Approved remote work — preserved",
    approved_unavailability: "Approved unavailability — preserved",
    pending_request:
      "Pending request — preserved; future decision will be revalidated",
    different_onsite_location:
      "Another active onsite requirement at a different location",
    other_requirement: "Another onsite requirement in the range — preserved",
  },
  read: "Acknowledge reading this revision",
  readHint:
    "Acknowledging reading does not mean accepting a change to the approved plan.",
  readDone: "Reading acknowledged",
  unread: "Reading not yet acknowledged",
  edit: "Edit",
  cancelOnsite: "Cancel onsite requirement",
  confirmCancel: "Confirm cancellation",
  cancelHint:
    "Removes this requirement. Preserves approved decisions, other onsite requirements and linked tasks.",
  resolve: "Propose plan resolution",
  resolveHint:
    "Open each affected approval: the manager proposes onsite work, the employee accepts the alternative and the manager decides on the new revision. Editing or cancelling the requirement may also resolve the conflict.",
  linkedResolution: "Onsite resolution — revision",
  version: "Version",
  revision: "Revision",
  history: "Comments and history",
  comment: "Comment",
  sendComment: "Add comment",
  title: "Title",
  description: "Description",
  deadline: "Deadline",
  requiresOnsite: "Requires onsite work (informational)",
  requiresHint:
    "This option does not create an onsite requirement or change the calendar.",
  link: "Linked onsite requirement",
  noLink: "No link",
  linkHint:
    "The link follows the current revision. Editing or cancelling the onsite requirement does not change the task's status or deadline.",
  taskStatus: "Task status",
  saveTask: "Save task",
  progress: "Update progress",
  progressNote: "Progress note",
  terminal: "Task closed. Only the manager can reopen it.",
  emptyOnsite: "No onsite requirements match this filter yet.",
  emptyTasks: "No tasks match this filter yet.",
  choose: "Select an item to view its details.",
  close: "Close details",
  preserved: "Approved plan preserved",
  mandatory: "Required onsite attendance",
  newFromCalendar: "Create onsite requirement on selected dates",
  more: "See more",
  entryActions: {
    "onsite.created": "Onsite requirement created",
    "onsite.edited": "Onsite requirement changed",
    "onsite.cancelled": "Onsite requirement cancelled",
    "onsite.read": "Reading acknowledged",
    "onsite.revalidated": "Conflicts revalidated",
    "task.assigned": "Task assigned",
    "task.updated": "Task changed",
    "task.progress": "Progress updated",
    "work.commented": "Comment",
  },
  errors: {
    active_onsite_conflict:
      "There is an active onsite requirement on these dates. Change or cancel it before approving an incompatible location or availability.",
    requirement_cancelled:
      "This onsite requirement was cancelled. Refresh the data before continuing.",
    already_acknowledged:
      "This revision has already been read. Refresh the data.",
    invalid_onsite_resolution:
      "The resolution must propose onsite work on the requirement's dates.",
    task_terminal: "The task was closed. Ask the manager to reopen it.",
    invalid_task_progress: "Choose a permitted progress status.",
    requirement_not_found:
      "This onsite requirement is not available for this employee.",
    task_not_found: "This task is not available for this employee.",
  },
};
import type { n as nPt } from "./notifications.pt-PT";
export const n: typeof nPt = {
  title: "Notifications",
  intro:
    "Work updates with links to the current state of each request, onsite requirement or task.",
  unread: "Unread",
  all: "All current",
  archive: "History before notifications",
  filter: "Filter notifications",
  emptyUnread: "You have no unread notifications.",
  readFailed: "The context opened, but its read status could not be saved.",
  retryRead: "Retry saving read status",
  empty: "No notifications match this filter.",
  readFilter: "Read",
  read: "Read",
  unreadLabel: "Unread",
  markRead: "Mark as read",
  markUnread: "Mark as unread",
  open: "Open context",
  unavailable: "The context is no longer available. No decisions were changed.",
  error: "Unable to update notifications. Please try again.",
  refresh: "Refresh notifications",
  updated: "Read status saved.",
  loading: "Loading notifications…",
  more: "Next page",
  back: "Previous page",
  automatic:
    "Refreshes automatically while this page is visible. Reading does not approve requests or acknowledge onsite attendance.",
  archiveHint:
    "Events from before this centre was activated. They did not generate push messages and do not count as new notifications.",
  events: {
    "planning.submitted": "Request or revision submitted",
    "planning.withdrawn": "Request withdrawn",
    "planning.decided": "Decision recorded on request",
    "planning.counterproposed": "New counterproposal or change",
    "planning.counterproposal-accepted":
      "Counterproposal accepted — awaiting decision",
    "onsite.created": "New required onsite attendance",
    "onsite.edited": "Required onsite attendance changed",
    "onsite.cancelled": "Required onsite attendance cancelled",
    "task.assigned": "New task assigned",
    "task.updated": "Task changed",
    "context.unavailable": "Update unavailable",
  },
};
import type { appearance as appearancePt } from "./appearance.pt-PT";
export const appearance: typeof appearancePt = {
  title: "Appearance",
  description: "Choose how you prefer to view your workspace on this device.",
  label: "Interface theme",
  light: "Light",
  dark: "Dark",
  system: "System",
  storage:
    "This preference will be used for this session. It could not be saved on this device.",
  context: "Context and location",
  contextHint:
    "These values apply to days you add. You can adjust each day in the summary.",
  selection: "Date selection",
  mode: "How would you like to select days?",
  range: "Date range",
  single: "Individual days",
  rangeHint:
    "Choose the start and end. Review the included days before adding them to the summary.",
  singleHint:
    "Add one date at a time. You can combine days from different weeks.",
  summary: "Day summary",
  summaryHint:
    "Confirm the dates and location. Saving a draft does not submit the request.",
  comment: "Comment and context",
  actions: "Available actions",
  history: "History and context",
  noActions:
    "There are no actions for these days. The history remains available below.",
};
import type { a as aPt } from "./admin.pt-PT";
export const a: typeof aPt = {
  title: "Administration",
  intro:
    "Members, invitations and reporting relationships in your organisation.",
  members: "Organisation members",
  invite: "Invite member",
  search: "Search by name or email",
  empty: "No members found.",
  loading: "Loading members…",
  refresh: "Refresh members",
  more: "Show more members",
  forbidden: "You are not authorised to administer this organisation.",
  readError: "Unable to retrieve members. Check your connection and try again.",
  detail: "Manage member",
  close: "Back to list",
  identity: "Identity",
  name: "Name",
  email: "Invitation email",
  roles: "Roles and access",
  employee: "Employee",
  manager: "Manager",
  admin: "Administrator",
  active: "Active access",
  self: "This is your account. You can manage members and use your calendar. Only another administrator or the restricted operator procedure can change your roles and access.",
  saveRoles: "Review roles and access",
  saveManager: "Review relationship",
  currentManager: "Current manager",
  selectManager: "Assigned manager",
  none: "No manager assigned",
  unavailableManager:
    "Manager currently lacks authority; review the relationship or roles.",
  relationship: "Management and decisions",
  relationshipHelp:
    "Only a distinct, active and assigned manager can decide this employee's requests. Administration does not permit self-approval.",
  relationImpact:
    "Changing or removing the manager changes who can view and decide this employee's requests. The calendar and history are preserved.",
  roleImpact:
    "Permissions are enforced immediately by the API. Suspension blocks access; removing the manager role prevents decisions for assigned employees. Data and calendar are preserved. Removing the last active administrator is not permitted.",
  pendingImpact:
    "Warning: suspending an account before activation permanently cancels the invitation and invalidates its codes. A cancelled invitation cannot be reopened.",
  invitation: "Invitation and activation",
  delivery: "Email delivery",
  state: {
    Pending: "Awaiting acceptance",
    Accepted: "Accepted · account activated",
    Cancelled: "Cancelled",
  },
  deliveries: {
    Pending: "Queued · attempt pending",
    Sending: "Sending",
    Sent: "Sent to email service",
    Failed: "Delivery failed",
    Stopped: "Delivery stopped",
    Unknown: "No delivery record",
  },
  deliveryHelp:
    "Email sent does not mean invitation accepted. Activation finishes only when the person uses a valid code and sets their password.",
  failureHelp:
    "Delivery encountered a failure. The service retries while attempts remain. Refresh the status; once the limit is reached, ask the operator to fix the email service and resend the invitation.",
  codeExpired:
    "Code expired. The invitation remains pending; resend it to issue a new code.",
  codeValid: "Code valid until",
  resendAt: "Next resend available",
  attempts: "Delivery attempts",
  resend: "Resend invitation",
  cancel: "Cancel invitation",
  resendImpact:
    "A new code will be issued. The previous code will stop working. Resending respects server limits.",
  cancelImpact:
    "The invitation will be permanently cancelled and access disabled. No previous code can activate this account. This operation is not for already activated accounts.",
  confirm: "Confirm operation",
  back: "Back without sending",
  confirmTitle: "Review change",
  sendInvite: "Review invitation",
  inviteImpact:
    "A private account with these roles will be created and an activation invitation sent. The person sets their password on acceptance. This is not an invitation to install the APK.",
  busy: "Confirming operation…",
  success:
    "Operation confirmed by the API. Check the member's current state; delivery and acceptance are separate processes.",
  uncertain:
    "The response did not arrive. The operation may have been applied. Recover the same operation before making another change; do not create a second invitation.",
  recover: "Recover the same operation",
  stale:
    "The data changed in the meantime. The operation was not applied. Refresh members and review the change again.",
  storage:
    "Unable to save this operation for recovery in this browser. Nothing was sent. Enable session storage and try again.",
  error:
    "The operation was refused. Refresh members and review the data before trying again.",
  errors: {
    forbidden: "You are not authorised for this operation.",
    self_administration_denied: "You cannot change your own roles or access.",
    last_active_administrator:
      "The organisation must retain at least one active administrator.",
    invitation_cancelled:
      "This invitation is cancelled and cannot be reactivated.",
    invitation_unavailable:
      "This invitation no longer permits the operation. Check its current status.",
    invalid_relationship:
      "Choose a distinct, active manager for an active employee.",
    resend_limited:
      "The resend limit was reached. Check when resending becomes available.",
    invitation_limit: "The invitation limit was reached. Try again later.",
    account_exists:
      "This email is not available for a new invitation. Check existing members.",
    invalid_member: "Check the invitation's name, email and roles.",
  },
  suspended: "Suspended",
  enabled: "Active",
  noRoles: "No roles assigned",
  you: "Your account",
  unknown: "Unrecognised status",
  selected: "Selected member",
  timestampNone: "Not available",
};
