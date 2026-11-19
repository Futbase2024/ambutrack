import 'package:equatable/equatable.dart';

/// Eventos del GeneracionTrasladosBloc
abstract class GeneracionTrasladosEvent extends Equatable {
  const GeneracionTrasladosEvent();

  @override
  List<Object?> get props => <Object?>[];
}

/// Carga el estado de la generación (servicios recurrentes vigentes)
class GeneracionEstadoRequested extends GeneracionTrasladosEvent {
  const GeneracionEstadoRequested();
}

/// Ejecuta la generación de traslados para los próximos [dias] días
class GeneracionEjecutarRequested extends GeneracionTrasladosEvent {
  const GeneracionEjecutarRequested({this.dias = 14});

  final int dias;

  @override
  List<Object?> get props => <Object?>[dias];
}
