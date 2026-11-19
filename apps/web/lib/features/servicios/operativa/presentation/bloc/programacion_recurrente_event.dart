import 'package:equatable/equatable.dart';

/// Eventos del ProgramacionRecurrenteBloc
abstract class ProgramacionRecurrenteEvent extends Equatable {
  const ProgramacionRecurrenteEvent();

  @override
  List<Object?> get props => <Object?>[];
}

/// Carga los servicios con recurrencia activa
class ProgramacionLoadRequested extends ProgramacionRecurrenteEvent {
  const ProgramacionLoadRequested();
}

/// Carga los traslados generados de un servicio recurrente
class ProgramacionTrasladosRequested extends ProgramacionRecurrenteEvent {
  const ProgramacionTrasladosRequested({required this.idServicioRecurrente});

  final String idServicioRecurrente;

  @override
  List<Object?> get props => <Object?>[idServicioRecurrente];
}
