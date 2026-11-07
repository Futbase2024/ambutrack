import 'entities/equipamiento_personal_entity.dart';

/// Contrato para el datasource de equipamiento personal
abstract class EquipamientoPersonalDataSource {
  /// Obtiene todos los registros de equipamiento
  Future<List<EquipamientoPersonalEntity>> getAll();

  /// Obtiene un registro por ID
  Future<EquipamientoPersonalEntity> getById(String id);

  /// Obtiene equipamiento por personal
  Future<List<EquipamientoPersonalEntity>> getByPersonalId(String personalId);

  /// Obtiene equipamiento asignado (sin devolución)
  Future<List<EquipamientoPersonalEntity>> getAsignado();

  /// Obtiene equipamiento por tipo
  Future<List<EquipamientoPersonalEntity>> getByTipo(String tipo);

  /// Crea un nuevo registro
  Future<EquipamientoPersonalEntity> create(EquipamientoPersonalEntity entity);

  /// Actualiza un registro existente
  Future<EquipamientoPersonalEntity> update(EquipamientoPersonalEntity entity);

  /// Elimina un registro
  Future<void> delete(String id);

  /// Stream de todos los registros
  Stream<List<EquipamientoPersonalEntity>> watchAll();

  /// Stream de equipamiento por personal
  Stream<List<EquipamientoPersonalEntity>> watchByPersonalId(String personalId);
}
