import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/features/personal/domain/entities/personal_entity.dart';
import 'package:ambutrack_web/features/turnos/data/services/indisponibilidad_personal_loader.dart';
import 'package:ambutrack_web/features/turnos/domain/entities/configuracion_generacion_entity.dart';
import 'package:ambutrack_web/features/turnos/domain/entities/preferencia_personal_entity.dart';
import 'package:ambutrack_web/features/turnos/domain/entities/resultado_generacion_entity.dart';
import 'package:ambutrack_web/features/turnos/domain/services/estadisticas_generacion_calculator.dart';
import 'package:ambutrack_web/features/turnos/domain/services/generacion_automatica_service.dart';
import 'package:ambutrack_web/features/turnos/domain/services/turno_ausencias_checker.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';

@LazySingleton(as: GeneracionAutomaticaService)
class GeneracionAutomaticaServiceImpl implements GeneracionAutomaticaService {
  final Uuid _uuid = const Uuid();

  @override
  Future<ResultadoGeneracionEntity> generarCuadrante({
    required DateTime fechaInicio,
    required DateTime fechaFin,
    required List<PersonalEntity> personal,
    required ConfiguracionGeneracionEntity configuracion,
    List<PreferenciaPersonalEntity>? preferencias,
    List<TurnoEntity>? turnosExistentes,
    List<PeriodoIndisponibilidad>? indisponibilidades,
  }) async {
    debugPrint('🚀 Iniciando generación automática de cuadrante...');
    debugPrint('📅 Período: ${fechaInicio.toString().split(' ')[0]} - ${fechaFin.toString().split(' ')[0]}');
    debugPrint('👥 Personal disponible: ${personal.length}');

    final List<TurnoEntity> turnosGenerados = <TurnoEntity>[];
    final List<ConflictoGeneracion> conflictos = <ConflictoGeneracion>[];
    final List<AdvertenciaGeneracion> advertencias = <AdvertenciaGeneracion>[];
    final List<TurnoEntity> todosTurnos = turnosExistentes ?? <TurnoEntity>[];
    final List<PeriodoIndisponibilidad> periodos = indisponibilidades ??
        await _cargarIndisponibilidades(fechaInicio, fechaFin, advertencias);
    // Evita repetir el mismo conflicto de ausencia por persona y día
    final Set<String> ausenciasNotificadas = <String>{};

    // Calcular días a generar
    final int totalDias = fechaFin.difference(fechaInicio).inDays + 1;
    debugPrint('📊 Total de días a generar: $totalDias');

    // Tipos de turno a generar por día (3 turnos: Mañana, Tarde, Noche)
    const List<TipoTurno> tiposTurnoPorDia = <TipoTurno>[
      TipoTurno.manana,
      TipoTurno.tarde,
      TipoTurno.noche,
    ];

    // Índice para rotación equitativa
    int indicePersonal = 0;

    // Generar turnos día por día
    for (int dia = 0; dia < totalDias; dia++) {
      final DateTime fecha = fechaInicio.add(Duration(days: dia));
      final int diaSemana = fecha.weekday; // 1=Lunes, 7=Domingo

      debugPrint('📆 Generando turnos para ${fecha.toString().split(' ')[0]} (día ${dia + 1}/$totalDias)');

      // Generar 3 turnos por día (Mañana, Tarde, Noche)
      for (final TipoTurno tipoTurno in tiposTurnoPorDia) {
        // Buscar personal disponible siguiendo rotación
        PersonalEntity? personalAsignado;
        int intentos = 0;

        while (personalAsignado == null && intentos < personal.length) {
          final PersonalEntity candidato = personal[indicePersonal % personal.length];
          indicePersonal++;
          intentos++;

          // Verificar si el candidato puede tomar este turno
          final TurnoEntity turnoTemporal = _crearTurnoTemporal(
            idPersonal: candidato.id,
            fecha: fecha,
            tipoTurno: tipoTurno,
          );

          // Ausencias y vacaciones aprobadas bloquean la asignación
          final PeriodoIndisponibilidad? ausencia = TurnoAusenciasChecker.buscarConflicto(
            turno: turnoTemporal,
            idPersonal: candidato.id,
            periodos: periodos,
          );
          if (ausencia != null) {
            if (ausenciasNotificadas.add('${candidato.id}_${TurnoAusenciasChecker.formatearFecha(fecha)}')) {
              conflictos.add(ConflictoGeneracion(
                tipo: TipoConflicto.personalNoDisponible,
                mensaje: TurnoAusenciasChecker.mensajeConflicto(
                  nombrePersonal: '${candidato.nombre} ${candidato.apellidos}',
                  periodo: ausencia,
                ),
                idPersonal: candidato.id,
                fecha: fecha,
              ));
            }
            continue;
          }

          // Validar restricciones legales
          final List<TurnoEntity> turnosCandidato = todosTurnos
              .where((TurnoEntity t) => t.idPersonal == candidato.id)
              .toList();

          if (validarRestriccionesLegales(
            turnoNuevo: turnoTemporal,
            turnosExistentesPersonal: turnosCandidato,
            configuracion: configuracion,
          )) {
            // Verificar preferencias si está habilitado
            if (configuracion.respetarPreferencias && preferencias != null) {
              final PreferenciaPersonalEntity? pref = preferencias
                  .where((PreferenciaPersonalEntity p) =>
                      p.idPersonal == candidato.id && p.activo)
                  .firstOrNull;

              if (pref != null) {
                // Verificar día de la semana preferido
                if (pref.diasSemanaPreferidos.isNotEmpty &&
                    !pref.diasSemanaPreferidos.contains(diaSemana)) {
                  advertencias.add(AdvertenciaGeneracion(
                    mensaje:
                        '${candidato.nombre} ${candidato.apellidos} asignado fuera de sus días preferidos',
                    idPersonal: candidato.id,
                    fecha: fecha,
                  ));
                }

                // Verificar tipo de turno preferido
                if (pref.tipoTurnoPreferido != null &&
                    pref.tipoTurnoPreferido != tipoTurno) {
                  advertencias.add(AdvertenciaGeneracion(
                    mensaje:
                        '${candidato.nombre} ${candidato.apellidos} asignado a turno no preferido',
                    idPersonal: candidato.id,
                    fecha: fecha,
                  ));
                }
              }
            }

            personalAsignado = candidato;
          }
        }

        if (personalAsignado != null) {
          // Crear turno definitivo
          final TurnoEntity turno = _crearTurno(
            idPersonal: personalAsignado.id,
            fecha: fecha,
            tipoTurno: tipoTurno,
          );

          turnosGenerados.add(turno);
          todosTurnos.add(turno);

          debugPrint(
              '✅ Turno ${tipoTurno.nombre} asignado a ${personalAsignado.nombre} ${personalAsignado.apellidos}');
        } else {
          // No se pudo asignar nadie (conflicto)
          conflictos.add(ConflictoGeneracion(
            tipo: TipoConflicto.personalNoDisponible,
            mensaje:
                'No se pudo asignar personal para turno ${tipoTurno.nombre} en ${fecha.toString().split(' ')[0]}',
            idPersonal: null,
            fecha: fecha,
          ));

          debugPrint(
              '❌ No se pudo asignar personal para turno ${tipoTurno.nombre}');
        }
      }
    }

    // Calcular estadísticas
    final EstadisticasGeneracion estadisticas = EstadisticasGeneracionCalculator.calcular(
      turnosGenerados: turnosGenerados,
      huecosNecesarios: totalDias * tiposTurnoPorDia.length,
    );

    debugPrint('📊 Generación completada:');
    debugPrint('   - Turnos generados: ${turnosGenerados.length}');
    debugPrint('   - Conflictos: ${conflictos.length}');
    debugPrint('   - Advertencias: ${advertencias.length}');

    return ResultadoGeneracionEntity(
      turnosGenerados: turnosGenerados,
      conflictos: conflictos,
      advertencias: advertencias,
      estadisticas: estadisticas,
    );
  }

