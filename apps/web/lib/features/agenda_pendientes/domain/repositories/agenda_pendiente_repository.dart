import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';

/// Contrato del repositorio de agenda de pendientes
abstract class AgendaPendienteRepository {
  /// Obtiene todos los pendientes
  Future<List<AgendaPendienteEntity>> getAll();

  /// Obtiene un pendiente por ID
  Future<AgendaPendienteEntity?> getById(String id);

  /// Obtiene los pendientes de una empresa
  Future<List<AgendaPendienteEntity>> getByEmpresa(String empresaId);

  /// Obtiene los pendientes de hoy para una empresa
  Future<List<AgendaPendienteEntity>> getPendientesHoy(String empresaId);

  /// Crea un nuevo pendiente
  Future<AgendaPendienteEntity> create(AgendaPendienteEntity pendiente);

  /// Actualiza un pendiente existente
  Future<AgendaPendienteEntity> update(AgendaPendienteEntity pendiente);

  /// Elimina un pendiente por ID
  Future<void> delete(String id);

  /// Marca un pendiente como completado o pendiente
  Future<void> marcarCompletado(String id, {required bool completado});

  /// Stream de todos los pendientes en tiempo real
  Stream<List<AgendaPendienteEntity>> watchAll();
}
