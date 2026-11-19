/// Repositorio para la gestión de datos de la página Home
///
/// Define el contrato para obtener información relacionada
/// con la funcionalidad principal de la aplicación.
abstract class HomeRepository {
  /// Obtiene el estado de conectividad actual
  Future<bool> getConnectivityStatus();

  /// Realiza una verificación completa del sistema
  Future<Map<String, dynamic>> getSystemStatus();
}