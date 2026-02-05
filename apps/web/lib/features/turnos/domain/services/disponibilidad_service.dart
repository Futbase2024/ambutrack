import 'package:ambutrack_core/ambutrack_core.dart';
import 'package:ambutrack_web/features/turnos/domain/entities/disponibilidad_entity.dart';

/// Servicio para calcular disponibilidad y ocupación de personal
abstract class DisponibilidadService {
  /// Calcula la disponibilidad por franjas horarias en un rango de fechas
  ///
  /// Parámetros:
  /// - [turnos]: Lista de turnos a analizar
  /// - [fechaInicio]: Fecha de inicio del análisis
  /// - [fechaFin]: Fecha de fin del análisis
  /// - [intervaloHoras]: Duración de cada franja en horas (por defecto 1h)
  /// - [filter]: Filtros opcionales a aplicar
  ///
  /// Retorna lista de [DisponibilidadEntity] con la ocupación por franja
  Future<List<DisponibilidadEntity>> calcularDisponibilidad({
    required List<TurnoEntity> turnos,
    required DateTime fechaInicio,
    required DateTime fechaFin,
    int intervaloHoras = 1,
    DisponibilidadFilter filter = DisponibilidadFilter.empty,
  });

  /// Identifica gaps (franjas sin cobertura) en un rango de fechas
  ///
  /// Retorna solo las franjas con [NivelOcupacion.sinCobertura]
  Future<List<DisponibilidadEntity>> identificarGaps({
    required List<TurnoEntity> turnos,
    required DateTime fechaInicio,
    required DateTime fechaFin,
    int intervaloHoras = 1,
  });

  /// Identifica sobrecargas (franjas con exceso de personal)
  ///
  /// Retorna solo las franjas con [NivelOcupacion.sobrecarga]
  Future<List<DisponibilidadEntity>> identificarSobrecargas({
    required List<TurnoEntity> turnos,
    required DateTime fechaInicio,
    required DateTime fechaFin,
    int intervaloHoras = 1,
  });

  /// Calcula resumen de disponibilidad por día
  ///
  /// Agrupa las franjas por día y calcula estadísticas:
  /// - Cantidad promedio de personal
  /// - Franjas sin cobertura
  /// - Franjas con sobrecarga
  Future<Map<DateTime, DisponibilidadResumen>> calcularResumenDiario({
    required List<TurnoEntity> turnos,
    required DateTime fechaInicio,
    required DateTime fechaFin,
  });
}

/// Resumen de disponibilidad para un día completo
class DisponibilidadResumen {
  const DisponibilidadResumen({
    required this.fecha,
    required this.promedioPersonal,
    required this.cantidadGaps,
    required this.cantidadSobrecargas,
    required this.franjas,
  });

  /// Fecha del resumen
  final DateTime fecha;

  /// Cantidad promedio de personal en el día
  final double promedioPersonal;

  /// Cantidad de franjas sin cobertura
  final int cantidadGaps;

  /// Cantidad de franjas con sobrecarga
  final int cantidadSobrecargas;

  /// Lista de franjas del día
  final List<DisponibilidadEntity> franjas;
}
