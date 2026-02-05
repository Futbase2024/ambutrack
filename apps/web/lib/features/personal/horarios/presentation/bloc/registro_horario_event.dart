import 'package:equatable/equatable.dart';

/// Eventos para el BLoC de registro horario
abstract class RegistroHorarioEvent extends Equatable {
  const RegistroHorarioEvent();

  @override
  List<Object?> get props => <Object?>[];
}

/// Evento para cargar los datos iniciales del personal seleccionado
class LoadRegistroHorarioData extends RegistroHorarioEvent {
  const LoadRegistroHorarioData({required this.personalId});

  final String personalId;

  @override
  List<Object?> get props => <Object?>[personalId];
}

/// Evento para cambiar el personal seleccionado
class ChangeSelectedPersonal extends RegistroHorarioEvent {
  const ChangeSelectedPersonal({
    required this.personalId,
    required this.nombrePersonal,
  });

  final String personalId;
  final String nombrePersonal;

  @override
  List<Object?> get props => <Object?>[personalId, nombrePersonal];
}

/// Evento para registrar una entrada
class RegisterEntrada extends RegistroHorarioEvent {
  const RegisterEntrada({
    required this.personalId,
    required this.nombrePersonal,
    this.ubicacion,
    this.latitud,
    this.longitud,
    this.vehiculoId,
    this.turno,
    this.notas,
  });

  final String personalId;
  final String nombrePersonal;
  final String? ubicacion;
  final double? latitud;
  final double? longitud;
  final String? vehiculoId;
  final String? turno;
  final String? notas;

  @override
  List<Object?> get props => <Object?>[
        personalId,
        nombrePersonal,
        ubicacion,
        latitud,
        longitud,
        vehiculoId,
        turno,
        notas,
      ];
}

/// Evento para registrar una salida
class RegisterSalida extends RegistroHorarioEvent {
  const RegisterSalida({
    required this.personalId,
    required this.nombrePersonal,
    this.ubicacion,
    this.latitud,
    this.longitud,
    this.notas,
  });

  final String personalId;
  final String nombrePersonal;
  final String? ubicacion;
  final double? latitud;
  final double? longitud;
  final String? notas;

  @override
  List<Object?> get props => <Object?>[
        personalId,
        nombrePersonal,
        ubicacion,
        latitud,
        longitud,
        notas,
      ];
}

/// Evento para refrescar los datos
class RefreshRegistroHorarioData extends RegistroHorarioEvent {
  const RefreshRegistroHorarioData({required this.personalId});

  final String personalId;

  @override
  List<Object?> get props => <Object?>[personalId];
}

/// Evento para cargar registros de una fecha específica
class LoadRegistrosByDate extends RegistroHorarioEvent {
  const LoadRegistrosByDate({
    required this.personalId,
    required this.fecha,
  });

  final String personalId;
  final DateTime fecha;

  @override
  List<Object?> get props => <Object?>[personalId, fecha];
}

/// Evento para cargar registros en un rango de fechas
class LoadRegistrosByDateRange extends RegistroHorarioEvent {
  const LoadRegistrosByDateRange({
    required this.personalId,
    required this.fechaInicio,
    required this.fechaFin,
  });

  final String personalId;
  final DateTime fechaInicio;
  final DateTime fechaFin;

  @override
  List<Object?> get props => <Object?>[personalId, fechaInicio, fechaFin];
}

/// Evento para cargar estadísticas
class LoadEstadisticas extends RegistroHorarioEvent {
  const LoadEstadisticas({
    this.fechaInicio,
    this.fechaFin,
  });

  final DateTime? fechaInicio;
  final DateTime? fechaFin;

  @override
  List<Object?> get props => <Object?>[fechaInicio, fechaFin];
}
