import 'entities/plantilla_turno_entity.dart';

/// Contrato para el datasource de plantillas de turno
///
/// Proporciona operaciones CRUD base para gestionar plantillas
/// reutilizables de turnos.
abstract class PlantillaTurnoDataSource {
  // ===== MÉTODOS CRUD BASE =====

  /// Obtiene todas las plantillas
  Future<List<PlantillaTurnoEntity>> getAll({int? limit, int? offset});

  /// Obtiene una plantilla por ID
  Future<PlantillaTurnoEntity?> getById(String id);

  /// Crea una nueva plantilla
  Future<PlantillaTurnoEntity> create(PlantillaTurnoEntity entity);

  /// Actualiza una plantilla existente
  Future<PlantillaTurnoEntity> update(PlantillaTurnoEntity entity);

  /// Elimina una plantilla por ID
  Future<void> delete(String id);

  /// Elimina múltiples plantillas
  Future<void> deleteBatch(List<String> ids);

  /// Cuenta el total de plantillas
  Future<int> count();

  /// Stream de todas las plantillas
  Stream<List<PlantillaTurnoEntity>> watchAll();

  /// Stream de una plantilla específica
  Stream<PlantillaTurnoEntity?> watchById(String id);

  /// Limpia todos los datos
  Future<void> clear();

  /// Crea múltiples plantillas
  Future<List<PlantillaTurnoEntity>> createBatch(
    List<PlantillaTurnoEntity> entities,
  );

  /// Verifica si existe una plantilla
  Future<bool> exists(String id);

  /// Actualiza múltiples plantillas
  Future<List<PlantillaTurnoEntity>> updateBatch(
    List<PlantillaTurnoEntity> entities,
  );

  // ===== MÉTODOS ESPECIALIZADOS =====

  /// Obtiene solo las plantillas activas
  ///
  /// Returns: Lista de plantillas con activo=true
  Future<List<PlantillaTurnoEntity>> getActivos();
}
