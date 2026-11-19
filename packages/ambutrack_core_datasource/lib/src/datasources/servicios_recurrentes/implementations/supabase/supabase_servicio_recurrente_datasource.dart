import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../entities/servicio_recurrente_entity.dart';
import '../../models/servicio_recurrente_supabase_model.dart';
import '../../servicio_recurrente_contract.dart';

/// Implementación del DataSource de Servicios Recurrentes usando Supabase
/// NOTA: Al crear un servicio, el trigger `generar_traslados_al_crear_servicio`
/// se ejecuta automáticamente para generar los traslados correspondientes
class SupabaseServicioRecurrenteDataSource
    implements ServicioRecurrenteDataSource {
  SupabaseServicioRecurrenteDataSource(this._supabase);

  final SupabaseClient _supabase;
  static const String _tableName = 'servicios_recurrentes';

  @override
  Future<List<ServicioRecurrenteEntity>> getAll() async {
    try {
      debugPrint(
        '📦 SupabaseServicioRecurrenteDataSource: Obteniendo todos los servicios recurrentes activos...',
      );

      final response = await _supabase
          .from(_tableName)
          .select()
          .eq('activo', true)
          .order('created_at', ascending: false);

      debugPrint(
        '📦 SupabaseServicioRecurrenteDataSource: ✅ ${response.length} servicios obtenidos',
      );

      return (response as List)
          .map((json) => ServicioRecurrenteSupabaseModel.fromJson(
                json as Map<String, dynamic>,
              ).toEntity())
          .toList();
    } catch (e) {
      debugPrint(
        '📦 SupabaseServicioRecurrenteDataSource: ❌ Error al obtener servicios: $e',
      );
      rethrow;
    }
  }

  @override
  Future<ServicioRecurrenteEntity> getById(String id) async {
    try {
      debugPrint(
        '📦 SupabaseServicioRecurrenteDataSource: Obteniendo servicio con ID: $id',
      );

      final response =
          await _supabase.from(_tableName).select().eq('id', id).single();

      debugPrint(
        '📦 SupabaseServicioRecurrenteDataSource: ✅ Servicio obtenido',
      );

      return ServicioRecurrenteSupabaseModel.fromJson(response).toEntity();
    } catch (e) {
      debugPrint(
        '📦 SupabaseServicioRecurrenteDataSource: ❌ Error al obtener servicio: $e',
      );
      rethrow;
    }
  }

  @override
  Future<ServicioRecurrenteEntity> getByServicioId(String idServicio) async {
    try {
      debugPrint(
        '📦 SupabaseServicioRecurrenteDataSource: Obteniendo servicio por idServicio: $idServicio',
      );

      // ✅ Obtener el servicio_recurrente ACTIVO más reciente para este servicio
      // Puede haber múltiples servicios_recurrentes con el mismo id_servicio
      // (histórico de cambios), tomamos el más reciente y activo
      final response = await _supabase
          .from(_tableName)
          .select()
          .eq('id_servicio', idServicio)
          .eq('activo', true)
          .order('created_at', ascending: false)
          .limit(1)
          .single();

      debugPrint(
        '📦 SupabaseServicioRecurrenteDataSource: ✅ Servicio obtenido por idServicio',
      );

      return ServicioRecurrenteSupabaseModel.fromJson(response).toEntity();
    } catch (e) {
      debugPrint(
        '📦 SupabaseServicioRecurrenteDataSource: ❌ Error al obtener servicio por idServicio: $e',
      );
      rethrow;
    }
  }

  @override
  Future<List<ServicioRecurrenteEntity>> getByPaciente(
    String idPaciente,
  ) async {
    try {
      debugPrint(
        '📦 SupabaseServicioRecurrenteDataSource: Obteniendo servicios del paciente: $idPaciente',
      );

      final response = await _supabase
          .from(_tableName)
          .select()
          .eq('id_paciente', idPaciente)
          .eq('activo', true)
          .order('created_at', ascending: false);

      debugPrint(
        '📦 SupabaseServicioRecurrenteDataSource: ✅ ${response.length} servicios obtenidos',
      );

      return (response as List)
          .map((json) => ServicioRecurrenteSupabaseModel.fromJson(
                json as Map<String, dynamic>,
              ).toEntity())
          .toList();
    } catch (e) {
      debugPrint(
        '📦 SupabaseServicioRecurrenteDataSource: ❌ Error al obtener servicios por paciente: $e',
      );
      rethrow;
    }
  }

  @override
  Future<List<ServicioRecurrenteEntity>> getByTipoRecurrencia(
    String tipoRecurrencia,
  ) async {
    try {
      debugPrint(
        '📦 SupabaseServicioRecurrenteDataSource: Obteniendo servicios con tipo: $tipoRecurrencia',
      );

      final response = await _supabase
          .from(_tableName)
          .select()
          .eq('tipo_recurrencia', tipoRecurrencia)
          .eq('activo', true)
          .order('created_at', ascending: false);

      debugPrint(
        '📦 SupabaseServicioRecurrenteDataSource: ✅ ${response.length} servicios obtenidos',
      );

      return (response as List)
          .map((json) => ServicioRecurrenteSupabaseModel.fromJson(
                json as Map<String, dynamic>,
              ).toEntity())
          .toList();
    } catch (e) {
      debugPrint(
        '📦 SupabaseServicioRecurrenteDataSource: ❌ Error al filtrar por tipo: $e',
      );
      rethrow;
    }
  }

  @override
  Future<List<ServicioRecurrenteEntity>> getActivos() async {
    try {
      final now = DateTime.now();
      final nowStr = now.toIso8601String().split('T').first;

      debugPrint(
        '📦 SupabaseServicioRecurrenteDataSource: Obteniendo servicios activos (en curso)...',
      );

      final response = await _supabase
          .from(_tableName)
          .select()
          .eq('activo', true)
          .lte('fecha_servicio_inicio', nowStr)
          .or('fecha_servicio_fin.is.null,fecha_servicio_fin.gte.$nowStr')
          .order('created_at', ascending: false);

      debugPrint(
        '📦 SupabaseServicioRecurrenteDataSource: ✅ ${response.length} servicios activos',
      );

      return (response as List)
          .map((json) => ServicioRecurrenteSupabaseModel.fromJson(
                json as Map<String, dynamic>,
              ).toEntity())
          .toList();
    } catch (e) {
      debugPrint(
        '📦 SupabaseServicioRecurrenteDataSource: ❌ Error al obtener servicios activos: $e',
      );
      rethrow;
    }
  }

  @override
  Future<List<ServicioRecurrenteEntity>> getRequierenGeneracion() async {
    try {
      final now = DateTime.now();
      final nowStr = now.toIso8601String().split('T').first;

      debugPrint(
        '📦 SupabaseServicioRecurrenteDataSource: Obteniendo servicios que requieren generación...',
      );

      final response = await _supabase
          .from(_tableName)
          .select()
          .eq('activo', true)
          .lte('fecha_servicio_inicio', nowStr)
          .or('fecha_servicio_fin.is.null,fecha_servicio_fin.gte.$nowStr')
          .order('created_at', ascending: false);

      debugPrint(
        '📦 SupabaseServicioRecurrenteDataSource: ✅ ${response.length} servicios encontrados',
      );

      return (response as List)
          .map((json) => ServicioRecurrenteSupabaseModel.fromJson(
                json as Map<String, dynamic>,
              ).toEntity())
          .toList();
    } catch (e) {
      debugPrint(
        '📦 SupabaseServicioRecurrenteDataSource: ❌ Error al obtener servicios para generación: $e',
      );
      rethrow;
    }
  }

  @override
  Future<List<ServicioRecurrenteEntity>> searchByCodigo(String query) async {
    try {
      debugPrint(
        '📦 SupabaseServicioRecurrenteDataSource: Buscando servicios con código: "$query"',
      );

      if (query.isEmpty) {
        return await getAll();
      }

      final response = await _supabase
          .from(_tableName)
          .select()
          .ilike('codigo', '%$query%')
          .eq('activo', true)
          .order('created_at', ascending: false);

      debugPrint(
        '📦 SupabaseServicioRecurrenteDataSource: ✅ ${response.length} servicios encontrados',
      );

      return (response as List)
          .map((json) => ServicioRecurrenteSupabaseModel.fromJson(
                json as Map<String, dynamic>,
              ).toEntity())
          .toList();
    } catch (e) {
      debugPrint(
        '📦 SupabaseServicioRecurrenteDataSource: ❌ Error en búsqueda: $e',
      );
      rethrow;
    }
  }

  @override
  Future<ServicioRecurrenteEntity> create(
    ServicioRecurrenteEntity servicioRecurrente,
  ) async {
    try {
      debugPrint(
        '📦 SupabaseServicioRecurrenteDataSource: Creando servicio recurrente: ${servicioRecurrente.codigo}',
      );

      final model =
          ServicioRecurrenteSupabaseModel.fromEntity(servicioRecurrente);
      final json = model.toJson();

      // WHITELIST: Solo mantener los campos que existen en la tabla servicios_recurrentes
      final Map<String, dynamic> allowedFields = {
        'codigo': json['codigo'],
        'id_servicio': json['id_servicio'], // FK hacia servicios (tabla padre)
        'id_paciente': json['id_paciente'],
        'tipo_recurrencia': json['tipo_recurrencia'],
        if (json['dias_semana'] != null) 'dias_semana': json['dias_semana'],
        if (json['intervalo_semanas'] != null)
          'intervalo_semanas': json['intervalo_semanas'],
        if (json['intervalo_dias'] != null)
          'intervalo_dias': json['intervalo_dias'],
        if (json['dias_mes'] != null) 'dias_mes': json['dias_mes'],
        if (json['fechas_especificas'] != null)
          'fechas_especificas': json['fechas_especificas'],
        'fecha_servicio_inicio': json['fecha_servicio_inicio'],
        if (json['fecha_servicio_fin'] != null)
          'fecha_servicio_fin': json['fecha_servicio_fin'],
        'hora_recogida': json['hora_recogida'],
        if (json['hora_vuelta'] != null) 'hora_vuelta': json['hora_vuelta'],
        if (json['requiere_vuelta'] != null)
          'requiere_vuelta': json['requiere_vuelta'],
        // ✅ CAMPOS AGREGADOS: Motivo de traslado y ubicaciones
        if (json['id_motivo_traslado'] != null)
          'id_motivo_traslado': json['id_motivo_traslado'],
        if (json['tipo_origen'] != null) 'tipo_origen': json['tipo_origen'],
        if (json['origen'] != null) 'origen': json['origen'],
        if (json['origen_ubicacion_centro'] != null)
          'origen_ubicacion_centro': json['origen_ubicacion_centro'],
        if (json['tipo_destino'] != null) 'tipo_destino': json['tipo_destino'],
        if (json['destino'] != null) 'destino': json['destino'],
        if (json['destino_ubicacion_centro'] != null)
          'destino_ubicacion_centro': json['destino_ubicacion_centro'],
        // Observaciones
        if (json['observaciones'] != null)
          'observaciones': json['observaciones'],
        if (json['activo'] != null) 'activo': json['activo'],
      };

      // ⚡ IMPORTANTE: Al hacer INSERT, el trigger generar_traslados_al_crear_servicio
      // se ejecutará automáticamente en Supabase y generará los traslados
      final response = await _supabase
          .from(_tableName)
          .insert(allowedFields)
          .select()
          .single();

      final servicioId = response['id'] as String;

      debugPrint(
        '📦 SupabaseServicioRecurrenteDataSource: ✅ Servicio creado exitosamente',
      );
      debugPrint(
        '⚡ El trigger generó automáticamente los traslados correspondientes',
      );

      // 📊 Verificar cuántos traslados se generaron
      try {
        final trasladosData = await _supabase
            .from('traslados')
            .select('id')
            .eq('id_servicio_recurrente', servicioId);

        final count = (trasladosData as List).length;
        debugPrint(
          '📊 SupabaseServicioRecurrenteDataSource: Total traslados generados: $count',
        );
      } catch (e) {
        debugPrint(
          '⚠️ SupabaseServicioRecurrenteDataSource: No se pudo verificar traslados generados: $e',
        );
      }

      return ServicioRecurrenteSupabaseModel.fromJson(response).toEntity();
    } catch (e) {
      debugPrint(
        '📦 SupabaseServicioRecurrenteDataSource: ❌ Error al crear servicio: $e',
      );
      rethrow;
    }
  }

  @override
  Future<ServicioRecurrenteEntity> update(
    ServicioRecurrenteEntity servicioRecurrente,
  ) async {
    try {
      debugPrint(
        '📦 SupabaseServicioRecurrenteDataSource: Actualizando servicio: ${servicioRecurrente.codigo}',
      );

      final model =
          ServicioRecurrenteSupabaseModel.fromEntity(servicioRecurrente);
      final json = model.toJson();

      // Remover campos de auditoría que no se actualizan manualmente
      json.remove('created_at');
      json.remove('created_by');
      json.remove('updated_at'); // Trigger lo actualiza automáticamente

      final response = await _supabase
          .from(_tableName)
          .update(json)
          .eq('id', servicioRecurrente.id)
          .select()
          .single();

      debugPrint(
        '📦 SupabaseServicioRecurrenteDataSource: ✅ Servicio actualizado exitosamente',
      );

      return ServicioRecurrenteSupabaseModel.fromJson(response).toEntity();
    } catch (e) {
      debugPrint(
        '📦 SupabaseServicioRecurrenteDataSource: ❌ Error al actualizar servicio: $e',
      );
      rethrow;
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      debugPrint(
        '📦 SupabaseServicioRecurrenteDataSource: Eliminando (soft delete) servicio ID: $id',
      );

      await _supabase.from(_tableName).update({'activo': false}).eq('id', id);

      debugPrint(
        '📦 SupabaseServicioRecurrenteDataSource: ✅ Servicio desactivado exitosamente',
      );
    } catch (e) {
      debugPrint(
        '📦 SupabaseServicioRecurrenteDataSource: ❌ Error al eliminar servicio: $e',
      );
      rethrow;
    }
  }

  @override
  Future<void> hardDelete(String id) async {
    try {
      debugPrint(
        '📦 SupabaseServicioRecurrenteDataSource: Eliminando permanentemente servicio ID: $id',
      );
      debugPrint(
        '⚠️  ADVERTENCIA: Esto también eliminará los traslados asociados en cascada',
      );

      await _supabase.from(_tableName).delete().eq('id', id);

      debugPrint(
        '📦 SupabaseServicioRecurrenteDataSource: ✅ Servicio eliminado permanentemente',
      );
    } catch (e) {
      debugPrint(
        '📦 SupabaseServicioRecurrenteDataSource: ❌ Error al eliminar permanentemente: $e',
      );
      rethrow;
    }
  }

  @override
  Future<void> hardDeleteOldVersions({
    required String idServicio,
    required String idServicioRecurrenteActual,
  }) async {
    try {
      debugPrint(
        '📦 SupabaseServicioRecurrenteDataSource: Limpiando versiones antiguas de servicio_recurrente',
      );
      debugPrint('   - idServicio (FK): $idServicio');
      debugPrint('   - Conservar: $idServicioRecurrenteActual');

      // ✅ Eliminar físicamente TODOS los servicios_recurrentes con el mismo id_servicio
      // EXCEPTO el actual (el que acabamos de crear/actualizar)
      await _supabase
          .from(_tableName)
          .delete()
          .eq('id_servicio', idServicio)
          .neq('id', idServicioRecurrenteActual);

      debugPrint(
        '📦 SupabaseServicioRecurrenteDataSource: ✅ Versiones antiguas eliminadas (si existían)',
      );
    } catch (e) {
      debugPrint(
        '📦 SupabaseServicioRecurrenteDataSource: ❌ Error al limpiar versiones antiguas: $e',
      );
      rethrow;
    }
  }

  @override
  Stream<List<ServicioRecurrenteEntity>> watchAll() {
    debugPrint(
      '📦 SupabaseServicioRecurrenteDataSource: Iniciando stream de servicios...',
    );

    return _supabase
        .from(_tableName)
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .map((data) {
          debugPrint(
            '📦 SupabaseServicioRecurrenteDataSource: 🔄 Stream actualizó ${data.length} servicios',
          );
          // Filtrar por activo en la transformación del stream
          return data
              .where((json) => json['activo'] == true)
              .map((json) =>
                  ServicioRecurrenteSupabaseModel.fromJson(json).toEntity())
              .toList();
        });
  }

  @override
  Stream<ServicioRecurrenteEntity?> watchById(String id) {
    debugPrint(
      '📦 SupabaseServicioRecurrenteDataSource: Iniciando stream del servicio ID: $id',
    );

    return _supabase
        .from(_tableName)
        .stream(primaryKey: ['id'])
        .map((data) {
          debugPrint(
            '📦 SupabaseServicioRecurrenteDataSource: 🔄 Stream actualizó servicio',
          );
          // Buscar el servicio con el ID especificado
          final servicio = data.where((json) => json['id'] == id).firstOrNull;
          if (servicio == null) return null;
          return ServicioRecurrenteSupabaseModel.fromJson(servicio)
              .toEntity();
        });
  }

  @override
  Stream<List<ServicioRecurrenteEntity>> watchByPaciente(
    String idPaciente,
  ) {
    debugPrint(
      '📦 SupabaseServicioRecurrenteDataSource: Iniciando stream de servicios del paciente: $idPaciente',
    );

    return _supabase
        .from(_tableName)
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .map((data) {
          debugPrint(
            '📦 SupabaseServicioRecurrenteDataSource: 🔄 Stream actualizó ${data.length} servicios',
          );
          // Filtrar por paciente y activo en la transformación del stream
          return data
              .where((json) =>
                  json['id_paciente'] == idPaciente &&
                  json['activo'] == true)
              .map((json) =>
                  ServicioRecurrenteSupabaseModel.fromJson(json).toEntity())
              .toList();
        });
  }
}
