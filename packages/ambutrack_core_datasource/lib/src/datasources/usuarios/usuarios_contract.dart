import 'entities/usuario_entity.dart';

/// Contrato del datasource de usuarios
///
/// Define todas las operaciones CRUD y métodos específicos del dominio
abstract class UsuarioDataSource {
  // CRUD básico

  /// Crea un nuevo usuario
  Future<UserEntity> create(UserEntity entity);

  /// Obtiene un usuario por ID
  Future<UserEntity?> getById(String id);

  /// Obtiene todos los usuarios
  Future<List<UserEntity>> getAll({int? limit, int? offset});

  /// Actualiza un usuario existente
  Future<UserEntity> update(UserEntity entity);

  /// Elimina un usuario
  Future<void> delete(String id);

  // Métodos específicos del dominio
  /// Obtiene usuarios por rol específico
  ///
  /// [rol] - Rol a filtrar (admin, coordinador, conductor, sanitario, jefe_personal, gestor_flota)
  Future<List<UserEntity>> getByRol(String rol);

  /// Obtiene usuarios de una empresa específica
  ///
  /// [empresaId] - ID de la empresa
  Future<List<UserEntity>> getByEmpresa(String empresaId);

  /// Obtiene solo usuarios activos
  Future<List<UserEntity>> getActivos();

  /// Busca usuarios por email o DNI (búsqueda parcial)
  ///
  /// [query] - Texto a buscar en email o DNI
  Future<List<UserEntity>> searchByEmailOrDni(String query);

  /// Obtiene un usuario por su email (búsqueda exacta)
  ///
  /// Returns null si no existe
  Future<UserEntity?> getByEmail(String email);

  /// Obtiene un usuario por su DNI (búsqueda exacta)
  ///
  /// Returns null si no existe
  Future<UserEntity?> getByDni(String dni);

  /// Cambia el estado activo/inactivo de un usuario
  ///
  /// [id] - ID del usuario
  /// [activo] - Nuevo estado (true = activo, false = inactivo)
  Future<void> cambiarEstado(String id, bool activo);
}
