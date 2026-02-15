import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../alertas_caducidad_contract.dart';
import '../../entities/alerta_caducidad_entity.dart';
import '../../models/alerta_caducidad_supabase_model.dart';

/// Implementación del DataSource de Alertas de Caducidad usando Supabase
///
/// Utiliza las funciones RPC de Supabase para obtener alertas desde
/// la vista materializada `vw_alertas_caducidad_activas`
class SupabaseAlertasCaducidadDataSource
    implements AlertasCaducidadDataSource {
  /// Cliente de Supabase
  final SupabaseClient supabase;

  /// Nombre de la vista materializada
  final String viewName;

  /// Constructor
  SupabaseAlertasCaducidadDataSource({
    SupabaseClient? supabase,
    this.viewName = 'vw_alertas_caducidad_activas',
  }) : supabase = supabase ?? Supabase.instance.client;

  @override
  Future<List<AlertaCaducidadEntity>> getAlertasActivas({
    String? usuarioId,
    int? umbralSeguro,
    int? umbralItv,
    int? umbralHomologacion,
    int? umbralMantenimiento,
    bool incluirVistas = true,
  }) async {
    try {
      final response = await supabase.rpc(
        'obtener_alertas_activas',
        params: {
          'p_usuario_id': usuarioId,
          'p_umbral_seguro': umbralSeguro ?? 90,
          'p_umbral_itv': umbralItv ?? 90,
          'p_umbral_homologacion': umbralHomologacion ?? 90,
          'p_umbral_mantenimiento': umbralMantenimiento ?? 90,
          'p_incluir_vistas': incluirVistas,
        },
      );

      final dataList = response as List;
      return dataList
          .map((json) => AlertaCaducidadSupabaseModel.fromJson(
              json as Map<String, dynamic>))
          .map((model) => model.toEntity())
          .toList();
    } catch (e) {
      throw Exception('Error al obtener alertas activas: $e');
    }
  }

  @override
  Future<List<AlertaCaducidadEntity>> getAlertasCriticas({
    String? usuarioId,
  }) async {
    try {
      debugPrint('🔵 DataSource: Llamando a RPC obtener_alertas_criticas con usuarioId=$usuarioId');
      final response = await supabase.rpc(
        'obtener_alertas_criticas',
        params: {
          'p_usuario_id': usuarioId,
        },
      );
      debugPrint('🔵 DataSource: RPC respondió con éxito, tipo=${response.runtimeType}');

      final dataList = response as List;
      debugPrint('🔵 DataSource: Convertidos ${dataList.length} registros a lista');

      final result = dataList
          .map((json) {
            debugPrint('🔵 DataSource: Procesando JSON=$json');
            return AlertaCaducidadSupabaseModel.fromJson(
                json as Map<String, dynamic>);
          })
          .map((model) => model.toEntity())
          .toList();

      debugPrint('✅ DataSource: ${result.length} alertas críticas procesadas');
      return result;
    } catch (e, stackTrace) {
      debugPrint('❌ DataSource Error: $e');
      debugPrint('❌ DataSource StackTrace: $stackTrace');
      throw Exception('Error al obtener alertas críticas: $e');
    }
  }

  @override
  Future<AlertasResumenEntity> getResumen() async {
    try {
      final response = await supabase.rpc('obtener_resumen_alertas');

      // La RPC devuelve una lista con un solo elemento (una fila)
      final dataList = response as List;
      if (dataList.isEmpty) {
        return const AlertasResumenEntity(
          criticas: 0,
          altas: 0,
          medias: 0,
          bajas: 0,
          total: 0,
        );
      }

      final json = dataList.first as Map<String, dynamic>;
      final model = AlertasResumenSupabaseModel.fromJson(json);
      return model.toEntity();
    } catch (e) {
      throw Exception('Error al obtener resumen de alertas: $e');
    }
  }

  @override
  Future<List<AlertaCaducidadEntity>> getAlertasPorTipo(
      AlertaTipo tipo) async {
    try {
      final tipoString = _tipoToString(tipo);

      final response = await supabase
          .from(viewName)
          .select()
          .eq('tipo_alerta', tipoString)
          .order('prioridad', ascending: true)
          .order('fecha_caducidad', ascending: true);

      final dataList = response as List;
      return dataList
          .map((json) => AlertaCaducidadSupabaseModel.fromJson(
              json as Map<String, dynamic>))
          .map((model) => model.toEntity())
          .toList();
    } catch (e) {
      throw Exception('Error al obtener alertas por tipo: $e');
    }
  }

  @override
  Future<List<AlertaCaducidadEntity>> getAlertasPorSeveridad(
      AlertaSeveridad severidad) async {
    try {
      final severidadString = _severidadToString(severidad);

      final response = await supabase
          .from(viewName)
          .select()
          .eq('severidad', severidadString)
          .order('prioridad', ascending: true)
          .order('fecha_caducidad', ascending: true);

      final dataList = response as List;
      return dataList
          .map((json) => AlertaCaducidadSupabaseModel.fromJson(
              json as Map<String, dynamic>))
          .map((model) => model.toEntity())
          .toList();
    } catch (e) {
      throw Exception('Error al obtener alertas por severidad: $e');
    }
  }

  @override
  Future<List<AlertaCaducidadEntity>> getAlertasPorVehiculo(
      String vehiculoId) async {
    try {
      final response = await supabase
          .from(viewName)
          .select()
          .eq('entidad_id', vehiculoId)
          .order('prioridad', ascending: true)
          .order('fecha_caducidad', ascending: true);

      final dataList = response as List;
      return dataList
          .map((json) => AlertaCaducidadSupabaseModel.fromJson(
              json as Map<String, dynamic>))
          .map((model) => model.toEntity())
          .toList();
    } catch (e) {
      throw Exception('Error al obtener alertas por vehículo: $e');
    }
  }

  /// Convierte el enum AlertaTipo a string para Supabase
  String _tipoToString(AlertaTipo tipo) {
    switch (tipo) {
      case AlertaTipo.seguro:
        return 'seguro';
      case AlertaTipo.itv:
        return 'itv';
      case AlertaTipo.homologacion:
        return 'homologacion';
      case AlertaTipo.revisionTecnica:
        return 'revision_tecnica';
      case AlertaTipo.revision:
        return 'revision';
      case AlertaTipo.mantenimiento:
        return 'mantenimiento';
    }
  }

  /// Convierte el enum AlertaSeveridad a string para Supabase
  String _severidadToString(AlertaSeveridad severidad) {
    switch (severidad) {
      case AlertaSeveridad.critica:
        return 'critica';
      case AlertaSeveridad.alta:
        return 'alta';
      case AlertaSeveridad.media:
        return 'media';
      case AlertaSeveridad.baja:
        return 'baja';
    }
  }
}
