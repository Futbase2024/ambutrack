import 'package:equatable/equatable.dart';
import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';

/// Estados del RegistroHorarioBloc
sealed class RegistroHorarioState extends Equatable {
  const RegistroHorarioState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial - Cargando datos
class RegistroHorarioInitial extends RegistroHorarioState {
  const RegistroHorarioInitial();
}

/// Estado con datos cargados
class RegistroHorarioLoaded extends RegistroHorarioState {
  const RegistroHorarioLoaded({
    this.ultimoRegistro,
    required this.historial,
    required this.estadoActual,
  });

  final RegistroHorarioEntity? ultimoRegistro;
  final List<RegistroHorarioEntity> historial;
  final EstadoFichaje estadoActual;

  @override
  List<Object?> get props => [ultimoRegistro, historial, estadoActual];
}

/// Estado procesando fichaje
class RegistroHorarioFichando extends RegistroHorarioState {
  const RegistroHorarioFichando();
}

/// Estado de fichaje exitoso (temporal)
class RegistroHorarioSuccess extends RegistroHorarioState {
  const RegistroHorarioSuccess(this.mensaje);

  final String mensaje;

  @override
  List<Object?> get props => [mensaje];
}

/// Estado de error
class RegistroHorarioError extends RegistroHorarioState {
  const RegistroHorarioError(this.mensaje);

  final String mensaje;

  @override
  List<Object?> get props => [mensaje];
}

/// Enum para el estado actual del personal (dentro/fuera)
enum EstadoFichaje {
  fuera, // No ha fichado entrada o ya fichó salida
  dentro, // Ha fichado entrada y no ha fichado salida
}

/// Estado con datos cargados incluyendo contexto del turno
class RegistroHorarioLoadedWithContext extends RegistroHorarioState {
  const RegistroHorarioLoadedWithContext({
    this.ultimoRegistro,
    required this.historial,
    required this.estadoActual,
    this.vehiculo,
    this.companero,
    this.proximoTurno,
  });

  final RegistroHorarioEntity? ultimoRegistro;
  final List<RegistroHorarioEntity> historial;
  final EstadoFichaje estadoActual;
  final VehiculoEntity? vehiculo;
  final PersonalContexto? companero;
  final TurnoContexto? proximoTurno;

  /// Entrada con la que empezó la jornada en curso (null si está fuera).
  ///
  /// Se salta los pares salida/entrada de "Cambio de vehículo" para no
  /// confundir el cambio con el inicio de la jornada.
  RegistroHorarioEntity? get entradaJornada {
    if (estadoActual != EstadoFichaje.dentro || historial.isEmpty) {
      return null;
    }
    RegistroHorarioEntity? inicio;
    for (int i = 0; i < historial.length; i++) {
      final RegistroHorarioEntity r = historial[i];
      final bool esEntrada = r.tipo.toLowerCase() == 'entrada';
      if (esEntrada) {
        inicio = r;
        continue;
      }
      if (r.notas != 'Cambio de vehículo') {
        break;
      }
    }
    return inicio ?? ultimoRegistro;
  }

  @override
  List<Object?> get props => [
        ultimoRegistro,
        historial,
        estadoActual,
        vehiculo,
        companero,
        proximoTurno,
      ];
}

/// Mini-entidad para contexto de personal (compañero)
class PersonalContexto extends Equatable {
  const PersonalContexto({
    required this.id,
    required this.nombre,
    this.categoria,
  });

  final String id;
  final String nombre;
  final String? categoria;

  @override
  List<Object?> get props => [id, nombre, categoria];
}

/// Mini-entidad para contexto de turno
class TurnoContexto extends Equatable {
  const TurnoContexto({
    required this.fecha,
    this.turno,
  });

  final DateTime fecha;
  final String? turno;

  @override
  List<Object?> get props => [fecha, turno];
}
