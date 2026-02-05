import 'package:ambutrack_core/ambutrack_core.dart';
import 'package:equatable/equatable.dart';

/// Eventos del BLoC de Turnos
abstract class TurnosEvent extends Equatable {
  const TurnosEvent();

  @override
  List<Object?> get props => <Object?>[];
}

/// Solicita la carga de todos los turnos
class TurnosLoadRequested extends TurnosEvent {
  const TurnosLoadRequested();
}

/// Solicita la carga de turnos por rango de fechas
class TurnosLoadByDateRangeRequested extends TurnosEvent {
  const TurnosLoadByDateRangeRequested({
    required this.startDate,
    required this.endDate,
  });

  final DateTime startDate;
  final DateTime endDate;

  @override
  List<Object?> get props => <Object?>[startDate, endDate];
}

/// Solicita la carga de turnos de un personal
class TurnosLoadByPersonalRequested extends TurnosEvent {
  const TurnosLoadByPersonalRequested(this.idPersonal);

  final String idPersonal;

  @override
  List<Object?> get props => <Object?>[idPersonal];
}

/// Solicita la creación de un turno
class TurnoCreateRequested extends TurnosEvent {
  const TurnoCreateRequested(this.turno);

  final TurnoEntity turno;

  @override
  List<Object?> get props => <Object?>[turno];
}

/// Solicita la actualización de un turno
class TurnoUpdateRequested extends TurnosEvent {
  const TurnoUpdateRequested(this.turno);

  final TurnoEntity turno;

  @override
  List<Object?> get props => <Object?>[turno];
}

/// Solicita la eliminación de un turno
class TurnoDeleteRequested extends TurnosEvent {
  const TurnoDeleteRequested(this.id);

  final String id;

  @override
  List<Object?> get props => <Object?>[id];
}

/// Verifica conflictos de turnos
class TurnosCheckConflictsRequested extends TurnosEvent {
  const TurnosCheckConflictsRequested({
    required this.idPersonal,
    required this.fechaInicio,
    required this.fechaFin,
    this.excludeTurnoId,
    this.horaInicio,
    this.horaFin,
  });

  final String idPersonal;
  final DateTime fechaInicio;
  final DateTime fechaFin;
  final String? excludeTurnoId;
  final String? horaInicio;
  final String? horaFin;

  @override
  List<Object?> get props => <Object?>[
        idPersonal,
        fechaInicio,
        fechaFin,
        excludeTurnoId,
        horaInicio,
        horaFin,
      ];
}
