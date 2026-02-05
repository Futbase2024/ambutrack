import 'package:ambutrack_core/ambutrack_core.dart';

/// Contrato del repositorio de Bases/Centros Operativos
///
/// Define las operaciones disponibles para la gestión de bases
/// desde la capa de dominio de la aplicación
abstract class BasesRepository {
  // ==================== CRUD BÁSICO ====================

  /// Obtiene todas las bases
  ///
  /// [limit] - Límite de resultados (opcional)
  /// [offset] - Offset para paginación (opcional)
  /// Devuelve lista de bases ordenadas por nombre
  Future<List<BaseCentroEntity>> getAll({int? limit, int? offset});

  /// Obtiene una base por ID
  ///
  /// [id] - ID de la base
  /// Devuelve la base o null si no existe
  Future<BaseCentroEntity?> getById(String id);

  /// Crea una nueva base
  ///
  /// [base] - Entidad de la base a crear
  /// Devuelve la base creada con ID generado
  Future<BaseCentroEntity> create(BaseCentroEntity base);

  /// Actualiza una base existente
  ///
  /// [base] - Entidad de la base con datos actualizados
  /// Devuelve la base actualizada
  Future<BaseCentroEntity> update(BaseCentroEntity base);

  /// Elimina una base por ID
  ///
  /// [id] - ID de la base a eliminar
  Future<void> delete(String id);

  /// Verifica si existe una base con el ID dado
  ///
  /// [id] - ID de la base
  /// Devuelve true si existe, false en caso contrario
  Future<bool> exists(String id);

  /// Cuenta el total de bases registradas
  ///
  /// Devuelve el número total de bases
  Future<int> count();

  // ==================== STREAMING ====================

  /// Observa cambios en todas las bases en tiempo real
  ///
  /// Devuelve stream que emite lista actualizada cuando hay cambios
  Stream<List<BaseCentroEntity>> watchAll();

  /// Observa cambios en una base específica en tiempo real
  ///
  /// [id] - ID de la base a observar
  /// Devuelve stream que emite la base actualizada cuando hay cambios
  Stream<BaseCentroEntity?> watchById(String id);

  // ==================== BATCH OPERATIONS ====================

  /// Crea múltiples bases de una vez
  ///
  /// [bases] - Lista de bases a crear
  /// Devuelve lista de bases creadas con IDs generados
  Future<List<BaseCentroEntity>> createBatch(List<BaseCentroEntity> bases);

  /// Actualiza múltiples bases de una vez
  ///
  /// [bases] - Lista de bases a actualizar
  /// Devuelve lista de bases actualizadas
  Future<List<BaseCentroEntity>> updateBatch(List<BaseCentroEntity> bases);

  /// Elimina múltiples bases de una vez
  ///
  /// [ids] - Lista de IDs de bases a eliminar
  Future<void> deleteBatch(List<String> ids);

  // ==================== MÉTODOS ESPECÍFICOS ====================

  /// Obtiene todas las bases activas
  ///
  /// Devuelve lista de bases con activo = true
  Future<List<BaseCentroEntity>> getActivas();

  /// Obtiene bases de una población específica
  ///
  /// [poblacionId] - ID de la población
  /// Devuelve lista de bases en esa población
  Future<List<BaseCentroEntity>> getByPoblacion(String poblacionId);

  /// Desactiva una base (soft delete)
  ///
  /// Establece activo = false sin eliminar el registro
  /// [baseId] - ID de la base a desactivar
  /// Devuelve la base desactivada
  Future<BaseCentroEntity> deactivateBase(String baseId);

  /// Reactiva una base previamente desactivada
  ///
  /// Establece activo = true
  /// [baseId] - ID de la base a reactivar
  /// Devuelve la base reactivada
  Future<BaseCentroEntity> reactivateBase(String baseId);
}
