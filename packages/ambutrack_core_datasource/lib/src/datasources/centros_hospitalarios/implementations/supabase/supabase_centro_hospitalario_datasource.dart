import 'package:supabase_flutter/supabase_flutter.dart';

import '../../centro_hospitalario_contract.dart';
import '../../entities/centro_hospitalario_entity.dart';
import '../../models/centro_hospitalario_supabase_model.dart';

/// Implementación de [CentroHospitalarioDataSource] usando Supabase
class SupabaseCentroHospitalarioDataSource
    implements CentroHospitalarioDataSource {
  SupabaseCentroHospitalarioDataSource({
    SupabaseClient? supabase,
    this.tableName = 'tcentros_hospitalarios',
  }) : _supabase = supabase ?? Supabase.instance.client;

  final SupabaseClient _supabase;
  final String tableName;

  @override
  Future<List<CentroHospitalarioEntity>> getAll({
    int? limit,
    int? offset,
  }) async {
    try {
      // JOIN con tpoblaciones para traer localidad_nombre
      dynamic query = _supabase.from(tableName).select('''
        *,
        tpoblaciones!tcentros_hospitalarios_localidad_id_fkey(nombre)
      ''');

      if (offset != null) {
        query = query.range(offset, offset + (limit ?? 100) - 1);
      } else if (limit != null) {
        query = query.limit(limit);
      }

      final dynamic response = await query.order('nombre', ascending: true);

      // Mapear la respuesta incluyendo el nombre de la localidad del JOIN
      return (response as List).map((dynamic item) {
        final Map<String, dynamic> json = Map<String, dynamic>.from(item as Map<String, dynamic>);

        // Extraer el nombre de la localidad del JOIN
        if (json['tpoblaciones'] != null && json['tpoblaciones'] is Map) {
          final Map<String, dynamic> poblacion = json['tpoblaciones'] as Map<String, dynamic>;
          json['localidad_nombre'] = poblacion['nombre'];
        }

        // Remover el objeto tpoblaciones para evitar conflictos
        json.remove('tpoblaciones');

        return CentroHospitalarioSupabaseModel.fromJson(json).toEntity();
      }).toList();
    } catch (e) {
      throw Exception('Error al obtener centros hospitalarios: $e');
    }
  }

  @override
  Future<CentroHospitalarioEntity?> getById(String id) async {
    try {
      final Map<String, dynamic>? response = await _supabase
          .from(tableName)
          .select()
          .eq('id', id)
          .maybeSingle();

      if (response == null) {
        return null;
      }

      return CentroHospitalarioSupabaseModel.fromJson(response).toEntity();
    } catch (e) {
      throw Exception('Error al obtener centro hospitalario por ID: $e');
    }
  }

  @override
  Future<CentroHospitalarioEntity> create(
    CentroHospitalarioEntity entity,
  ) async {
    try {
      final CentroHospitalarioSupabaseModel model =
          CentroHospitalarioSupabaseModel.fromEntity(entity);

      final Map<String, dynamic> data = model.toJson();
      data.remove('id');
      data.remove('created_at');
      data.remove('updated_at');
      // Remover campos calculados (JOIN)
      data.remove('localidad_nombre');
      data.remove('provincia_nombre');

      final Map<String, dynamic> response = await _supabase
          .from(tableName)
          .insert(data)
          .select()
          .single();

      return CentroHospitalarioSupabaseModel.fromJson(response).toEntity();
    } catch (e) {
      throw Exception('Error al crear centro hospitalario: $e');
    }
  }

  @override
  Future<CentroHospitalarioEntity> update(
    CentroHospitalarioEntity entity,
  ) async {
    try {
      final CentroHospitalarioSupabaseModel model =
          CentroHospitalarioSupabaseModel.fromEntity(entity);

      final Map<String, dynamic> data = model.toJson();
      data.remove('id');
      data.remove('created_at');
      data['updated_at'] = DateTime.now().toIso8601String();
      // Remover campos calculados (JOIN)
      data.remove('localidad_nombre');
      data.remove('provincia_nombre');

      final Map<String, dynamic> response = await _supabase
          .from(tableName)
          .update(data)
          .eq('id', entity.id)
          .select()
          .single();

      return CentroHospitalarioSupabaseModel.fromJson(response).toEntity();
    } catch (e) {
      throw Exception('Error al actualizar centro hospitalario: $e');
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      await _supabase.from(tableName).delete().eq('id', id);
    } catch (e) {
      throw Exception('Error al eliminar centro hospitalario: $e');
    }
  }

  @override
  Future<List<CentroHospitalarioEntity>> createBatch(
    List<CentroHospitalarioEntity> entities,
  ) async {
    try {
      final List<Map<String, dynamic>> dataList = entities.map((entity) {
        final model = CentroHospitalarioSupabaseModel.fromEntity(entity);
        final data = model.toJson();
        data.remove('id');
        data.remove('created_at');
        data.remove('updated_at');
        // Remover campos calculados (JOINs)
        data.remove('localidad_nombre');
        data.remove('provincia_nombre');
        return data;
      }).toList();

      final List<dynamic> response = await _supabase
          .from(tableName)
          .insert(dataList)
          .select();

      return response
          .map((dynamic json) => CentroHospitalarioSupabaseModel.fromJson(
                json as Map<String, dynamic>,
              ).toEntity())
          .toList();
    } catch (e) {
      throw Exception('Error al crear centros en lote: $e');
    }
  }

  @override
  Future<List<CentroHospitalarioEntity>> updateBatch(
    List<CentroHospitalarioEntity> entities,
  ) async {
    try {
      final List<CentroHospitalarioEntity> results = [];
      for (final entity in entities) {
        final updated = await update(entity);
        results.add(updated);
      }
      return results;
    } catch (e) {
      throw Exception('Error al actualizar centros en lote: $e');
    }
  }

  @override
  Future<void> deleteBatch(List<String> ids) async {
    try {
      await _supabase.from(tableName).delete().inFilter('id', ids);
    } catch (e) {
      throw Exception('Error al eliminar centros en lote: $e');
    }
  }

  @override
  Future<int> count() async {
    try {
      final dynamic response = await _supabase
          .from(tableName)
          .select()
          .count();

      return response.count as int;
    } catch (e) {
      throw Exception('Error al contar centros hospitalarios: $e');
    }
  }

  @override
  Future<bool> exists(String id) async {
    try {
      final Map<String, dynamic>? response =
          await _supabase.from(tableName).select('id').eq('id', id).maybeSingle();

      return response != null;
    } catch (e) {
      throw Exception('Error al verificar existencia del centro: $e');
    }
  }

  @override
  Future<void> clear() async {
    try {
      await _supabase
          .from(tableName)
          .delete()
          .neq('id', '00000000-0000-0000-0000-000000000000');
    } catch (e) {
      throw Exception('Error al limpiar centros hospitalarios: $e');
    }
  }

  @override
  Stream<List<CentroHospitalarioEntity>> watchAll() {
    return _supabase
        .from(tableName)
        .stream(primaryKey: <String>['id'])
        .order('nombre')
        .map((List<Map<String, dynamic>> data) {
          return data
              .map((Map<String, dynamic> json) =>
                  CentroHospitalarioSupabaseModel.fromJson(json).toEntity())
              .toList();
        });
  }

  @override
  Stream<CentroHospitalarioEntity?> watchById(String id) {
    return _supabase
        .from(tableName)
        .stream(primaryKey: <String>['id'])
        .eq('id', id)
        .map((List<Map<String, dynamic>> data) {
          if (data.isEmpty) {
            return null;
          }
          return CentroHospitalarioSupabaseModel.fromJson(data.first).toEntity();
        });
  }
}
