import 'package:supabase_flutter/supabase_flutter.dart';

import '../../audit_log_contract.dart';
import '../../entities/audit_log_entity.dart';
import '../../models/audit_log_supabase_model.dart';

/// Implementación Supabase (solo lectura) de la tabla `audit_log`.
///
/// La RLS solo devuelve filas a administradores de la misma empresa.
class SupabaseAuditLogDataSource implements AuditLogDataSource {
  SupabaseAuditLogDataSource({
    SupabaseClient? supabase,
    String tableName = 'audit_log',
  })  : _supabase = supabase ?? Supabase.instance.client,
        _tableName = tableName;

  final SupabaseClient _supabase;
  final String _tableName;

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
    try {
      final PostgrestFilterBuilder<PostgrestList> query = _filtrar(
        _supabase.from(_tableName).select(),
        tabla: tabla,
        accion: accion,
        usuarioId: usuarioId,
        desde: desde,
        hasta: hasta,
      );
      final List<Map<String, dynamic>> response = await query
          .order('created_at', ascending: false)
          .order('id', ascending: false)
          .range(offset, offset + limit - 1);
      return response
          .map((Map<String, dynamic> json) => AuditLogSupabaseModel.fromJson(json).toEntity())
          .toList();
    } catch (e) {
      throw Exception('Error al consultar la auditoría: $e');
    }
  }

  @override
  Future<int> count({
    String? tabla,
    String? accion,
    String? usuarioId,
    DateTime? desde,
    DateTime? hasta,
  }) async {
    try {
      final PostgrestResponse<PostgrestList> response = await _filtrar(
        _supabase.from(_tableName).select('id'),
        tabla: tabla,
        accion: accion,
        usuarioId: usuarioId,
        desde: desde,
        hasta: hasta,
      ).count(CountOption.exact);
      return response.count;
    } catch (e) {
      throw Exception('Error al contar registros de auditoría: $e');
    }
  }

  PostgrestFilterBuilder<T> _filtrar<T>(
    PostgrestFilterBuilder<T> query, {
    String? tabla,
    String? accion,
    String? usuarioId,
    DateTime? desde,
    DateTime? hasta,
  }) {
    PostgrestFilterBuilder<T> q = query;
    if (tabla != null && tabla.isNotEmpty) {
      q = q.eq('tabla', tabla);
    }
    if (accion != null && accion.isNotEmpty) {
      q = q.eq('accion', accion);
    }
    if (usuarioId != null && usuarioId.isNotEmpty) {
      q = q.eq('usuario_id', usuarioId);
    }
    if (desde != null) {
      q = q.gte('created_at', desde.toUtc().toIso8601String());
    }
    if (hasta != null) {
      q = q.lt('created_at', hasta.toUtc().toIso8601String());
    }
    return q;
  }
}
