import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../entities/resultado_generacion_traslados_entity.dart';
import '../../generacion_traslados_contract.dart';
import '../../models/resultado_generacion_supabase_model.dart';

/// Implementación Supabase de la generación de traslados (RPC)
class SupabaseGeneracionTrasladosDataSource
    implements GeneracionTrasladosDataSource {
  SupabaseGeneracionTrasladosDataSource(this._supabase);

  final SupabaseClient _supabase;
  static const String _rpcName = 'generar_traslados_periodo';

  @override
  Future<ResultadoGeneracionTrasladosEntity> generarPeriodo({
    required DateTime desde,
    required DateTime hasta,
  }) async {
    final String desdeStr = desde.toIso8601String().split('T').first;
    final String hastaStr = hasta.toIso8601String().split('T').first;
    debugPrint(
      '📦 SupabaseGeneracionTrasladosDataSource: Generando traslados $desdeStr → $hastaStr',
    );
    try {
      final Object? response = await _supabase.rpc<Object?>(
        _rpcName,
        params: <String, dynamic>{
          'p_fecha_desde': desdeStr,
          'p_fecha_hasta': hastaStr,
        },
      );
      final ResultadoGeneracionTrasladosEntity resultado =
          ResultadoGeneracionSupabaseModel.fromResponse(response).toEntity(
        fechaDesde: desde,
        fechaHasta: hasta,
        ejecutadoEn: DateTime.now(),
      );
      debugPrint(
        '📦 SupabaseGeneracionTrasladosDataSource: ✅ ${resultado.trasladosGenerados} traslados generados '
        '(${resultado.serviciosProcesados} servicios, ${resultado.serviciosConError} con error)',
      );
      return resultado;
    } catch (e) {
      debugPrint('📦 SupabaseGeneracionTrasladosDataSource: ❌ Error: $e');
      rethrow;
    }
  }
}
