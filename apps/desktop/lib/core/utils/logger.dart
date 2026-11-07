import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';

/// 📝 Logger centralizado para la aplicación
/// Proporciona logging estructurado con diferentes niveles de severidad
class AppLogger {
  static const String _appName = '';

  /// Configuración de logging
  static bool _isEnabled = true;
  static LogLevel _minLevel = kDebugMode ? LogLevel.debug : LogLevel.info;

  /// Configurar el logger
  static void configure({
    bool enabled = true,
    LogLevel minLevel = LogLevel.info,
  }) {
    _isEnabled = enabled;
    _minLevel = minLevel;
  }

  /// Log de depuración
  static void debug(
    String tag,
    String message, [
    Object? error,
    StackTrace? stackTrace,
  ]) {
    _log(LogLevel.debug, tag, message, error, stackTrace);
  }

  /// Log informativo
  static void info(
    String tag,
    String message, [
    Object? error,
    StackTrace? stackTrace,
  ]) {
    _log(LogLevel.info, tag, message, error, stackTrace);
  }

  /// Log de advertencia
  static void warning(
    String tag,
    String message, [
    Object? error,
    StackTrace? stackTrace,
  ]) {
    _log(LogLevel.warning, tag, message, error, stackTrace);
  }

  /// Log de error
  static void error(
    String tag,
    String message, [
    Object? error,
    StackTrace? stackTrace,
  ]) {
    _log(LogLevel.error, tag, message, error, stackTrace);
  }

  /// Log fatal
  static void fatal(
    String tag,
    String message, [
    Object? error,
    StackTrace? stackTrace,
  ]) {
    _log(LogLevel.fatal, tag, message, error, stackTrace);
  }

  /// Logging interno
  static void _log(
    LogLevel level,
    String tag,
    String message,
    Object? error,
    StackTrace? stackTrace,
  ) {
    if (!_isEnabled || level.index < _minLevel.index) {
      return;
    }

    final String timestamp = DateTime.now().toIso8601String();
    final String levelStr = level.name.toUpperCase().padRight(7);
    final String tagStr = tag.padRight(20);

    final String logMessage =
        '[$timestamp] $levelStr [$_appName] $tagStr: $message';

    // En debug, usar print para mejor visualización en IDE
    if (kDebugMode) {
      print(logMessage);
      if (error != null) {
        print('  Error: $error');
      }
      if (stackTrace != null) {
        print('  StackTrace: $stackTrace');
      }
    } else {
      // En release, usar developer.log para mejor performance
      developer.log(
        message,
        name: '$_appName.$tag',
        level: _levelToInt(level),
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  /// Convertir nivel a entero
  static int _levelToInt(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return 300;
      case LogLevel.info:
        return 800;
      case LogLevel.warning:
        return 900;
      case LogLevel.error:
        return 1000;
      case LogLevel.fatal:
        return 1200;
    }
  }
}

/// Niveles de logging
enum LogLevel {
  debug,
  info,
  warning,
  error,
  fatal,
}