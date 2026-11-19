/// Contrato para los ajustes de dispositivo del perfil
abstract class AjustesDispositivoRepository {
  /// Rol (`usuarios.rol`) del usuario autenticado
  Future<String?> obtenerRolUsuario();
}
