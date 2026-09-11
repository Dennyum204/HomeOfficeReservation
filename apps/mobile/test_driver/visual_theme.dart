import 'dart:io';

import 'package:integration_test/integration_test_driver.dart';

Future<void> main() => integrationDriver(
  timeout: const Duration(minutes: 8),
  responseDataCallback: (data) async {
    final shots = data?['screenshots'] as List? ?? [];
    if (shots.isEmpty) throw StateError('No visual evidence returned');
    for (final shot in shots) {
      final name = shot['screenshotName'] as String;
      if (!RegExp(r'^ho016-(before|after)-(light|dark)-[a-z-]+$')
          .hasMatch(name)) {
        throw StateError('Unexpected visual evidence name');
      }
      final bytes = List<int>.from(shot['bytes']);
      if (bytes.isEmpty) throw StateError('Empty visual evidence');
      final file = File('test-results/$name.png');
      await file.parent.create(recursive: true);
      await file.writeAsBytes(bytes);
    }
  },
);
