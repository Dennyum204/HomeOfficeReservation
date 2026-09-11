import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:homeoffice_mobile/main.dart';
import 'package:homeoffice_mobile/theme/appearance.dart';

class PreferenceStorage extends FlutterSecureStorage {
  String? value;
  Completer<String?>? reading;
  Completer<void>? writing;
  bool fail = false;
  @override
  Future<String?> read({
    required String key,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async => reading == null ? value : reading!.future;
  @override
  Future<void> write({
    required String key,
    required String? value,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    if (writing != null) await writing!.future;
    if (fail) throw StateError('Simulated unavailable preference storage');
    this.value = value;
  }
}

void main() {
  test('late restore cannot overwrite a choice; rapid choices persist in order; failure is nonfatal', () async {
    final storage = PreferenceStorage()..reading = Completer<String?>();
    final c = AppearanceController(storage: storage);
    addTearDown(c.dispose);
    final restoration = c.restore();
    storage.writing = Completer<void>();
    final first = c.select(ThemeMode.dark);
    final last = c.select(ThemeMode.light);
    storage.reading!.complete('dark');
    await restoration;
    expect(c.mode, ThemeMode.light);
    storage.writing!.complete();
    await Future.wait([first, last]);
    expect(storage.value, 'light');
    storage.reading = null;
    final restored = AppearanceController(storage: storage);
    addTearDown(restored.dispose);
    await restored.restore();
    expect(restored.mode, ThemeMode.light);
    storage.fail = true;
    await c.select(ThemeMode.system);
    expect(c.mode, ThemeMode.system);
    expect(c.storageFailed, isTrue);
  });

  testWidgets(
    'real app follows system, explicit theme wins and reduced motion disables theme animation',
    (t) async {
      final c = AppearanceController(storage: PreferenceStorage());
      addTearDown(c.dispose);
      t.binding.platformDispatcher.platformBrightnessTestValue =
          Brightness.dark;
      addTearDown(
        t.binding.platformDispatcher.clearPlatformBrightnessTestValue,
      );
      await t.pumpWidget(HomeOfficeApp(repository: null, appearance: c));
      await t.pumpAndSettle();
      Brightness brightness() =>
          Theme.of(t.element(find.byType(Scaffold).first)).brightness;
      expect(brightness(), Brightness.dark);
      await c.select(ThemeMode.light);
      await t.pumpAndSettle();
      expect(brightness(), Brightness.light);
      await c.select(ThemeMode.system);
      await t.pumpAndSettle();
      expect(brightness(), Brightness.dark);
      t.binding.platformDispatcher.accessibilityFeaturesTestValue =
          const FakeAccessibilityFeatures(disableAnimations: true);
      addTearDown(
        t.binding.platformDispatcher.clearAccessibilityFeaturesTestValue,
      );
      await t.pumpAndSettle();
      expect(
        t.widget<MaterialApp>(find.byType(MaterialApp)).themeAnimationDuration,
        Duration.zero,
      );
      expect(t.takeException(), isNull);
      await t.pumpWidget(const SizedBox.shrink());
    },
  );
}
