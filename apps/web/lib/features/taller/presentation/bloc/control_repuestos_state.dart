import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:equatable/equatable.dart';

/// Línea del control de repuestos: repuesto + orden a la que pertenece
class RepuestoControlItem extends Equatable {
  const RepuestoControlItem({required this.repuesto, this.orden});

  final RepuestoOrdenEntity repuesto;

  /// Orden asociada (null si no se encontró, p.ej. por permisos)
  final OrdenReparacionEntity? orden;

  String get id => repuesto.id;
  String? get numeroOrden => orden == null || orden!.numeroOrden.isEmpty ? null : orden!.numeroOrden;
  String? get vehiculoId => orden?.vehiculoId;
  String? get vehiculoMatricula => orden?.vehiculoMatricula;

  /// Fecha de referencia del repuesto (pedido o, si no, alta)
  DateTime get fechaReferencia => repuesto.fechaPedido ?? repuesto.createdAt;

  @override
  List<Object?> get props => <Object?>[repuesto, orden];
}

/// Estados del ControlRepuestosBloc
abstract class ControlRepuestosState extends Equatable {
  const ControlRepuestosState();

  @override
  List<Object?> get props => <Object?>[];
}

class ControlRepuestosInitial extends ControlRepuestosState {
  const ControlRepuestosInitial();
}

class ControlRepuestosLoading extends ControlRepuestosState {
  const ControlRepuestosLoading();
}

class ControlRepuestosLoaded extends ControlRepuestosState {
  const ControlRepuestosLoaded({required this.items});

  final List<RepuestoControlItem> items;

  @override
  List<Object?> get props => <Object?>[items];
}

class ControlRepuestosError extends ControlRepuestosState {
  const ControlRepuestosError({required this.message});

  final String message;

  @override
  List<Object?> get props => <Object?>[message];
}
