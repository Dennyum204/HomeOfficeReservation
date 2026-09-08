import 'package:flutter/foundation.dart';

class ApiSettings {
  static String get baseUrl {
    const configured = String.fromEnvironment('API_BASE_URL');
    final value = configured.isNotEmpty
        ? configured
        : (defaultTargetPlatform == TargetPlatform.android
              ? 'http://10.0.2.2:5080'
              : 'http://localhost:5080');
    final uri = Uri.tryParse(value);
    if (uri == null ||
        !uri.hasAuthority ||
        !['http', 'https'].contains(uri.scheme) ||
        uri.userInfo.isNotEmpty ||
        (uri.path.isNotEmpty && uri.path != '/') ||
        uri.hasQuery ||
        uri.hasFragment ||
        (kReleaseMode && (configured.isEmpty || uri.scheme != 'https'))) {
      throw ArgumentError(
        'API_BASE_URL must be an absolute origin; release requires explicit HTTPS.',
      );
    }
    return value.replaceFirst(RegExp(r'/$'), '');
  }
}
