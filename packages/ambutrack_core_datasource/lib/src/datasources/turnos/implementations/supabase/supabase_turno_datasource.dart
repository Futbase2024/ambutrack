import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../entities/turno_entity.dart';
import '../../models/turno_supabase_model.dart';
import '../../turno_contract.dart';

/// Implementación de TurnoDataSource usando Supabase
class SupabaseTurnoDataSource implements TurnoDataSource {
  SupabaseTurnoDataSource(this._supabase);

  final SupabaseClient _supabase;
  static const String tableName = 'turnos';

  @override
  Future<List<TurnoEntity>> getAll({int? limit, int? offset}) async {
    dynamic query = _supabase.from(tableName).select();

    if (offset != null) {
      query = query.range(offset, offset + (limit ?? 100) - 1);
    } else if (limit != null) {
      query = query.limit(limit);
    }

    final dynamic response = await query.order('fechaInicio', ascending: false);

    final List<Map<String, dynamic>> data =
        (response as List).cast<Map<String, dynamic>>();

    return data
        .map(TurnoSupabaseModel.fromJson)
        .map((model) => model.toEntity())
        .toList();
  }

  @override
  Future<TurnoEntity?> getById(String id) async {
    final dynamic response = await _supabase
        .from(tableName)
        .select()
        .eq('id', id)
        .maybeSingle();

    if (response == null) {
      return null;
    }

    final Map<String, dynamic> data = response as Map<String, dynamic>;
    return TurnoSupabaseModel.fromJson(data).toEntity();
  }

  @override
  Future<TurnoEntity> create(TurnoEntity entity) async {
    final TurnoSupabaseModel model = TurnoSupabaseModel.fromEntity(entity);

    final Map<String, dynamic> data = model.toJsonForInsert();

    final dynamic response =
        await _supabase.from(tableName).insert(data).select().single();

    final Map<String, dynamic> result = response as Map<String, dynamic>;
    return TurnoSupabaseModel.fromJson(result).toEntity();
  }

  @override
  Future<TurnoEntity> update(TurnoEntity entity) async {
    final TurnoSupabaseModel model = TurnoSupabaseModel.fromEntity(entity);

    final Map<String, dynamic> data = model.toJson()
      ..remove('id')
      ..remove('created_at')
      ..remove('updated_at');

    final dynamic response = await _supabase
        .from(tableName)
        .update(data)
        .eq('id', entity.id)
        .select()
        .single();

    final Map<String, dynamic> result = response as Map<String, dynamic>;
    return TurnoSupabaseModel.fromJson(result).toEntity();
  }

  @override
  Future<void> delete(String id) async {
    // Soft delete
    await _supabase.from(tableName).update(<String, dynamic>{
      'activo': false,
    }).eq('id', id);
  }

  @override
  Future<void> deleteBatch(List<String> ids) async {
    // Soft delete batch
    await _supabase.from(tableName).update(<String, dynamic>{
      'activo': false,
    }).inFilter('id', ids);
  }

  @override
  Future<int> count() async {
    final response = await _supabase
        .from(tableName)
        .select('id')
        .count(CountOption.exact);
    return response.count;
  }

  @override
  Stream<List<TurnoEntity>> watchAll() {
    return _supabase
        .from(tableName)
        .stream(primaryKey: <String>['id'])
        .order('fechaInicio', ascending: false)
        .map((List<Map<String, dynamic>> data) {
          return data
              .map(TurnoSupabaseModel.fromJson)
              .map((model) => model.toEntity())
              .toList();
        });
  }

  @override
  Stream<TurnoEntity?> watchById(String id) {
    return _supabase
        .from(tableName)
        .stream(primaryKey: <String>['id'])
        .eq('id', id)
        .map((List<Map<String, dynamic>> data) {
          if (data.isEmpty) {
            return null;
          }
          return TurnoSupabaseModel.fromJson(data.first).toEntity();
        });
  }

  @override
  Future<void> clear() async {
    await _supabase.from(tableName).delete().neq('id', '');
  }

  @override
  Future<List<TurnoEntity>> createBatch(List<TurnoEntity> entities) async {
    final List<Map<String, dynamic>> dataList = entities.map((entity) {
      final model = TurnoSupabaseModel.fromEntity(entity);
      return model.toJsonForInsert();
    }).toList();

    final dynamic response =
        await _supabase.from(tableName).insert(dataList).select();

    final List<Map<String, dynamic>> results =
        (response as List).cast<Map<String, dynamic>>();

    return results
        .map(TurnoSupabaseModel.fromJson)
        .map((model) => model.toEntity())
        .toList();
  }

