import 'package:ambutrack_core_datasource/src/datasources/vacaciones/entities/vacaciones_entity.dart';

/// Contrato para el datasource de Vacaciones
abstract class VacacionesDataSource {
  /// Obtiene todas las vacaciones
  Future<List<VacacionesEntity>> getAll();

  /// Obtiene vacaciones por ID
  Future<VacacionesEntity> getById(String id);

  /// Obtiene vacaciones por ID de personal
  Future<List<VacacionesEntity>> getByPersonalId(String idPersonal);

  /// Crea nueva solicitud de vacaciones
  Future<VacacionesEntity> create(VacacionesEntity entity);

  /// Actualiza vacaciones existentes
  Future<VacacionesEntity> update(VacacionesEntity entity);

  /// Elimina vacaciones (soft delete)
  Future<void> delete(String id);

  /// Observa cambios en tiempo real
  Stream<List<VacacionesEntity>> watchAll();

  /// Observa vacaciones de un personal específico
  Stream<List<VacacionesEntity>> watchByPersonalId(String idPersonal);
}
