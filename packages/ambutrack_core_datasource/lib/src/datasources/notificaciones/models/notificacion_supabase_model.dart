import 'package:freezed_annotation/freezed_annotation.dart';
import '../entities/notificacion_entity.dart';

part 'notificacion_supabase_model.freezed.dart';
part 'notificacion_supabase_model.g.dart';

/// Model Supabase para Notificaciones
@freezed
class NotificacionSupabaseModel with _$NotificacionSupabaseModel {
  const NotificacionSupabaseModel._();

  const factory NotificacionSupabaseModel({
    required String id,
    @JsonKey(name: 'empresa_id') required String empresaId,
    @JsonKey(name: 'usuario_destino_id') required String usuarioDestinoId,
    required String tipo,
    required String titulo,
    required String mensaje,
    @JsonKey(name: 'entidad_tipo') String? entidadTipo,
    @JsonKey(name: 'entidad_id') String? entidadId,
    required bool leida,
    @JsonKey(name: 'fecha_lectura') DateTime? fechaLectura,
    @Default({}) Map<String, dynamic> metadata,  // ✅ Default vacío en lugar de required
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _NotificacionSupabaseModel;

  factory NotificacionSupabaseModel.fromJson(Map<String, dynamic> json) =>
      _$NotificacionSupabaseModelFromJson(json);

  /// Convierte el Model de Supabase a Entity de dominio
  NotificacionEntity toEntity() {
    return NotificacionEntity(
      id: id,
      empresaId: empresaId,
      usuarioDestinoId: usuarioDestinoId,
      tipo: NotificacionTipo.fromString(tipo),
      titulo: titulo,
      mensaje: mensaje,
      entidadTipo: entidadTipo,
      entidadId: entidadId,
      leida: leida,
      fechaLectura: fechaLectura,
      metadata: metadata,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Convierte Entity de dominio a Model de Supabase
  factory NotificacionSupabaseModel.fromEntity(NotificacionEntity entity) {
    return NotificacionSupabaseModel(
      id: entity.id,
      empresaId: entity.empresaId,
      usuarioDestinoId: entity.usuarioDestinoId,
      tipo: entity.tipo.value,
      titulo: entity.titulo,
      mensaje: entity.mensaje,
      entidadTipo: entity.entidadTipo,
      entidadId: entity.entidadId,
      leida: entity.leida,
      fechaLectura: entity.fechaLectura,
      metadata: entity.metadata,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}
