import 'package:equatable/equatable.dart';

/// Eventos del RegistroHorarioBloc
sealed class RegistroHorarioEvent extends Equatable {
  const RegistroHorarioEvent();

  @override
  List<Object?> get props => [];
}

/// Evento para cargar el historial de registros al entrar a la página
class CargarRegistrosHorario extends RegistroHorarioEvent {
  const CargarRegistrosHorario();
}

/// Evento para fichar entrada
class FicharEntrada extends RegistroHorarioEvent {
  const FicharEntrada({
    required this.latitud,
    required this.longitud,
    required this.precisionGps,
    this.observaciones,
  });

  final double latitud;
  final double longitud;
  final double precisionGps;
  final String? observaciones;

  @override
  List<Object?> get props => [latitud, longitud, precisionGps, observaciones];
}

/// Evento para fichar salida
class FicharSalida extends RegistroHorarioEvent {
  const FicharSalida({
    required this.latitud,
    required this.longitud,
    required this.precisionGps,
    this.observaciones,
  });

  final double latitud;
  final double longitud;
  final double precisionGps;
  final String? observaciones;

  @override
  List<Object?> get props => [latitud, longitud, precisionGps, observaciones];
}

/// Evento para refrescar el historial
class RefrescarHistorial extends RegistroHorarioEvent {
  const RefrescarHistorial();
}

/// Evento para obtener contexto completo del turno
///
/// Carga registros + información contextual (vehículo, compañero, próximo turno)
class ObtenerContextoTurno extends RegistroHorarioEvent {
  const ObtenerContextoTurno();
}
