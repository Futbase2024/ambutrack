import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/features/cuadrante/cuadrante_module/domain/entities/cuadrante_filter.dart';
import 'package:ambutrack_web/features/cuadrante/cuadrante_module/domain/entities/personal_con_turnos_entity.dart';
import 'package:ambutrack_web/features/cuadrante/cuadrante_module/domain/repositories/cuadrante_repository.dart';
import 'package:ambutrack_web/features/personal/domain/entities/personal_entity.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Implementación del repositorio de cuadrante
@LazySingleton(as: CuadranteRepository)
class CuadranteRepositoryImpl implements CuadranteRepository {
  CuadranteRepositoryImpl(this._supabase)
      : _turnosDataSource = TurnoDataSourceFactory.createSupabase();

  final SupabaseClient _supabase;
  final TurnoDataSource _turnosDataSource;

  @override
  Future<List<PersonalConTurnosEntity>> getCuadrante(CuadranteFilter filter) async {
    try {
      debugPrint('🔍 CuadranteRepository: Obteniendo cuadrante con filtros...');
      debugPrint('   Categoría: ${filter.categoriaServicio?.name}');
      debugPrint('   Puesto: ${filter.puestoId}');
      debugPrint('   Rango: ${filter.fechaInicio} - ${filter.fechaFin}');

      // Construir query de personal con filtros
      PostgrestFilterBuilder<dynamic> query = _supabase
          .from('tpersonal')
          .select('*, tcategorias(categoria)');

      // IMPORTANTE: Solo personal activo
      query = query.eq('activo', true);

      // Filtrar por puesto (si se proporciona)
      if (filter.puestoId != null) {
        query = query.eq('id_tpuesto', filter.puestoId!);
      }

      // Ejecutar query ordenado por apellidos
      final dynamic response = await query.order('apellidos');
      final List<dynamic> responseList = response as List<dynamic>;

      debugPrint('✅ Personal obtenido: ${responseList.length}');

      // Convertir a entidades extrayendo categoría del JOIN
      final List<PersonalEntity> personalList = responseList.cast<Map<String, dynamic>>().map((Map<String, dynamic> itemMap) {
        final dynamic categoriaData = itemMap['tcategorias'];
        String? categoriaNombre;
        if (categoriaData is Map && categoriaData.isNotEmpty) {
          categoriaNombre = categoriaData['categoria']?.toString();
        }
        final Map<String, dynamic> itemWithCategoria = Map<String, dynamic>.from(itemMap)
          ..['categoria'] = categoriaNombre
          ..remove('tcategorias');
        return PersonalEntity.fromMap(itemWithCategoria);
      }).toList();

      // Obtener turnos para el rango de fechas
      List<TurnoEntity> turnosList = <TurnoEntity>[];
      if (filter.fechaInicio != null && filter.fechaFin != null) {
        turnosList = await _turnosDataSource.getByDateRange(
          startDate: filter.fechaInicio!,
          endDate: filter.fechaFin!,
        );
      }

      debugPrint('✅ Turnos obtenidos: ${turnosList.length}');

      // Combinar personal con sus turnos
      final List<PersonalConTurnosEntity> cuadrante = personalList.map((PersonalEntity persona) {
        final List<TurnoEntity> turnosPersona = turnosList
            .where((TurnoEntity turno) => turno.idPersonal == persona.id)
            .toList();

        return PersonalConTurnosEntity(
          personal: persona,
          turnos: turnosPersona,
        );
      }).toList();

      // Filtrar solo con turnos si está activado
      if (filter.soloConTurnos) {
        final List<PersonalConTurnosEntity> filtered =
            cuadrante.where((PersonalConTurnosEntity pc) => pc.turnos.isNotEmpty).toList();
        debugPrint('✅ Filtrado solo con turnos: ${filtered.length}/${cuadrante.length}');
        return filtered;
      }

      debugPrint('✅ Cuadrante generado: ${cuadrante.length} personas');
      return cuadrante;
    } catch (e, stackTrace) {
      debugPrint('❌ Error al obtener cuadrante: $e');
      debugPrint('❌ StackTrace: $stackTrace');
      rethrow;
    }
  }

  @override
  Future<List<PersonalConTurnosEntity>> getCuadranteSemanal({
    required DateTime primerDiaSemana,
    CuadranteFilter? filter,
  }) async {
    debugPrint('📅 CuadranteRepository: Obteniendo cuadrante semanal');
    debugPrint('   Semana iniciando: ${primerDiaSemana.toIso8601String()}');

    // Normalizar fechas a medianoche
    final DateTime inicioNormalizado = DateTime(
      primerDiaSemana.year,
      primerDiaSemana.month,
      primerDiaSemana.day,
    );

    // Calcular último día de la semana (domingo) a las 23:59:59
    final DateTime finNormalizado = DateTime(
      inicioNormalizado.year,
      inicioNormalizado.month,
      inicioNormalizado.day + 6,
      23,
      59,
      59,
    );

    debugPrint('   Rango normalizado: ${inicioNormalizado.toIso8601String()} → ${finNormalizado.toIso8601String()}');

    // Crear filtro con rango de fechas
    final CuadranteFilter filterConFechas = (filter ?? const CuadranteFilter()).copyWith(
      fechaInicio: inicioNormalizado,
      fechaFin: finNormalizado,
    );

    return getCuadrante(filterConFechas);
  }

