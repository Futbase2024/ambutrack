import 'package:equatable/equatable.dart';

/// Entidad de dominio para Historial de Estados de un Traslado
///
/// Registra cada cambio de estado que ocurre en un traslado
class HistorialEstadoEntity extends Equatable {
  const HistorialEstadoEntity({
    required this.id,
    required this.trasladoId,
    required this.estadoAnterior,
    required this.estadoNuevo,
    required this.fechaCambio,
    this.usuarioId,
    this.usuarioNombre,
    this.motivo,
    this.observaciones,
    this.ubicacion,
    this.createdAt,
  });

  /// ID único del registro de historial
  final String id;

  /// ID del traslado al que pertenece este historial
  final String trasladoId;

  /// Estado anterior del traslado
  final String? estadoAnterior;

  /// Estado nuevo del traslado
  final String estadoNuevo;

  /// Fecha y hora en que ocurrió el cambio
  final DateTime fechaCambio;

  /// ID del usuario que realizó el cambio (opcional)
  final String? usuarioId;

  /// Nombre del usuario que realizó el cambio (opcional)
  final String? usuarioNombre;

  /// Motivo del cambio de estado (opcional)
  final String? motivo;

  /// Observaciones adicionales sobre el cambio (opcional)
  final String? observaciones;

  /// Ubicación GPS donde se realizó el cambio (opcional)
  final Map<String, dynamic>? ubicacion;

  /// Fecha de creación del registro
  final DateTime? createdAt;

  /// Convierte el historial a Map<String, dynamic>
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'traslado_id': trasladoId,
      if (estadoAnterior != null) 'estado_anterior': estadoAnterior,
      'estado_nuevo': estadoNuevo,
      'fecha_cambio': fechaCambio.toIso8601String(),
      if (usuarioId != null) 'usuario_id': usuarioId,
      if (usuarioNombre != null) 'usuario_nombre': usuarioNombre,
      if (motivo != null) 'motivo': motivo,
      if (observaciones != null) 'observaciones': observaciones,
      if (ubicacion != null) 'ubicacion': ubicacion,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
    };
  }

  /// Crea un HistorialEstadoEntity desde Map<String, dynamic>
  factory HistorialEstadoEntity.fromJson(Map<String, dynamic> json) {
    return HistorialEstadoEntity(
      id: json['id'] as String,
      trasladoId: json['traslado_id'] as String,
      estadoAnterior: json['estado_anterior'] as String?,
      estadoNuevo: json['estado_nuevo'] as String,
      fechaCambio: DateTime.parse(json['fecha_cambio'] as String),
      usuarioId: json['usuario_id'] as String?,
      usuarioNombre: json['usuario_nombre'] as String?,
      motivo: json['motivo'] as String?,
      observaciones: json['observaciones'] as String?,
      ubicacion: json['ubicacion'] as Map<String, dynamic>?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  /// Crea una copia con campos modificados
  HistorialEstadoEntity copyWith({
    String? id,
    String? trasladoId,
    String? estadoAnterior,
    String? estadoNuevo,
    DateTime? fechaCambio,
    String? usuarioId,
    String? usuarioNombre,
    String? motivo,
    String? observaciones,
    Map<String, dynamic>? ubicacion,
    DateTime? createdAt,
  }) {
    return HistorialEstadoEntity(
      id: id ?? this.id,
      trasladoId: trasladoId ?? this.trasladoId,
      estadoAnterior: estadoAnterior ?? this.estadoAnterior,
      estadoNuevo: estadoNuevo ?? this.estadoNuevo,
      fechaCambio: fechaCambio ?? this.fechaCambio,
      usuarioId: usuarioId ?? this.usuarioId,
      usuarioNombre: usuarioNombre ?? this.usuarioNombre,
      motivo: motivo ?? this.motivo,
      observaciones: observaciones ?? this.observaciones,
      ubicacion: ubicacion ?? this.ubicacion,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        trasladoId,
        estadoAnterior,
        estadoNuevo,
        fechaCambio,
        usuarioId,
        usuarioNombre,
        motivo,
        observaciones,
        ubicacion,
        createdAt,
      ];

  @override
  String toString() {
    return 'HistorialEstadoEntity('
        'id: $id, '
        'trasladoId: $trasladoId, '
        'estadoAnterior: $estadoAnterior, '
        'estadoNuevo: $estadoNuevo, '
        'fechaCambio: $fechaCambio'
        ')';
  }
}
