import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/features/turnos/domain/entities/disponibilidad_entity.dart';
import 'package:ambutrack_web/features/turnos/domain/services/disponibilidad_service.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

/// Implementación del servicio de disponibilidad
@LazySingleton(as: DisponibilidadService)
class DisponibilidadServiceImpl implements DisponibilidadService {
  @override
  Future<List<DisponibilidadEntity>> calcularDisponibilidad({
    required List<TurnoEntity> turnos,
    required DateTime fechaInicio,
    required DateTime fechaFin,
    int intervaloHoras = 1,
    DisponibilidadFilter filter = DisponibilidadFilter.empty,
  }) async {
    debugPrint(
      '🔍 Calculando disponibilidad desde $fechaInicio hasta $fechaFin',
    );

    final List<DisponibilidadEntity> disponibilidades = <DisponibilidadEntity>[];

    // Generar todas las franjas horarias
    DateTime franjaActual = fechaInicio;

    while (franjaActual.isBefore(fechaFin)) {
      final DateTime franjaFin = franjaActual.add(Duration(hours: intervaloHoras));

      // Contar cuántos turnos cubren esta franja
      final List<TurnoEntity> turnosCubriendo = _getTurnosCubriendoFranja(
        turnos: turnos,
        franjaInicio: franjaActual,
        franjaFin: franjaFin,
        filter: filter,
      );

      final DisponibilidadEntity disponibilidad = DisponibilidadEntity.fromTurnos(
        fecha: DateTime(franjaActual.year, franjaActual.month, franjaActual.day),
        horaInicio: franjaActual,
        horaFin: franjaFin,
        cantidadPersonal: turnosCubriendo.length,
        personalAsignado: turnosCubriendo.map((TurnoEntity t) => t.idPersonal).toList(),
      );

      // Aplicar filtros adicionales
      if (_pasaFiltros(disponibilidad, filter)) {
        disponibilidades.add(disponibilidad);
      }

      franjaActual = franjaFin;
    }

    debugPrint('✅ ${disponibilidades.length} franjas calculadas');
    return disponibilidades;
  }

  @override
  Future<List<DisponibilidadEntity>> identificarGaps({
    required List<TurnoEntity> turnos,
    required DateTime fechaInicio,
    required DateTime fechaFin,
    int intervaloHoras = 1,
  }) async {
    debugPrint('🔍 Identificando gaps de cobertura...');

    final List<DisponibilidadEntity> todasDisponibilidades =
        await calcularDisponibilidad(
      turnos: turnos,
      fechaInicio: fechaInicio,
      fechaFin: fechaFin,
      intervaloHoras: intervaloHoras,
    );

    final List<DisponibilidadEntity> gaps = todasDisponibilidades
        .where(
          (DisponibilidadEntity d) =>
              d.nivelOcupacion == NivelOcupacion.sinCobertura,
        )
        .toList();

    debugPrint('⚠️ ${gaps.length} gaps identificados');
    return gaps;
  }

  @override
  Future<List<DisponibilidadEntity>> identificarSobrecargas({
    required List<TurnoEntity> turnos,
    required DateTime fechaInicio,
    required DateTime fechaFin,
    int intervaloHoras = 1,
  }) async {
    debugPrint('🔍 Identificando sobrecargas...');

    final List<DisponibilidadEntity> todasDisponibilidades =
        await calcularDisponibilidad(
      turnos: turnos,
      fechaInicio: fechaInicio,
      fechaFin: fechaFin,
      intervaloHoras: intervaloHoras,
    );

    final List<DisponibilidadEntity> sobrecargas = todasDisponibilidades
        .where(
          (DisponibilidadEntity d) =>
              d.nivelOcupacion == NivelOcupacion.sobrecarga,
        )
        .toList();

    debugPrint('⚡ ${sobrecargas.length} sobrecargas identificadas');
    return sobrecargas;
  }

