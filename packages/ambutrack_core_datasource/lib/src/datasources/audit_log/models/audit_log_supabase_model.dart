import '../entities/audit_log_entity.dart';

/// Model: Serialización JSON de la tabla `audit_log` (sin codegen)
class AuditLogSupabaseModel {
  const AuditLogSupabaseModel({
    required this.id,
    required this.tabla,
    required this.accion,
    required this.createdAt,
    this.empresaId,
    this.registroId,
    this.usuarioId,
    this.usuarioEmail,
    this.datosAntes,
    this.datosDespues,
    this.camposModificados = const <String>[],
  });

  factory AuditLogSupabaseModel.fromJson(Map<String, dynamic> json) {
    return AuditLogSupabaseModel(
      id: _parseInt(json['id']),
      empresaId: json['empresa_id'] as String?,
      tabla: (json['tabla'] as String?) ?? '',
      registroId: json['registro_id']?.toString(),
      accion: (json['accion'] as String?) ?? '',
      usuarioId: json['usuario_id'] as String?,
      usuarioEmail: json['usuario_email'] as String?,
      datosAntes: _parseMap(json['datos_antes']),
      datosDespues: _parseMap(json['datos_despues']),
      camposModificados: _parseList(json['campos_modificados']),
      createdAt: DateTime.tryParse((json['created_at'] as String?) ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  final int id;
  final String? empresaId;
  final String tabla;
  final String? registroId;
  final String accion;
  final String? usuarioId;
  final String? usuarioEmail;
  final Map<String, dynamic>? datosAntes;
  final Map<String, dynamic>? datosDespues;
  final List<String> camposModificados;
  final DateTime createdAt;

  static int _parseInt(dynamic value) {
    if (value is int) {
      return value;
    }
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static Map<String, dynamic>? _parseMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }
    if (value is Map) {
      return value.map((dynamic k, dynamic v) => MapEntry<String, dynamic>(k.toString(), v));
    }
    return null;
  }

  static List<String> _parseList(dynamic value) {
    if (value is List) {
      return value.map((dynamic e) => e.toString()).toList();
    }
    return const <String>[];
  }

  AuditLogEntity toEntity() {
    return AuditLogEntity(
      id: id,
      empresaId: empresaId,
      tabla: tabla,
      registroId: registroId,
      accion: accion,
      usuarioId: usuarioId,
      usuarioEmail: usuarioEmail,
      datosAntes: datosAntes,
      datosDespues: datosDespues,
      camposModificados: camposModificados,
      createdAt: createdAt,
    );
  }
}
