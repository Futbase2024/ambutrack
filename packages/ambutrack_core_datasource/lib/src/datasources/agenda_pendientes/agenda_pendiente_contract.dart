import '../../core/base_datasource.dart';
import 'entities/agenda_pendiente_entity.dart';

/// Contrato para operaciones de datasource de agenda de pendientes
///
/// Extiende [BaseDatasource] con operaciones CRUD estándar
/// y métodos específicos para filtrado por empresa y fecha.
abstract class AgendaPendienteDataSource
    extends BaseDatasource<AgendaPendienteEntity> {
  /// Obtiene todos los pendientes de una empresa
  Future<List<AgendaPendienteEntity>> getByEmpresa(String empresaId);

  /// Obtiene los pendientes de hoy (fecha = hoy, completado = false)
  /// para una empresa específica
  Future<List<AgendaPendienteEntity>> getPendientesHoy(String empresaId);

  /// Marca un pendiente como completado o pendiente
  Future<void> marcarCompletado(String id, bool completado);
}
