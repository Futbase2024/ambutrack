import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:equatable/equatable.dart';

/// Estados del bloc de caducidades
abstract class CaducidadesState extends Equatable {
  const CaducidadesState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial
class CaducidadesInitial extends CaducidadesState {
  const CaducidadesInitial();
}

/// Estado de carga
class CaducidadesLoading extends CaducidadesState {
  const CaducidadesLoading();
}

/// Estado de éxito
class CaducidadesLoaded extends CaducidadesState {
  final List<StockVehiculoEntity> items;
  final int vencidos;
  final int proximosAVencer;
  final int vigentes;

  const CaducidadesLoaded({
    required this.items,
    required this.vencidos,
    required this.proximosAVencer,
    required this.vigentes,
  });

  @override
  List<Object?> get props => [items, vencidos, proximosAVencer, vigentes];
}

/// Estado de error
class CaducidadesError extends CaducidadesState {
  final String message;

  const CaducidadesError(this.message);

  @override
  List<Object?> get props => [message];
}