  @override
  Future<bool> exists(String id) async {
    final response = await _supabase
        .from(tableName)
        .select('id')
        .eq('id', id)
        .maybeSingle();

    return response != null;
  }

  @override
  Future<List<TurnoEntity>> updateBatch(List<TurnoEntity> entities) async {
    final List<TurnoEntity> updated = [];

    for (final entity in entities) {
      final result = await update(entity);
      updated.add(result);
    }

    return updated;
  }

  // ===== MÉTODOS ESPECIALIZADOS =====

  @override
  Future<List<TurnoEntity>> getByDateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    debugPrint('🔍 TurnoDataSource.getByDateRange:');
    debugPrint('   startDate: ${startDate.toIso8601String()}');
    debugPrint('   endDate: ${endDate.toIso8601String()}');

    // Query que trae turnos que se solapen con el rango:
    // fechaInicio <= endDate AND fechaFin >= startDate
    final dynamic response = await _supabase
        .from(tableName)
        .select()
        .eq('activo', true)
        .lte('fechaInicio', endDate.toIso8601String())
        .gte('fechaFin', startDate.toIso8601String())
        .order('fechaInicio', ascending: true);

    final List<Map<String, dynamic>> data =
        (response as List).cast<Map<String, dynamic>>();

    debugPrint('   ✅ Turnos encontrados: ${data.length}');

