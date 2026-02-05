import 'package:ambutrack_core/ambutrack_core.dart';
import 'package:ambutrack_web/features/personal/domain/entities/personal_entity.dart';
import 'package:equatable/equatable.dart';

/// Entidad que representa personal con sus turnos asignados
/// Usado en el cuadrante para mostrar personal y su planificación
class PersonalConTurnosEntity extends Equatable {
  const PersonalConTurnosEntity({
    required this.personal,
    required this.turnos,
  });

  /// Información del personal
  final PersonalEntity personal;

  /// Lista de turnos asignados a este personal
  final List<TurnoEntity> turnos;

  /// Obtiene turnos para una fecha específica
  List<TurnoEntity> getTurnosParaFecha(DateTime fecha) {
    final DateTime fechaSinHora = DateTime(fecha.year, fecha.month, fecha.day);

    return turnos.where((TurnoEntity turno) {
      final DateTime inicioSinHora = DateTime(
        turno.fechaInicio.year,
        turno.fechaInicio.month,
        turno.fechaInicio.day,
      );
      final DateTime finSinHora = DateTime(
        turno.fechaFin.year,
        turno.fechaFin.month,
        turno.fechaFin.day,
      );

      // Un turno se muestra en una fecha si:
      // - La fecha está entre el inicio y el fin (inclusive)
      return !fechaSinHora.isBefore(inicioSinHora) && !fechaSinHora.isAfter(finSinHora);
    }).toList();
  }

  /// Verifica si tiene turno en una fecha específica
  bool tieneTurnoEn(DateTime fecha) {
    return getTurnosParaFecha(fecha).isNotEmpty;
  }

  /// Cuenta total de turnos asignados
  int get totalTurnos => turnos.length;

  @override
  List<Object?> get props => <Object?>[personal, turnos];

  /// Copia con modificaciones
  PersonalConTurnosEntity copyWith({
    PersonalEntity? personal,
    List<TurnoEntity>? turnos,
  }) {
    return PersonalConTurnosEntity(
      personal: personal ?? this.personal,
      turnos: turnos ?? this.turnos,
    );
  }
}