  @override
  bool validarRestriccionesLegales({
    required TurnoEntity turnoNuevo,
    required List<TurnoEntity> turnosExistentesPersonal,
    required ConfiguracionGeneracionEntity configuracion,
  }) {
    // 1. Verificar que no tenga otro turno el mismo día
    final bool tieneTurnoMismoDia = turnosExistentesPersonal.any(
      (TurnoEntity t) =>
          t.fechaInicio.year == turnoNuevo.fechaInicio.year &&
          t.fechaInicio.month == turnoNuevo.fechaInicio.month &&
          t.fechaInicio.day == turnoNuevo.fechaInicio.day,
    );

    if (tieneTurnoMismoDia) {
      return false;
    }

    // 2. Verificar descanso mínimo entre turnos (12 horas)
    for (final TurnoEntity turnoExistente in turnosExistentesPersonal) {
      final Duration diferencia =
          turnoNuevo.fechaInicio.difference(turnoExistente.fechaFin).abs();
      if (diferencia.inHours < configuracion.horasMinimasDescansoEntreTurnos) {
        return false;
      }
    }

    // 3. Verificar horas máximas semanales
    final DateTime inicioSemana =
        turnoNuevo.fechaInicio.subtract(Duration(days: turnoNuevo.fechaInicio.weekday - 1));
    final DateTime finSemana = inicioSemana.add(const Duration(days: 6));

    final double horasSemana = calcularHorasTrabajadas(
      idPersonal: turnoNuevo.idPersonal,
      fechaInicio: inicioSemana,
      fechaFin: finSemana,
      turnos: <TurnoEntity>[...turnosExistentesPersonal, turnoNuevo],
    );

    if (horasSemana > configuracion.horasMaximasSemanales) {
      return false;
    }

    // 4. Verificar días de descanso semanal
    final List<TurnoEntity> turnosSemana = turnosExistentesPersonal
        .where((TurnoEntity t) =>
            !t.fechaInicio.isBefore(inicioSemana) && !t.fechaInicio.isAfter(finSemana))
        .toList();

    final Set<int> diasConTurno = turnosSemana
        .map((TurnoEntity t) => t.fechaInicio.weekday)
        .toSet();

    if (diasConTurno.length >= 7 - configuracion.diasDescansoSemanal) {
      return false;
    }

    return true;
  }

