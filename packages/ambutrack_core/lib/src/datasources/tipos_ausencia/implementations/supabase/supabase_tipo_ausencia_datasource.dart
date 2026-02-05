import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../entities/tipo_ausencia_entity.dart';
import '../../models/tipo_ausencia_supabase_model.dart';
import '../../tipo_ausencia_contract.dart';

/// Implementación de TipoAusenciaDataSource usando Supabase
class SupabaseTipoAusenciaDataSource implements TipoAusenciaDataSource {
  SupabaseTipoAusenciaDataSource({SupabaseClient? supabaseClient})
      : _supabase = supabaseClient ?? Supabase.instance.client;

  final SupabaseClient _supabase;
  static const String _tableName = 'tipos_ausencia';

  @override
  Future<List<TipoAusenciaEntity>> getAll() async {
    try {
      debugPrint('📦 SupabaseTipoAusenciaDS: Obteniendo todos los tipos...');

      final response = await _supabase
          .from(_tableName)
          .select()
          .eq('activo', true)
          .order('nombre');

      final List<TipoAusenciaEntity> tipos = (response as List)
          .map((json) =>
              TipoAusenciaSupabaseModel.fromJson(json as Map<String, dynamic>)
                  .toEntity())
          .toList();

      debugPrint('📦 SupabaseTipoAusenciaDS: ✅ ${tipos.length} tipos obtenidos');
      return tipos;
    } catch (e, stack) {
      debugPrint('📦 SupabaseTipoAusenciaDS: ❌ Error al obtener tipos: $e');
      debugPrint('Stack: $stack');
      rethrow;
    }
  }

  @override
  Future<TipoAusenciaEntity> getById(String id) async {
    try {
      debugPrint('📦 SupabaseTipoAusenciaDS: Obteniendo tipo ID: $id');

      final response = await _supabase
          .from(_tableName)
          .select()
          .eq('id', id)
          .single();

      final tipo = TipoAusenciaSupabaseModel.fromJson(
        response,
      ).toEntity();

      debugPrint('📦 SupabaseTipoAusenciaDS: ✅ Tipo obtenido: ${tipo.nombre}');
      return tipo;
    } catch (e, stack) {
      debugPrint('📦 SupabaseTipoAusenciaDS: ❌ Error al obtener tipo: $e');
      debugPrint('Stack: $stack');
      rethrow;
    }
  }

  @override
  Future<TipoAusenciaEntity> create(TipoAusenciaEntity tipoAusencia) async {
    try {
      debugPrint('📦 SupabaseTipoAusenciaDS: Creando tipo: ${tipoAusencia.nombre}');

      final model = TipoAusenciaSupabaseModel.fromEntity(tipoAusencia);
      final json = model.toJson();
      json.remove('id');
      json.remove('created_at');
      json.remove('updated_at');

      final response = await _supabase
          .from(_tableName)
          .insert(json)
          .select()
          .single();

      final created = TipoAusenciaSupabaseModel.fromJson(
        response,
      ).toEntity();

      debugPrint('📦 SupabaseTipoAusenciaDS: ✅ Tipo creado con ID: ${created.id}');
      return created;
    } catch (e, stack) {
      debugPrint('📦 SupabaseTipoAusenciaDS: ❌ Error al crear tipo: $e');
      debugPrint('Stack: $stack');
      rethrow;
    }
  }

  @override
  Future<TipoAusenciaEntity> update(TipoAusenciaEntity tipoAusencia) async {
    try {
      debugPrint('📦 SupabaseTipoAusenciaDS: Actualizando tipo ID: ${tipoAusencia.id}');

      final model = TipoAusenciaSupabaseModel.fromEntity(tipoAusencia);
      final json = model.toJson();
      json.remove('id');
      json.remove('created_at');
      json.remove('updated_at');

      final response = await _supabase
          .from(_tableName)
          .update(json)
          .eq('id', tipoAusencia.id)
          .select()
          .single();

      final updated = TipoAusenciaSupabaseModel.fromJson(
        response,
      ).toEntity();

      debugPrint('📦 SupabaseTipoAusenciaDS: ✅ Tipo actualizado');
      return updated;
    } catch (e, stack) {
      debugPrint('📦 SupabaseTipoAusenciaDS: ❌ Error al actualizar tipo: $e');
      debugPrint('Stack: $stack');
      rethrow;
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      debugPrint('📦 SupabaseTipoAusenciaDS: Eliminando (soft) tipo ID: $id');

      await _supabase
          .from(_tableName)
          .update({'activo': false})
          .eq('id', id);

      debugPrint('📦 SupabaseTipoAusenciaDS: ✅ Tipo eliminado (soft)');
    } catch (e, stack) {
      debugPrint('📦 SupabaseTipoAusenciaDS: ❌ Error al eliminar tipo: $e');
      debugPrint('Stack: $stack');
      rethrow;
    }
  }

  @override
  Stream<List<TipoAusenciaEntity>> watchAll() {
    debugPrint('📦 SupabaseTipoAusenciaDS: 🔄 Iniciando stream de tipos...');

    return _supabase
        .from(_tableName)
        .stream(primaryKey: ['id'])
        .eq('activo', true)
        .order('nombre')
        .map((data) {
          debugPrint('📦 SupabaseTipoAusenciaDS: 🔄 Stream actualizado: ${data.length} tipos');
          return data
              .map((json) =>
                  TipoAusenciaSupabaseModel.fromJson(json).toEntity())
              .toList();
        });
  }
}
