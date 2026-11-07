/// Configuración global de la aplicación
///
/// Centraliza todas las constantes y configuraciones de la app.
/// Se integra con los flavors para manejar diferentes ambientes.
class AppConfig {
  // Prevenir instanciación
  AppConfig._();

  // --- Información de la App ---
  static const String appName = 'Ambutrack Web';
  static const String packageName = 'com.ambutrack.web.ambutrack_web';
  static const String version = '1.0.0';
  static const String buildNumber = '1';

  // --- URLs de API por ambiente ---
  static const String devApiUrl = 'https://dev-api.com.ambutrack.web.com';
  static const String prodApiUrl = 'https://api.com.ambutrack.web.com';

  // --- Configuración de Red ---
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // --- Storage Keys ---
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String themeKey = 'app_theme';
  static const String languageKey = 'app_language';

  // --- Feature Flags ---
  static const bool enableAnalytics = false;
  static const bool enableCrashlytics = false;
  static const bool enableDebugMode = true;

  /// Obtiene la URL de la API según el flavor actual
  ///
  /// Esta función se integrará con flutter_flavorizr después de su ejecución.
  /// Por defecto retorna la URL de desarrollo.
  static String getApiUrl() {
    // TODO(dev): Integrar con flutter_flavorizr
    // Después de ejecutar flutter_flavorizr, usar:
    // return F.appFlavor == Flavor.prod ? prodApiUrl : devApiUrl;
    return devApiUrl;
  }

  /// Obtiene configuración para inyección de dependencias
  ///
  /// Centraliza toda la configuración necesaria para los providers.
  static Map<String, dynamic> get dependencyConfig => <String, dynamic>{
        'baseUrl': getApiUrl(),
        'connectTimeout': connectionTimeout.inMilliseconds,
        'receiveTimeout': receiveTimeout.inMilliseconds,
        'enableLogging': enableDebugMode,
      };
}
