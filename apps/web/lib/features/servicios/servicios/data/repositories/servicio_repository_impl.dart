import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/servicio_entity.dart';
import '../../domain/repositories/servicio_repository.dart';

/// Implementación del repositorio de Servicios
///
/// Conecta con la tabla `servicios` en Supabase.
@LazySingleton(as: ServicioRepository)
class ServicioRepositoryImpl implements ServicioRepository {
  ServicioRepositoryImpl() : _supabase = Supabase.instance.client;

  final SupabaseClient _supabase;

  @override
  Future<List<ServicioEntity>> getAll() async {
    debugPrint('📦 ServicioRepository: Obteniendo todos los servicios...');
    try {
      final List<dynamic> response = await _supabase
          .from('servicios')
          .select('''
            *,
            pacientes!servicios_id_paciente_fkey (
              id,
              nombre,
              primer_apellido,
              segundo_apellido,
              documento,
              tipo_documento,
              fecha_nacimiento,
              telefono_movil,
              domicilio_direccion,
              localidad_id
            ),
            tmotivos_traslado!servicios_id_motivo_traslado_fkey (
              id,
              nombre,
              descripcion,
              activo,
              tiempo,
              vuelta,
              created_at,
              updated_at
            )
          ''')
          .order('created_at', ascending: false);

      // DEBUG: Imprimir JSON del primer servicio para verificar localidad_id
      if (response.isNotEmpty) {
        debugPrint('📥 PRIMER SERVICIO JSON RAW:');
        final Map<String, dynamic> firstService = response.first as Map<String, dynamic>;
        debugPrint(firstService.toString());
        if (firstService['pacientes'] != null) {
          debugPrint('📥 PACIENTES DEL PRIMER SERVICIO:');
          debugPrint(firstService['pacientes'].toString());
        }
      }

      final List<ServicioEntity> servicios = response
          // ignore: always_specify_types
          .map((json) => ServicioEntity.fromJson(json as Map<String, dynamic>))
          .toList();

      debugPrint('📦 ServicioRepository: ✅ ${servicios.length} servicios obtenidos');
      return servicios;
    } catch (e) {
      debugPrint('📦 ServicioRepository: ❌ Error: $e');
      rethrow;
    }
  }

  @override
  Future<ServicioEntity?> getById(String id) async {
    debugPrint('📦 ServicioRepository: Obteniendo servicio $id...');
    try {
      final Map<String, dynamic>? response = await _supabase
          .from('servicios')
          .select('''
            *,
            pacientes!servicios_id_paciente_fkey (
              id,
              nombre,
              primer_apellido,
              segundo_apellido,
              documento,
              tipo_documento,
              fecha_nacimiento,
              telefono_movil,
              domicilio_direccion,
              localidad_id
            ),
            tmotivos_traslado!servicios_id_motivo_traslado_fkey (
              id,
              nombre,
              descripcion,
              activo,
              tiempo,
              vuelta,
              created_at,
              updated_at
            )
          ''')
          .eq('id', id)
          .maybeSingle();

      if (response == null) {
        debugPrint('📦 ServicioRepository: ⚠️ Servicio no encontrado');
        return null;
      }

      debugPrint('📥 JSON RAW DE SUPABASE:');
      debugPrint(response.toString());
      debugPrint('📥 PACIENTES JSON:');
      debugPrint(response['pacientes'].toString());

      final ServicioEntity servicio = ServicioEntity.fromJson(response);
      debugPrint('📦 ServicioRepository: ✅ Servicio obtenido');
      return servicio;
    } catch (e) {
      debugPrint('📦 ServicioRepository: ❌ Error: $e');
      rethrow;
    }
  }

  @override
  Stream<List<ServicioEntity>> watchAll() {
    debugPrint('📦 ServicioRepository: Iniciando stream de servicios...');
    // NOTA: El stream de Supabase no soporta JOINs complejos
    // Los datos relacionados (paciente, motivo_traslado) vendrán como null
    // Si se necesita esta funcionalidad, considerar usar polling con getAll()
    return _supabase
        .from('servicios')
        .stream(primaryKey: <String>['id'])
        .order('created_at')
        .map((List<Map<String, dynamic>> data) =>
            data.map(ServicioEntity.fromJson).toList());
  }

