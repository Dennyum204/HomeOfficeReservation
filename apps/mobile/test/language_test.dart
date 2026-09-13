import 'planning_fixture.dart';

import 'package:homeoffice_mobile/features/planning/planning_screen.dart';

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:homeoffice_mobile/main.dart';
import 'package:homeoffice_mobile/theme/appearance.dart';
import 'package:homeoffice_mobile/l10n/generated/app_localizations.dart';
import 'package:homeoffice_mobile/features/planning/planning_dates.dart';
import 'package:intl/intl.dart';

class LanguageStorage extends FlutterSecureStorage {
  final values = <String, String>{};
  bool fail = false;
  Completer<String?>? pendingRead;
  @override
  Future<String?> read({
    required String key,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async => pendingRead == null ? values[key] : pendingRead!.future;
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
    if (fail) throw StateError('storage unavailable');
    if (value != null) values[key] = value;
  }
}

void main() {
  testWidgets('German calendar accepts two-letter weekday abbreviations', (
    t,
  ) async {
    final fixture = PlanningFixture();
    await fixture.start();
    addTearDown(fixture.dispose);
    Intl.defaultLocale = 'de_CH';
    await t.pumpWidget(
      MaterialApp(
        locale: const Locale('de', 'CH'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: PlanningScreen(
            controller: fixture.c,
            requests: false,
            onRequests: () {},
          ),
        ),
      ),
    );
    await t.pumpAndSettle();
    expect(find.text('Mo'), findsOneWidget);
    expect(find.text('So'), findsOneWidget);
    expect(t.takeException(), isNull);
    await t.pumpWidget(const SizedBox.shrink());
  });

  tearDown(() => Intl.defaultLocale = 'pt_PT');
  test('language persists separately; late restoration and failed writes preserve the current choice', () async {
    final storage = LanguageStorage()..values['homeoffice.appearance'] = 'dark';
    final c = AppearanceController(storage: storage);
    addTearDown(c.dispose);
    expect(c.language, 'pt');
    await c.restore();
    expect(c.mode, ThemeMode.dark);
    storage.pendingRead = Completer<String?>();
    final restore = c.restoreLanguage();
    await c.selectLanguage('en');
    await c.selectLanguage('de');
    storage.pendingRead!.complete('pt');
    await restore;
    expect(c.language, 'de');
    expect(storage.values[AppearanceController.languageKey], 'de');
    expect(storage.values['homeoffice.appearance'], 'dark');
    storage.pendingRead = null;
    final restarted = AppearanceController(storage: storage);
    addTearDown(restarted.dispose);
    await restarted.restore();
    expect(restarted.language, 'de');
    storage.fail = true;
    await c.selectLanguage('en');
    expect(c.language, 'en');
    expect(c.languageStorageFailed, isTrue);
    await c.selectLanguage('unsupported');
    expect(c.language, 'en');
  });
  test('ARB coverage and placeholders match in all three languages', () {
    final pt = jsonDecode(
      File('lib/l10n/app_pt.arb').readAsStringSync(),
    ) as Map<String, dynamic>;
    for (final language in ['en', 'de']) {
      final catalog = jsonDecode(
        File('lib/l10n/app_$language.arb').readAsStringSync(),
      ) as Map<String, dynamic>;
      expect(catalog.keys.toSet(), pt.keys.toSet());
      for (final key in pt.keys.where((key) => !key.startsWith('@'))) {
        expect(catalog[key], isNotEmpty, reason: key);
        final meta = pt['@$key'] as Map<String, dynamic>?;
        for (final placeholder in ((meta?['placeholders'] ?? {}) as Map).keys) {
          expect(catalog[key], contains('{$placeholder'), reason: key);
        }
      }
    }
  });
  testWidgets(
    'real settings switch language with enlarged text; date-only keys remain stable',
    (t) async {
      t.view.physicalSize = const Size(390, 844);
      t.view.devicePixelRatio = 1;
      t.platformDispatcher.textScaleFactorTestValue = 1.3;
      addTearDown(t.view.resetPhysicalSize);
      addTearDown(t.view.resetDevicePixelRatio);
      addTearDown(t.platformDispatcher.clearTextScaleFactorTestValue);
      final c = AppearanceController(storage: LanguageStorage());
      addTearDown(c.dispose);
      await t.pumpWidget(HomeOfficeApp(repository: null, appearance: c));
      await t.pumpAndSettle();
      await t.tap(find.text('Definições').last);
      await t.pumpAndSettle();
      await t.ensureVisible(find.byKey(const ValueKey('language-pt')));
      await t.tap(find.byKey(const ValueKey('language-pt')));
      await t.pumpAndSettle();
      await t.tap(find.text('Deutsch').last);
      await t.pumpAndSettle();
      expect(find.text('Einstellungen'), findsWidgets);
      expect(
        t.widget<MaterialApp>(find.byType(MaterialApp)).locale,
        const Locale('de', 'CH'),
      );
      final s = AppLocalizations.of(t.element(find.byType(Scaffold).first))!;
      expect(s.planDayCounts(1, 2), '1 genehmigter Tag · 2 ausstehende Tage');
      expect(dayLabel(DateTime(2026, 10, 25)), contains('Okt'));
      expect(dateKey(DateTime(2026, 10, 25)), '2026-10-25');
      expect(t.takeException(), isNull);
      await t.pumpWidget(const SizedBox.shrink());
    },
  );
}
