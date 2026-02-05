import 'package:ambutrack_core/ambutrack_core.dart';

/// Repositorio para Historial Médico del Personal
abstract class HistorialMedicoRepository {
  /// Obtiene todos los registros de historial médico
  Future<List<HistorialMedicoEntity>> getAll();

  /// Obtiene un registro por ID
  Future<HistorialMedicoEntity> getById(String id);

  /// Obtiene el historial médico de un personal específico
  Future<List<HistorialMedicoEntity>> getByPersonalId(String personalId);

  /// Obtiene los reconocimientos próximos a caducar
  Future<List<HistorialMedicoEntity>> getProximosACaducar();

  /// Obtiene los reconocimientos caducados
  Future<List<HistorialMedicoEntity>> getCaducados();

  /// Crea un nuevo registro
  Future<HistorialMedicoEntity> create(HistorialMedicoEntity entity);

  /// Actualiza un registro existente
  Future<HistorialMedicoEntity> update(HistorialMedicoEntity entity);

  /// Elimina un registro
  Future<void> delete(String id);

  /// Stream de todos los registros
  Stream<List<HistorialMedicoEntity>> watchAll();

  /// Stream del historial de un personal
  Stream<List<HistorialMedicoEntity>> watchByPersonalId(String personalId);
}