  @override
  Future<List<ServicioEntity>> search(String query) async {
    debugPrint('📦 ServicioRepository: Buscando servicios con query: $query');
    try {
      final List<dynamic> response = await _supabase
          .from('servicios')
          .select('''
            *,
            pacientes!servicios_id_paciente_fkey (
              id,
              nombre,
              primer_apellido,
              segundo_apellido,
              documento,
              fecha_nacimiento,
              telefono_movil,
              domicilio_direccion,
              localidad_id
            ),
            tmotivos_traslado!servicios_id_motivo_traslado_fkey (
              id,
              nombre,
              descripcion,
              activo,
              tiempo,
              vuelta,
              created_at,
              updated_at
            )
          ''')
          .or('codigo.ilike.%$query%,observaciones.ilike.%$query%')
          .order('created_at', ascending: false);

      final List<ServicioEntity> servicios = response
          // ignore: always_specify_types
          .map((json) => ServicioEntity.fromJson(json as Map<String, dynamic>))
          .toList();

      debugPrint('📦 ServicioRepository: ✅ ${servicios.length} servicios encontrados');
      return servicios;
    } catch (e) {
      debugPrint('📦 ServicioRepository: ❌ Error: $e');
      rethrow;
    }
  }

  @override
  Future<List<ServicioEntity>> getByYear(int year) async {
    debugPrint('📦 ServicioRepository: Filtrando servicios por año: $year');
    try {
      final String startDate = '$year-01-01';
      final String endDate = '$year-12-31';

      final List<dynamic> response = await _supabase
          .from('servicios')
          .select('''
            *,
            pacientes!servicios_id_paciente_fkey (
              id,
              nombre,
              primer_apellido,
              segundo_apellido,
              documento,
              fecha_nacimiento,
              telefono_movil,
              domicilio_direccion,
              localidad_id
            ),
            tmotivos_traslado!servicios_id_motivo_traslado_fkey (
              id,
              nombre,
              descripcion,
              activo,
              tiempo,
              vuelta,
              created_at,
              updated_at
            )
          ''')
          .gte('fecha_servicio_inicio', startDate)
          .lte('fecha_servicio_inicio', endDate)
          .order('created_at', ascending: false);

      final List<ServicioEntity> servicios = response
          // ignore: always_specify_types
          .map((json) => ServicioEntity.fromJson(json as Map<String, dynamic>))
          .toList();

      debugPrint('📦 ServicioRepository: ✅ ${servicios.length} servicios del año $year');
      return servicios;
    } catch (e) {
      debugPrint('📦 ServicioRepository: ❌ Error: $e');
      rethrow;
    }
  }

  @override
  Future<List<ServicioEntity>> getByEstado(String estado) async {
    debugPrint('📦 ServicioRepository: Filtrando servicios por estado: $estado');
    try {
      final List<dynamic> response = await _supabase
          .from('servicios')
          .select('''
            *,
            pacientes!servicios_id_paciente_fkey (
              id,
              nombre,
              primer_apellido,
              segundo_apellido,
              documento,
              fecha_nacimiento,
              telefono_movil,
              domicilio_direccion,
              localidad_id
            ),
            tmotivos_traslado!servicios_id_motivo_traslado_fkey (
              id,
              nombre,
              descripcion,
              activo,
              tiempo,
              vuelta,
              created_at,
              updated_at
            )
          ''')
          .eq('estado', estado)
          .order('created_at', ascending: false);

      final List<ServicioEntity> servicios = response
          // ignore: always_specify_types
          .map((json) => ServicioEntity.fromJson(json as Map<String, dynamic>))
          .toList();

      debugPrint('📦 ServicioRepository: ✅ ${servicios.length} servicios con estado $estado');
      return servicios;
    } catch (e) {
      debugPrint('📦 ServicioRepository: ❌ Error: $e');
      rethrow;
    }
  }

