import 'package:homeoffice_api/api.dart';

// Presentation state composed from generated input models, never a second wire DTO.
class WorkEditor {
  WorkEditor({this.id, this.onsite, this.task, this.progress});
  final String? id;
  OnsiteInput? onsite;
  TaskInput? task;
  TaskProgressInput? progress;
  WorkContext get kind =>
      onsite != null ? WorkContext.requirement : WorkContext.task;
  String get draftKey => '${kind.name}:${id ?? "new"}:${progress != null}';
  Map<String, dynamic> toJson() => {
    'id': id,
    'onsite': onsite,
    'task': task,
    'progress': progress,
  };
  factory WorkEditor.fromJson(Map<String, dynamic> value) => WorkEditor(
    id: value['id'] as String?,
    onsite: OnsiteInput.fromJson(value['onsite']),
    task: TaskInput.fromJson(value['task']),
    progress: TaskProgressInput.fromJson(value['progress']),
  );
}
