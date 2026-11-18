import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/features/turnos/domain/entities/validation_result_entity.dart';
import 'package:equatable/equatable.dart';

/// Periodo (por días, inclusivo) en el que una persona no puede trabajar:
/// ausencia aprobada o vacaciones aprobadas.
class PeriodoIndisponibilidad extends Equatable {
  const PeriodoIndisponibilidad({
    required this.idPersonal,
    required this.fechaInicio,
    required this.fechaFin,
    required this.motivo,
    this.esVacaciones = false,
  });

  final String idPersonal;
  final DateTime fechaInicio;
  final DateTime fechaFin;

  /// Texto legible: "vacaciones" o el nombre del tipo de ausencia
  final String motivo;
  final bool esVacaciones;

  /// Indica si el día [dia] cae dentro del periodo (comparación por fecha)
  bool contieneDia(DateTime dia) {
    final DateTime d = TurnoAusenciasChecker.soloFecha(dia);
    return !d.isBefore(TurnoAusenciasChecker.soloFecha(fechaInicio)) &&
        !d.isAfter(TurnoAusenciasChecker.soloFecha(fechaFin));
  }

  @override
  List<Object?> get props => <Object?>[idPersonal, fechaInicio, fechaFin, motivo, esVacaciones];
}

/// Lógica pura para detectar turnos que coinciden con ausencias/vacaciones.
class TurnoAusenciasChecker {
  const TurnoAusenciasChecker._();

  /// Ausencias activas y aprobadas → periodos de indisponibilidad.
  /// [nombresTipo] mapea `idTipoAusencia` → nombre legible (opcional).
  static List<PeriodoIndisponibilidad> desdeAusencias(
    List<AusenciaEntity> ausencias, {
    Map<String, String> nombresTipo = const <String, String>{},
  }) {
    return ausencias
        .where((AusenciaEntity a) => a.activo && a.estado == EstadoAusencia.aprobada)
        .map(
          (AusenciaEntity a) => PeriodoIndisponibilidad(
            idPersonal: a.idPersonal,
            fechaInicio: a.fechaInicio,
            fechaFin: a.fechaFin,
            motivo: (nombresTipo[a.idTipoAusencia] ?? 'ausencia').toLowerCase(),
          ),
        )
        .toList();
  }

  /// Vacaciones activas y aprobadas → periodos de indisponibilidad.
  static List<PeriodoIndisponibilidad> desdeVacaciones(List<VacacionesEntity> vacaciones) {
    return vacaciones
        .where((VacacionesEntity v) => v.activo && v.estado.toLowerCase() == 'aprobada')
        .map(
          (VacacionesEntity v) => PeriodoIndisponibilidad(
            idPersonal: v.idPersonal,
            fechaInicio: v.fechaInicio,
            fechaFin: v.fechaFin,
            motivo: 'vacaciones',
            esVacaciones: true,
          ),
        )
        .toList();
  }

  /// Días naturales que ocupa un turno.
  ///
  /// Un turno nocturno (p.ej. 23:00-07:00) solo cuenta su día de inicio: la
  /// madrugada siguiente no bloquea una ausencia que empiece ese día.
  static List<DateTime> diasDelTurno(TurnoEntity turno) {
    final DateTime inicio = soloFecha(turno.fechaInicio);
    DateTime fin = soloFecha(turno.fechaFin);
    final bool cruzaMedianoche = fin.isAfter(inicio) && _minutos(turno.horaFin) <= _minutos(turno.horaInicio);
    if (cruzaMedianoche) {
      fin = fin.subtract(const Duration(days: 1));
    }
    if (fin.isBefore(inicio)) {
      fin = inicio;
    }
    final List<DateTime> dias = <DateTime>[];
    for (DateTime d = inicio; !d.isAfter(fin); d = DateTime(d.year, d.month, d.day + 1)) {
      dias.add(d);
    }
    return dias;
  }

  /// Primer periodo de [idPersonal] que coincide con el turno, o null.
  static PeriodoIndisponibilidad? buscarConflicto({
    required TurnoEntity turno,
    required String idPersonal,
    required List<PeriodoIndisponibilidad> periodos,
  }) {
    final List<DateTime> dias = diasDelTurno(turno);
    for (final PeriodoIndisponibilidad p in periodos) {
      if (p.idPersonal == idPersonal && dias.any(p.contieneDia)) {
        return p;
      }
    }
    return null;
  }

  /// Resultado de validación: error crítico si el turno cae en una ausencia.
  static ValidationResult validar({
    required TurnoEntity turno,
    required String idPersonal,
    required List<PeriodoIndisponibilidad> periodos,
  }) {
    final PeriodoIndisponibilidad? conflicto =
        buscarConflicto(turno: turno, idPersonal: idPersonal, periodos: periodos);
    if (conflicto == null) {
      return ValidationResult.empty();
    }
    return ValidationResult.error(
      ValidationIssue(
        ruleType: ValidationRuleType.cruceConAusencia,
        severity: ValidationSeverity.error,
        message: mensajeConflicto(nombrePersonal: turno.nombrePersonal, periodo: conflicto),
        details: 'El turno del ${formatearFecha(turno.fechaInicio)} '
            '(${turno.horaInicio}-${turno.horaFin}) coincide con un periodo aprobado de ${conflicto.motivo}.',
        suggestedAction: 'Asigna el turno a otra persona o modifica la ${conflicto.esVacaciones ? 'solicitud de vacaciones' : 'ausencia'}.',
      ),
    );
  }

  /// Mensaje claro para mostrar al usuario
  static String mensajeConflicto({
    required String nombrePersonal,
    required PeriodoIndisponibilidad periodo,
  }) {
    final String quien = nombrePersonal.trim().isEmpty ? 'La persona' : nombrePersonal.trim();
    final String aprobada = periodo.esVacaciones ? 'aprobadas' : 'aprobada';
    return '$quien tiene ${periodo.motivo} $aprobada del '
        '${formatearFecha(periodo.fechaInicio)} al ${formatearFecha(periodo.fechaFin)}';
  }

  static DateTime soloFecha(DateTime d) => DateTime(d.year, d.month, d.day);

  static String formatearFecha(DateTime d) {
    final String dd = d.day.toString().padLeft(2, '0');
    final String mm = d.month.toString().padLeft(2, '0');
    return '$dd/$mm/${d.year}';
  }

  static int _minutos(String hora) {
    final List<String> partes = hora.split(':');
    if (partes.length < 2) {
      return 0;
    }
    return (int.tryParse(partes[0]) ?? 0) * 60 + (int.tryParse(partes[1]) ?? 0);
  }
}
