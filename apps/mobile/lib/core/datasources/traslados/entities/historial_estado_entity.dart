import 'package:equatable/equatable.dart';
import 'estado_traslado_enum.dart';
import 'ubicacion_entity.dart';

/// Entidad que representa un cambio de estado en el historial de un traslado
class HistorialEstadoEntity extends Equatable {
  const HistorialEstadoEntity({
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
  final EstadoTraslado? estadoAnterior;
  final EstadoTraslado estadoNuevo;
  final String? idUsuario;
  final UbicacionEntity? ubicacion;
  final DateTime fechaCambio;
  final String? observaciones;
  final Map<String, dynamic>? metadata; // Metadata adicional en formato JSONB

  @override
  List<Object?> get props => [
        id,
        idTraslado,
        estadoAnterior,
        estadoNuevo,
        fechaCambio,
        idUsuario,
      ];

  HistorialEstadoEntity copyWith({
    String? id,
    String? idTraslado,
    EstadoTraslado? estadoAnterior,
    EstadoTraslado? estadoNuevo,
    String? idUsuario,
    UbicacionEntity? ubicacion,
    DateTime? fechaCambio,
    String? observaciones,
    Map<String, dynamic>? metadata,
  }) {
    return HistorialEstadoEntity(
      id: id ?? this.id,
      idTraslado: idTraslado ?? this.idTraslado,
      estadoAnterior: estadoAnterior ?? this.estadoAnterior,
      estadoNuevo: estadoNuevo ?? this.estadoNuevo,
      idUsuario: idUsuario ?? this.idUsuario,
      ubicacion: ubicacion ?? this.ubicacion,
      fechaCambio: fechaCambio ?? this.fechaCambio,
      observaciones: observaciones ?? this.observaciones,
      metadata: metadata ?? this.metadata,
    );
  }
}