  @override
  Future<List<PersonalConTurnosEntity>> getCuadranteMensual({
    required int mes,
    required int anio,
    CuadranteFilter? filter,
  }) async {
    debugPrint('📅 CuadranteRepository: Obteniendo cuadrante mensual');
    debugPrint('   Mes/Año: $mes/$anio');

    // Calcular primer día del mes a las 00:00:00
    final DateTime primerDia = DateTime(anio, mes);

    // Calcular último día del mes a las 23:59:59
    final DateTime ultimoDiaMes = DateTime(anio, mes + 1, 0); // Día 0 del siguiente mes = último día del mes actual
    final DateTime ultimoDia = DateTime(
      ultimoDiaMes.year,
      ultimoDiaMes.month,
      ultimoDiaMes.day,
      23,
      59,
      59,
    );

    debugPrint('   Rango normalizado: ${primerDia.toIso8601String()} → ${ultimoDia.toIso8601String()}');

    // Crear filtro con rango de fechas
    final CuadranteFilter filterConFechas = (filter ?? const CuadranteFilter()).copyWith(
      fechaInicio: primerDia,
      fechaFin: ultimoDia,
    );

    return getCuadrante(filterConFechas);
  }

  @override
  Future<void> copiarSemanaTurnos({
    required DateTime semanaOrigen,
    required DateTime semanaDestino,
    List<String>? idPersonal,
  }) async {
    try {
      debugPrint('📋 CuadranteRepository: Copiando turnos de semana...');
      debugPrint('   Personal: ${idPersonal == null ? "TODOS" : idPersonal.join(", ")}');

      // Calcular rango de la semana origen (lunes 00:00 - domingo 23:59)
      final DateTime inicioOrigen = DateTime(
        semanaOrigen.year,
        semanaOrigen.month,
        semanaOrigen.day,
      );
      final DateTime finOrigen = inicioOrigen.add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59));

      // Obtener todos los turnos de la semana origen
      final List<TurnoEntity> turnosOrigen = await _turnosDataSource.getByDateRange(
        startDate: inicioOrigen,
        endDate: finOrigen,
      );

      debugPrint('   📊 Turnos encontrados en semana origen: ${turnosOrigen.length}');

      // Filtrar por personal si se especificó
      final List<TurnoEntity> turnosFiltrados = idPersonal == null
          ? turnosOrigen
          : turnosOrigen.where((TurnoEntity t) => idPersonal.contains(t.idPersonal)).toList();

      debugPrint('   📊 Turnos a copiar (después de filtrar): ${turnosFiltrados.length}');

      if (turnosFiltrados.isEmpty) {
        debugPrint('   ⚠️ No hay turnos para copiar');
        return;
      }

      // Calcular diferencia en días entre semanas
      final int diferenciaDias = semanaDestino.difference(semanaOrigen).inDays;
      debugPrint('   📅 Diferencia de días: $diferenciaDias');

