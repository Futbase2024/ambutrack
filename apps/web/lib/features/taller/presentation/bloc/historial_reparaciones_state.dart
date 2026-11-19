import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:equatable/equatable.dart';

/// Estados del HistorialReparacionesBloc
abstract class HistorialReparacionesState extends Equatable {
  const HistorialReparacionesState();

  @override
  List<Object?> get props => <Object?>[];
}

class HistorialReparacionesInitial extends HistorialReparacionesState {
  const HistorialReparacionesInitial();
}

class HistorialReparacionesLoading extends HistorialReparacionesState {
  const HistorialReparacionesLoading();
}

/// Órdenes finalizadas, cerradas y anuladas
class HistorialReparacionesLoaded extends HistorialReparacionesState {
  const HistorialReparacionesLoaded({required this.ordenes});

  final List<OrdenReparacionEntity> ordenes;

  @override
  List<Object?> get props => <Object?>[ordenes];
}

class HistorialReparacionesError extends HistorialReparacionesState {
  const HistorialReparacionesError({required this.message});

  final String message;

  @override
  List<Object?> get props => <Object?>[message];
}
