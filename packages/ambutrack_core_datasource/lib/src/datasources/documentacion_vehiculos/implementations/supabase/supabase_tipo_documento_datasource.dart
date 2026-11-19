import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../entities/tipo_documento_entity.dart';
import '../../models/tipo_documento_supabase_model.dart';
import '../../tipo_documento_datasource_contract.dart';

/// Implementación de Supabase para Tipos de Documento de Vehículo
@immutable
class SupabaseTipoDocumentoDataSource implements TipoDocumentoDataSource {
  const SupabaseTipoDocumentoDataSource(this._client);

  final SupabaseClient _client;
  static const String _tableName = 'tipos_documento_vehiculo';

  @override
  Future<List<TipoDocumentoEntity>> getAll() async {
    debugPrint('📡 SupabaseTipoDocumento: Obteniendo todos...');

    final response = await _client
        .from(_tableName)
        .select()
        .order('nombre');

    return (response as List)
        .map((json) => TipoDocumentoSupabaseModel.fromJson(json).toEntity())
        .toList();
  }

  @override
  Future<TipoDocumentoEntity?> getById(String id) async {
    debugPrint('📡 SupabaseTipoDocumento: Obteniendo id=$id');

    final response = await _client
        .from(_tableName)
        .select()
        .eq('id', id)
        .maybeSingle();

    if (response == null) return null;
    return TipoDocumentoSupabaseModel.fromJson(response).toEntity();
  }

  @override
  Future<List<TipoDocumentoEntity>> getByCategoria(String categoria) async {
    debugPrint('📡 SupabaseTipoDocumento: Obteniendo por categoría=$categoria');

    final response = await _client
        .from(_tableName)
        .select()
        .eq('categoria', categoria)
        .order('nombre');

    return (response as List)
        .map((json) => TipoDocumentoSupabaseModel.fromJson(json).toEntity())
        .toList();
  }

  @override
  Future<List<TipoDocumentoEntity>> getActivos() async {
    debugPrint('📡 SupabaseTipoDocumento: Obteniendo activos...');

    final response = await _client
        .from(_tableName)
        .select()
        .eq('activo', true)
        .order('nombre');

    return (response as List)
        .map((json) => TipoDocumentoSupabaseModel.fromJson(json).toEntity())
        .toList();
  }

  @override
  Future<TipoDocumentoEntity> create(TipoDocumentoEntity entity) async {
    debugPrint('📡 SupabaseTipoDocumento: Creando...');

    final model = TipoDocumentoSupabaseModel.fromEntity(entity);
    final response = await _client
        .from(_tableName)
        .insert(model.toJson())
        .select()
        .single();

    return TipoDocumentoSupabaseModel.fromJson(response).toEntity();
  }

  @override
  Future<TipoDocumentoEntity> update(TipoDocumentoEntity entity) async {
    debugPrint('📡 SupabaseTipoDocumento: Actualizando id=${entity.id}');

    final model = TipoDocumentoSupabaseModel.fromEntity(entity);
    final response = await _client
        .from(_tableName)
        .update(model.toJson())
        .eq('id', entity.id)
        .select()
        .single();

    return TipoDocumentoSupabaseModel.fromJson(response).toEntity();
  }

  @override
  Future<void> delete(String id) async {
    debugPrint('📡 SupabaseTipoDocumento: Eliminando id=$id');

    await _client.from(_tableName).delete().eq('id', id);
  }

  @override
  Future<TipoDocumentoEntity> desactivar(String id) async {
    debugPrint('📡 SupabaseTipoDocumento: Desactivando id=$id');

    final response = await _client
        .from(_tableName)
        .update({'activo': false, 'fecha_baja': DateTime.now().toIso8601String()})
        .eq('id', id)
        .select()
        .single();

    return TipoDocumentoSupabaseModel.fromJson(response).toEntity();
  }
}
