import 'package:supabase_flutter/supabase_flutter.dart';

import '../../entities/tipo_traslado_entity.dart';
import '../../models/tipo_traslado_supabase_model.dart';
import '../../tipo_traslado_contract.dart';

/// Implementación de TipoTrasladoDataSource usando Supabase
class SupabaseTipoTrasladoDataSource implements TipoTrasladoDataSource {
  SupabaseTipoTrasladoDataSource(this._supabase);

  final SupabaseClient _supabase;
  static const String tableName = 'ttipos_traslado';

  @override
  Future<List<TipoTrasladoEntity>> getAll({int? limit, int? offset}) async {
    dynamic query = _supabase.from(tableName).select();

    if (offset != null) {
      query = query.range(offset, offset + (limit ?? 100) - 1);
    } else if (limit != null) {
      query = query.limit(limit);
    }

    final dynamic response = await query.order('nombre', ascending: true);

    final List<Map<String, dynamic>> data =
        (response as List).cast<Map<String, dynamic>>();

    return data
        .map(TipoTrasladoSupabaseModel.fromJson)
        .cast<TipoTrasladoEntity>()
        .toList();
  }

  @override
  Future<TipoTrasladoEntity?> getById(String id) async {
    final dynamic response = await _supabase
        .from(tableName)
        .select()
        .eq('id', id)
        .maybeSingle();

    if (response == null) {
      return null;
    }

    final Map<String, dynamic> data = response as Map<String, dynamic>;
    return TipoTrasladoSupabaseModel.fromJson(data);
  }

  @override
  Future<TipoTrasladoEntity> create(TipoTrasladoEntity entity) async {
    final TipoTrasladoSupabaseModel model = TipoTrasladoSupabaseModel(
      id: entity.id,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      nombre: entity.nombre,
      descripcion: entity.descripcion,
      activo: entity.activo,
    );

    final Map<String, dynamic> data = model.toJson()
      ..remove('id')
      ..remove('created_at')
      ..remove('updated_at');

    final dynamic response =
        await _supabase.from(tableName).insert(data).select().single();

    final Map<String, dynamic> result = response as Map<String, dynamic>;
    return TipoTrasladoSupabaseModel.fromJson(result);
  }

  @override
  Future<TipoTrasladoEntity> update(TipoTrasladoEntity entity) async {
    final TipoTrasladoSupabaseModel model = TipoTrasladoSupabaseModel(
      id: entity.id,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      nombre: entity.nombre,
      descripcion: entity.descripcion,
      activo: entity.activo,
    );

    final Map<String, dynamic> data = model.toJson()
      ..remove('id')
      ..remove('created_at')
      ..remove('updated_at');

    final dynamic response = await _supabase
        .from(tableName)
        .update(data)
        .eq('id', entity.id)
        .select()
        .single();

    final Map<String, dynamic> result = response as Map<String, dynamic>;
    return TipoTrasladoSupabaseModel.fromJson(result);
  }

  @override
  Future<void> delete(String id) async {
    await _supabase.from(tableName).delete().eq('id', id);
  }

  @override
  Future<void> deleteBatch(List<String> ids) async {
    await _supabase.from(tableName).delete().inFilter('id', ids);
  }

  @override
  Future<int> count() async {
    final response = await _supabase
        .from(tableName)
        .select('id')
        .count(CountOption.exact);
    return response.count;
  }

  @override
  Stream<List<TipoTrasladoEntity>> watchAll() {
    return _supabase
        .from(tableName)
        .stream(primaryKey: <String>['id'])
        .order('nombre', ascending: true)
        .map((List<Map<String, dynamic>> data) {
          return data
              .map(TipoTrasladoSupabaseModel.fromJson)
              .cast<TipoTrasladoEntity>()
              .toList();
        });
  }

  @override
  Stream<TipoTrasladoEntity?> watchById(String id) {
    return _supabase
        .from(tableName)
        .stream(primaryKey: <String>['id'])
        .eq('id', id)
        .map((List<Map<String, dynamic>> data) {
          if (data.isEmpty) {
            return null;
          }
          return TipoTrasladoSupabaseModel.fromJson(data.first);
        });
  }

  @override
  Future<List<TipoTrasladoEntity>> getActivos() async {
    final dynamic response = await _supabase
        .from(tableName)
        .select()
        .eq('activo', true)
        .order('nombre', ascending: true);

    final List<Map<String, dynamic>> data =
        (response as List).cast<Map<String, dynamic>>();

    return data
        .map(TipoTrasladoSupabaseModel.fromJson)
        .cast<TipoTrasladoEntity>()
        .toList();
  }

  @override
  Future<void> clear() async {
    await _supabase.from(tableName).delete().neq('id', '');
  }

  @override
  Future<List<TipoTrasladoEntity>> createBatch(
    List<TipoTrasladoEntity> entities,
  ) async {
    final List<Map<String, dynamic>> dataList = entities.map((entity) {
      final model = TipoTrasladoSupabaseModel(
        id: entity.id,
        createdAt: entity.createdAt,
        updatedAt: entity.updatedAt,
        nombre: entity.nombre,
        descripcion: entity.descripcion,
        activo: entity.activo,
      );
      return model.toJson()
        ..remove('id')
        ..remove('created_at')
        ..remove('updated_at');
    }).toList();

    final dynamic response =
        await _supabase.from(tableName).insert(dataList).select();

    final List<Map<String, dynamic>> results =
        (response as List).cast<Map<String, dynamic>>();

    return results
        .map(TipoTrasladoSupabaseModel.fromJson)
        .cast<TipoTrasladoEntity>()
        .toList();
  }

  @override
  Future<bool> exists(String id) async {
    final response = await _supabase
        .from(tableName)
        .select('id')
        .eq('id', id)
        .maybeSingle();

    return response != null;
  }

  @override
  Future<List<TipoTrasladoEntity>> updateBatch(
    List<TipoTrasladoEntity> entities,
  ) async {
    final List<TipoTrasladoEntity> updated = [];

    for (final entity in entities) {
      final result = await update(entity);
      updated.add(result);
    }

    return updated;
  }
}
