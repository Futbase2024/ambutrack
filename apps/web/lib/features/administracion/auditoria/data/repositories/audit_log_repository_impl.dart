import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/features/administracion/auditoria/domain/repositories/audit_log_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

/// Implementación pass-through del repositorio de auditoría
@LazySingleton(as: AuditLogRepository)
class AuditLogRepositoryImpl implements AuditLogRepository {
  AuditLogRepositoryImpl() : _dataSource = AuditLogDataSourceFactory.createSupabase();

  final AuditLogDataSource _dataSource;

  @override
  Future<List<AuditLogEntity>> search({
    String? tabla,
    String? accion,
    String? usuarioId,
    DateTime? desde,
    DateTime? hasta,
    int limit = 200,
    int offset = 0,
  }) async {
    debugPrint('📦 AuditLogRepository: Solicitando auditoría (offset $offset, limit $limit)...');
    return _dataSource.search(
      tabla: tabla,
      accion: accion,
      usuarioId: usuarioId,
      desde: desde,
      hasta: hasta,
      limit: limit,
      offset: offset,
    );
  }

  @override
  Future<int> count({
    String? tabla,
    String? accion,
    String? usuarioId,
    DateTime? desde,
    DateTime? hasta,
  }) async {
    return _dataSource.count(
      tabla: tabla,
      accion: accion,
      usuarioId: usuarioId,
      desde: desde,
      hasta: hasta,
    );
  }

  @override
  Future<List<AuditLogEntity>> getByRegistro({
    required String tabla,
    required String registroId,
    int limit = 100,
  }) async {
    debugPrint('📦 AuditLogRepository: Historial de $tabla/$registroId...');
    return _dataSource.getByRegistro(tabla: tabla, registroId: registroId, limit: limit);
  }
}
