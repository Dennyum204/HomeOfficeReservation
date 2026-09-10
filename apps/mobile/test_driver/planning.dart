import 'dart:io';

import 'package:integration_test/integration_test_driver.dart';

Future<void> main() => integrationDriver(
  timeout: const Duration(minutes: 8),
  responseDataCallback: (data) async {
    for (final screenshot in data?['screenshots'] ?? []) {
      final name = screenshot['screenshotName'] as String;
      if (!RegExp(r'^ho010-[a-z-]+$').hasMatch(name)) {
        throw StateError('Unexpected screenshot name');
      }
      final bytes = List<int>.from(screenshot['bytes']);
      if (bytes.isEmpty) throw StateError('Empty screenshot');
      final file = File('test-results/$name.png');
      await file.parent.create(recursive: true);
      await file.writeAsBytes(bytes);
    }
  },
);
