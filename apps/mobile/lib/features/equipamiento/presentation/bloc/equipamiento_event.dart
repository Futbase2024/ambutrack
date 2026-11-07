import 'package:equatable/equatable.dart';

/// Eventos del BLoC de equipamiento del vehículo (técnico)
sealed class EquipamientoEvent extends Equatable {
  const EquipamientoEvent();

  @override
  List<Object?> get props => <Object?>[];
}

/// Carga (o recarga) la dotación del vehículo
class EquipamientoLoadRequested extends EquipamientoEvent {
  const EquipamientoLoadRequested(this.vehiculoId);

  final String vehiculoId;

  @override
  List<Object?> get props => <Object?>[vehiculoId];
}

/// Registra cantidad, caducidad, lote y observaciones de una línea
class EquipamientoLineaGuardada extends EquipamientoEvent {
  const EquipamientoLineaGuardada({
    required this.id,
    required this.cantidad,
    this.fechaCaducidad,
    this.borrarCaducidad = false,
    this.lote,
    this.observaciones,
  });

  final String id;
  final int cantidad;
  final DateTime? fechaCaducidad;
  final bool borrarCaducidad;
  final String? lote;
  final String? observaciones;

  @override
  List<Object?> get props => <Object?>[id, cantidad, fechaCaducidad, borrarCaducidad, lote, observaciones];
}
