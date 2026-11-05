import 'package:equatable/equatable.dart';

/// Eventos del HistorialReparacionesBloc
abstract class HistorialReparacionesEvent extends Equatable {
  const HistorialReparacionesEvent();

  @override
  List<Object?> get props => <Object?>[];
}

/// Solicita (re)cargar el historial de órdenes terminadas
class HistorialReparacionesLoadRequested extends HistorialReparacionesEvent {
  const HistorialReparacionesLoadRequested();
}
