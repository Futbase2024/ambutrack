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

  /// Crea un nuevo usuario
  ///
  /// [usuario] - Datos del usuario a crear
  /// [password] - Contraseña inicial del usuario
  ///
  /// Este método:
  /// 1. Crea el usuario en auth.users usando AuthService
  /// 2. Crea el registro en la tabla usuarios con el ID generado
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
  /// Este método:
  /// 1. Elimina el registro de la tabla usuarios
  /// 2. Elimina el usuario de auth.users usando Admin API
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
  /// Usa la Admin API de Supabase para cambiar la contraseña
  /// sin requerir la contraseña actual
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