  @override
  double calcularHorasTrabajadas({
    required String idPersonal,
    required DateTime fechaInicio,
    required DateTime fechaFin,
    required List<TurnoEntity> turnos,
  }) {
    final List<TurnoEntity> turnosPeriodo = turnos
        .where((TurnoEntity t) =>
            t.idPersonal == idPersonal &&
            !t.fechaInicio.isBefore(fechaInicio) &&
            !t.fechaFin.isAfter(fechaFin))
        .toList();

    double totalHoras = 0;
    for (final TurnoEntity turno in turnosPeriodo) {
      totalHoras += turno.fechaFin.difference(turno.fechaInicio).inHours.toDouble();
    }

    return totalHoras;
  }

  @override
  Map<String, int> distribuirTurnosEquitativamente({
    required int totalTurnosNecesarios,
    required List<PersonalEntity> personal,
  }) {
    final Map<String, int> distribucion = <String, int>{};
    final int turnosPorPersona = totalTurnosNecesarios ~/ personal.length;
    final int turnosRestantes = totalTurnosNecesarios % personal.length;

    for (int i = 0; i < personal.length; i++) {
      final PersonalEntity p = personal[i];
      distribucion[p.id] = turnosPorPersona + (i < turnosRestantes ? 1 : 0);
    }

    return distribucion;
  }

  // Métodos privados auxiliares

  TurnoEntity _crearTurnoTemporal({
    required String idPersonal,
    required DateTime fecha,
    required TipoTurno tipoTurno,
  }) {
    final Map<String, String> horarios = _obtenerHorariosTurno(tipoTurno);

    return TurnoEntity(
      id: 'temp',
      idPersonal: idPersonal,
      nombrePersonal: '', // Temporal, no se usa para validación
      tipoTurno: tipoTurno,
      fechaInicio: _parsearFechaHora(fecha, horarios['inicio']!),
      fechaFin: _parsearFechaHora(fecha, horarios['fin']!),
      horaInicio: horarios['inicio']!,
      horaFin: horarios['fin']!,
    );
  }

  TurnoEntity _crearTurno({
    required String idPersonal,
    required DateTime fecha,
    required TipoTurno tipoTurno,
  }) {
    final Map<String, String> horarios = _obtenerHorariosTurno(tipoTurno);

    return TurnoEntity(
      id: _uuid.v4(),
      idPersonal: idPersonal,
      nombrePersonal: '', // Se poblará desde el repositorio
      tipoTurno: tipoTurno,
      fechaInicio: _parsearFechaHora(fecha, horarios['inicio']!),
      fechaFin: _parsearFechaHora(fecha, horarios['fin']!),
      horaInicio: horarios['inicio']!,
      horaFin: horarios['fin']!,
      observaciones: 'Generado automáticamente',
    );
  }

  Map<String, String> _obtenerHorariosTurno(TipoTurno tipo) {
    switch (tipo) {
      case TipoTurno.manana:
        return <String, String>{'inicio': '07:00', 'fin': '15:00'};
      case TipoTurno.tarde:
        return <String, String>{'inicio': '15:00', 'fin': '23:00'};
      case TipoTurno.noche:
        return <String, String>{'inicio': '23:00', 'fin': '07:00'};
      case TipoTurno.personalizado:
        return <String, String>{'inicio': '08:00', 'fin': '16:00'};
    }
  }

  DateTime _parsearFechaHora(DateTime fecha, String hora) {
    final List<String> partes = hora.split(':');
    final int horas = int.parse(partes[0]);
    final int minutos = int.parse(partes[1]);

    DateTime resultado = DateTime(fecha.year, fecha.month, fecha.day, horas, minutos);

    // Si el turno termina antes de que empiece (ej: noche 23:00-07:00), agregar 1 día al fin
    if (hora == '07:00' && horas < 12) {
      resultado = resultado.add(const Duration(days: 1));
    }

    return resultado;
  }

  /// Carga ausencias/vacaciones aprobadas del período; si falla, avisa y sigue
  Future<List<PeriodoIndisponibilidad>> _cargarIndisponibilidades(
    DateTime fechaInicio,
    DateTime fechaFin,
    List<AdvertenciaGeneracion> advertencias,
  ) async {
    try {
      return await IndisponibilidadPersonalLoader().cargarEnRango(desde: fechaInicio, hasta: fechaFin);
    } catch (e) {
      debugPrint('⚠️ No se pudieron cargar ausencias/vacaciones: $e');
      advertencias.add(const AdvertenciaGeneracion(
        mensaje: 'No se pudieron comprobar ausencias y vacaciones: revisa el cuadrante manualmente',
        idPersonal: null,
      ));
      return <PeriodoIndisponibilidad>[];
    }
  }
}
