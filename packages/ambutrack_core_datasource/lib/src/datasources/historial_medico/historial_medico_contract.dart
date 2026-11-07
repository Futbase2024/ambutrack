import 'entities/historial_medico_entity.dart';

/// Contrato para el DataSource de Historial Médico del Personal
abstract class HistorialMedicoDataSource {
  /// Obtiene todos los registros de historial médico
  Future<List<HistorialMedicoEntity>> getAll();

  /// Obtiene un registro de historial médico por ID
  Future<HistorialMedicoEntity> getById(String id);

  /// Obtiene el historial médico de un personal específico
  Future<List<HistorialMedicoEntity>> getByPersonalId(String personalId);

  /// Obtiene los reconocimientos médicos próximos a caducar (30 días)
  Future<List<HistorialMedicoEntity>> getProximosACaducar();

  /// Obtiene los reconocimientos médicos caducados
  Future<List<HistorialMedicoEntity>> getCaducados();

  /// Crea un nuevo registro de historial médico
  Future<HistorialMedicoEntity> create(HistorialMedicoEntity entity);

  /// Actualiza un registro de historial médico existente
  Future<HistorialMedicoEntity> update(HistorialMedicoEntity entity);

  /// Elimina un registro de historial médico
  Future<void> delete(String id);

  /// Stream de todos los registros (tiempo real)
  Stream<List<HistorialMedicoEntity>> watchAll();

  /// Stream del historial de un personal específico
  Stream<List<HistorialMedicoEntity>> watchByPersonalId(String personalId);
}
