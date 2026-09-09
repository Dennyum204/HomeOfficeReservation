import 'package:flutter/material.dart';
import 'package:homeoffice_api/api.dart';

import 'config/api_settings.dart';
import 'features/auth/auth_controller.dart';
import 'features/auth/auth_screen.dart';
import 'features/auth/token_store.dart';
import 'features/workspace/workspace_repository.dart';
import 'features/workspace/workspace_screen.dart';
import 'l10n/generated/app_localizations.dart';

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

class HomeOfficeApp extends StatelessWidget {
  const HomeOfficeApp({super.key, required this.repository, this.auth});
  final WorkspaceRepository? repository;
  final AuthController? auth;

  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    onGenerateTitle: (context) => AppLocalizations.of(context)!.appName,
    locale: const Locale('pt', 'PT'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    theme: ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xff264e3e)),
      scaffoldBackgroundColor: const Color(0xfff5f6f3),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xffe0e6dc)),
        ),
      ),
    ),
    home: auth == null
        ? WorkspaceScreen(repository: repository)
        : AuthScreen(controller: auth!),
  );
}
