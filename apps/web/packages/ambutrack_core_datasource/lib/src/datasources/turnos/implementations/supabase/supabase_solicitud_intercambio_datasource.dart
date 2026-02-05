import 'package:supabase_flutter/supabase_flutter.dart';

import '../../entities/solicitud_intercambio_entity.dart';
import '../../models/solicitud_intercambio_supabase_model.dart';
import '../../solicitud_intercambio_contract.dart';

/// Implementación de SolicitudIntercambioDataSource usando Supabase
class SupabaseSolicitudIntercambioDataSource
    implements SolicitudIntercambioDataSource {
  SupabaseSolicitudIntercambioDataSource(this._supabase);

  final SupabaseClient _supabase;
  static const String tableName = 'solicitudes_intercambio_turnos';

  @override
  Future<List<SolicitudIntercambioEntity>> getAll({
    int? limit,
    int? offset,
  }) async {
    dynamic query = _supabase.from(tableName).select();

    if (offset != null) {
      query = query.range(offset, offset + (limit ?? 100) - 1);
    } else if (limit != null) {
      query = query.limit(limit);
    }

    final dynamic response = await query.order('fechaSolicitud', ascending: false);

    final List<Map<String, dynamic>> data =
        (response as List).cast<Map<String, dynamic>>();

    return data
        .map(SolicitudIntercambioSupabaseModel.fromJson)
        .map((model) => model.toEntity())
        .toList();
  }

  @override
  Future<SolicitudIntercambioEntity?> getById(String id) async {
    final dynamic response = await _supabase
        .from(tableName)
        .select()
        .eq('id', id)
        .maybeSingle();

    if (response == null) {
      return null;
    }

    final Map<String, dynamic> data = response as Map<String, dynamic>;
    return SolicitudIntercambioSupabaseModel.fromJson(data).toEntity();
  }

  @override
  Future<SolicitudIntercambioEntity> create(
    SolicitudIntercambioEntity entity,
  ) async {
    final SolicitudIntercambioSupabaseModel model =
        SolicitudIntercambioSupabaseModel.fromEntity(entity);

    final Map<String, dynamic> data = model.toJsonForInsert();

    final dynamic response =
        await _supabase.from(tableName).insert(data).select().single();

    final Map<String, dynamic> result = response as Map<String, dynamic>;
    return SolicitudIntercambioSupabaseModel.fromJson(result).toEntity();
  }

  @override
  Future<SolicitudIntercambioEntity> update(
    SolicitudIntercambioEntity entity,
  ) async {
    final SolicitudIntercambioSupabaseModel model =
        SolicitudIntercambioSupabaseModel.fromEntity(entity);

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
    return SolicitudIntercambioSupabaseModel.fromJson(result).toEntity();
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
  Stream<List<SolicitudIntercambioEntity>> watchAll() {
    return _supabase
        .from(tableName)
        .stream(primaryKey: <String>['id'])
        .order('fechaSolicitud', ascending: false)
        .map((List<Map<String, dynamic>> data) {
          return data
              .map(SolicitudIntercambioSupabaseModel.fromJson)
              .map((model) => model.toEntity())
              .toList();
        });
  }

  @override
  Stream<SolicitudIntercambioEntity?> watchById(String id) {
    return _supabase
        .from(tableName)
        .stream(primaryKey: <String>['id'])
        .eq('id', id)
        .map((List<Map<String, dynamic>> data) {
          if (data.isEmpty) {
            return null;
          }
          return SolicitudIntercambioSupabaseModel.fromJson(data.first).toEntity();
        });
  }

  @override
  Future<void> clear() async {
    await _supabase.from(tableName).delete().neq('id', '');
  }

  @override
  Future<List<SolicitudIntercambioEntity>> createBatch(
    List<SolicitudIntercambioEntity> entities,
  ) async {
    final List<Map<String, dynamic>> dataList = entities.map((entity) {
      final model = SolicitudIntercambioSupabaseModel.fromEntity(entity);
      return model.toJsonForInsert();
    }).toList();

    final dynamic response =
        await _supabase.from(tableName).insert(dataList).select();

    final List<Map<String, dynamic>> results =
        (response as List).cast<Map<String, dynamic>>();

    return results
        .map(SolicitudIntercambioSupabaseModel.fromJson)
        .map((model) => model.toEntity())
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
  Future<List<SolicitudIntercambioEntity>> updateBatch(
    List<SolicitudIntercambioEntity> entities,
  ) async {
    final List<SolicitudIntercambioEntity> updated = [];

    for (final entity in entities) {
      final result = await update(entity);
      updated.add(result);
    }

    return updated;
  }

  // ===== MÉTODOS ESPECIALIZADOS =====

  @override
  Future<List<SolicitudIntercambioEntity>> getByEstado(
    EstadoSolicitud estado,
  ) async {
    final dynamic response = await _supabase
        .from(tableName)
        .select()
        .eq('estado', estado.name)
        .order('fechaSolicitud', ascending: false);

    final List<Map<String, dynamic>> data =
        (response as List).cast<Map<String, dynamic>>();

    return data
        .map(SolicitudIntercambioSupabaseModel.fromJson)
        .map((model) => model.toEntity())
        .toList();
  }

  @override
  Future<List<SolicitudIntercambioEntity>> getPendientesByPersonal(
    String idPersonal,
  ) async {
    final dynamic response = await _supabase
        .from(tableName)
        .select()
        .or('idPersonalSolicitante.eq.$idPersonal,idPersonalDestino.eq.$idPersonal')
        .inFilter('estado', [
          EstadoSolicitud.pendienteAprobacionTrabajador.name,
          EstadoSolicitud.pendienteAprobacionResponsable.name,
        ])
        .order('fechaSolicitud', ascending: false);

    final List<Map<String, dynamic>> data =
        (response as List).cast<Map<String, dynamic>>();

    return data
        .map(SolicitudIntercambioSupabaseModel.fromJson)
        .map((model) => model.toEntity())
        .toList();
  }

  @override
  Future<List<SolicitudIntercambioEntity>> getBySolicitante(
    String idPersonal,
  ) async {
    final dynamic response = await _supabase
        .from(tableName)
        .select()
        .eq('idPersonalSolicitante', idPersonal)
        .order('fechaSolicitud', ascending: false);

    final List<Map<String, dynamic>> data =
        (response as List).cast<Map<String, dynamic>>();

    return data
        .map(SolicitudIntercambioSupabaseModel.fromJson)
        .map((model) => model.toEntity())
        .toList();
  }

  @override
  Future<List<SolicitudIntercambioEntity>> getByDestino(
    String idPersonal,
  ) async {
    final dynamic response = await _supabase
        .from(tableName)
        .select()
        .eq('idPersonalDestino', idPersonal)
        .order('fechaSolicitud', ascending: false);

    final List<Map<String, dynamic>> data =
        (response as List).cast<Map<String, dynamic>>();

    return data
        .map(SolicitudIntercambioSupabaseModel.fromJson)
        .map((model) => model.toEntity())
        .toList();
  }
}
