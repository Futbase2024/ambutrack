import 'package:equatable/equatable.dart';

/// Eventos del ControlRepuestosBloc
abstract class ControlRepuestosEvent extends Equatable {
  const ControlRepuestosEvent();

  @override
  List<Object?> get props => <Object?>[];
}

/// Solicita (re)cargar todos los repuestos con su orden
class ControlRepuestosLoadRequested extends ControlRepuestosEvent {
  const ControlRepuestosLoadRequested();
}
