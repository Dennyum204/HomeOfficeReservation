import 'package:homeoffice_api/api.dart';

enum EditorMode { create, edit, revision, proposal }

// Local presentation input. All request bodies still use generated types.
class PlanningEditor {
  PlanningEditor({
    required this.mode,
    this.requestId,
    this.parentRevisionId,
    this.proposalId,
    this.requirementId,
    this.requirementRevision,
    this.affected = const [],
    this.days = const [],
    this.note = '',
  });
  final EditorMode mode;
  final String? requestId, parentRevisionId, proposalId, requirementId;
  final int? requirementRevision;
  final List<SelectedDay> affected;
  List<DayInput> days;
  String note;
  Map<String, dynamic> toJson() => {
    'mode': mode.name,
    'requestId': requestId,
    'parentRevisionId': parentRevisionId,
    'proposalId': proposalId,
    'requirementId': requirementId,
    'requirementRevision': requirementRevision,
    'affected': affected,
    'days': days,
    'note': note,
  };
  factory PlanningEditor.fromJson(Map<String, dynamic> value) => PlanningEditor(
    mode: EditorMode.values.byName(value['mode'] as String),
    requestId: value['requestId'] as String?,
    parentRevisionId: value['parentRevisionId'] as String?,
    proposalId: value['proposalId'] as String?,
    requirementId: value['requirementId'] as String?,
    requirementRevision: value['requirementRevision'] as int?,
    affected: SelectedDay.listFromJson(value['affected']),
    days: DayInput.listFromJson(value['days']),
    note: value['note'] as String,
  );
}
