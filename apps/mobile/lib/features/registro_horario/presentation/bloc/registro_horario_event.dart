import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:equatable/equatable.dart';

import '../../domain/models/datos_inicio_turno.dart';

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

/// Datos elegidos en la hoja "Iniciar turno"
///
/// - [turno] != null → turno del cuadrante (se actualiza el vehículo si cambia)
/// - [turno] == null → se crea turno desde la app con [plantilla]
class InicioTurnoSeleccion extends Equatable {
  const InicioTurnoSeleccion({
    required this.vehiculo,
    this.turno,
    this.plantilla,
    this.datos,
  });

  final TurnoEntity? turno;
  final VehiculoEntity vehiculo;
  final PlantillaTurnoEntity? plantilla;

  /// Rol, km, combustible, checklist, geocerca... (null = sin datos extra)
  final DatosInicioTurno? datos;

  @override
  List<Object?> get props => [turno, vehiculo, plantilla, datos];
}

/// Evento para fichar entrada (inicio de turno)
class FicharEntrada extends RegistroHorarioEvent {
  const FicharEntrada({
    required this.latitud,
    required this.longitud,
    required this.precisionGps,
    required this.seleccion,
    this.observaciones,
  });

  final double latitud;
  final double longitud;
  final double precisionGps;
  final InicioTurnoSeleccion seleccion;
  final String? observaciones;

  @override
  List<Object?> get props => [latitud, longitud, precisionGps, seleccion, observaciones];
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

/// Evento para cambiar de vehículo durante el turno
///
/// 1. Cierra turno actual (salida) con vehículo actual
/// 2. Actualiza asignación en tabla turnos
/// 3. Abre nuevo turno (entrada) con nuevo vehículo
class CambiarVehiculo extends RegistroHorarioEvent {
  const CambiarVehiculo({
    required this.nuevoVehiculoId,
    required this.latitud,
    required this.longitud,
    required this.precisionGps,
    this.observaciones,
  });

  final String nuevoVehiculoId;
  final double latitud;
  final double longitud;
  final double precisionGps;
  final String? observaciones;

  @override
  List<Object?> get props => [nuevoVehiculoId, latitud, longitud, precisionGps, observaciones];
}
