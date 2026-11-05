import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';

/// Contrato del repositorio de auditoría general (tabla `audit_log`, solo lectura)
abstract class AuditLogRepository {
  /// Registros ordenados por fecha descendente. [hasta] es exclusivo.
  Future<List<AuditLogEntity>> search({
    String? tabla,
    String? accion,
    String? usuarioId,
    DateTime? desde,
    DateTime? hasta,
    int limit = 200,
    int offset = 0,
  });

  /// Total de registros que cumplen los filtros. [hasta] es exclusivo.
  Future<int> count({
    String? tabla,
    String? accion,
    String? usuarioId,
    DateTime? desde,
    DateTime? hasta,
  });
}
