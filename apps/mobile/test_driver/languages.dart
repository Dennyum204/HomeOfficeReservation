import 'dart:io';

import 'package:integration_test/integration_test_driver.dart';

Future<void> main() => integrationDriver(
  timeout: const Duration(minutes: 10),
  responseDataCallback: (data) async {
    final shots = data?['screenshots'] as List? ?? [];
    if (shots.length != 18) {
      throw StateError('Expected 18 completed locale screenshots');
    }
    for (final shot in shots) {
      final name = shot['screenshotName'] as String;
      if (!RegExp(
        r'^ho021-(pt|en|de)-(light|dark)-(settings|calendar|notifications)$',
      ).hasMatch(name)) {
        throw StateError('Unexpected screenshot name');
      }
      final bytes = List<int>.from(shot['bytes']);
      if (bytes.isEmpty) throw StateError('Empty screenshot');
      final file = File('test-results/$name.png');
      await file.parent.create(recursive: true);
      await file.writeAsBytes(bytes);
    }
  },
);