    return data
        .map(TurnoSupabaseModel.fromJson)
        .map((model) => model.toEntity())
        .toList();
  }

  @override
  Future<List<TurnoEntity>> getByPersonal(String idPersonal) async {
    final dynamic response = await _supabase
        .from(tableName)
        .select()
        .eq('activo', true)
        .eq('idPersonal', idPersonal)
        .order('fechaInicio', ascending: false);

    final List<Map<String, dynamic>> data =
        (response as List).cast<Map<String, dynamic>>();

    return data
        .map(TurnoSupabaseModel.fromJson)
        .map((model) => model.toEntity())
        .toList();
  }

  @override
  Future<bool> hasConflicts({
    required String idPersonal,
    required DateTime fechaInicio,
    required DateTime fechaFin,
    String? excludeTurnoId,
    String? horaInicio,
    String? horaFin,
  }) async {
    debugPrint('🔍 TurnoDataSource.hasConflicts:');
    debugPrint('   idPersonal: $idPersonal');
    debugPrint('   fechaInicio: ${fechaInicio.toIso8601String()}');
    debugPrint('   fechaFin: ${fechaFin.toIso8601String()}');
    debugPrint('   horaInicio: $horaInicio');
    debugPrint('   horaFin: $horaFin');
    debugPrint('   excludeTurnoId: $excludeTurnoId');

    // Obtener todos los turnos activos del personal en el rango de fechas
    PostgrestFilterBuilder<dynamic> query = _supabase
        .from(tableName)
        .select('id, horaInicio, horaFin, fechaInicio, fechaFin')
        .eq('activo', true)
        .eq('idPersonal', idPersonal)
        .lte('fechaInicio', fechaFin.toIso8601String())
        .gte('fechaFin', fechaInicio.toIso8601String());

    if (excludeTurnoId != null) {
      query = query.neq('id', excludeTurnoId);
    }

    final dynamic response = await query;
    final List<dynamic> turnos = response as List<dynamic>;

    debugPrint('   📊 Turnos existentes encontrados: ${turnos.length}');

    // Si no hay turnos, no hay conflictos
    if (turnos.isEmpty) {
      debugPrint('   ✅ No hay conflictos (sin turnos existentes)');
      return false;
    }

    // Si no se proporcionan horas, solo verificar solapamiento de fechas
    if (horaInicio == null || horaFin == null) {
      debugPrint('   ⚠️ Conflicto detectado (sin verificación de horarios)');
      return true;
    }

    // Convertir horas del nuevo turno a minutos
    final int nuevoInicio = _horaAMinutos(horaInicio);
    final int nuevoFin = _horaAMinutos(horaFin);
    final bool nuevoCruzaMedianoche = nuevoFin <= nuevoInicio;

    debugPrint('   Nuevo turno - inicio: $nuevoInicio min, fin: $nuevoFin min, cruzaMedianoche: $nuevoCruzaMedianoche');

    // Verificar solapamiento con cada turno existente
    for (final dynamic turno in turnos) {
      final Map<String, dynamic> t = turno as Map<String, dynamic>;
      final String? existenteHoraInicio = t['horaInicio'] as String?;
      final String? existenteHoraFin = t['horaFin'] as String?;

      if (existenteHoraInicio == null || existenteHoraFin == null) {
        // Si el turno existente no tiene horas definidas, considerarlo como conflicto
        debugPrint('   ⚠️ Conflicto con turno ${t['id']} (sin horas definidas)');
        return true;
      }

      final int existenteInicio = _horaAMinutos(existenteHoraInicio);
      final int existenteFin = _horaAMinutos(existenteHoraFin);
      final bool existenteCruzaMedianoche = existenteFin <= existenteInicio;

      debugPrint('   Turno existente ${t['id']} - inicio: $existenteInicio min, fin: $existenteFin min, cruzaMedianoche: $existenteCruzaMedianoche');

      // Verificar solapamiento de horarios
      if (_hayaSolapamientoHorarios(
        nuevoInicio: nuevoInicio,
        nuevoFin: nuevoFin,
        nuevoCruzaMedianoche: nuevoCruzaMedianoche,
        existenteInicio: existenteInicio,
        existenteFin: existenteFin,
        existenteCruzaMedianoche: existenteCruzaMedianoche,
      )) {
        debugPrint('   ❌ Conflicto detectado con turno ${t['id']}');
        return true;
      }
    }

    debugPrint('   ✅ No hay conflictos de horarios');
    return false;
  }

  /// Convierte una hora en formato "HH:mm" a minutos desde medianoche
  int _horaAMinutos(String hora) {
    final List<String> partes = hora.split(':');
    if (partes.length != 2) {
      return 0;
    }
    final int horas = int.tryParse(partes[0]) ?? 0;
    final int minutos = int.tryParse(partes[1]) ?? 0;
    return horas * 60 + minutos;
  }

  /// Verifica si hay solapamiento entre dos rangos de horarios
  /// Maneja correctamente los turnos que cruzan medianoche
  bool _hayaSolapamientoHorarios({
    required int nuevoInicio,
    required int nuevoFin,
    required bool nuevoCruzaMedianoche,
    required int existenteInicio,
    required int existenteFin,
    required bool existenteCruzaMedianoche,
  }) {
    // Caso 1: Ninguno cruza medianoche - verificación simple
    if (!nuevoCruzaMedianoche && !existenteCruzaMedianoche) {
      return nuevoInicio < existenteFin && nuevoFin > existenteInicio;
    }

    // Caso 2: Ambos cruzan medianoche - siempre hay solapamiento
    // (ambos cubren la medianoche, por lo que se solapan ahí)
    if (nuevoCruzaMedianoche && existenteCruzaMedianoche) {
      return true;
    }

    // Caso 3: Solo el nuevo turno cruza medianoche
    if (nuevoCruzaMedianoche) {
      // El nuevo turno cubre [nuevoInicio -> 24:00] y [00:00 -> nuevoFin]
      // Hay solapamiento si el existente está en alguno de esos rangos
      return existenteInicio < nuevoFin || existenteFin > nuevoInicio;
    }

    // Caso 4: Solo el turno existente cruza medianoche
    // El existente cubre [existenteInicio -> 24:00] y [00:00 -> existenteFin]
    // Hay solapamiento si el nuevo está en alguno de esos rangos
    return nuevoInicio < existenteFin || nuevoFin > existenteInicio;
  }

  @override
  Future<List<TurnoEntity>> getActivos() async {
    final dynamic response = await _supabase
        .from(tableName)
        .select()
        .eq('activo', true)
        .order('fechaInicio', ascending: false);

    final List<Map<String, dynamic>> data =
        (response as List).cast<Map<String, dynamic>>();

    return data
        .map(TurnoSupabaseModel.fromJson)
        .map((model) => model.toEntity())
        .toList();
  }

  @override
  Future<List<TurnoEntity>> copiarSemana({
    required DateTime fechaInicioOrigen,
    required DateTime fechaInicioDestino,
    List<String>? idPersonal,
  }) async {
    try {
      debugPrint('📦 TurnoDataSource: Copiando semana de turnos');
      debugPrint('   Origen: ${fechaInicioOrigen.toIso8601String().split('T')[0]}');
      debugPrint('   Destino: ${fechaInicioDestino.toIso8601String().split('T')[0]}');
      debugPrint('   Personal IDs: ${idPersonal?.join(", ") ?? 'TODOS'}');

      // Calcular rango de fechas (7 días de lunes a domingo)
      final DateTime fechaFinOrigen = fechaInicioOrigen.add(const Duration(days: 6));

      // Obtener todos los turnos de la semana origen
      final List<TurnoEntity> turnosOrigen = await getByDateRange(
        startDate: fechaInicioOrigen,
        endDate: fechaFinOrigen,
      );

      debugPrint('   📊 ${turnosOrigen.length} turnos encontrados en semana origen');

      // Filtrar por personal si se especifica
      List<TurnoEntity> turnosFiltrados = turnosOrigen;
      if (idPersonal != null && idPersonal.isNotEmpty) {
        turnosFiltrados = turnosOrigen
            .where((t) => idPersonal.contains(t.idPersonal))
            .toList();
        debugPrint('   🔍 ${turnosFiltrados.length} turnos después de filtrar por personal');
      }

      if (turnosFiltrados.isEmpty) {
        debugPrint('   ⚠️ No hay turnos para copiar');
        return <TurnoEntity>[];
      }

      // Calcular diferencia de días entre origen y destino
      final int diferenciaDias = fechaInicioDestino.difference(fechaInicioOrigen).inDays;

      // Crear nuevos turnos en la semana destino
      final List<TurnoEntity> turnosACrear = [];

      for (final TurnoEntity turnoOrigen in turnosFiltrados) {
        // Calcular nuevas fechas (mismo día de la semana pero en la semana destino)
        final DateTime nuevaFechaInicio = turnoOrigen.fechaInicio.add(Duration(days: diferenciaDias));
        final DateTime nuevaFechaFin = turnoOrigen.fechaFin.add(Duration(days: diferenciaDias));

        // Crear nueva entidad de turno con todos los datos del origen
        final TurnoEntity nuevoTurno = TurnoEntity(
          id: '', // Se generará automáticamente en Supabase
          idPersonal: turnoOrigen.idPersonal,
          nombrePersonal: turnoOrigen.nombrePersonal,
          tipoTurno: turnoOrigen.tipoTurno,
          fechaInicio: nuevaFechaInicio,
          fechaFin: nuevaFechaFin,
          horaInicio: turnoOrigen.horaInicio,
          horaFin: turnoOrigen.horaFin,
          observaciones: turnoOrigen.observaciones != null
              ? 'Copiado de ${turnoOrigen.fechaInicio.toIso8601String().split('T')[0]} - ${turnoOrigen.observaciones}'
              : 'Copiado de ${turnoOrigen.fechaInicio.toIso8601String().split('T')[0]}',
          activo: true,
          idContrato: turnoOrigen.idContrato,
          idBase: turnoOrigen.idBase,
          categoriaPersonal: turnoOrigen.categoriaPersonal,
          idVehiculo: turnoOrigen.idVehiculo,
          idDotacion: turnoOrigen.idDotacion,
        );

        turnosACrear.add(nuevoTurno);
      }

      // Crear los turnos en batch
      final List<TurnoEntity> turnosCreados = await createBatch(turnosACrear);

      debugPrint('✅ TurnoDataSource: Semana copiada exitosamente - ${turnosCreados.length} turnos creados');
      return turnosCreados;
    } catch (e, stackTrace) {
      debugPrint('❌ TurnoDataSource: Error al copiar semana: $e');
      debugPrint('StackTrace: $stackTrace');
      rethrow;
    }
  }

  @override
  Future<TurnoEntity?> getTurnoVigente(
    String idPersonal, {
    DateTime? ahora,
    Duration margen = const Duration(hours: 1),
  }) async {
    final DateTime momento = ahora ?? DateTime.now();
    final DateTime hoy = DateTime(momento.year, momento.month, momento.day);

    // Turnos que empiezan ayer (pueden cruzar medianoche), hoy o mañana
    final dynamic response = await _supabase
        .from(tableName)
        .select()
        .eq('idPersonal', idPersonal)
        .eq('activo', true)
        .gte('fechaInicio', hoy.subtract(const Duration(days: 1)).toUtc().toIso8601String())
        .lt('fechaInicio', hoy.add(const Duration(days: 2)).toUtc().toIso8601String());

    final List<TurnoEntity> candidatos = (response as List)
        .cast<Map<String, dynamic>>()
        .map(TurnoSupabaseModel.fromJson)
        .map((TurnoSupabaseModel m) => m.toEntity())
        .where((TurnoEntity t) =>
            !momento.isBefore(t.inicioReal.subtract(margen)) &&
            !momento.isAfter(t.finReal.add(margen)))
        .toList()
      ..sort((TurnoEntity a, TurnoEntity b) => a.inicioReal
          .difference(momento)
          .abs()
          .compareTo(b.inicioReal.difference(momento).abs()));

    debugPrint('🕐 TurnoDataSource: turno vigente para $idPersonal → '
        '${candidatos.isEmpty ? 'ninguno' : candidatos.first.id}');
    return candidatos.isEmpty ? null : candidatos.first;
  }

  @override
  Future<TurnoEntity> validar(String id) async {
    final dynamic response = await _supabase
        .from(tableName)
        .update(<String, dynamic>{'validado': true})
        .eq('id', id)
        .select()
        .single();

    return TurnoSupabaseModel.fromJson(response as Map<String, dynamic>).toEntity();
  }
}
