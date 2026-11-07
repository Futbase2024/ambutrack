import 'package:supabase_flutter/supabase_flutter.dart';

import '../../contrato_contract.dart';
import '../../entities/contrato_entity.dart';
import '../../models/contrato_supabase_model.dart';

/// Implementación de [ContratoDataSource] usando Supabase
class SupabaseContratoDataSource implements ContratoDataSource {
  SupabaseContratoDataSource({
    SupabaseClient? supabase,
    this.tableName = 'contratos',
  }) : _supabase = supabase ?? Supabase.instance.client;

  final SupabaseClient _supabase;
  final String tableName;

  @override
  Future<List<ContratoEntity>> getAll({int? limit, int? offset}) async {
    try {
      dynamic query = _supabase.from(tableName).select();

      if (offset != null) {
        query = query.range(offset, offset + (limit ?? 100) - 1);
      } else if (limit != null) {
        query = query.limit(limit);
      }

      final List<Map<String, dynamic>> response =
          await query.order('created_at', ascending: false);

      return response.map(ContratoSupabaseModel.fromJson).map((ContratoSupabaseModel model) => model.toEntity()).toList();
    } catch (e) {
      throw Exception('Error al obtener contratos: $e');
    }
  }

  @override
  Future<List<ContratoEntity>> getActivos({int? limit, int? offset}) async {
    try {
      dynamic query = _supabase.from(tableName).select().eq('activo', true);

      if (offset != null) {
        query = query.range(offset, offset + (limit ?? 100) - 1);
      } else if (limit != null) {
        query = query.limit(limit);
      }

      final List<Map<String, dynamic>> response =
          await query.order('created_at', ascending: false);

      return response.map(ContratoSupabaseModel.fromJson).map((ContratoSupabaseModel model) => model.toEntity()).toList();
    } catch (e) {
      throw Exception('Error al obtener contratos activos: $e');
    }
  }

  @override
  Future<List<ContratoEntity>> getVigentes({int? limit, int? offset}) async {
    try {
      final String ahora = DateTime.now().toIso8601String();

      dynamic query = _supabase
          .from(tableName)
          .select()
          .eq('activo', true)
          .lte('fecha_inicio', ahora)
          .or('fecha_fin.is.null,fecha_fin.gte.$ahora');

      if (offset != null) {
        query = query.range(offset, offset + (limit ?? 100) - 1);
      } else if (limit != null) {
        query = query.limit(limit);
      }

      final List<Map<String, dynamic>> response =
          await query.order('created_at', ascending: false);

      return response.map(ContratoSupabaseModel.fromJson).map((ContratoSupabaseModel model) => model.toEntity()).toList();
    } catch (e) {
      throw Exception('Error al obtener contratos vigentes: $e');
    }
  }

  @override
  Future<List<ContratoEntity>> getByHospitalId(String hospitalId) async {
    try {
      final List<Map<String, dynamic>> response = await _supabase
          .from(tableName)
          .select()
          .eq('hospital_id', hospitalId)
          .order('created_at', ascending: false);

      return response.map(ContratoSupabaseModel.fromJson).map((ContratoSupabaseModel model) => model.toEntity()).toList();
    } catch (e) {
      throw Exception('Error al obtener contratos por hospital: $e');
    }
  }

  @override
  Future<ContratoEntity?> getById(String id) async {
    try {
      final Map<String, dynamic>? response = await _supabase
          .from(tableName)
          .select()
          .eq('id', id)
          .maybeSingle();

      if (response == null) {
        return null;
      }

      return ContratoSupabaseModel.fromJson(response).toEntity();
    } catch (e) {
      throw Exception('Error al obtener contrato por ID: $e');
    }
  }

  @override
  Future<ContratoEntity?> getByCodigo(String codigo) async {
    try {
      final Map<String, dynamic>? response = await _supabase
          .from(tableName)
          .select()
          .eq('codigo', codigo)
          .maybeSingle();

      if (response == null) {
        return null;
      }

      return ContratoSupabaseModel.fromJson(response).toEntity();
    } catch (e) {
      throw Exception('Error al obtener contrato por código: $e');
    }
  }