  @override
  Future<List<ServicioEntity>> getByTipoRecurrencia(String tipoRecurrencia) async {
    debugPrint('📦 ServicioRepository: Filtrando por tipo_recurrencia: $tipoRecurrencia');
    try {
      final List<dynamic> response = await _supabase
          .from('servicios')
          .select('''
            *,
            pacientes!servicios_id_paciente_fkey (
              id,
              nombre,
              primer_apellido,
              segundo_apellido,
              documento,
              fecha_nacimiento,
              telefono_movil,
              domicilio_direccion,
              localidad_id
            ),
            tmotivos_traslado!servicios_id_motivo_traslado_fkey (
              id,
              nombre,
              descripcion,
              activo,
              tiempo,
              vuelta,
              created_at,
              updated_at
            )
          ''')
          .eq('tipo_recurrencia', tipoRecurrencia)
          .order('created_at', ascending: false);

      final List<ServicioEntity> servicios = response
          // ignore: always_specify_types
          .map((json) => ServicioEntity.fromJson(json as Map<String, dynamic>))
          .toList();

      debugPrint('📦 ServicioRepository: ✅ ${servicios.length} servicios tipo $tipoRecurrencia');
      return servicios;
    } catch (e) {
      debugPrint('📦 ServicioRepository: ❌ Error: $e');
      rethrow;
    }
  }

  @override
  Future<void> update(ServicioEntity servicio) async {
    debugPrint('📦 ServicioRepository: Actualizando servicio ${servicio.codigo} (${servicio.id})...');
    try {
      // Validar que el servicio tenga ID
      if (servicio.id == null) {
        throw Exception('El servicio debe tener un ID para poder ser actualizado');
      }

      // ✅ Convertir la entidad completa a JSON para el UPDATE
      // ❌ Eliminar campos que NO deben actualizarse (read-only o auto-generados)
      final Map<String, dynamic> updateData = servicio.toJson()
        ..remove('id') // ID no se modifica
        ..remove('codigo') // Código no se modifica
        ..remove('created_at') // Fecha de creación no se modifica
        ..remove('created_by') // Usuario creador no se modifica
        ..remove('pacientes') // Objeto anidado JOIN (no es columna real)
        ..remove('tmotivos_traslado') // Objeto anidado JOIN (no es columna real)
        // ✅ Actualizar solo campos que no sean null o que explícitamente deban setearse a null
        // ignore: always_specify_types
        ..removeWhere((String key, value) => value == null);

      debugPrint('📊 Campos a actualizar: ${updateData.keys.join(", ")}');

      await _supabase
          .from('servicios')
          .update(updateData)
          .eq('id', servicio.id!);

      debugPrint('📦 ServicioRepository: ✅ Servicio actualizado exitosamente');
    } catch (e) {
      debugPrint('📦 ServicioRepository: ❌ Error: $e');
      rethrow;
    }
  }

  @override
  Future<void> updateEstado(String id, String estado) async {
    debugPrint('📦 ServicioRepository: Actualizando estado de $id a $estado...');
    try {
      await _supabase
          .from('servicios')
          .update(<String, dynamic>{'estado': estado})
          .eq('id', id);

      debugPrint('📦 ServicioRepository: ✅ Estado actualizado a $estado');
    } catch (e) {
      debugPrint('📦 ServicioRepository: ❌ Error: $e');
      rethrow;
    }
  }

  @override
  Future<void> delete(String id) async {
    debugPrint('📦 ServicioRepository: Eliminando servicio $id (soft delete)...');
    try {
      await _supabase
          .from('servicios')
          .update(<String, dynamic>{'estado': 'ELIMINADO'})
          .eq('id', id);

      debugPrint('📦 ServicioRepository: ✅ Servicio marcado como ELIMINADO');
    } catch (e) {
      debugPrint('📦 ServicioRepository: ❌ Error: $e');
      rethrow;
    }
  }

