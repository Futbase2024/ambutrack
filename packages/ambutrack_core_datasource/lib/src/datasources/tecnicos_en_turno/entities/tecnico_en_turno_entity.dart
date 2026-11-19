import 'package:equatable/equatable.dart';

/// Estado de presencia de un técnico respecto a su turno
enum PresenciaTecnico {
  /// Turno en curso y último fichaje de hoy es una entrada
  fichado,

  /// Turno en curso pero sin entrada fichada (retraso o ausencia)
  sinFichar,

  /// El turno empieza en las próximas horas
  porLlegar,
}

/// Técnico (TES / conductor) con turno en curso o próximo y su último fichaje.
///
/// Proyección de solo lectura que combina `turnos`, `tpersonal`/`tcategorias`
/// y `registros_horarios`.
class TecnicoEnTurnoEntity extends Equatable {
  const TecnicoEnTurnoEntity({
    required this.turnoId,
    required this.personalId,
    required this.nombre,
    required this.categoria,
    required this.inicioTurno,
    required this.finTurno,
    this.tipoTurno,
    this.ultimoFichajeTipo,
    this.ultimoFichajeHora,
  });

  /// ID del turno
  final String turnoId;

  /// ID del personal (tpersonal.id)
  final String personalId;

  /// Nombre completo en mayúsculas
  final String nombre;

  /// Categoría del personal (TES, CONDUCTOR...)
  final String categoria;

  /// Inicio real del turno
  final DateTime inicioTurno;

  /// Fin real del turno
  final DateTime finTurno;

  /// Tipo de turno (manana, tarde, noche...)
  final String? tipoTurno;

  /// Tipo del último fichaje desde el inicio del turno ('entrada' / 'salida')
  final String? ultimoFichajeTipo;

  /// Hora del último fichaje
  final DateTime? ultimoFichajeHora;

  /// Presencia del técnico en el instante [ahora]
  PresenciaTecnico presencia(DateTime ahora) {
    if (inicioTurno.isAfter(ahora)) {
      return PresenciaTecnico.porLlegar;
    }
    return ultimoFichajeTipo == 'entrada' ? PresenciaTecnico.fichado : PresenciaTecnico.sinFichar;
  }

  @override
  List<Object?> get props => <Object?>[
        turnoId,
        personalId,
        nombre,
        categoria,
        inicioTurno,
        finTurno,
        tipoTurno,
        ultimoFichajeTipo,
        ultimoFichajeHora,
      ];
}
