import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:equatable/equatable.dart';

/// Tipo de operación sobre un repuesto
enum RepuestoOperacion { crear, actualizar, eliminar }

/// Estados del RepuestoOrdenBloc
abstract class RepuestoOrdenState extends Equatable {
  const RepuestoOrdenState();

  @override
  List<Object?> get props => <Object?>[];
}

class RepuestoOrdenInitial extends RepuestoOrdenState {
  const RepuestoOrdenInitial();
}

class RepuestoOrdenLoading extends RepuestoOrdenState {
  const RepuestoOrdenLoading();
}

class RepuestoOrdenLoaded extends RepuestoOrdenState {
  const RepuestoOrdenLoaded({required this.repuestos});

  final List<RepuestoOrdenEntity> repuestos;

  @override
  List<Object?> get props => <Object?>[repuestos];
}

class RepuestoOrdenOperationSuccess extends RepuestoOrdenLoaded {
  RepuestoOrdenOperationSuccess({required super.repuestos, required this.operacion})
    : timestamp = DateTime.now().microsecondsSinceEpoch;

  final RepuestoOperacion operacion;
  final int timestamp;

  @override
  List<Object?> get props => <Object?>[repuestos, operacion, timestamp];
}

class RepuestoOrdenOperationFailure extends RepuestoOrdenLoaded {
  RepuestoOrdenOperationFailure({required super.repuestos, required this.operacion, required this.message})
    : timestamp = DateTime.now().microsecondsSinceEpoch;

  final RepuestoOperacion operacion;
  final String message;
  final int timestamp;

  @override
  List<Object?> get props => <Object?>[repuestos, operacion, message, timestamp];
}

class RepuestoOrdenError extends RepuestoOrdenState {
  const RepuestoOrdenError({required this.message});

  final String message;

  @override
  List<Object?> get props => <Object?>[message];
}
