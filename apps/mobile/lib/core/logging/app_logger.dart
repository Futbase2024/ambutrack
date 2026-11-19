import 'package:flutter/foundation.dart';
import '../monitoring/error_monitoring.dart';

/// Sistema de logging centralizado y estructurado
///
/// Reemplaza debugPrint() con un sistema profesional que soporta:
/// - Niveles de log (debug, info, warning, error)
/// - Tags para organización
/// - Formato legible con emojis
/// - Filtrado por entorno (dev/prod)
/// - Timestamps automáticos
///
/// NOTA: Para producción, integrar con Sentry o Firebase Crashlytics
class AppLogger {
  // Configuración
  static bool enableDebugLogs = kDebugMode;
  static bool enableInfoLogs = true;
  static bool enableWarningLogs = true;
  static bool enableErrorLogs = true;

  /// Formatea el mensaje con timestamp y tag
  static String _formatMessage(String level, String message, String? tag) {
    final timestamp = DateTime.now().toIso8601String().substring(11, 23);
    final tagPrefix = tag != null ? '[$tag] ' : '';
    return '$timestamp $level $tagPrefix$message';
  }

  /// Log nivel DEBUG (desarrollo)
  /// Solo visible en modo debug
  static void debug(String message, {String? tag, dynamic data}) {
    if (!enableDebugLogs) return;

    final formatted = _formatMessage('🔍 DEBUG', message, tag);
    debugPrint(formatted);

    if (data != null) {
      debugPrint('  └─ Data: $data');
    }
  }

  /// Log nivel INFO (informativo)
  /// Eventos importantes del sistema
  static void info(String message, {String? tag, dynamic data}) {
    if (!enableInfoLogs) return;

    final formatted = _formatMessage('ℹ️  INFO ', message, tag);
    debugPrint(formatted);

    if (data != null) {
      debugPrint('  └─ Data: $data');
    }
  }

  /// Log nivel WARNING (advertencia)
  /// Situaciones no óptimas pero no críticas
  static void warning(String message, {String? tag, dynamic data}) {
    if (!enableWarningLogs) return;

    final formatted = _formatMessage('⚠️  WARN ', message, tag);
    debugPrint(formatted);

    if (data != null) {
      debugPrint('  └─ Data: $data');
    }
  }

  /// Log nivel ERROR (error)
  /// Errores que deben ser investigados
  static void error(
    String message,
    Object? error,
    StackTrace? stackTrace, {
    String? tag,
  }) {
    if (!enableErrorLogs) return;

    final formatted = _formatMessage('❌ ERROR', message, tag);
    debugPrint(formatted);

    if (error != null) {
      debugPrint('  └─ Error: $error');
    }

    if (stackTrace != null) {
      debugPrint('  └─ Stack:\n${stackTrace.toString().split('\n').take(5).join('\n')}');
    }

    // Crash reporting (Sentry): solo si la app se compiló con SENTRY_DSN
    if (error != null) {
      ErrorMonitoring.capture(error, stackTrace, message: message);
    }
  }

  /// Registra el inicio de una operación importante
  static void startOperation(String operation, {String? tag}) {
    info('▶️ Iniciando: $operation', tag: tag);
  }

  /// Registra el fin exitoso de una operación
  static void endOperation(String operation, {String? tag, Duration? duration}) {
    final durationText = duration != null ? ' (${duration.inMilliseconds}ms)' : '';
    info('✅ Completado: $operation$durationText', tag: tag);
  }

  /// Registra el fallo de una operación
  static void failOperation(
    String operation,
    Object error,
    StackTrace? stackTrace, {
    String? tag,
  }) {
    AppLogger.error('❌ Falló: $operation', error, stackTrace, tag: tag);
  }
}
