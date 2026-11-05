import 'package:equatable/equatable.dart';

/// Eventos del AlertasMantenimientoBloc
abstract class AlertasMantenimientoEvent extends Equatable {
  const AlertasMantenimientoEvent();

  @override
  List<Object?> get props => <Object?>[];
}

/// Solicita (re)calcular las alertas
class AlertasMantenimientoLoadRequested extends AlertasMantenimientoEvent {
  const AlertasMantenimientoLoadRequested();
}
