import 'package:supabase_flutter/supabase_flutter.dart';

import '../../entities/taller_entity.dart';
import '../../models/taller_supabase_model.dart';
import '../../talleres_contract.dart';

/// Implementación Supabase del datasource de Talleres
class SupabaseTalleresDataSource implements TalleresDataSource {
  SupabaseTalleresDataSource({
    SupabaseClient? supabase,
    String tableName = 'ttalleres',
  })  : _supabase = supabase ?? Supabase.instance.client,
        _tableName = tableName;

  final SupabaseClient _supabase;
  final String _tableName;

  @override
  Future<List<TallerEntity>> getAll() async {
    try {
      final List<Map<String, dynamic>> response = await _supabase
          .from(_tableName)
          .select()
          .order('nombre', ascending: true);

      return response
          .map((Map<String, dynamic> json) =>
              TallerSupabaseModel.fromJson(json).toEntity())
          .toList();
    } catch (e) {
      throw Exception('Error al obtener talleres: $e');
    }
  }

  @override
  Future<TallerEntity?> getById(String id) async {
    try {
      final Map<String, dynamic>? response = await _supabase
          .from(_tableName)
          .select()
          .eq('id', id)
          .maybeSingle();

      if (response == null) return null;
      return TallerSupabaseModel.fromJson(response).toEntity();
    } catch (e) {
      throw Exception('Error al obtener taller por ID: $e');
    }
  }

  @override
  Future<TallerEntity> create(TallerEntity entity) async {
    try {
      final TallerSupabaseModel model =
          TallerSupabaseModel.fromEntity(entity);
      final Map<String, dynamic> response = await _supabase
          .from(_tableName)
          .insert(model.toJson())
          .select()
          .single();

      return TallerSupabaseModel.fromJson(response).toEntity();
    } catch (e) {
      throw Exception('Error al crear taller: $e');
    }
  }

  @override
  Future<TallerEntity> update(TallerEntity entity) async {
    try {
      final TallerSupabaseModel model =
          TallerSupabaseModel.fromEntity(entity);
      final Map<String, dynamic> response = await _supabase
          .from(_tableName)
          .update(model.toJson())
          .eq('id', entity.id)
          .select()
          .single();

      return TallerSupabaseModel.fromJson(response).toEntity();
    } catch (e) {
      throw Exception('Error al actualizar taller: $e');
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      await _supabase.from(_tableName).delete().eq('id', id);
    } catch (e) {
      throw Exception('Error al eliminar taller: $e');
    }
  }

  @override
  Future<List<TallerEntity>> getByTipo(String tipo) async {
    try {
      final List<Map<String, dynamic>> response = await _supabase
          .from(_tableName)
          .select()
          .eq('tipo', tipo)
          .order('nombre', ascending: true);

      return response
          .map((Map<String, dynamic> json) =>
              TallerSupabaseModel.fromJson(json).toEntity())
          .toList();
    } catch (e) {
      throw Exception('Error al obtener talleres por tipo: $e');
    }
  }

  @override
  Future<List<TallerEntity>> getActivos() async {
    try {
      final List<Map<String, dynamic>> response = await _supabase
          .from(_tableName)
          .select()
          .eq('activo', true)
          .order('nombre', ascending: true);

      return response
          .map((Map<String, dynamic> json) =>
              TallerSupabaseModel.fromJson(json).toEntity())
          .toList();
    } catch (e) {
      throw Exception('Error al obtener talleres activos: $e');
    }
  }

  @override
  Future<int> count() async {
    try {
      final PostgrestList data =
          await _supabase.from(_tableName).select('id');
      return data.length;
    } catch (e) {
      throw Exception('Error al contar talleres: $e');
    }
  }
}
