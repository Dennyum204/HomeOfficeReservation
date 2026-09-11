import 'package:flutter/material.dart';
import 'package:homeoffice_api/api.dart';

import 'config/api_settings.dart';
import 'features/auth/auth_controller.dart';
import 'features/auth/auth_screen.dart';
import 'features/auth/token_store.dart';
import 'features/workspace/workspace_repository.dart';
import 'features/workspace/workspace_screen.dart';
import 'l10n/generated/app_localizations.dart';
import 'theme/app_theme.dart';
import 'theme/appearance.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  AuthController? auth;
  try {
    auth = AuthController(
      ApiClient(basePath: ApiSettings.baseUrl),
      SecureTokenStore(ApiSettings.baseUrl),
    );
  } on ArgumentError {
    // Invalid release configuration gets a visible localized state, never a false connection.
  }
  runApp(HomeOfficeApp(repository: null, auth: auth));
}

class HomeOfficeApp extends StatefulWidget {
  const HomeOfficeApp({
    super.key,
    required this.repository,
    this.auth,
    this.appearance,
  });
  final WorkspaceRepository? repository;
  final AuthController? auth;
  final AppearanceController? appearance;
  @override
  State<HomeOfficeApp> createState() => _HomeOfficeAppState();
}

class _HomeOfficeAppState extends State<HomeOfficeApp>
    with WidgetsBindingObserver {
  late final AppearanceController appearance;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    appearance = widget.appearance ?? AppearanceController();
    if (widget.appearance == null) appearance.restore();
  }

  @override
  void didChangeAccessibilityFeatures() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (widget.appearance == null) appearance.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: appearance,
    builder: (context, _) => AppearanceScope(
      controller: appearance,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        onGenerateTitle: (context) => AppLocalizations.of(context)!.appName,
        locale: const Locale('pt', 'PT'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: appTheme(Brightness.light),
        darkTheme: appTheme(Brightness.dark),
        themeMode: appearance.mode,
        themeAnimationDuration:
            WidgetsBinding
                .instance
                .platformDispatcher
                .accessibilityFeatures
                .disableAnimations
            ? Duration.zero
            : const Duration(milliseconds: 180),
        home: widget.auth == null
            ? WorkspaceScreen(repository: widget.repository)
            : AuthScreen(controller: widget.auth!),
      ),
    ),
  );
}
