import type { strings as stringsPt } from "./pt-PT";
export const strings: typeof stringsPt = {
  auth: {
    titles: {
      login: "Bei Ihrem Arbeitsbereich anmelden",
      activation: "Konto aktivieren",
      recovery: "Zugang wiederherstellen",
      activate: "Passwort festlegen",
      reset: "Neues Passwort",
    },
    submit: {
      login: "Anmelden",
      activation: "Aktivierungscode anfordern",
      recovery: "Wiederherstellungscode anfordern",
      activate: "Konto aktivieren",
      reset: "Passwort speichern",
    },
    intro:
      "Ihr HomeOffice-Konto. Microsoft und Outlook sind nicht erforderlich.",
    email: "E-Mail",
    password: "Passwort",
    code: "Erhaltener Code",
    wait: "Bitte warten…",
    passwordHelp:
      "Verwenden Sie mindestens 12 Zeichen mit Grossbuchstaben, Kleinbuchstaben, Zahl und Sonderzeichen.",
    controlled:
      "Konten werden von der Administration Ihrer Organisation erstellt.",
    invalid:
      "Anmeldung nicht möglich. Prüfen Sie Ihre Angaben und die Kontoaktivierung oder versuchen Sie es später erneut.",
    invalidCode:
      "Vorgang nicht abgeschlossen. Prüfen Sie den Code, seine Gültigkeit und die Passwortanforderungen.",
    sent: "Wenn Ihr Konto berechtigt ist, erhalten Sie einen Code. Prüfen Sie die Aktivierungs- oder Wiederherstellungsnachricht.",
    completed: "Passwort festgelegt. Sie können sich jetzt anmelden.",
    expired: "Ihre Sitzung ist abgelaufen. Bitte melden Sie sich erneut an.",
    forbidden:
      "Zugriff verweigert. Wenden Sie sich an die Administration Ihrer Organisation.",
    network:
      "Sitzung konnte nicht geprüft werden. Prüfen Sie Ihre Verbindung und versuchen Sie es erneut.",
    logoutFailed:
      "Abmeldung auf dem Server fehlgeschlagen. Versuchen Sie es mit einer Verbindung erneut.",
    limited:
      "Zu viele Versuche. Warten Sie eine Minute und versuchen Sie es erneut.",
    loading: "Sitzung wird geprüft…",
    account: "Konto",
    signedInAs: "Angemeldet als",
    employee: "Mitarbeitende Person",
    manager: "Führungskraft",
    admin: "Kontoadministration",
    check: "Sitzung prüfen",
    logout: "Abmelden",
    back: "Zurück zur Anmeldung",
    activateLink: "Mein Konto ist noch nicht aktiviert",
    haveCode: "Ich habe bereits einen Code",
    recoverLink: "Ich habe mein Passwort vergessen",
  },
  brand: "HomeOffice",
  brandCaption: "PORTUGAL / SCHWEIZ",
  navigation: "Hauptnavigation",
  workspace: "Arbeitsbereich",
  welcome: "Gute Arbeit beginnt mit einem guten Plan.",
  introduction:
    "Ein Ort, um Arbeitstage zu planen, das Team abzustimmen und zwischen Portugal und der Schweiz zu arbeiten.",
  foundation: "Erste Version · im Aufbau",
  scope:
    "Die Grundlage ist bereit. Kalender und Arbeitsabläufe folgen in den nächsten Schritten.",
  nav: {
    calendar: "Kalender",
    requests: "Anträge",
    tasks: "Aufgaben",
    notifications: "Benachrichtigungen",
    settings: "Einstellungen",
  },
  sections: {
    calendar: {
      eyebrow: "IHRE PLANUNG",
      title: "Jeden Tag am richtigen Ort.",
      description:
        "Sehen Sie Remotetage in Portugal, Präsenztage in der Schweiz und offene Anträge in einem Kalender.",
      detail:
        "Der Kalender ist noch nicht verfügbar. In dieser Version sind keine Tage oder Genehmigungen erfasst.",
      step: "Kalender in Vorbereitung",
    },
    requests: {
      eyebrow: "TEAMABSTIMMUNG",
      title: "Gemeinsam planen.",
      description:
        "Stellen Sie Anträge und verfolgen Sie Entscheidungen, Änderungen und Konflikte an einem Ort.",
      detail: "Anträge und Genehmigungen sind noch nicht verfügbar.",
      step: "Anträge in Vorbereitung",
    },
    tasks: {
      eyebrow: "ARBEIT MIT KONTEXT",
      title: "Sehen Sie, was Ihre Aufmerksamkeit braucht.",
      description:
        "Aufgaben Ihrer Führungskraft, Fristen und Gründe für Präsenzarbeit in der Schweiz.",
      detail:
        "Aufgaben und verpflichtende Präsenztage sind noch nicht verfügbar.",
      step: "Aufgaben in Vorbereitung",
    },
    notifications: {
      eyebrow: "INFORMIERT BLEIBEN",
      title: "Alle Neuigkeiten an einem Ort.",
      description:
        "Entscheidungen, Anträge und Aufgaben erhalten Benachrichtigungen in der App und auf dem Mobilgerät.",
      detail: "App- und Push-Benachrichtigungen sind noch nicht verfügbar.",
      step: "Benachrichtigungen in Vorbereitung",
    },
    settings: {
      eyebrow: "AUF SIE ABGESTIMMT",
      title: "Ihr Arbeitsbereich, Ihre Einstellungen.",
      description:
        "Ihr Konto funktioniert ohne Microsoft. Eine optionale Outlook-Verbindung folgt später.",
      detail:
        "Sitzungen sind verfügbar. Einstellungen und Outlook folgen später.",
      step: "Einstellungen in Vorbereitung",
    },
  },
  remote: "Remote in Portugal",
  onsite: "Präsenz in der Schweiz",
  locations: "Zwei Länder. Ein gemeinsamer Plan.",
  locationsDetail: "Arbeitstage gehören zum Kalender der Anwendung.",
  connectionTitle: "Verbindung zum Dienst",
  connecting: "Verbindung zum Dienst wird hergestellt…",
  connected: "Dienst verbunden",
  offline: "Verbindung zum Dienst fehlgeschlagen.",
  offlineHelp: "Prüfen Sie, ob die API läuft, und versuchen Sie es erneut.",
  refresh: "Verbindung aktualisieren",
  retry: "Erneut versuchen",
  received: "Serverantwort",
  timeZones: "Planungszeitzonen",
  independent: "Kein Microsoft-Konto. Keine verpflichtende Outlook-Verbindung.",
  footer: "Für einen gemeinsamen Plan entwickelt.",
  skip: "Zum Inhalt springen",
};
import type { p as pPt } from "./planning.pt-PT";
export const p: typeof pPt = {
  draftCount: (count: number) =>
    `${count.toLocaleString("de")} ${count === 1 ? "Tag im Entwurf" : "Tage im Entwurf"} · noch nicht eingereicht`,
  emptyPreview:
    "Dieser Zeitraum enthält keine Arbeitstage. Prüfen Sie die Daten oder schliessen Sie Wochenenden ein.",
  locationShort: {
    OfficeSwitzerland: "Präsenz CH",
    RemotePortugal: "Remote PT",
    Unplanned: "Kein Plan",
  },
  calendar: "Kalender",
  requests: "Anträge",
  settings: "Einstellungen",
  title: "Jeden Tag am richtigen Ort.",
  intro:
    "Planen Sie Ihre Tage. Sehen Sie, was bestätigt ist und was noch eine Entscheidung braucht.",
  teamIntro:
    "Sehen Sie die Pläne und Anträge der Ihnen zugeordneten Mitarbeitenden.",
  activeTargets: "Web und Android",
  employee: "Ausgewählte mitarbeitende Person",
  own: "Mein Kalender",
  noEmployees: "Ihnen sind keine Mitarbeitenden zugeordnet.",
  noPlanning:
    "Dieses Konto hat keinen Zugriff auf einen Mitarbeitendenkalender.",
  today: "Heute",
  previous: "Vorheriger Zeitraum",
  next: "Nächster Zeitraum",
  month: "Monat",
  week: "Woche",
  view: "Kalenderansicht",
  weekdays: [
    "Montag",
    "Dienstag",
    "Mittwoch",
    "Donnerstag",
    "Freitag",
    "Samstag",
    "Sonntag",
  ],
  weekdayShort: ["Mo", "Di", "Mi", "Do", "Fr", "Sa", "So"],
  legend: "Legende",
  pattern: "Wochenmuster",
  confirmed: "Bestätigt",
  pending: "Ausstehend",
  proposed: "Vorgeschlagene Änderung",
  effective: "Gültiger Plan",
  location: {
    OfficeSwitzerland: "Präsenz · Schweiz",
    RemotePortugal: "Remote · Portugal",
    Unplanned: "Kein Arbeitsort",
  },
  availability: {
    Working: "Arbeitend",
    Leave: "Ferien",
    Unavailable: "Nicht verfügbar",
  },
  decision: {
    Pending: "Ausstehend",
    Approved: "Genehmigt",
    Rejected: "Abgelehnt",
    Withdrawn: "Zurückgezogen",
    Superseded: "Ersetzt",
    Cancelled: "Storniert",
  },
  requestState: {
    Draft: "Entwurf",
    Submitted: "Entscheidung ausstehend",
    Closed: "Abgeschlossen",
    Withdrawn: "Zurückgezogen",
  },
  proposalState: {
    Open: "Antwort ausstehend",
    Accepted: "Angenommen · endgültige Entscheidung ausstehend",
    Superseded: "Alternative ersetzt",
  },
  neutral: "Kein Plan",
  source: "Quelle",
  dayDetails: "Tagesdetails",
  noPending: "Keine offenen Anträge für diesen Tag.",
  patternHint: "Das Muster ist eine übliche Planung und keine Genehmigung.",
  pendingHint:
    "Eine ausstehende Änderung erhält den genehmigten Plan bis zur endgültigen Entscheidung.",
  period: "Zeitraumübersicht",
  countedDays:
    "Summen zählen Tage im ausgewählten Zeitraum; Anträge werden in der Liste separat gezählt.",
  remoteTotal: "Genehmigte Remotetage",
  officeTotal: "Bestätigte Präsenztage",
  pendingTotal: "Ausstehende Tage",
  awayTotal: "Ferien / nicht verfügbar",
  patternTotal: "Tage aus dem Muster",
  loading: "Planung wird geladen…",
  refresh: "Daten aktualisieren",
  retry: "Erneut versuchen",
  error:
    "Daten konnten nicht geladen werden. Prüfen Sie Ihre Verbindung und versuchen Sie es erneut.",
  forbidden: "Sie dürfen diesen Plan nicht ansehen oder ändern.",
  expired: "Ihre Sitzung ist abgelaufen. Bitte melden Sie sich erneut an.",
  stale:
    "Die Planung wurde geändert. Die Daten wurden aktualisiert und Ihr Text blieb erhalten. Prüfen Sie Daten und Entscheidungen vor dem erneuten Senden.",
  reviewed: "Ich habe die aktualisierten Daten geprüft",
  conflict:
    "Vorgang nicht angewendet. Prüfen Sie den Plan und die ausgewählten Daten.",
  errors: {
    pending_overlap:
      "Für eines dieser Daten gibt es bereits einen offenen Antrag. Prüfen Sie ihn, bevor Sie einen weiteren Vorschlag einreichen.",
    approved_day_requires_revision:
      "Für diese Daten besteht ein genehmigter Plan. Wählen Sie beim genehmigten Tag oder Antrag «Änderung vorschlagen»; die bisherige Genehmigung bleibt erhalten.",
    stale_plan_base:
      "Der genehmigte Plan wurde geändert. Öffnen Sie die Revision aus dem aktuellen Plan erneut; Ihr Text bleibt in diesem Formular erhalten.",
    date_outside_planning_window:
      "Wählen Sie Daten ab heute bis in zwei Jahren. Rückwirkende Änderungen sind nicht erlaubt.",
    duplicate_dates: "Ein Datum kommt mehrfach vor. Prüfen Sie Ihre Auswahl.",
    invalid_text:
      "Prüfen Sie den Text und geben Sie bei Bedarf einen Grund an.",
    day_not_pending:
      "Einer der ausgewählten Tage ist nicht mehr ausstehend. Prüfen Sie die aktualisierte Auswahl.",
    accepted_proposal_already_resolved:
      "Über diese Alternative wurde bereits entschieden. Erstellen Sie einen neuen Gegenvorschlag zum aktuellen Plan.",
    proposal_superseded:
      "Dieser Gegenvorschlag wurde ersetzt. Sehen Sie sich die neueste Alternative an.",
    proposal_not_open:
      "Auf diesen Gegenvorschlag wurde bereits geantwortet. Prüfen Sie den aktuellen Status.",
    idempotency_payload_mismatch:
      "Diese Übermittlung entspricht nicht dem ursprünglichen Auftrag. Aktualisieren Sie die Daten und prüfen Sie den Vorgang.",
    pattern_effective_date_must_advance:
      "Das neue Gültigkeitsdatum muss nach der letzten Musteränderung liegen.",
  },
  invalid: "Prüfen Sie Felder und Daten, bevor Sie fortfahren.",
  limited:
    "Zu viele Anfragen. Warten Sie eine Minute und versuchen Sie es erneut.",
  busy: "Wird gesendet…",
  success: "Vorgang vom Server bestätigt.",
  uncertain:
    "Die Antwort auf die Übermittlung fehlt. Das Ergebnis ist noch unbekannt. Stellen Sie denselben Vorgang wieder her, bevor Sie eine weitere Änderung vornehmen.",
  recover: "Dieselbe Übermittlung wiederherstellen",
  recovering: "Übermittlung wird wiederhergestellt…",
  storage:
    "Wiederherstellung in diesem Browser konnte nicht vorbereitet werden. Prüfen Sie, ob der Sitzungsspeicher verfügbar ist.",
  newRequest: "Meine Arbeitstage beantragen",
  selectDates: "Daten auswählen",
  selectedDates: "Ausgewählte Daten",
  selectHelp:
    "Wählen Sie Kalendertage oder fügen Sie einen Zeitraum hinzu. Pfeiltasten bewegen den Fokus; Eingabe oder Leertaste wählt den Tag aus.",
  chooseDates: "Daten wählen",
  addDate: "Tag hinzufügen",
  date: "Datum",
  from: "Von",
  to: "Bis",
  addRange: "Zeitraum prüfen",
  includeWeekends: "Wochenenden einschliessen",
  addIncluded: "Diese Tage hinzufügen",
  included: "Enthaltene Tage",
  emptyDates: "Wählen Sie mindestens ein Datum aus.",
  removeDate: "Tag entfernen",
  note: "Kommentar zum Antrag",
  reason: "Grund",
  reasonHelp: "Bei Ablehnung und Gegenvorschlägen erforderlich.",
  workLocation: "Arbeitsort",
  availabilityLabel: "Verfügbarkeit",
  manualHint:
    "Ferien und Nichtverfügbarkeit sind Planungseinträge, die einer Entscheidung bedürfen; sie ersetzen keine Personalbewilligung.",
  saveDraft: "Entwurf speichern",
  editDraft: "Entwurf bearbeiten",
  draftSaved:
    "Entwurf gespeichert. Prüfen Sie die Tage und reichen Sie ihn ein, wenn Sie bereit sind.",
  review: "Vorgang prüfen",
  confirm: "Übermittlung bestätigen",
  close: "Schliessen",
  back: "Zurück",
  submit: "Antrag einreichen",
  withdraw: "Ausstehende Tage zurückziehen",
  approve: "Tage genehmigen",
  reject: "Tage ablehnen",
  selected: "Ausgewählte Tage",
  selectPending: "Ausstehende Tage auswählen",
  clearSelection: "Auswahl aufheben",
  viewRequest: "Antrag öffnen",
  requestDetails: "Antragsdetails",
  revision: "Revision",
  previousRevision: "Vorherige Revision öffnen",
  created: "Erstellt am",
  submitted: "Eingereicht am",
  decisions: "Entscheidungen pro Tag",
  decidedAt: "Entschieden am",
  by: "von",
  partial: "Teilentscheidung",
  days: "Tage",
  requestsUnit: "Anträge",
  all: "Alle",
  filter: "Anträge filtern",
  page: "Seite",
  noRequests: "Keine Anträge in diesem Filter.",
  more: "Mehr laden",
  previousPage: "Vorherige Seite",
  nextPage: "Nächste Seite",
  proposeChange: "Änderung vorschlagen",
  proposeCancellation: "Stornierung vorschlagen",
  revisionHint:
    "Diese Revision ändert nur die enthaltenen Daten nach der Genehmigung. Bis dahin bleibt der bestätigte Plan erhalten.",
  cancelDay: "Genehmigung dieses Tages stornieren",
  cancellation: "Vorgeschlagene Stornierung",
  original: "Ursprünglich genehmigtes Datum",
  changeDraft: "Revision als Entwurf speichern",
  counterpropose: "Gegenvorschlag erstellen",
  reviseProposal: "Gegenvorschlag überarbeiten",
  proposals: "Gegenvorschläge",
  noProposals: "Keine Gegenvorschläge.",
  acceptProposal: "Gegenvorschlag annehmen",
  acceptHint:
    "Die Annahme genau dieser Revision erstellt einen offenen Antrag. Die Führungskraft muss weiterhin endgültig entscheiden.",
  affected: "Betroffene ursprüngliche Tage",
  alternative: "Vorgeschlagene Alternative",
  acknowledged: "Angenommen am",
  openAccepted: "Durch Annahme erstellten Antrag öffnen",
  comments: "Kommentare",
  noComments: "Noch keine Kommentare.",
  comment: "Neuer Kommentar",
  addComment: "Kommentar hinzufügen",
  member: "Organisationsmitglied",
  manager: "Führungskraft",
  collaborator: "Mitarbeitende Person",
  settingsTitle: "Konto und übliches Muster",
  patternFrom: "Neues Muster gültig ab",
  patternSettingsHint:
    "Ein neues Gültigkeitsdatum erhält den bisherigen Verlauf. Das Muster ändert keine bestätigten Tage und ist keine Genehmigung.",
  savePattern: "Neues Gültigkeitsdatum speichern",
  patternHistory: "Musterverlauf",
  noPatterns: "Anfangsmuster: Präsenz an Werktagen; Wochenenden ohne Plan.",
  accountSettings:
    "Die Mitgliederverwaltung ist der Kontoadministration vorbehalten. Sie ist in dieser Planungsansicht nicht verfügbar.",
  plannedFeatures:
    "Kalender, Anträge, Präsenzanforderungen und Aufgaben teilen denselben Plan in Web und Android. Outlook ist optional und noch nicht verfügbar.",
  selectedOnly: "Wählen Sie Tage mit einem für diese Aktion passenden Status.",
  cancelHint:
    "Eine Stornierung entfernt die Genehmigung erst nach der Entscheidung der Führungskraft. Danach wird das Muster wieder sichtbar.",
  request: "Antrag",
  countDays: (count: number) =>
    `${count.toLocaleString("de")} ${count === 1 ? "Tag" : "Tage"}`,
  counts: (approved: number, pending: number) =>
    `${approved.toLocaleString("de")} ${approved === 1 ? "genehmigter Tag" : "genehmigte Tage"} · ${pending.toLocaleString("de")} ${pending === 1 ? "ausstehender Tag" : "ausstehende Tage"}`,
};
import type { w as wPt } from "./work.pt-PT";
export const w: typeof wPt = {
  filter: "Nach Status filtern",
  onsite: "Präsenzanforderungen",
  tasks: "Aufgaben",
  newOnsite: "Präsenz der mitarbeitenden Person anfordern",
  newTask: "Aufgabe zuweisen",
  onsiteIntro:
    "Die Führungskraft verlangt Präsenz mit Daten und Grund. Mitarbeitende bestätigen das Lesen; jede Änderung des genehmigten Plans erfordert eine separate Entscheidung.",
  taskIntro:
    "Zugewiesene Arbeit, Fristen und Fortschritt. Der Präsenzbedarf dient zur Information.",
  state: {
    Active: "Aktiv",
    NeedsResolution: "Klärung erforderlich",
    Cancelled: "Storniert",
  },
  taskState: {
    Todo: "Offen",
    InProgress: "In Bearbeitung",
    Done: "Erledigt",
    Cancelled: "Storniert",
  },
  reason: "Grund",
  location: "Ort",
  reference: "Maschine / Projekt (optional)",
  from: "Erster Tag",
  to: "Letzter Tag",
  inclusive:
    "Der Zeitraum schliesst Anfangs- und Enddatum sowie Wochenenden ein. Prüfen Sie alle Daten vor der Bestätigung.",
  preview: "Konflikte prüfen",
  previewTitle: "Vor Veröffentlichung prüfen",
  confirm: "Präsenzanforderung bestätigen",
  previewHint:
    "Prüfen Sie Daten, Grund und Konflikte. Der genehmigte Plan bleibt bis zur Klärung der Änderung erhalten.",
  noConflicts: "Derzeit keine blockierenden Konflikte.",
  conflict:
    "Der genehmigte Plan bleibt bis zu einer ausdrücklichen Klärung erhalten.",
  conflictCode: {
    approved_remote: "Genehmigte Remotearbeit — bleibt erhalten",
    approved_unavailability: "Genehmigte Nichtverfügbarkeit — bleibt erhalten",
    pending_request:
      "Offener Antrag — bleibt erhalten; spätere Entscheidung wird erneut geprüft",
    different_onsite_location:
      "Andere aktive Präsenzanforderung an einem anderen Ort",
    other_requirement:
      "Andere Präsenzanforderung im Zeitraum — bleibt erhalten",
  },
  read: "Lesen dieser Revision bestätigen",
  readHint:
    "Eine Lesebestätigung bedeutet keine Zustimmung zu einer Änderung des genehmigten Plans.",
  readDone: "Lesen bestätigt",
  unread: "Lesebestätigung ausstehend",
  edit: "Bearbeiten",
  cancelOnsite: "Präsenzanforderung stornieren",
  confirmCancel: "Stornierung bestätigen",
  cancelHint:
    "Entfernt diese Anforderung. Genehmigte Entscheidungen, andere Präsenzanforderungen und verknüpfte Aufgaben bleiben erhalten.",
  resolve: "Planlösung vorschlagen",
  resolveHint:
    "Öffnen Sie jede betroffene Genehmigung: Die Führungskraft schlägt Präsenz vor, die mitarbeitende Person nimmt die Alternative an, dann entscheidet die Führungskraft über die neue Revision. Auch eine Änderung oder Stornierung der Anforderung kann den Konflikt lösen.",
  linkedResolution: "Präsenzklärung — Revision",
  version: "Version",
  revision: "Revision",
  history: "Kommentare und Verlauf",
  comment: "Kommentar",
  sendComment: "Kommentar hinzufügen",
  title: "Titel",
  description: "Beschreibung",
  deadline: "Frist",
  requiresOnsite: "Erfordert Präsenzarbeit (informativ)",
  requiresHint:
    "Diese Option erstellt keine Präsenzanforderung und ändert den Kalender nicht.",
  link: "Verknüpfte Präsenzanforderung",
  noLink: "Keine Verknüpfung",
  linkHint:
    "Die Verknüpfung folgt der aktuellen Revision. Änderungen oder Stornierungen der Präsenzanforderung ändern weder Aufgabenstatus noch Frist.",
  taskStatus: "Aufgabenstatus",
  saveTask: "Aufgabe speichern",
  progress: "Fortschritt aktualisieren",
  progressNote: "Fortschrittsnotiz",
  terminal:
    "Aufgabe abgeschlossen. Nur die Führungskraft kann sie wieder öffnen.",
  emptyOnsite: "Noch keine Präsenzanforderungen in diesem Filter.",
  emptyTasks: "Noch keine Aufgaben in diesem Filter.",
  choose: "Wählen Sie einen Eintrag, um die Details zu sehen.",
  close: "Details schliessen",
  preserved: "Genehmigter Plan bleibt erhalten",
  mandatory: "Verpflichtende Präsenz",
  newFromCalendar: "Präsenzanforderung für ausgewählte Daten erstellen",
  more: "Mehr anzeigen",
  entryActions: {
    "onsite.created": "Präsenzanforderung erstellt",
    "onsite.edited": "Präsenzanforderung geändert",
    "onsite.cancelled": "Präsenzanforderung storniert",
    "onsite.read": "Lesen bestätigt",
    "onsite.revalidated": "Konflikte erneut geprüft",
    "task.assigned": "Aufgabe zugewiesen",
    "task.updated": "Aufgabe geändert",
    "task.progress": "Fortschritt aktualisiert",
    "work.commented": "Kommentar",
  },
  errors: {
    active_onsite_conflict:
      "Für diese Daten besteht eine aktive Präsenzanforderung. Ändern oder stornieren Sie sie, bevor Sie einen unvereinbaren Arbeitsort oder eine unvereinbare Verfügbarkeit genehmigen.",
    requirement_cancelled:
      "Diese Präsenzanforderung wurde storniert. Aktualisieren Sie die Daten, bevor Sie fortfahren.",
    already_acknowledged:
      "Diese Revision wurde bereits gelesen. Aktualisieren Sie die Daten.",
    invalid_onsite_resolution:
      "Die Lösung muss Präsenzarbeit an den Daten dieser Anforderung vorschlagen.",
    task_terminal:
      "Die Aufgabe wurde abgeschlossen. Bitten Sie die Führungskraft, sie wieder zu öffnen.",
    invalid_task_progress: "Wählen Sie einen zulässigen Fortschrittsstatus.",
    requirement_not_found:
      "Diese Präsenzanforderung ist für diese mitarbeitende Person nicht verfügbar.",
    task_not_found:
      "Diese Aufgabe ist für diese mitarbeitende Person nicht verfügbar.",
  },
};
import type { n as nPt } from "./notifications.pt-PT";
export const n: typeof nPt = {
  title: "Benachrichtigungen",
  intro:
    "Neuigkeiten zu Ihrer Arbeit mit Links zum aktuellen Stand jedes Antrags, jeder Präsenzanforderung oder Aufgabe.",
  unread: "Ungelesen",
  all: "Alle aktuellen",
  archive: "Verlauf vor Benachrichtigungen",
  filter: "Benachrichtigungen filtern",
  emptyUnread: "Sie haben keine ungelesenen Benachrichtigungen.",
  readFailed:
    "Der Kontext wurde geöffnet, aber der Lesestatus konnte nicht gespeichert werden.",
  retryRead: "Lesestatus erneut speichern",
  empty: "Keine Benachrichtigungen in diesem Filter.",
  readFilter: "Gelesen",
  read: "Gelesen",
  unreadLabel: "Ungelesen",
  markRead: "Als gelesen markieren",
  markUnread: "Als ungelesen markieren",
  open: "Kontext öffnen",
  unavailable:
    "Der Kontext ist nicht mehr verfügbar. Es wurden keine Entscheidungen geändert.",
  error:
    "Benachrichtigungen konnten nicht aktualisiert werden. Bitte versuchen Sie es erneut.",
  refresh: "Benachrichtigungen aktualisieren",
  updated: "Lesestatus gespeichert.",
  loading: "Benachrichtigungen werden geladen…",
  more: "Nächste Seite",
  back: "Vorherige Seite",
  automatic:
    "Wird automatisch aktualisiert, solange diese Seite sichtbar ist. Lesen genehmigt keine Anträge und bestätigt keine Präsenzanforderungen.",
  archiveHint:
    "Ereignisse vor der Aktivierung dieses Bereichs. Sie haben keine Push-Nachrichten erzeugt und zählen nicht als neue Benachrichtigungen.",
  events: {
    "planning.submitted": "Antrag oder Revision eingereicht",
    "planning.withdrawn": "Antrag zurückgezogen",
    "planning.decided": "Entscheidung zum Antrag erfasst",
    "planning.counterproposed": "Neuer Gegenvorschlag oder Änderung",
    "planning.counterproposal-accepted":
      "Gegenvorschlag angenommen — Entscheidung ausstehend",
    "onsite.created": "Neue verpflichtende Präsenz",
    "onsite.edited": "Verpflichtende Präsenz geändert",
    "onsite.cancelled": "Verpflichtende Präsenz storniert",
    "task.assigned": "Neue Aufgabe zugewiesen",
    "task.updated": "Aufgabe geändert",
    "context.unavailable": "Aktualisierung nicht verfügbar",
  },
};
import type { appearance as appearancePt } from "./appearance.pt-PT";
export const appearance: typeof appearancePt = {
  title: "Darstellung",
  description:
    "Wählen Sie, wie Ihr Arbeitsbereich auf diesem Gerät dargestellt wird.",
  label: "Oberflächendesign",
  light: "Hell",
  dark: "Dunkel",
  system: "System",
  storage:
    "Diese Einstellung gilt für diese Sitzung. Sie konnte auf diesem Gerät nicht gespeichert werden.",
  context: "Kontext und Arbeitsort",
  contextHint:
    "Diese Werte gelten für hinzugefügte Tage. Sie können jeden Tag in der Übersicht anpassen.",
  selection: "Datumsauswahl",
  mode: "Wie möchten Sie Tage auswählen?",
  range: "Zeitraum",
  single: "Einzelne Tage",
  rangeHint:
    "Wählen Sie Anfang und Ende. Prüfen Sie die enthaltenen Tage, bevor Sie sie zur Übersicht hinzufügen.",
  singleHint:
    "Fügen Sie jeweils ein Datum hinzu. Sie können Tage aus verschiedenen Wochen kombinieren.",
  summary: "Tagesübersicht",
  summaryHint:
    "Bestätigen Sie Daten und Arbeitsort. Das Speichern eines Entwurfs reicht den Antrag noch nicht ein.",
  comment: "Kommentar und Kontext",
  actions: "Verfügbare Aktionen",
  history: "Verlauf und Kontext",
  noActions:
    "Für diese Tage gibt es keine Aktionen. Der Verlauf bleibt unten verfügbar.",
};
import type { a as aPt } from "./admin.pt-PT";
export const a: typeof aPt = {
  title: "Administration",
  intro: "Mitglieder, Einladungen und Führungszuordnungen Ihrer Organisation.",
  members: "Organisationsmitglieder",
  invite: "Mitglied einladen",
  search: "Nach Name oder E-Mail suchen",
  empty: "Keine Mitglieder gefunden.",
  loading: "Mitglieder werden geladen…",
  refresh: "Mitglieder aktualisieren",
  more: "Weitere Mitglieder anzeigen",
  forbidden: "Sie dürfen diese Organisation nicht verwalten.",
  readError:
    "Mitglieder konnten nicht geladen werden. Prüfen Sie Ihre Verbindung und versuchen Sie es erneut.",
  detail: "Mitglied verwalten",
  close: "Zurück zur Liste",
  identity: "Identifikation",
  name: "Name",
  email: "Einladungs-E-Mail",
  roles: "Rollen und Zugriff",
  employee: "Mitarbeitende Person",
  manager: "Führungskraft",
  admin: "Administration",
  active: "Aktiver Zugriff",
  self: "Dies ist Ihr Konto. Sie können Mitglieder verwalten und Ihren Kalender nutzen. Nur eine andere Administration oder das beschränkte Betreiberverfahren kann Ihre Rollen und Ihren Zugriff ändern.",
  saveRoles: "Rollen und Zugriff prüfen",
  saveManager: "Zuordnung prüfen",
  currentManager: "Aktuelle Führungskraft",
  selectManager: "Zugeordnete Führungskraft",
  none: "Keine Führungskraft zugeordnet",
  unavailableManager:
    "Die Führungskraft hat derzeit keine Berechtigung; prüfen Sie Zuordnung oder Rollen.",
  relationship: "Führung und Entscheidungen",
  relationshipHelp:
    "Nur eine andere, aktive und zugeordnete Führungskraft darf die Anträge dieser Person entscheiden. Administration erlaubt keine Selbstgenehmigung.",
  relationImpact:
    "Eine Änderung oder Entfernung der Führungskraft ändert, wer die Anträge dieser Person sehen und entscheiden darf. Kalender und Verlauf bleiben erhalten.",
  roleImpact:
    "Die API setzt Berechtigungen sofort durch. Eine Sperrung blockiert den Zugriff; ohne Führungsrolle sind Entscheidungen für zugeordnete Mitarbeitende nicht möglich. Daten und Kalender bleiben erhalten. Die letzte aktive Administration darf nicht entfernt werden.",
  pendingImpact:
    "Achtung: Eine Sperrung vor der Kontoaktivierung storniert die Einladung endgültig und macht ihre Codes ungültig. Eine stornierte Einladung kann nicht wieder geöffnet werden.",
  invitation: "Einladung und Aktivierung",
  delivery: "E-Mail-Zustellung",
  state: {
    Pending: "Annahme ausstehend",
    Accepted: "Angenommen · Konto aktiviert",
    Cancelled: "Storniert",
  },
  deliveries: {
    Pending: "In Warteschlange · Versuch ausstehend",
    Sending: "Wird gesendet",
    Sent: "An E-Mail-Dienst gesendet",
    Failed: "Zustellung fehlgeschlagen",
    Stopped: "Zustellung beendet",
    Unknown: "Kein Zustellnachweis",
  },
  deliveryHelp:
    "Eine gesendete E-Mail bedeutet keine angenommene Einladung. Die Aktivierung endet erst, wenn die Person einen gültigen Code verwendet und ihr Passwort festlegt.",
  failureHelp:
    "Die Zustellung ist fehlgeschlagen. Der Dienst versucht es erneut, solange Versuche verfügbar sind. Aktualisieren Sie den Status; nach Erreichen des Limits muss der Betreiber den E-Mail-Dienst korrigieren, danach können Sie die Einladung erneut senden.",
  codeExpired:
    "Code abgelaufen. Die Einladung bleibt offen; senden Sie sie erneut, um einen neuen Code auszustellen.",
  codeValid: "Code gültig bis",
  resendAt: "Erneutes Senden verfügbar ab",
  attempts: "Zustellversuche",
  resend: "Einladung erneut senden",
  cancel: "Einladung stornieren",
  resendImpact:
    "Ein neuer Code wird ausgestellt. Der bisherige Code wird ungültig. Erneutes Senden beachtet die Serverlimits.",
  cancelImpact:
    "Die Einladung wird endgültig storniert und der Zugriff gesperrt. Kein bisheriger Code kann dieses Konto aktivieren. Dieser Vorgang ist nicht für bereits aktivierte Konten vorgesehen.",
  confirm: "Vorgang bestätigen",
  back: "Zurück ohne Senden",
  confirmTitle: "Änderung prüfen",
  sendInvite: "Einladung prüfen",
  inviteImpact:
    "Ein privates Konto mit diesen Rollen wird erstellt und eine Aktivierungseinladung gesendet. Die Person legt bei der Annahme ihr Passwort fest. Dies ist keine Einladung zur APK-Installation.",
  busy: "Vorgang wird bestätigt…",
  success:
    "Vorgang von der API bestätigt. Prüfen Sie den aktuellen Mitgliedsstatus; Zustellung und Annahme sind separate Prozesse.",
  uncertain:
    "Die Antwort fehlt. Der Vorgang könnte bereits angewendet worden sein. Stellen Sie denselben Vorgang wieder her, bevor Sie eine weitere Änderung vornehmen; erstellen Sie keine zweite Einladung.",
  recover: "Denselben Vorgang wiederherstellen",
  stale:
    "Die Daten wurden inzwischen geändert. Der Vorgang wurde nicht angewendet. Aktualisieren Sie die Mitglieder und prüfen Sie die Änderung erneut.",
  storage:
    "Der Vorgang konnte in diesem Browser nicht zur Wiederherstellung gespeichert werden. Es wurde nichts gesendet. Aktivieren Sie den Sitzungsspeicher und versuchen Sie es erneut.",
  error:
    "Der Vorgang wurde abgelehnt. Aktualisieren Sie die Mitglieder und prüfen Sie die Daten vor einem erneuten Versuch.",
  errors: {
    forbidden: "Sie sind für diesen Vorgang nicht berechtigt.",
    self_administration_denied:
      "Sie können Ihre eigenen Rollen oder Ihren Zugriff nicht ändern.",
    last_active_administrator:
      "Die Organisation muss mindestens eine aktive Administration behalten.",
    invitation_cancelled:
      "Diese Einladung ist storniert und kann nicht reaktiviert werden.",
    invitation_unavailable:
      "Diese Einladung erlaubt den Vorgang nicht mehr. Prüfen Sie ihren aktuellen Status.",
    invalid_relationship:
      "Wählen Sie eine andere, aktive Führungskraft für eine aktive mitarbeitende Person.",
    resend_limited:
      "Das Limit für erneutes Senden wurde erreicht. Prüfen Sie den nächsten verfügbaren Zeitpunkt.",
    invitation_limit:
      "Das Einladungslimit wurde erreicht. Versuchen Sie es später erneut.",
    account_exists:
      "Diese E-Mail-Adresse ist nicht für eine neue Einladung verfügbar. Prüfen Sie bestehende Mitglieder.",
    invalid_member: "Prüfen Sie Name, E-Mail und Rollen der Einladung.",
  },
  suspended: "Gesperrt",
  enabled: "Aktiv",
  noRoles: "Keine Rollen zugewiesen",
  you: "Ihr Konto",
  unknown: "Unbekannter Status",
  selected: "Ausgewähltes Mitglied",
  timestampNone: "Nicht verfügbar",
};
