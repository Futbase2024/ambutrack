import 'package:supabase_flutter/supabase_flutter.dart';

import '../../busqueda_global_contract.dart';
import '../../entities/resultado_busqueda_entity.dart';
import '../../models/resultado_busqueda_supabase_model.dart';

/// Implementación Supabase de la búsqueda global (RPC `fn_buscar_global`)
class SupabaseBusquedaGlobalDataSource implements BusquedaGlobalDataSource {
  SupabaseBusquedaGlobalDataSource({SupabaseClient? supabase}) : _supabase = supabase ?? Supabase.instance.client;

  final SupabaseClient _supabase;

  @override
  Future<List<ResultadoBusquedaEntity>> buscar(String texto, {int limitePorTipo = 6}) async {
    try {
      final dynamic response = await _supabase.rpc<dynamic>(
        'fn_buscar_global',
        params: <String, dynamic>{'p_texto': texto, 'p_limite': limitePorTipo},
      );
      return (response as List<dynamic>)
          .map((dynamic json) => ResultadoBusquedaSupabaseModel.fromJson(json as Map<String, dynamic>).toEntity())
          .toList();
    } catch (e) {
      throw Exception('Error en la búsqueda global: $e');
    }
  }
}
