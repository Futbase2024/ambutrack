import 'package:supabase_flutter/supabase_flutter.dart';

import '../../entities/proveedor_taller_entity.dart';
import '../../models/proveedor_taller_supabase_model.dart';
import '../../proveedores_taller_contract.dart';

/// Implementación Supabase del datasource de Proveedores de Taller
class SupabaseProveedoresTallerDataSource
    implements ProveedoresTallerDataSource {
  SupabaseProveedoresTallerDataSource({
    SupabaseClient? supabase,
    String tableName = 'tproveedores_taller',
  })  : _supabase = supabase ?? Supabase.instance.client,
        _tableName = tableName;

  final SupabaseClient _supabase;
  final String _tableName;

  @override
  Future<List<ProveedorTallerEntity>> getAll() async {
    try {
      final List<Map<String, dynamic>> response = await _supabase
          .from(_tableName)
          .select()
          .order('nombre', ascending: true);

      return response
          .map((Map<String, dynamic> json) =>
              ProveedorTallerSupabaseModel.fromJson(json).toEntity())
          .toList();
    } catch (e) {
      throw Exception('Error al obtener proveedores: $e');
    }
  }

  @override
  Future<ProveedorTallerEntity?> getById(String id) async {
    try {
      final Map<String, dynamic>? response = await _supabase
          .from(_tableName)
          .select()
          .eq('id', id)
          .maybeSingle();

      if (response == null) return null;
      return ProveedorTallerSupabaseModel.fromJson(response).toEntity();
    } catch (e) {
      throw Exception('Error al obtener proveedor por ID: $e');
    }
  }

  @override
  Future<ProveedorTallerEntity> create(ProveedorTallerEntity entity) async {
    try {
      final ProveedorTallerSupabaseModel model =
          ProveedorTallerSupabaseModel.fromEntity(entity);
      final Map<String, dynamic> response = await _supabase
          .from(_tableName)
          .insert(model.toJson())
          .select()
          .single();

      return ProveedorTallerSupabaseModel.fromJson(response).toEntity();
    } catch (e) {
      throw Exception('Error al crear proveedor: $e');
    }
  }

  @override
  Future<ProveedorTallerEntity> update(ProveedorTallerEntity entity) async {
    try {
      final ProveedorTallerSupabaseModel model =
          ProveedorTallerSupabaseModel.fromEntity(entity);
      final Map<String, dynamic> response = await _supabase
          .from(_tableName)
          .update(model.toJson())
          .eq('id', entity.id)
          .select()
          .single();

      return ProveedorTallerSupabaseModel.fromJson(response).toEntity();
    } catch (e) {
      throw Exception('Error al actualizar proveedor: $e');
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      await _supabase.from(_tableName).delete().eq('id', id);
    } catch (e) {
      throw Exception('Error al eliminar proveedor: $e');
    }
  }

  @override
  Future<List<ProveedorTallerEntity>> getByTipo(String tipo) async {
    try {
      final List<Map<String, dynamic>> response = await _supabase
          .from(_tableName)
          .select()
          .eq('tipo', tipo)
          .order('nombre', ascending: true);

      return response
          .map((Map<String, dynamic> json) =>
              ProveedorTallerSupabaseModel.fromJson(json).toEntity())
          .toList();
    } catch (e) {
      throw Exception('Error al obtener proveedores por tipo: $e');
    }
  }

  @override
  Future<List<ProveedorTallerEntity>> getActivos() async {
    try {
      final List<Map<String, dynamic>> response = await _supabase
          .from(_tableName)
          .select()
          .eq('activo', true)
          .order('nombre', ascending: true);

      return response
          .map((Map<String, dynamic> json) =>
              ProveedorTallerSupabaseModel.fromJson(json).toEntity())
          .toList();
    } catch (e) {
      throw Exception('Error al obtener proveedores activos: $e');
    }
  }

  @override
  Future<int> count() async {
    try {
      final PostgrestList data =
          await _supabase.from(_tableName).select('id');
      return data.length;
    } catch (e) {
      throw Exception('Error al contar proveedores: $e');
    }
  }
}
