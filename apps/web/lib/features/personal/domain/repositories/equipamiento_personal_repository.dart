import 'package:ambutrack_core/ambutrack_core.dart';

/// Repositorio para equipamiento personal
abstract class EquipamientoPersonalRepository {
  /// Obtiene todos los registros
  Future<List<EquipamientoPersonalEntity>> getAll();

  /// Obtiene un registro por ID
  Future<EquipamientoPersonalEntity> getById(String id);

  /// Obtiene equipamiento por personal
  Future<List<EquipamientoPersonalEntity>> getByPersonalId(String personalId);

  /// Obtiene equipamiento asignado
  Future<List<EquipamientoPersonalEntity>> getAsignado();

  /// Obtiene equipamiento por tipo
  Future<List<EquipamientoPersonalEntity>> getByTipo(String tipo);

  /// Crea un nuevo registro
  Future<EquipamientoPersonalEntity> create(EquipamientoPersonalEntity entity);

  /// Actualiza un registro
  Future<EquipamientoPersonalEntity> update(EquipamientoPersonalEntity entity);

  /// Elimina un registro
  Future<void> delete(String id);

  /// Stream de todos los registros
  Stream<List<EquipamientoPersonalEntity>> watchAll();

  /// Stream por personal
  Stream<List<EquipamientoPersonalEntity>> watchByPersonalId(String personalId);
}
