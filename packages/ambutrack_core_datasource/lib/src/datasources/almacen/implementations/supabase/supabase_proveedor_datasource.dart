import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../entities/proveedor_entity.dart';
import '../../models/proveedor_supabase_model.dart';
import '../../proveedor_contract.dart';

/// Implementación Supabase del datasource de Proveedores
class SupabaseProveedorDataSource implements ProveedorDataSource {
  SupabaseProveedorDataSource(this._supabase);

  final SupabaseClient _supabase;
  static const String _tableName = 'proveedores';

  @override
  Future<ProveedorEntity> create(ProveedorEntity entity) async {
    debugPrint('📦 SupabaseProveedorDataSource: Creando proveedor ${entity.nombreComercial}');
    try {
      final ProveedorSupabaseModel model = ProveedorSupabaseModel.fromEntity(entity);
      final Map<String, dynamic> data = await _supabase
          .from(_tableName)
          .insert(model.toJson())
          .select()
          .single();

      final ProveedorEntity created = ProveedorSupabaseModel.fromJson(data).toEntity();
      debugPrint('📦 SupabaseProveedorDataSource: ✅ Proveedor creado');
      return created;
    } catch (e, stackTrace) {
      debugPrint('📦 SupabaseProveedorDataSource: ❌ Error: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  @override
  Future<ProveedorEntity?> getById(String id) async {
    debugPrint('📦 SupabaseProveedorDataSource: Obteniendo proveedor $id');
    try {
      final List<dynamic> data = await _supabase
          .from(_tableName)
          .select()
          .eq('id', id)
          .limit(1);

      if (data.isEmpty) {
        return null;
      }

      final ProveedorEntity proveedor =
          ProveedorSupabaseModel.fromJson(data.first as Map<String, dynamic>).toEntity();
      debugPrint('📦 SupabaseProveedorDataSource: ✅ Proveedor obtenido');
      return proveedor;
    } catch (e, stackTrace) {
      debugPrint('📦 SupabaseProveedorDataSource: ❌ Error: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  @override
  Future<List<ProveedorEntity>> getAll({int? limit, int? offset}) async {
    debugPrint('📦 SupabaseProveedorDataSource: Obteniendo proveedores (limit: $limit, offset: $offset)');
    try {
      var query = _supabase.from(_tableName).select().order('nombre_comercial', ascending: true);

      if (limit != null) {
        query = query.limit(limit);
      }
      if (offset != null) {
        query = query.range(offset, offset + (limit ?? 100) - 1);
      }

      final List<dynamic> data = await query;

      final List<ProveedorEntity> proveedores = data
          .map((dynamic json) =>
              ProveedorSupabaseModel.fromJson(json as Map<String, dynamic>).toEntity())
          .toList();

      debugPrint('📦 SupabaseProveedorDataSource: ✅ ${proveedores.length} proveedores obtenidos');
      return proveedores;
    } catch (e, stackTrace) {
      debugPrint('📦 SupabaseProveedorDataSource: ❌ Error: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  @override
  Future<ProveedorEntity> update(ProveedorEntity entity) async {
    debugPrint('📦 SupabaseProveedorDataSource: Actualizando proveedor ${entity.id}');
    try {
      final ProveedorSupabaseModel model = ProveedorSupabaseModel.fromEntity(entity);
      final Map<String, dynamic> data = await _supabase
          .from(_tableName)
          .update(model.toJson())
          .eq('id', entity.id)
          .select()
          .single();

      final ProveedorEntity updated = ProveedorSupabaseModel.fromJson(data).toEntity();
      debugPrint('📦 SupabaseProveedorDataSource: ✅ Proveedor actualizado');
      return updated;
    } catch (e, stackTrace) {
      debugPrint('📦 SupabaseProveedorDataSource: ❌ Error: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  @override
  Future<void> delete(String id) async {
    debugPrint('📦 SupabaseProveedorDataSource: Desactivando proveedor $id');
    try {
      await _supabase.from(_tableName).update(<String, dynamic>{
        'activo': false,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', id);

      debugPrint('📦 SupabaseProveedorDataSource: ✅ Proveedor desactivado');
    } catch (e, stackTrace) {
      debugPrint('📦 SupabaseProveedorDataSource: ❌ Error: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  @override
  Future<bool> exists(String id) async {
    try {
      final List<dynamic> data = await _supabase.from(_tableName).select('id').eq('id', id).limit(1);
      return data.isNotEmpty;
    } catch (e) {
      debugPrint('📦 SupabaseProveedorDataSource: ❌ Error verificando existencia: $e');
      return false;
    }
  }

  @override
  Stream<List<ProveedorEntity>> watchAll() {
    return _supabase
        .from(_tableName)
        .stream(primaryKey: <String>['id'])
        .order('nombre_comercial', ascending: true)
        .map((List<Map<String, dynamic>> data) {
          return data.map((Map<String, dynamic> json) => ProveedorSupabaseModel.fromJson(json).toEntity()).toList();
        });
  }

  @override
  Stream<ProveedorEntity?> watchById(String id) {
    return _supabase
        .from(_tableName)
        .stream(primaryKey: <String>['id'])
        .eq('id', id)
        .map((List<Map<String, dynamic>> data) {
          if (data.isEmpty) return null;
          return ProveedorSupabaseModel.fromJson(data.first).toEntity();
        });
  }

  @override
  Future<List<ProveedorEntity>> createBatch(List<ProveedorEntity> entities) async {
    debugPrint('📦 SupabaseProveedorDataSource: Creando ${entities.length} proveedores en lote');
    try {
      final List<Map<String, dynamic>> jsonList =
          entities.map((ProveedorEntity e) => ProveedorSupabaseModel.fromEntity(e).toJson()).toList();

      final List<dynamic> data = await _supabase.from(_tableName).insert(jsonList).select();

      final List<ProveedorEntity> created =
          data.map((dynamic json) => ProveedorSupabaseModel.fromJson(json as Map<String, dynamic>).toEntity()).toList();

      debugPrint('📦 SupabaseProveedorDataSource: ✅ ${created.length} proveedores creados');
      return created;
    } catch (e, stackTrace) {
      debugPrint('📦 SupabaseProveedorDataSource: ❌ Error: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  @override
  Future<List<ProveedorEntity>> updateBatch(List<ProveedorEntity> entities) async {
    debugPrint('📦 SupabaseProveedorDataSource: Actualizando ${entities.length} proveedores en lote');
    // Supabase no soporta update batch directamente, hay que hacerlo uno por uno
    final List<ProveedorEntity> updated = <ProveedorEntity>[];
    for (final ProveedorEntity entity in entities) {
      updated.add(await update(entity));
    }
    return updated;
  }

  @override
  Future<void> deleteBatch(List<String> ids) async {
    debugPrint('📦 SupabaseProveedorDataSource: Desactivando ${ids.length} proveedores en lote');
    try {
      // Supabase usa .inFilter() en lugar de .in_()
      await _supabase.from(_tableName).update(<String, dynamic>{
        'activo': false,
        'updated_at': DateTime.now().toIso8601String(),
      }).inFilter('id', ids);

      debugPrint('📦 SupabaseProveedorDataSource: ✅ ${ids.length} proveedores desactivados');
    } catch (e, stackTrace) {
      debugPrint('📦 SupabaseProveedorDataSource: ❌ Error: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  @override
  Future<int> count() async {
    try {
      final List<dynamic> data = await _supabase.from(_tableName).select('id');
      return data.length;
    } catch (e) {
      debugPrint('📦 SupabaseProveedorDataSource: ❌ Error contando: $e');
      rethrow;
    }
  }

  @override
  Future<void> clear() async {
    debugPrint('📦 SupabaseProveedorDataSource: ⚠️ Limpiando TODOS los proveedores');
    try {
      await _supabase.from(_tableName).delete().neq('id', '');
      debugPrint('📦 SupabaseProveedorDataSource: ✅ Tabla limpiada');
    } catch (e, stackTrace) {
      debugPrint('📦 SupabaseProveedorDataSource: ❌ Error: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  // Métodos específicos de ProveedorDataSource

  @override
  Future<List<ProveedorEntity>> search(String query) async {
    debugPrint('📦 SupabaseProveedorDataSource: Buscando proveedores con query: $query');
    try {
      final List<dynamic> data = await _supabase
          .from(_tableName)
          .select()
          .or('nombre_comercial.ilike.%$query%,razon_social.ilike.%$query%,cif_nif.ilike.%$query%')
          .order('nombre_comercial', ascending: true);

      final List<ProveedorEntity> proveedores = data
          .map((dynamic json) =>
              ProveedorSupabaseModel.fromJson(json as Map<String, dynamic>).toEntity())
          .toList();

      debugPrint('📦 SupabaseProveedorDataSource: ✅ ${proveedores.length} proveedores encontrados');
      return proveedores;
    } catch (e, stackTrace) {
      debugPrint('📦 SupabaseProveedorDataSource: ❌ Error: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  @override
  Future<List<ProveedorEntity>> getActivos() async {
    debugPrint('📦 SupabaseProveedorDataSource: Obteniendo proveedores activos');
    try {
      final List<dynamic> data = await _supabase
          .from(_tableName)
          .select()
          .eq('activo', true)
          .order('nombre_comercial', ascending: true);

      final List<ProveedorEntity> proveedores = data
          .map((dynamic json) =>
              ProveedorSupabaseModel.fromJson(json as Map<String, dynamic>).toEntity())
          .toList();

      debugPrint('📦 SupabaseProveedorDataSource: ✅ ${proveedores.length} proveedores activos obtenidos');
      return proveedores;
    } catch (e, stackTrace) {
      debugPrint('📦 SupabaseProveedorDataSource: ❌ Error: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  @override
  Future<List<ProveedorEntity>> getByCiudad(String ciudad) async {
    debugPrint('📦 SupabaseProveedorDataSource: Obteniendo proveedores de $ciudad');
    try {
      final List<dynamic> data = await _supabase
          .from(_tableName)
          .select()
          .eq('ciudad', ciudad)
          .order('nombre_comercial', ascending: true);

      final List<ProveedorEntity> proveedores = data
          .map((dynamic json) =>
              ProveedorSupabaseModel.fromJson(json as Map<String, dynamic>).toEntity())
          .toList();

      debugPrint('📦 SupabaseProveedorDataSource: ✅ ${proveedores.length} proveedores de $ciudad obtenidos');
      return proveedores;
    } catch (e, stackTrace) {
      debugPrint('📦 SupabaseProveedorDataSource: ❌ Error: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }
}
