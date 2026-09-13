import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../l10n/generated/app_localizations.dart';

import 'package:intl/intl.dart';

class AppearanceController extends ChangeNotifier {
  AppearanceController({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();
  final FlutterSecureStorage _storage;
  static const _key = 'homeoffice.appearance';
  static const languageKey = 'homeoffice.language';
  String language = 'pt';
  String get formattingLocale => switch (language) {
    'en' => 'en_GB',
    'de' => 'de_CH',
    _ => 'pt_PT',
  };
  bool languageStorageFailed = false;
  int _languageGeneration = 0;
  Future<void> _languageWrites = Future<void>.value();
  ThemeMode mode = ThemeMode.system;
  bool storageFailed = false;
  bool _disposed = false;
  int _generation = 0;
  Future<void> _writes = Future<void>.value();

  Future<void> restore() async {
    await Future.wait([_restoreAppearance(), restoreLanguage()]);
  }

  Future<void> _restoreAppearance() async {
    final generation = _generation;
    try {
      final value = await _storage.read(key: _key);
      if (_disposed || generation != _generation) return;
      mode = switch (value) {
        'dark' => ThemeMode.dark,
        'light' => ThemeMode.light,
        _ => ThemeMode.system,
      };
      notifyListeners();
    } catch (_) {
      // A nonessential local preference never prevents authentication or planning.
    }
  }

  Future<void> select(ThemeMode value) async {
    final generation = ++_generation;
    mode = value;
    storageFailed = false;
    notifyListeners();
    // Keep rapid choices in order even when platform storage completes slowly.
    _writes = _writes.then((_) async {
      try {
        await _storage.write(key: _key, value: value.name);
      } catch (_) {
        if (_disposed || generation != _generation) return;
        storageFailed = true;
        notifyListeners();
      }
    });
    await _writes;
  }

  Future<void> restoreLanguage() async {
    final generation = _languageGeneration;
    try {
      final value = await _storage.read(key: languageKey);
      if (_disposed || generation != _languageGeneration) return;
      language = value == 'en' || value == 'de' ? value! : 'pt';
      Intl.defaultLocale = formattingLocale;
      notifyListeners();
    } catch (_) {
      // Language storage failure must not prevent access to the application.
    }
  }

  Future<void> selectLanguage(String value) async {
    if (!['pt', 'en', 'de'].contains(value)) return;
    final generation = ++_languageGeneration;
    language = value;
    Intl.defaultLocale = formattingLocale;
    languageStorageFailed = false;
    notifyListeners();
    _languageWrites = _languageWrites.then((_) async {
      try {
        await _storage.write(key: languageKey, value: value);
      } catch (_) {
        if (_disposed || generation != _languageGeneration) return;
        languageStorageFailed = true;
        notifyListeners();
      }
    });
    await _languageWrites;
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}

class AppearanceScope extends InheritedNotifier<AppearanceController> {
  const AppearanceScope({
    super.key,
    required AppearanceController controller,
    required super.child,
  }) : super(notifier: controller);
  static AppearanceController? of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppearanceScope>()?.notifier;
}

class AppearancePicker extends StatelessWidget {
  const AppearancePicker({super.key});
  @override
  Widget build(BuildContext context) {
    final c = AppearanceScope.of(context);
    if (c == null) return const SizedBox.shrink();
    final s = AppLocalizations.of(context)!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              s.appearanceTitle,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(s.appearanceDescription),
            const SizedBox(height: 16),
            DropdownButtonFormField<ThemeMode>(
              key: ValueKey('appearance-${c.mode.name}'),
              initialValue: c.mode,
              isExpanded: true,
              decoration: InputDecoration(labelText: s.appearanceLabel),
              items: [
                DropdownMenuItem(
                  value: ThemeMode.system,
                  child: Text(s.appearanceSystem),
                ),
                DropdownMenuItem(
                  value: ThemeMode.light,
                  child: Text(s.appearanceLight),
                ),
                DropdownMenuItem(
                  value: ThemeMode.dark,
                  child: Text(s.appearanceDark),
                ),
              ],
              onChanged: (value) {
                if (value != null) c.select(value);
              },
            ),
            if (c.storageFailed)
              Semantics(liveRegion: true, child: Text(s.appearanceStorage)),
          ],
        ),
      ),
    );
  }
}

class LanguagePicker extends StatelessWidget {
  const LanguagePicker({super.key});
  @override
  Widget build(BuildContext context) {
    final c = AppearanceScope.of(context);
    if (c == null) return const SizedBox.shrink();
    final s = AppLocalizations.of(context)!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              s.languageTitle,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(s.languageHelp),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              key: ValueKey('language-${c.language}'),
              initialValue: c.language,
              isExpanded: true,
              decoration: InputDecoration(labelText: s.languageTitle),
              items: const [
                DropdownMenuItem(value: 'pt', child: Text('Português')),
                DropdownMenuItem(value: 'en', child: Text('English')),
                DropdownMenuItem(value: 'de', child: Text('Deutsch')),
              ],
              onChanged: (value) {
                if (value != null) c.selectLanguage(value);
              },
            ),
            if (c.languageStorageFailed)
              Semantics(liveRegion: true, child: Text(s.languageStorage)),
          ],
        ),
      ),
    );
  }
}
