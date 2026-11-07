import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Monitor de errores (Sentry).
///
/// Solo se activa si la app se compila con `--dart-define=SENTRY_DSN=<dsn>`.
/// Sin DSN la app arranca exactamente igual que antes.
///
/// Privacidad (la app maneja datos de salud):
/// - `sendDefaultPii = false`: sin IP, cookies ni cabeceras.
/// - Se identifica al usuario solo por su id interno (sin email ni nombre).
/// - No se adjuntan cuerpos de petición ni capturas de pantalla.
class ErrorMonitoring {
  const ErrorMonitoring._();

  static const String _dsn = String.fromEnvironment('SENTRY_DSN');

  static bool get enabled => _dsn.isNotEmpty;

  /// Inicializa Sentry (si hay DSN) y ejecuta [appRunner] dentro de él
  static Future<void> run({
    required String environment,
    required FutureOr<void> Function() appRunner,
  }) async {
    if (!enabled) {
      await appRunner();
      return;
    }
    debugPrint('🛰️ ErrorMonitoring: Sentry activo ($environment)');
    await SentryFlutter.init(
      (SentryFlutterOptions options) {
        options
          ..dsn = _dsn
          ..environment = environment
          ..sendDefaultPii = false
          ..tracesSampleRate = 0
          ..attachScreenshot = false
          ..maxRequestBodySize = MaxRequestBodySize.never;
      },
      appRunner: () async {
        _trackUser();
        await appRunner();
      },
    );
  }

  /// Asocia los errores al id del usuario con sesión (sin datos personales)
  static void _trackUser() {
    Future<void> setUser(User? user) async {
      await Sentry.configureScope(
        (Scope scope) async => scope.setUser(user == null ? null : SentryUser(id: user.id)),
      );
    }

    unawaited(setUser(Supabase.instance.client.auth.currentUser));
    Supabase.instance.client.auth.onAuthStateChange.listen(
      (AuthState state) => unawaited(setUser(state.session?.user)),
    );
  }
}
