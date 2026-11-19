import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';

/// Contrato del repositorio de usuarios
///
/// Define las operaciones de negocio para la gestión de usuarios
abstract class UsuariosRepository {
  /// Obtiene todos los usuarios
  Future<List<UserEntity>> getAll();

  /// Obtiene un usuario por ID
  ///
  /// Returns null si no existe
  Future<UserEntity?> getById(String id);

  /// Crea un nuevo usuario con una clave provisional
  ///
  /// [usuario] - Datos del usuario a crear
  /// [password] - Clave provisional (PIN de 6 dígitos o contraseña web)
  ///
  /// Va por la Edge Function `admin-users`: crea la cuenta ya confirmada,
  /// completa la fila de `usuarios` y marca la clave como provisional
  /// (el usuario tendrá que cambiarla en su primer acceso).
  ///
  /// Returns el usuario creado con su ID
  Future<UserEntity> create(UserEntity usuario, String password);

  /// Actualiza un usuario existente
  ///
  /// [usuario] - Usuario con datos actualizados
  ///
  /// Returns el usuario actualizado
  Future<UserEntity> update(UserEntity usuario);

  /// Elimina un usuario
  ///
  /// [id] - ID del usuario a eliminar
  ///
  /// Solo admin. Elimina la cuenta de auth.users (la fila de usuarios cae en cascada).
  Future<void> delete(String id);

  /// Cambia el estado activo/inactivo de un usuario
  ///
  /// [id] - ID del usuario
  /// [activo] - Nuevo estado (true = activo, false = inactivo)
  Future<void> cambiarEstado(String id, {required bool activo});

  /// Resetea la contraseña de un usuario
  ///
  /// [userId] - ID del usuario
  /// [newPassword] - Nueva contraseña
  ///
  /// La nueva clave queda como provisional: el usuario la cambiará al entrar
  Future<void> resetearPassword(String userId, String newPassword);

  /// Obtiene usuarios por rol específico
  ///
  /// [rol] - Rol a filtrar (admin, coordinador, conductor, sanitario, jefe_personal, gestor_flota)
  Future<List<UserEntity>> getByRol(String rol);

  /// Obtiene usuarios de una empresa específica
  ///
  /// [empresaId] - ID de la empresa
  Future<List<UserEntity>> getByEmpresa(String empresaId);

  /// Busca usuarios por email o DNI (búsqueda parcial)
  ///
  /// [query] - Texto a buscar en email o DNI
  Future<List<UserEntity>> searchByEmailOrDni(String query);
}
