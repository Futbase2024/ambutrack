import 'dart:typed_data';

import 'package:equatable/equatable.dart';

/// Eventos del BLoC de equipamiento de un vehículo
abstract class EquipamientoVehiculoEvent extends Equatable {
  const EquipamientoVehiculoEvent();

  @override
  List<Object?> get props => <Object?>[];
}

/// Carga (o recarga) la dotación del vehículo
class EquipamientoVehiculoLoadRequested extends EquipamientoVehiculoEvent {
  const EquipamientoVehiculoLoadRequested(this.vehiculoId);

  final String vehiculoId;

  @override
  List<Object?> get props => <Object?>[vehiculoId];
}

/// Actualiza los datos que registra el técnico en una línea
class EquipamientoLineaUpdateRequested extends EquipamientoVehiculoEvent {
  const EquipamientoLineaUpdateRequested({
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
  List<Object?> get props =>
      <Object?>[id, cantidad, fechaCaducidad, borrarCaducidad, lote, observaciones];
}

/// Excluye / vuelve a incluir un item de plantilla
class EquipamientoExcluirRequested extends EquipamientoVehiculoEvent {
  const EquipamientoExcluirRequested({required this.id, required this.excluido});

  final String id;
  final bool excluido;

  @override
  List<Object?> get props => <Object?>[id, excluido];
}

/// Añade un item extra fuera de plantilla
class EquipamientoExtraAddRequested extends EquipamientoVehiculoEvent {
  const EquipamientoExtraAddRequested({
    required this.productoId,
    required this.cantidad,
    this.fechaCaducidad,
    this.lote,
    this.observaciones,
  });

  final String productoId;
  final int cantidad;
  final DateTime? fechaCaducidad;
  final String? lote;
  final String? observaciones;

  @override
  List<Object?> get props => <Object?>[productoId, cantidad, fechaCaducidad, lote, observaciones];
}

/// Elimina un item extra
class EquipamientoExtraDeleteRequested extends EquipamientoVehiculoEvent {
  const EquipamientoExtraDeleteRequested(this.id);

  final String id;

  @override
  List<Object?> get props => <Object?>[id];
}

/// Sube o sustituye el adjunto de una línea
class EquipamientoAdjuntoUploadRequested extends EquipamientoVehiculoEvent {
  const EquipamientoAdjuntoUploadRequested({
    required this.id,
    required this.bytes,
    required this.fileName,
    this.contentType,
  });

  final String id;
  final Uint8List bytes;
  final String fileName;
  final String? contentType;

  @override
  List<Object?> get props => <Object?>[id, fileName, bytes.length, contentType];
}

/// Quita el adjunto de una línea
class EquipamientoAdjuntoDeleteRequested extends EquipamientoVehiculoEvent {
  const EquipamientoAdjuntoDeleteRequested(this.id);

  final String id;

  @override
  List<Object?> get props => <Object?>[id];
}
