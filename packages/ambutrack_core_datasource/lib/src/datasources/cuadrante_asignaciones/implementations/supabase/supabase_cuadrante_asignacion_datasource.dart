import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../cuadrante_asignacion_contract.dart';
import '../../entities/cuadrante_asignacion_entity.dart';
import '../../models/cuadrante_asignacion_supabase_model.dart';

/// Implementación Supabase del datasource de cuadrante de asignaciones
class SupabaseCuadranteAsignacionDataSource
    implements CuadranteAsignacionDataSource {
  SupabaseCuadranteAsignacionDataSource(this._supabase);

  final SupabaseClient _supabase;
  static const String _tableName = 'cuadrante_asignaciones';

  @override
  Future<List<CuadranteAsignacionEntity>> getAll() async {
    try {
      debugPrint('📦 DataSource: Obteniendo todas las asignaciones activas');

      final List<Map<String, dynamic>> data = await _supabase
          .from(_tableName)
          .select()
          .eq('activo', true)
          .order('fecha', ascending: false)
          .order('hora_inicio', ascending: true);

      final List<CuadranteAsignacionEntity> asignaciones = data
          .map((json) =>
              CuadranteAsignacionSupabaseModel.fromJson(json).toEntity())
          .toList();

      debugPrint('✅ DataSource: ${asignaciones.length} asignaciones obtenidas');
      return asignaciones;
    } catch (e, stackTrace) {
      debugPrint('❌ DataSource: Error al obtener asignaciones: $e');
      debugPrint('StackTrace: $stackTrace');
      rethrow;
    }
  }

  @override
  Future<CuadranteAsignacionEntity?> getById(String id) async {
    try {
      debugPrint('📦 DataSource: Obteniendo asignación por ID: $id');

      final Map<String, dynamic>? data = await _supabase
          .from(_tableName)
          .select()
          .eq('id', id)
          .eq('activo', true)
          .maybeSingle();

      if (data == null) {
        debugPrint('⚠️ DataSource: Asignación no encontrada');
        return null;
      }

      final CuadranteAsignacionEntity asignacion =
          CuadranteAsignacionSupabaseModel.fromJson(data).toEntity();

      debugPrint('✅ DataSource: Asignación obtenida');
      return asignacion;
    } catch (e, stackTrace) {
      debugPrint('❌ DataSource: Error al obtener asignación: $e');
      debugPrint('StackTrace: $stackTrace');
      rethrow;
    }
  }

  @override
  Future<List<CuadranteAsignacionEntity>> getByFecha(DateTime fecha) async {
    try {
      final String fechaStr = fecha.toIso8601String().split('T')[0];
      debugPrint('📦 DataSource: Obteniendo asignaciones para fecha: $fechaStr');

      final List<Map<String, dynamic>> data = await _supabase
          .from(_tableName)
          .select()
          .eq('fecha', fechaStr)
          .eq('activo', true)
          .order('hora_inicio', ascending: true);

      final List<CuadranteAsignacionEntity> asignaciones = data
          .map((json) =>
              CuadranteAsignacionSupabaseModel.fromJson(json).toEntity())
          .toList();

      debugPrint('✅ DataSource: ${asignaciones.length} asignaciones obtenidas');
      return asignaciones;
    } catch (e, stackTrace) {
      debugPrint('❌ DataSource: Error al obtener asignaciones por fecha: $e');
      debugPrint('StackTrace: $stackTrace');
      rethrow;
    }
  }

  @override
  Future<List<CuadranteAsignacionEntity>> getByFechaRange({
    required DateTime fechaInicio,
    required DateTime fechaFin,
  }) async {
    try {
      final String fechaInicioStr = fechaInicio.toIso8601String().split('T')[0];
      final String fechaFinStr = fechaFin.toIso8601String().split('T')[0];
      debugPrint('📦 DataSource: Obteniendo asignaciones desde $fechaInicioStr hasta $fechaFinStr');

      final List<Map<String, dynamic>> data = await _supabase
          .from(_tableName)
          .select()
          .gte('fecha', fechaInicioStr)
          .lte('fecha', fechaFinStr)
          .eq('activo', true)
          .order('fecha', ascending: true)
          .order('hora_inicio', ascending: true);

      final List<CuadranteAsignacionEntity> asignaciones = data
          .map((json) =>
              CuadranteAsignacionSupabaseModel.fromJson(json).toEntity())
          .toList();

      debugPrint('✅ DataSource: ${asignaciones.length} asignaciones obtenidas');
      return asignaciones;
    } catch (e, stackTrace) {
      debugPrint('❌ DataSource: Error al obtener asignaciones por rango: $e');
      debugPrint('StackTrace: $stackTrace');
      rethrow;
    }
  }

  @override
  Future<List<CuadranteAsignacionEntity>> getByPersonal(String idPersonal) async {
    try {
      debugPrint('📦 DataSource: Obteniendo asignaciones del personal: $idPersonal');

      final List<Map<String, dynamic>> data = await _supabase
          .from(_tableName)
          .select()
          .eq('id_personal', idPersonal)
          .eq('activo', true)
          .order('fecha', ascending: false)
          .order('hora_inicio', ascending: true);

      final List<CuadranteAsignacionEntity> asignaciones = data
          .map((json) =>
              CuadranteAsignacionSupabaseModel.fromJson(json).toEntity())
          .toList();

      debugPrint('✅ DataSource: ${asignaciones.length} asignaciones obtenidas');
      return asignaciones;
    } catch (e, stackTrace) {
      debugPrint('❌ DataSource: Error al obtener asignaciones por personal: $e');
      debugPrint('StackTrace: $stackTrace');
      rethrow;
    }
  }

  @override
  Future<List<CuadranteAsignacionEntity>> getByPersonalAndFecha({
    required String idPersonal,
    required DateTime fecha,
  }) async {
    try {
      final String fechaStr = fecha.toIso8601String().split('T')[0];
      debugPrint('📦 DataSource: Obteniendo asignaciones del personal $idPersonal en fecha $fechaStr');

      final List<Map<String, dynamic>> data = await _supabase
          .from(_tableName)
          .select()
          .eq('id_personal', idPersonal)
          .eq('fecha', fechaStr)
          .eq('activo', true)
          .order('hora_inicio', ascending: true);

      final List<CuadranteAsignacionEntity> asignaciones = data
          .map((json) =>
              CuadranteAsignacionSupabaseModel.fromJson(json).toEntity())
          .toList();

      debugPrint('✅ DataSource: ${asignaciones.length} asignaciones obtenidas');
      return asignaciones;
    } catch (e, stackTrace) {
      debugPrint('❌ DataSource: Error al obtener asignaciones: $e');
      debugPrint('StackTrace: $stackTrace');
      rethrow;
    }
  }

  @override
  Future<List<CuadranteAsignacionEntity>> getByVehiculo(String idVehiculo) async {
    try {
      debugPrint('📦 DataSource: Obteniendo asignaciones del vehículo: $idVehiculo');

      final List<Map<String, dynamic>> data = await _supabase
          .from(_tableName)
          .select()
          .eq('id_vehiculo', idVehiculo)
          .eq('activo', true)
          .order('fecha', ascending: false);

      final List<CuadranteAsignacionEntity> asignaciones = data
          .map((json) =>
              CuadranteAsignacionSupabaseModel.fromJson(json).toEntity())
          .toList();

      debugPrint('✅ DataSource: ${asignaciones.length} asignaciones obtenidas');
      return asignaciones;
    } catch (e, stackTrace) {
      debugPrint('❌ DataSource: Error al obtener asignaciones por vehículo: $e');
      debugPrint('StackTrace: $stackTrace');
      rethrow;
    }
  }

  @override
  Future<List<CuadranteAsignacionEntity>> getByVehiculoAndFecha({
    required String idVehiculo,
    required DateTime fecha,
  }) async {
    try {
      final String fechaStr = fecha.toIso8601String().split('T')[0];
      debugPrint('📦 DataSource: Obteniendo asignaciones del vehículo $idVehiculo en fecha $fechaStr');

      final List<Map<String, dynamic>> data = await _supabase
          .from(_tableName)
          .select()
          .eq('id_vehiculo', idVehiculo)
          .eq('fecha', fechaStr)
          .eq('activo', true);

      final List<CuadranteAsignacionEntity> asignaciones = data
          .map((json) =>
              CuadranteAsignacionSupabaseModel.fromJson(json).toEntity())
          .toList();

      debugPrint('✅ DataSource: ${asignaciones.length} asignaciones obtenidas');
      return asignaciones;
    } catch (e, stackTrace) {
      debugPrint('❌ DataSource: Error al obtener asignaciones: $e');
      debugPrint('StackTrace: $stackTrace');
      rethrow;
    }
  }

  @override
  Future<List<CuadranteAsignacionEntity>> getByDotacion(String idDotacion) async {
    try {
      debugPrint('📦 DataSource: Obteniendo asignaciones de dotación: $idDotacion');

      final List<Map<String, dynamic>> data = await _supabase
          .from(_tableName)
          .select()
          .eq('id_dotacion', idDotacion)
          .eq('activo', true)
          .order('fecha', ascending: false)
          .order('numero_unidad', ascending: true);

      final List<CuadranteAsignacionEntity> asignaciones = data
          .map((json) =>
              CuadranteAsignacionSupabaseModel.fromJson(json).toEntity())
          .toList();

      debugPrint('✅ DataSource: ${asignaciones.length} asignaciones obtenidas');
      return asignaciones;
    } catch (e, stackTrace) {
      debugPrint('❌ DataSource: Error al obtener asignaciones por dotación: $e');
      debugPrint('StackTrace: $stackTrace');
      rethrow;
    }
  }

  @override
  Future<List<CuadranteAsignacionEntity>> getByDotacionAndFecha({
    required String idDotacion,
    required DateTime fecha,
  }) async {
    try {
      final String fechaStr = fecha.toIso8601String().split('T')[0];
      debugPrint('📦 DataSource: Obteniendo asignaciones de dotación $idDotacion en fecha $fechaStr');

      final List<Map<String, dynamic>> data = await _supabase
          .from(_tableName)
          .select()
          .eq('id_dotacion', idDotacion)
          .eq('fecha', fechaStr)
          .eq('activo', true)
          .order('numero_unidad', ascending: true);

      final List<CuadranteAsignacionEntity> asignaciones = data
          .map((json) =>
              CuadranteAsignacionSupabaseModel.fromJson(json).toEntity())
          .toList();

      debugPrint('✅ DataSource: ${asignaciones.length} asignaciones obtenidas');
      return asignaciones;
    } catch (e, stackTrace) {
      debugPrint('❌ DataSource: Error al obtener asignaciones: $e');
      debugPrint('StackTrace: $stackTrace');
      rethrow;
    }
  }

  @override
  Future<List<CuadranteAsignacionEntity>> getByEstado(EstadoAsignacion estado) async {
    try {
      debugPrint('📦 DataSource: Obteniendo asignaciones con estado: ${estado.value}');

      final List<Map<String, dynamic>> data = await _supabase
          .from(_tableName)
          .select()
          .eq('estado', estado.value)
          .eq('activo', true)
          .order('fecha', ascending: false);

      final List<CuadranteAsignacionEntity> asignaciones = data
          .map((json) =>
              CuadranteAsignacionSupabaseModel.fromJson(json).toEntity())
          .toList();

      debugPrint('✅ DataSource: ${asignaciones.length} asignaciones obtenidas');
      return asignaciones;
    } catch (e, stackTrace) {
      debugPrint('❌ DataSource: Error al obtener asignaciones por estado: $e');
      debugPrint('StackTrace: $stackTrace');
      rethrow;
    }
  }

  @override
  Future<bool> hasConflictPersonal({
    required String idPersonal,
    required DateTime fecha,
    required String horaInicio,
    required String horaFin,
    required bool cruzaMedianoche,
    String? excludeAsignacionId,
  }) async {
    try {
      final String fechaStr = fecha.toIso8601String().split('T')[0];
      debugPrint('🔍 DataSource: Verificando conflictos de personal');

      var query = _supabase
          .from(_tableName)
          .select()
          .eq('id_personal', idPersonal)
          .eq('fecha', fechaStr)
          .eq('activo', true);

      if (excludeAsignacionId != null) {
        query = query.neq('id', excludeAsignacionId);
      }

      final List<Map<String, dynamic>> data = await query;

      // Verificar solapamiento de horarios
      for (final json in data) {
        final model = CuadranteAsignacionSupabaseModel.fromJson(json);
        if (_horariosSeSuperponen(
          horaInicio,
          horaFin,
          cruzaMedianoche,
          model.horaInicio,
          model.horaFin,
          model.cruzaMedianoche,
        )) {
          debugPrint('⚠️ DataSource: Conflicto detectado');
          return true;
        }
      }

      debugPrint('✅ DataSource: No hay conflictos');
      return false;
    } catch (e, stackTrace) {
      debugPrint('❌ DataSource: Error al verificar conflictos: $e');
      debugPrint('StackTrace: $stackTrace');
      rethrow;
    }
  }

  @override
  Future<bool> hasConflictVehiculo({
    required String idVehiculo,
    required DateTime fecha,
    required String horaInicio,
    required String horaFin,
    required bool cruzaMedianoche,
    String? excludeAsignacionId,
  }) async {
    try {
      final String fechaStr = fecha.toIso8601String().split('T')[0];
      debugPrint('🔍 DataSource: Verificando conflictos de vehículo');

      var query = _supabase
          .from(_tableName)
          .select()
          .eq('id_vehiculo', idVehiculo)
          .eq('fecha', fechaStr)
          .eq('activo', true);

      if (excludeAsignacionId != null) {
        query = query.neq('id', excludeAsignacionId);
      }

      final List<Map<String, dynamic>> data = await query;

      // Verificar solapamiento de horarios
      for (final json in data) {
        final model = CuadranteAsignacionSupabaseModel.fromJson(json);
        if (_horariosSeSuperponen(
          horaInicio,
          horaFin,
          cruzaMedianoche,
          model.horaInicio,
          model.horaFin,
          model.cruzaMedianoche,
        )) {
          debugPrint('⚠️ DataSource: Conflicto detectado');
          return true;
        }
      }

      debugPrint('✅ DataSource: No hay conflictos');
      return false;
    } catch (e, stackTrace) {
      debugPrint('❌ DataSource: Error al verificar conflictos: $e');
      debugPrint('StackTrace: $stackTrace');
      rethrow;
    }
  }

  @override
  Future<bool> isDotacionUnidadAsignada({
    required String idDotacion,
    required DateTime fecha,
    required int numeroUnidad,
    String? excludeAsignacionId,
  }) async {
    try {
      final String fechaStr = fecha.toIso8601String().split('T')[0];
      debugPrint('🔍 DataSource: Verificando disponibilidad de unidad $numeroUnidad');

      var query = _supabase
          .from(_tableName)
          .select()
          .eq('id_dotacion', idDotacion)
          .eq('fecha', fechaStr)
          .eq('numero_unidad', numeroUnidad)
          .eq('activo', true)
          .inFilter('estado', ['planificada', 'confirmada', 'activa']);

      if (excludeAsignacionId != null) {
        query = query.neq('id', excludeAsignacionId);
      }

      final List<Map<String, dynamic>> data = await query;

      final bool asignada = data.isNotEmpty;
      debugPrint(asignada ? '⚠️ Unidad ya asignada' : '✅ Unidad disponible');
      return asignada;
    } catch (e, stackTrace) {
      debugPrint('❌ DataSource: Error al verificar unidad: $e');
      debugPrint('StackTrace: $stackTrace');
      rethrow;
    }
  }

  @override
  Future<CuadranteAsignacionEntity> create(
      CuadranteAsignacionEntity asignacion) async {
    try {
      debugPrint('📦 DataSource: Creando asignación');

      final model = CuadranteAsignacionSupabaseModel.fromEntity(asignacion);
      final Map<String, dynamic> data =
          await _supabase.from(_tableName).insert(model.toJson()).select().single();

      final CuadranteAsignacionEntity created =
          CuadranteAsignacionSupabaseModel.fromJson(data).toEntity();

      debugPrint('✅ DataSource: Asignación creada exitosamente');
      return created;
    } catch (e, stackTrace) {
      debugPrint('❌ DataSource: Error al crear asignación: $e');
      debugPrint('StackTrace: $stackTrace');
      rethrow;
    }
  }

  @override
  Future<CuadranteAsignacionEntity> update(
      CuadranteAsignacionEntity asignacion) async {
    try {
      debugPrint('📦 DataSource: Actualizando asignación ${asignacion.id}');

      final model = CuadranteAsignacionSupabaseModel.fromEntity(asignacion);
      final Map<String, dynamic> data = await _supabase
          .from(_tableName)
          .update(model.toJson())
          .eq('id', asignacion.id)
          .select()
          .single();

      final CuadranteAsignacionEntity updated =
          CuadranteAsignacionSupabaseModel.fromJson(data).toEntity();

      debugPrint('✅ DataSource: Asignación actualizada exitosamente');
      return updated;
    } catch (e, stackTrace) {
      debugPrint('❌ DataSource: Error al actualizar asignación: $e');
      debugPrint('StackTrace: $stackTrace');
      rethrow;
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      debugPrint('📦 DataSource: Eliminando asignación (soft delete) $id');

      await _supabase
          .from(_tableName)
          .update({'activo': false, 'updated_at': DateTime.now().toIso8601String()})
          .eq('id', id);

      debugPrint('✅ DataSource: Asignación eliminada exitosamente');
    } catch (e, stackTrace) {
      debugPrint('❌ DataSource: Error al eliminar asignación: $e');
      debugPrint('StackTrace: $stackTrace');
      rethrow;
    }
  }

  @override
  Future<CuadranteAsignacionEntity> confirmar({
    required String id,
    required String confirmadaPor,
  }) async {
    try {
      debugPrint('📦 DataSource: Confirmando asignación $id');

      final Map<String, dynamic> data = await _supabase
          .from(_tableName)
          .update({
            'estado': EstadoAsignacion.confirmada.value,
            'confirmada_por': confirmadaPor,
            'fecha_confirmacion': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', id)
          .select()
          .single();

      final CuadranteAsignacionEntity confirmed =
          CuadranteAsignacionSupabaseModel.fromJson(data).toEntity();

      debugPrint('✅ DataSource: Asignación confirmada exitosamente');
      return confirmed;
    } catch (e, stackTrace) {
      debugPrint('❌ DataSource: Error al confirmar asignación: $e');
      debugPrint('StackTrace: $stackTrace');
      rethrow;
    }
  }

  @override
  Future<CuadranteAsignacionEntity> cancelar(String id) async {
    try {
      debugPrint('📦 DataSource: Cancelando asignación $id');

      final Map<String, dynamic> data = await _supabase
          .from(_tableName)
          .update({
            'estado': EstadoAsignacion.cancelada.value,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', id)
          .select()
          .single();

      final CuadranteAsignacionEntity cancelled =
          CuadranteAsignacionSupabaseModel.fromJson(data).toEntity();

      debugPrint('✅ DataSource: Asignación cancelada exitosamente');
      return cancelled;
    } catch (e, stackTrace) {
      debugPrint('❌ DataSource: Error al cancelar asignación: $e');
      debugPrint('StackTrace: $stackTrace');
      rethrow;
    }
  }

  @override
  Future<CuadranteAsignacionEntity> completar({
    required String id,
    double? kmFinal,
    int? serviciosRealizados,
    double? horasEfectivas,
  }) async {
    try {
      debugPrint('📦 DataSource: Completando asignación $id');

      final Map<String, dynamic> updateData = {
        'estado': EstadoAsignacion.completada.value,
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (kmFinal != null) updateData['km_final'] = kmFinal;
      if (serviciosRealizados != null) {
        updateData['servicios_realizados'] = serviciosRealizados;
      }
      if (horasEfectivas != null) {
        updateData['horas_efectivas'] = horasEfectivas;
      }

      final Map<String, dynamic> data = await _supabase
          .from(_tableName)
          .update(updateData)
          .eq('id', id)
          .select()
          .single();

      final CuadranteAsignacionEntity completed =
          CuadranteAsignacionSupabaseModel.fromJson(data).toEntity();

      debugPrint('✅ DataSource: Asignación completada exitosamente');
      return completed;
    } catch (e, stackTrace) {
      debugPrint('❌ DataSource: Error al completar asignación: $e');
      debugPrint('StackTrace: $stackTrace');
      rethrow;
    }
  }

  @override
  Stream<List<CuadranteAsignacionEntity>> watchAll() {
    return _supabase
        .from(_tableName)
        .stream(primaryKey: ['id'])
        .order('fecha', ascending: false)
        .map((data) {
          final List<CuadranteAsignacionEntity> asignaciones = data
              .map((json) =>
                  CuadranteAsignacionSupabaseModel.fromJson(json).toEntity())
              .where((asignacion) => asignacion.activo)
              .toList();
          return asignaciones;
        });
  }

  @override
  Stream<List<CuadranteAsignacionEntity>> watchByFecha(DateTime fecha) {
    final String fechaStr = fecha.toIso8601String().split('T')[0];

    return _supabase
        .from(_tableName)
        .stream(primaryKey: ['id'])
        .order('hora_inicio', ascending: true)
        .map((data) {
          final List<CuadranteAsignacionEntity> asignaciones = data
              .map((json) =>
                  CuadranteAsignacionSupabaseModel.fromJson(json).toEntity())
              .where((asignacion) =>
                  asignacion.activo &&
                  asignacion.fecha.toIso8601String().split('T')[0] == fechaStr)
              .toList();
          return asignaciones;
        });
  }

  @override
  Stream<List<CuadranteAsignacionEntity>> watchByPersonal(String idPersonal) {
    return _supabase
        .from(_tableName)
        .stream(primaryKey: ['id'])
        .order('fecha', ascending: false)
        .map((data) {
          final List<CuadranteAsignacionEntity> asignaciones = data
              .map((json) =>
                  CuadranteAsignacionSupabaseModel.fromJson(json).toEntity())
              .where((asignacion) =>
                  asignacion.activo && asignacion.idPersonal == idPersonal)
              .toList();
          return asignaciones;
        });
  }

  @override
  Stream<List<CuadranteAsignacionEntity>> watchByDotacion(String idDotacion) {
    return _supabase
        .from(_tableName)
        .stream(primaryKey: ['id'])
        .order('fecha', ascending: false)
        .map((data) {
          final List<CuadranteAsignacionEntity> asignaciones = data
              .map((json) =>
                  CuadranteAsignacionSupabaseModel.fromJson(json).toEntity())
              .where((asignacion) =>
                  asignacion.activo && asignacion.idDotacion == idDotacion)
              .toList();
          return asignaciones;
        });
  }

  /// Verifica si dos rangos de horarios se superponen
  bool _horariosSeSuperponen(
    String inicio1,
    String fin1,
    bool cruza1,
    String inicio2,
    String fin2,
    bool cruza2,
  ) {
    // Convertir horas a minutos desde medianoche
    final int minInicio1 = _horaAMinutos(inicio1);
    final int minFin1 = _horaAMinutos(fin1) + (cruza1 ? 1440 : 0); // +24h si cruza
    final int minInicio2 = _horaAMinutos(inicio2);
    final int minFin2 = _horaAMinutos(fin2) + (cruza2 ? 1440 : 0); // +24h si cruza

    // Verificar solapamiento: inicio1 < fin2 && inicio2 < fin1
    return minInicio1 < minFin2 && minInicio2 < minFin1;
  }

  /// Convierte hora "HH:mm" a minutos desde medianoche
  int _horaAMinutos(String hora) {
    final List<String> parts = hora.split(':');
    final int horas = int.parse(parts[0]);
    final int minutos = int.parse(parts[1]);
    return horas * 60 + minutos;
  }

  @override
  Future<List<CuadranteAsignacionEntity>> copiarSemana({
    required DateTime fechaInicioOrigen,
    required DateTime fechaInicioDestino,
    List<String>? idPersonal,
  }) async {
    try {
      debugPrint('📦 DataSource: Copiando semana');
      debugPrint('   Origen: ${fechaInicioOrigen.toIso8601String().split('T')[0]}');
      debugPrint('   Destino: ${fechaInicioDestino.toIso8601String().split('T')[0]}');
      debugPrint('   Personal IDs: ${idPersonal?.join(", ") ?? 'TODOS'}');

      // Calcular rango de fechas (7 días de lunes a domingo)
      final DateTime fechaFinOrigen = fechaInicioOrigen.add(const Duration(days: 6));

      // 🔍 DEBUG: Obtener TODAS las asignaciones activas sin filtro de fecha
      debugPrint('   🔍 DEBUG: Verificando asignaciones activas en BD...');
      final List<Map<String, dynamic>> allDataDebug = await _supabase
          .from(_tableName)
          .select()
          .eq('activo', true)
          .limit(5);
      debugPrint('   🔍 DEBUG: ${allDataDebug.length} asignaciones activas encontradas en total');
      if (allDataDebug.isNotEmpty) {
        debugPrint('   🔍 DEBUG: Primera asignación: ${allDataDebug.first}');
      }

      // Obtener todas las asignaciones de la semana origen
      final List<CuadranteAsignacionEntity> asignacionesOrigen =
          await getByFechaRange(
        fechaInicio: fechaInicioOrigen,
        fechaFin: fechaFinOrigen,
      );

      debugPrint('   📊 ${asignacionesOrigen.length} asignaciones encontradas en semana origen');

      // 🔍 DEBUG: Listar IDs de personal encontrados
      if (asignacionesOrigen.isNotEmpty) {
        final Set<String> idsEncontrados = asignacionesOrigen.map((a) => a.idPersonal).toSet();
        debugPrint('   🔍 DEBUG: IDs de personal en semana origen: ${idsEncontrados.join(", ")}');
      }

      // Filtrar por personal si se especifica
      List<CuadranteAsignacionEntity> asignacionesFiltradas = asignacionesOrigen;
      if (idPersonal != null && idPersonal.isNotEmpty) {
        asignacionesFiltradas = asignacionesOrigen
            .where((a) => idPersonal.contains(a.idPersonal))
            .toList();
        debugPrint('   🔍 ${asignacionesFiltradas.length} asignaciones después de filtrar por personal');

        // 🔍 DEBUG: Mostrar por qué no hay match
        if (asignacionesFiltradas.isEmpty && asignacionesOrigen.isNotEmpty) {
          debugPrint('   ⚠️ DEBUG: Buscando UUID: ${idPersonal.first}');
          debugPrint('   ⚠️ DEBUG: IDs disponibles: ${asignacionesOrigen.map((a) => a.idPersonal).join(", ")}');
        }
      }

      if (asignacionesFiltradas.isEmpty) {
        debugPrint('   ⚠️ No hay asignaciones para copiar');
        return <CuadranteAsignacionEntity>[];
      }

      // Calcular diferencia de días entre origen y destino
      final int diferenciaDias = fechaInicioDestino.difference(fechaInicioOrigen).inDays;

      // Crear nuevas asignaciones en la semana destino
      final List<CuadranteAsignacionEntity> asignacionesCreadas = [];

      for (final CuadranteAsignacionEntity asignacionOrigen in asignacionesFiltradas) {
        // Calcular nueva fecha (mismo día de la semana pero en la semana destino)
        final DateTime nuevaFecha = asignacionOrigen.fecha.add(Duration(days: diferenciaDias));

        // Crear nueva asignación con todos los datos del origen
        final CuadranteAsignacionEntity nuevaAsignacion = CuadranteAsignacionEntity(
          id: '', // Se generará automáticamente en Supabase
          fecha: nuevaFecha,
          horaInicio: asignacionOrigen.horaInicio,
          horaFin: asignacionOrigen.horaFin,
          cruzaMedianoche: asignacionOrigen.cruzaMedianoche,
          idPersonal: asignacionOrigen.idPersonal,
          nombrePersonal: asignacionOrigen.nombrePersonal,
          categoriaPersonal: asignacionOrigen.categoriaPersonal,
          tipoTurno: asignacionOrigen.tipoTurno,
          plantillaTurnoId: asignacionOrigen.plantillaTurnoId,
          idVehiculo: asignacionOrigen.idVehiculo,
          matriculaVehiculo: asignacionOrigen.matriculaVehiculo,
          idDotacion: asignacionOrigen.idDotacion,
          nombreDotacion: asignacionOrigen.nombreDotacion,
          numeroUnidad: asignacionOrigen.numeroUnidad,
          idHospital: asignacionOrigen.idHospital,
          idBase: asignacionOrigen.idBase,
          estado: EstadoAsignacion.planificada, // Nueva asignación en estado planificada
          confirmadaPor: null, // Sin confirmar
          fechaConfirmacion: null,
          kmInicial: null, // Métricas en null para nueva asignación
          kmFinal: null,
          serviciosRealizados: 0,
          horasEfectivas: null,
          observaciones: asignacionOrigen.observaciones != null
              ? 'Copiado de ${asignacionOrigen.fecha.toIso8601String().split('T')[0]} - ${asignacionOrigen.observaciones}'
              : 'Copiado de ${asignacionOrigen.fecha.toIso8601String().split('T')[0]}',
          metadata: asignacionOrigen.metadata,
          activo: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          createdBy: asignacionOrigen.createdBy,
          updatedBy: asignacionOrigen.updatedBy,
        );

        // Crear la asignación en la base de datos
        final CuadranteAsignacionEntity creada = await create(nuevaAsignacion);
        asignacionesCreadas.add(creada);

        debugPrint('   ✅ Asignación copiada: ${creada.nombrePersonal} - ${creada.fecha.toIso8601String().split('T')[0]}');
      }

      debugPrint('✅ DataSource: Semana copiada exitosamente - ${asignacionesCreadas.length} asignaciones creadas');
      return asignacionesCreadas;
    } catch (e, stackTrace) {
      debugPrint('❌ DataSource: Error al copiar semana: $e');
      debugPrint('StackTrace: $stackTrace');
      rethrow;
    }
  }
}
