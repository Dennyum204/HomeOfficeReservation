import 'dart:io';

import 'package:homeoffice_api/api.dart';
import 'package:homeoffice_mobile/features/workspace/workspace_repository.dart';

// Runs the same repository and generated Dart client as the Flutter shell against a real API.
Future<void> main(List<String> args) async {
  final baseUrl = args.isEmpty ? 'http://localhost:5080' : args.single;
  final repository = WorkspaceRepository(
    WorkspaceApi(ApiClient(basePath: baseUrl)),
  );
  try {
    final result = await repository.load();
    if (result.apiVersion != 'v1' ||
        !result.planningTimeZones.contains('Europe/Lisbon') ||
        !result.planningTimeZones.contains('Europe/Zurich') ||
        DateTime.now().toUtc().difference(result.serverTimeUtc).abs() >
            const Duration(seconds: 30)) {
      throw StateError('Unexpected live API contract');
    }
    stdout.writeln(
      'Dart generated client: real API response and timestamp verified.',
    );
  } finally {
    repository.dispose();
  }
}
