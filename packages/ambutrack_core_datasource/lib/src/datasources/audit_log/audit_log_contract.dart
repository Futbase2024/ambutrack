import 'entities/audit_log_entity.dart';

/// Contrato del datasource de auditoría (tabla `audit_log`, solo lectura).
///
/// Filtros (todos opcionales, aplicados en servidor):
/// - [tabla]: nombre de la tabla auditada
/// - [accion]: `INSERT` | `UPDATE` | `DELETE`
/// - [usuarioId]: UUID del usuario que hizo el cambio
/// - [desde]: instante inicial (incluido)
/// - [hasta]: instante final (excluido)
abstract class AuditLogDataSource {
  /// Registros ordenados por `created_at` descendente, paginados con [limit]/[offset]
  Future<List<AuditLogEntity>> search({
    String? tabla,
    String? accion,
    String? usuarioId,
    DateTime? desde,
    DateTime? hasta,
    int limit = 200,
    int offset = 0,
  });

  /// Número total de registros que cumplen los filtros
  Future<int> count({
    String? tabla,
    String? accion,
    String? usuarioId,
    DateTime? desde,
    DateTime? hasta,
  });
}
