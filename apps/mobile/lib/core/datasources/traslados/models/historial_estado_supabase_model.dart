import '../entities/estado_traslado_enum.dart';
import '../entities/historial_estado_entity.dart';
import '../entities/ubicacion_entity.dart';

/// Modelo DTO para serialización JSON de historial de estados desde/hacia Supabase
class HistorialEstadoSupabaseModel {
  const HistorialEstadoSupabaseModel({
    required this.id,
    required this.idTraslado,
    required this.estadoNuevo,
    required this.fechaCambio,
    this.estadoAnterior,
    this.idUsuario,
    this.ubicacion,
    this.observaciones,
    this.metadata,
  });

  final String id;
  final String idTraslado;
  final String? estadoAnterior;
  final String estadoNuevo;
  final String? idUsuario;
  final Map<String, dynamic>? ubicacion;
  final DateTime fechaCambio;
  final String? observaciones;
  final Map<String, dynamic>? metadata;

  /// Convierte desde JSON de Supabase
  factory HistorialEstadoSupabaseModel.fromJson(Map<String, dynamic> json) {
    return HistorialEstadoSupabaseModel(
      id: json['id'] as String,
      idTraslado: json['id_traslado'] as String,
      estadoAnterior: json['estado_anterior'] as String?,
      estadoNuevo: json['estado_nuevo'] as String,
      idUsuario: json['id_usuario'] as String?,
      ubicacion: json['ubicacion'] as Map<String, dynamic>?,
      fechaCambio: DateTime.parse(json['fecha_cambio'] as String),
      observaciones: json['observaciones'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  /// Convierte a JSON para Supabase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'id_traslado': idTraslado,
      if (estadoAnterior != null) 'estado_anterior': estadoAnterior,
      'estado_nuevo': estadoNuevo,
      if (idUsuario != null) 'id_usuario': idUsuario,
      if (ubicacion != null) 'ubicacion': ubicacion,
      'fecha_cambio': fechaCambio.toIso8601String(),
      if (observaciones != null) 'observaciones': observaciones,
      if (metadata != null) 'metadata': metadata,
    };
  }

  /// Convierte a Entity de dominio
  HistorialEstadoEntity toEntity() {
    return HistorialEstadoEntity(
      id: id,
      idTraslado: idTraslado,
      estadoAnterior: estadoAnterior != null
          ? EstadoTraslado.fromString(estadoAnterior!)
          : null,
      estadoNuevo: EstadoTraslado.fromString(estadoNuevo),
      idUsuario: idUsuario,
      ubicacion:
          ubicacion != null ? UbicacionEntity.fromJson(ubicacion!) : null,
      fechaCambio: fechaCambio,
      observaciones: observaciones,
      metadata: metadata,
    );
  }

  /// Crea desde Entity de dominio
  factory HistorialEstadoSupabaseModel.fromEntity(HistorialEstadoEntity entity) {
    return HistorialEstadoSupabaseModel(
      id: entity.id,
      idTraslado: entity.idTraslado,
      estadoAnterior: entity.estadoAnterior?.value,
      estadoNuevo: entity.estadoNuevo.value,
      idUsuario: entity.idUsuario,
      ubicacion: entity.ubicacion?.toJson(),
      fechaCambio: entity.fechaCambio,
      observaciones: entity.observaciones,
      metadata: entity.metadata,
    );
  }
}