  @override
  Future<void> hardDelete(String id) async {
    debugPrint('🗑️ ServicioRepository: ELIMINACIÓN PERMANENTE del servicio $id...');
    debugPrint('⚠️  Esto eliminará: servicio + servicio_recurrente + traslados');

    try {
      // 1. Eliminar traslados asociados
      debugPrint('🗑️ Paso 1/3: Eliminando traslados del servicio $id...');
      await _supabase.from('traslados').delete().eq('id_servicio', id);
      debugPrint('✅ Traslados eliminados');

      // 2. Eliminar servicio recurrente (si existe)
      debugPrint('🗑️ Paso 2/3: Eliminando servicio_recurrente del servicio $id...');
      await _supabase.from('servicios_recurrentes').delete().eq('id_servicio', id);
      debugPrint('✅ Servicio recurrente eliminado (si existía)');

      // 3. Eliminar servicio principal
      debugPrint('🗑️ Paso 3/3: Eliminando servicio $id...');
      await _supabase.from('servicios').delete().eq('id', id);
      debugPrint('✅ Servicio eliminado');

      debugPrint('📦 ServicioRepository: ✅ ELIMINACIÓN PERMANENTE COMPLETADA');
    } catch (e) {
      debugPrint('📦 ServicioRepository: ❌ Error en eliminación permanente: $e');
      rethrow;
    }
  }

  @override
  Future<void> suspend(String id) async {
    debugPrint('⏸️ ServicioRepository: Suspendiendo servicio $id...');
    try {
      final String now = DateTime.now().toIso8601String().split('T').first;

      // 1. Cambiar estado del servicio a 'SUSPENDIDO'
      debugPrint('⏸️ Paso 1/3: Actualizando estado a SUSPENDIDO...');
      await _supabase
          .from('servicios')
          .update(<String, dynamic>{'estado': 'SUSPENDIDO'})
          .eq('id', id);
      debugPrint('✅ Estado actualizado');

      // 2. Obtener el ID del servicio_recurrente asociado
      debugPrint('⏸️ Paso 2/3: Obteniendo servicio recurrente...');
      final PostgrestList recurrenteResponse = await _supabase
          .from('servicios_recurrentes')
          .select('id')
          .eq('id_servicio', id)
          .limit(1);

      if (recurrenteResponse.isEmpty) {
        debugPrint('⚠️ No se encontró servicio recurrente para servicio $id');
        return;
      }

      final String idServicioRecurrente = recurrenteResponse.first['id'] as String;
      debugPrint('✅ Servicio recurrente encontrado: $idServicioRecurrente');

      // 3. Eliminar traslados desde HOY en adelante
      debugPrint('⏸️ Paso 3/3: Eliminando traslados futuros (>= $now)...');
      final PostgrestList deleteResponse = await _supabase
          .from('traslados')
          .delete()
          .eq('id_servicio_recurrente', idServicioRecurrente)
          .gte('fecha', now)
          .select();
      debugPrint('✅ Traslados futuros eliminados: ${deleteResponse.length} registros');

      debugPrint('📦 ServicioRepository: ✅ Servicio suspendido exitosamente');
    } catch (e) {
      debugPrint('📦 ServicioRepository: ❌ Error al suspender: $e');
      rethrow;
    }
  }