  @override
  Future<Map<DateTime, DisponibilidadResumen>> calcularResumenDiario({
    required List<TurnoEntity> turnos,
    required DateTime fechaInicio,
    required DateTime fechaFin,
  }) async {
    debugPrint('📊 Calculando resumen diario...');

    final List<DisponibilidadEntity> todasDisponibilidades =
        await calcularDisponibilidad(
      turnos: turnos,
      fechaInicio: fechaInicio,
      fechaFin: fechaFin,
    );

    final Map<DateTime, DisponibilidadResumen> resumenes =
        <DateTime, DisponibilidadResumen>{};

    // Agrupar franjas por día
    final Map<DateTime, List<DisponibilidadEntity>> franjasesPorDia =
        <DateTime, List<DisponibilidadEntity>>{};

    for (final DisponibilidadEntity disponibilidad in todasDisponibilidades) {
      final DateTime dia = DateTime(
        disponibilidad.fecha.year,
        disponibilidad.fecha.month,
        disponibilidad.fecha.day,
      );

      if (!franjasesPorDia.containsKey(dia)) {
        franjasesPorDia[dia] = <DisponibilidadEntity>[];
      }
      franjasesPorDia[dia]!.add(disponibilidad);
    }

    // Calcular resumen para cada día
    for (final MapEntry<DateTime, List<DisponibilidadEntity>> entry
        in franjasesPorDia.entries) {
      final DateTime dia = entry.key;
      final List<DisponibilidadEntity> franjas = entry.value;

      final double promedioPersonal = franjas.isEmpty
          ? 0
          : franjas
                  .map((DisponibilidadEntity f) => f.cantidadPersonal)
                  .reduce((int a, int b) => a + b) /
              franjas.length;

      final int cantidadGaps = franjas
          .where(
            (DisponibilidadEntity f) =>
                f.nivelOcupacion == NivelOcupacion.sinCobertura,
          )
          .length;

      final int cantidadSobrecargas = franjas
          .where(
            (DisponibilidadEntity f) =>
                f.nivelOcupacion == NivelOcupacion.sobrecarga,
          )
          .length;

      resumenes[dia] = DisponibilidadResumen(
        fecha: dia,
        promedioPersonal: promedioPersonal,
        cantidadGaps: cantidadGaps,
        cantidadSobrecargas: cantidadSobrecargas,
        franjas: franjas,
      );
    }

    debugPrint('✅ Resumen de ${resumenes.length} días calculado');
    return resumenes;
  }

  /// Obtiene los turnos que cubren una franja horaria específica
  List<TurnoEntity> _getTurnosCubriendoFranja({
    required List<TurnoEntity> turnos,
    required DateTime franjaInicio,
    required DateTime franjaFin,
    required DisponibilidadFilter filter,
  }) {
    return turnos.where((TurnoEntity turno) {
      // Verificar si el turno se solapa con la franja
      final bool seSuperpone = turno.fechaInicio.isBefore(franjaFin) &&
          turno.fechaFin.isAfter(franjaInicio);

      if (!seSuperpone) {
        return false;
      }

      // TODO(dev): Aplicar filtros cuando TurnoEntity incluya categoriaServicio
      // if (filter.categoriaServicio != null &&
      //     turno.categoriaServicio != filter.categoriaServicio) {
      //   return false;
      // }

      // if (filter.tipoTurno != null && turno.tipoTurno.nombre != filter.tipoTurno) {
      //   return false;
      // }

      return true;
    }).toList();
  }

  /// Verifica si una disponibilidad pasa los filtros aplicados
  bool _pasaFiltros(
    DisponibilidadEntity disponibilidad,
    DisponibilidadFilter filter,
  ) {
    if (filter.soloGaps &&
        disponibilidad.nivelOcupacion != NivelOcupacion.sinCobertura) {
      return false;
    }

    if (filter.soloSobrecarga &&
        disponibilidad.nivelOcupacion != NivelOcupacion.sobrecarga) {
      return false;
    }

    return true;
  }
}