  @override
  Future<ContratoEntity> create(ContratoEntity entity) async {
    try {
      final ContratoSupabaseModel model =
          ContratoSupabaseModel.fromEntity(entity);

      final Map<String, dynamic> data = model.toJson()
        ..remove('id')
        ..remove('created_at')
        ..remove('updated_at');

      final Map<String, dynamic> response = await _supabase
          .from(tableName)
          .insert(data)
          .select()
          .single();

      return ContratoSupabaseModel.fromJson(response).toEntity();
    } catch (e) {
      throw Exception('Error al crear contrato: $e');
    }
  }

  @override
  Future<ContratoEntity> update(ContratoEntity entity) async {
    try {
      final ContratoSupabaseModel model =
          ContratoSupabaseModel.fromEntity(entity);

      final Map<String, dynamic> data = model.toJson()
        ..remove('id')
        ..remove('created_at')
        ..remove('updated_at')
        ..remove('created_by');

      data['updated_at'] = DateTime.now().toIso8601String();

      final Map<String, dynamic> response = await _supabase
          .from(tableName)
          .update(data)
          .eq('id', entity.id)
          .select()
          .single();

      return ContratoSupabaseModel.fromJson(response).toEntity();
    } catch (e) {
      throw Exception('Error al actualizar contrato: $e');
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      await _supabase.from(tableName).delete().eq('id', id);
    } catch (e) {
      throw Exception('Error al eliminar contrato: $e');
    }
  }

  @override
  Future<void> toggleActivo(String id, {required bool activo}) async {
    try {
      await _supabase
          .from(tableName)
          .update(<String, dynamic>{'activo': activo}).eq('id', id);
    } catch (e) {
      throw Exception('Error al cambiar estado del contrato: $e');
    }
  }

  @override
  Future<bool> exists(String id) async {
    try {
      final Map<String, dynamic>? response = await _supabase
          .from(tableName)
          .select('id')
          .eq('id', id)
          .maybeSingle();

      return response != null;
    } catch (e) {
      throw Exception('Error al verificar existencia del contrato: $e');
    }
  }

  @override
  Stream<List<ContratoEntity>> watchAll() {
    return _supabase
        .from(tableName)
        .stream(primaryKey: <String>['id'])
        .order('created_at', ascending: false)
        .map((List<Map<String, dynamic>> data) {
      return data.map(ContratoSupabaseModel.fromJson).map((ContratoSupabaseModel model) => model.toEntity()).toList();
    });
  }

  @override
  Stream<ContratoEntity?> watchById(String id) {
    return _supabase
        .from(tableName)
        .stream(primaryKey: <String>['id'])
        .eq('id', id)
        .map((List<Map<String, dynamic>> data) {
      if (data.isEmpty) {
        return null;
      }
      return ContratoSupabaseModel.fromJson(data.first).toEntity();
    });
  }

  @override
  Future<List<ContratoEntity>> createBatch(List<ContratoEntity> entities) async {
    try {
      final List<Map<String, dynamic>> dataList = entities.map((ContratoEntity entity) {
        final ContratoSupabaseModel model = ContratoSupabaseModel.fromEntity(entity);
        return model.toJson()
          ..remove('id')
          ..remove('created_at')
          ..remove('updated_at');
      }).toList();

      final List<Map<String, dynamic>> response = await _supabase
          .from(tableName)
          .insert(dataList)
          .select();

      return response.map(ContratoSupabaseModel.fromJson).map((ContratoSupabaseModel model) => model.toEntity()).toList();
    } catch (e) {
      throw Exception('Error al crear contratos en batch: $e');
    }
  }

  @override
  Future<List<ContratoEntity>> updateBatch(List<ContratoEntity> entities) async {
    try {
      final List<ContratoEntity> updated = <ContratoEntity>[];

      for (final ContratoEntity entity in entities) {
        final ContratoEntity result = await update(entity);
        updated.add(result);
      }

      return updated;
    } catch (e) {
      throw Exception('Error al actualizar contratos en batch: $e');
    }
  }

  @override
  Future<void> deleteBatch(List<String> ids) async {
    try {
      for (final String id in ids) {
        await delete(id);
      }
    } catch (e) {
      throw Exception('Error al eliminar contratos en batch: $e');
    }
  }

  @override
  Future<int> count() async {
    try {
      final response = await _supabase
          .from(tableName)
          .select()
          .count();

      return response.count;
    } catch (e) {
      throw Exception('Error al contar contratos: $e');
    }
  }

  @override
  Future<void> clear() async {
    try {
      await _supabase.from(tableName).delete().neq('id', '');
    } catch (e) {
      throw Exception('Error al limpiar contratos: $e');
    }
  }
}