      // Obtener turnos existentes en la semana destino para validar conflictos de vehículos
      final DateTime inicioDestino = DateTime(
        semanaDestino.year,
        semanaDestino.month,
        semanaDestino.day,
      );
      final DateTime finDestino = inicioDestino.add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59));

      final List<TurnoEntity> turnosDestino = await _turnosDataSource.getByDateRange(
        startDate: inicioDestino,
        endDate: finDestino,
      );

      debugPrint('   📊 Turnos existentes en semana destino: ${turnosDestino.length}');

      // Copiar cada turno ajustando las fechas
      int copiadosCount = 0;
      int conflictosVehiculo = 0;
      for (final TurnoEntity turnoOrigen in turnosFiltrados) {
        // Calcular nuevas fechas sumando la diferencia
        final DateTime nuevaFechaInicio = turnoOrigen.fechaInicio.add(Duration(days: diferenciaDias));
        final DateTime nuevaFechaFin = turnoOrigen.fechaFin.add(Duration(days: diferenciaDias));

        // Validar conflicto de vehículo si tiene vehículo asignado
        String? idVehiculoFinal = turnoOrigen.idVehiculo;

        if (turnoOrigen.idVehiculo != null) {
          // Verificar si hay conflicto de vehículo en la semana destino
          final bool hayConflicto = _verificarConflictoVehiculo(
            turnosDestino,
            turnoOrigen.idVehiculo!,
            nuevaFechaInicio,
            turnoOrigen.horaInicio,
            turnoOrigen.horaFin,
          );

          if (hayConflicto) {
            idVehiculoFinal = null; // Copiar sin vehículo
            conflictosVehiculo++;
            debugPrint('      ⚠️ Conflicto de vehículo detectado, copiando sin vehículo');
          }
        }

        // Crear nuevo turno copiando TODOS los datos del original
        // Incluye: categoriaPersonal, contrato, dotación, vehículo (si no hay conflicto), base, observaciones
        final TurnoEntity nuevoTurno = TurnoEntity(
          id: '', // Se generará automáticamente en Supabase
          idPersonal: turnoOrigen.idPersonal,
          nombrePersonal: turnoOrigen.nombrePersonal,
          categoriaPersonal: turnoOrigen.categoriaPersonal, // Copiar categoría/función
          tipoTurno: turnoOrigen.tipoTurno,
          fechaInicio: nuevaFechaInicio,
          fechaFin: nuevaFechaFin,
          horaInicio: turnoOrigen.horaInicio,
          horaFin: turnoOrigen.horaFin,
          // Copiar TODOS los campos adicionales
          idBase: turnoOrigen.idBase,
          idVehiculo: idVehiculoFinal, // null si hay conflicto
          idDotacion: turnoOrigen.idDotacion,
          idContrato: turnoOrigen.idContrato,
          observaciones: turnoOrigen.observaciones,
        );

        // Log de datos copiados
        final String categoriaInfo = nuevoTurno.categoriaPersonal ?? 'Sin función';
        final String vehiculoInfo = nuevoTurno.idVehiculo ?? 'Sin vehículo';
        final String baseInfo = nuevoTurno.idBase ?? 'Sin base';
        final String dotacionInfo = nuevoTurno.idDotacion ?? 'Sin dotación';
        final String contratoInfo = nuevoTurno.idContrato ?? 'Sin contrato';

        debugPrint('   📋 Copiando turno #${copiadosCount + 1}: ${nuevoTurno.nombrePersonal}');
        debugPrint('      Tipo: ${nuevoTurno.tipoTurno.nombre}, Horario: ${nuevoTurno.horaInicio} - ${nuevoTurno.horaFin}');
        debugPrint('      Función: $categoriaInfo, Vehículo: $vehiculoInfo, Base: $baseInfo');
        debugPrint('      Dotación: $dotacionInfo, Contrato: $contratoInfo');

        // Crear el turno en la base de datos
        await _turnosDataSource.create(nuevoTurno);
        copiadosCount++;
      }

      debugPrint('   ✅ Copiados $copiadosCount turnos a la semana destino');
      if (conflictosVehiculo > 0) {
        debugPrint('   ⚠️ Se detectaron $conflictosVehiculo conflictos de vehículo (copiados sin vehículo)');
      }
    } catch (e, stackTrace) {
      debugPrint('   ❌ Error al copiar semana: $e');
      debugPrint('   StackTrace: $stackTrace');
      rethrow;
    }
  }

  /// Verifica si existe conflicto de vehículo en los turnos de destino
  bool _verificarConflictoVehiculo(
    List<TurnoEntity> turnosDestino,
    String idVehiculo,
    DateTime fecha,
    String horaInicio,
    String horaFin,
  ) {
    for (final TurnoEntity turno in turnosDestino) {
      // Solo verificar turnos con el mismo vehículo
      if (turno.idVehiculo == idVehiculo) {
        // Verificar si es el mismo día
        if (_mismaFecha(turno.fechaInicio, fecha)) {
          // Verificar si los horarios se solapan
          if (_horariosSeSolapan(horaInicio, horaFin, turno.horaInicio, turno.horaFin)) {
            debugPrint('      ⚠️ CONFLICTO VEHICULO: $idVehiculo ya asignado a ${turno.nombrePersonal}');
            return true;
          }
        }
      }
    }
    return false;
  }

  /// Verifica si dos fechas son el mismo día
  bool _mismaFecha(DateTime fecha1, DateTime fecha2) {
    return fecha1.year == fecha2.year &&
        fecha1.month == fecha2.month &&
        fecha1.day == fecha2.day;
  }

  /// Verifica si dos horarios se solapan
  bool _horariosSeSolapan(String inicio1, String fin1, String inicio2, String fin2) {
    final int minutos1Inicio = _horaAMinutos(inicio1);
    final int minutos1Fin = _horaAMinutos(fin1);
    final int minutos2Inicio = _horaAMinutos(inicio2);
    final int minutos2Fin = _horaAMinutos(fin2);

    // Verificar solapamiento
    return (minutos1Inicio < minutos2Fin) && (minutos1Fin > minutos2Inicio);
  }

  /// Convierte hora en formato "HH:mm" a minutos desde medianoche
  int _horaAMinutos(String hora) {
    final List<String> partes = hora.split(':');
    final int horas = int.parse(partes[0]);
    final int minutos = int.parse(partes[1]);
    return (horas * 60) + minutos;
  }
}