  @override
  Future<int> reanudar(String id) async {
    debugPrint('▶️ ServicioRepository: Reanudando servicio $id...');
    try {
      final String now = DateTime.now().toIso8601String().split('T').first;

      // 1. Cambiar estado del servicio a 'ACTIVO'
      debugPrint('▶️ Paso 1/4: Actualizando estado a ACTIVO...');
      await _supabase
          .from('servicios')
          .update(<String, dynamic>{'estado': 'ACTIVO'})
          .eq('id', id);
      debugPrint('✅ Estado actualizado');

      // 2. Obtener el ID del servicio_recurrente asociado
      debugPrint('▶️ Paso 2/4: Obteniendo servicio recurrente...');
      final PostgrestList recurrenteResponse = await _supabase
          .from('servicios_recurrentes')
          .select('id')
          .eq('id_servicio', id)
          .limit(1);

      if (recurrenteResponse.isEmpty) {
        debugPrint('⚠️ No se encontró servicio recurrente para servicio $id');
        return 0;
      }

      final String idServicioRecurrente = recurrenteResponse.first['id'] as String;
      debugPrint('✅ Servicio recurrente encontrado: $idServicioRecurrente');

      // 3. Eliminar traslados futuros existentes para evitar duplicados
      debugPrint('▶️ Paso 3/4: Eliminando traslados futuros existentes (>= $now)...');
      final PostgrestList deleteResponse = await _supabase
          .from('traslados')
          .delete()
          .eq('id_servicio_recurrente', idServicioRecurrente)
          .gte('fecha', now)
          .select();
      debugPrint('✅ Traslados futuros eliminados: ${deleteResponse.length} registros');

      // 4. Llamar función de PostgreSQL para regenerar traslados
      debugPrint('▶️ Paso 4/4: Regenerando traslados desde $now...');
      final dynamic response = await _supabase.rpc<dynamic>(
        'regenerar_traslados_servicio',
        params: <String, dynamic>{
          'p_id_servicio': id,
          'p_fecha_desde': now,
        },
      );

      // La RPC puede devolver: int, Map<String, dynamic>, o List<dynamic>
      int trasladosGenerados;
      if (response is int) {
        trasladosGenerados = response;
      } else if (response is Map) {
        // Si devuelve Map, intentar extraer el valor del primer key
        trasladosGenerados = response.values.first is int
            ? response.values.first as int
            : 0;
      } else if (response is List && response.isNotEmpty) {
        trasladosGenerados = response.first is int
            ? response.first as int
            : 0;
      } else {
        trasladosGenerados = 0;
      }

      debugPrint('✅ Traslados regenerados: $trasladosGenerados');

      // 5. Reaplicar fechas excluidas/incluidas sobre los traslados regenerados
      await _supabase.rpc<dynamic>(
        'aplicar_fechas_excepcion_servicio',
        params: <String, dynamic>{'p_id_servicio': id},
      );
      debugPrint('✅ Fechas excluidas/incluidas reaplicadas');
      debugPrint('📦 ServicioRepository: ✅ Servicio reanudado exitosamente');
      return trasladosGenerados;
    } catch (e) {
      debugPrint('📦 ServicioRepository: ❌ Error al reanudar: $e');
      rethrow;
    }
  }

  @override
  Future<FechasExcepcionServicio> getFechasExcepcion(String id) async {
    debugPrint('📦 ServicioRepository: Obteniendo fechas excluidas/incluidas de $id...');
    try {
      final Map<String, dynamic> response = await _supabase
          .from('servicios')
          .select('fechas_excluidas, fechas_incluidas')
          .eq('id', id)
          .single();

      return (
        excluidas: _parseFechas(response['fechas_excluidas']),
        incluidas: _parseFechas(response['fechas_incluidas']),
      );
    } catch (e) {
      debugPrint('📦 ServicioRepository: ❌ Error al obtener fechas: $e');
      rethrow;
    }
  }

  @override
  Future<void> updateFechasExcepcion(
    String id, {
    required List<DateTime> excluidas,
    required List<DateTime> incluidas,
  }) async {
    debugPrint(
      '📦 ServicioRepository: Guardando fechas de $id '
      '(${excluidas.length} excluidas, ${incluidas.length} incluidas)...',
    );
    try {
      await _supabase.from('servicios').update(<String, dynamic>{
        'fechas_excluidas': _formatFechas(excluidas),
        'fechas_incluidas': _formatFechas(incluidas),
      }).eq('id', id);
      debugPrint('📦 ServicioRepository: ✅ Fechas guardadas');
    } catch (e) {
      debugPrint('📦 ServicioRepository: ❌ Error al guardar fechas: $e');
      rethrow;
    }
  }

  List<DateTime> _parseFechas(Object? raw) {
    if (raw is! List) {
      return <DateTime>[];
    }
    return raw.map((Object? f) => DateTime.parse(f.toString())).toList()
      ..sort();
  }

  List<String> _formatFechas(List<DateTime> fechas) {
    final List<String> result = fechas
        .map((DateTime f) => DateTime(f.year, f.month, f.day).toIso8601String().split('T').first)
        .toSet()
        .toList()
      ..sort();
    return result;
  }
}
