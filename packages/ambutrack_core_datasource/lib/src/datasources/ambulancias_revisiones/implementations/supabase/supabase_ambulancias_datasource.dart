import 'package:supabase_flutter/supabase_flutter.dart';

import '../../ambulancias_revisiones_contract.dart';
import '../../entities/ambulancia_entity.dart';
import '../../entities/item_revision_entity.dart';
import '../../entities/revision_entity.dart';
import '../../entities/tipo_ambulancia_entity.dart';
import '../../models/ambulancia_supabase_model.dart';
import '../../models/item_revision_supabase_model.dart';
import '../../models/revision_supabase_model.dart';
import '../../models/tipo_ambulancia_supabase_model.dart';

/// Implementación de Supabase para el datasource de ambulancias y revisiones
class SupabaseAmbulanciasDataSource
    implements AmbulanciasRevisionesDataSource {
  SupabaseAmbulanciasDataSource({
    SupabaseClient? supabaseClient,
    String tableName = 'amb_ambulancias',
    String tiposTableName = 'amb_tipos_ambulancia',
    String revisionesTableName = 'amb_revisiones',
    String itemsTableName = 'amb_items_revision',
  })  : _supabase = supabaseClient ?? Supabase.instance.client,
        _tableName = tableName,
        _tiposTableName = tiposTableName,
        _revisionesTableName = revisionesTableName,
        _itemsTableName = itemsTableName;

  final SupabaseClient _supabase;
  final String _tableName;
  final String _tiposTableName;
  final String _revisionesTableName;
  final String _itemsTableName;

  // ==========================================
  // OPERACIONES CRUD DE AMBULANCIAS
  // ==========================================

  @override
  Future<List<AmbulanciaEntity>> getAll() async {
    final response = await _supabase.from(_tableName).select();
    return (response as List)
        .map((json) => AmbulanciaSupabaseModel.fromJson(json).toEntity())
        .toList();
  }

  @override
  Future<AmbulanciaEntity?> getById(String id) async {
    final response =
        await _supabase.from(_tableName).select().eq('id', id).maybeSingle();
    if (response == null) return null;
    return AmbulanciaSupabaseModel.fromJson(response).toEntity();
  }

  @override
  Future<AmbulanciaEntity> create(AmbulanciaEntity entity) async {
    final model = AmbulanciaSupabaseModel.fromEntity(entity);
    final response =
        await _supabase.from(_tableName).insert(model.toJson()).select().single();
    return AmbulanciaSupabaseModel.fromJson(response).toEntity();
  }

  @override
  Future<AmbulanciaEntity> update(AmbulanciaEntity entity) async {
    final model = AmbulanciaSupabaseModel.fromEntity(entity);
    final response = await _supabase
        .from(_tableName)
        .update(model.toJson())
        .eq('id', entity.id)
        .select()
        .single();
    return AmbulanciaSupabaseModel.fromJson(response).toEntity();
  }

  @override
  Future<void> delete(String id) async {
    await _supabase.from(_tableName).delete().eq('id', id);
  }

  // ==========================================
  // TIPOS DE AMBULANCIA
  // ==========================================

  @override
  Future<List<TipoAmbulanciaEntity>> getTiposAmbulancia() async {
    final response = await _supabase.from(_tiposTableName).select();

    return (response as List)
        .map((json) => TipoAmbulanciaSupabaseModel.fromJson(json).toEntity())
        .toList();
  }

  @override
  Future<TipoAmbulanciaEntity?> getTipoAmbulanciaById(String id) async {
    final response =
        await _supabase.from(_tiposTableName).select().eq('id', id).maybeSingle();

    if (response == null) return null;
    return TipoAmbulanciaSupabaseModel.fromJson(response).toEntity();
  }

  @override
  Future<TipoAmbulanciaEntity?> getTipoAmbulanciaByCodigo(String codigo) async {
    final response = await _supabase
        .from(_tiposTableName)
        .select()
        .eq('codigo', codigo)
        .maybeSingle();

    if (response == null) return null;
    return TipoAmbulanciaSupabaseModel.fromJson(response).toEntity();
  }

  // ==========================================
  // AMBULANCIAS
  // ==========================================

  @override
  Future<List<AmbulanciaEntity>> searchByMatricula(String matricula) async {
    final response = await _supabase
        .from(_tableName)
        .select()
        .ilike('matricula', '%$matricula%');

    return (response as List)
        .map((json) => AmbulanciaSupabaseModel.fromJson(json).toEntity())
        .toList();
  }

  @override
  Future<List<AmbulanciaEntity>> getAmbulanciasByEstado(
      EstadoAmbulancia estado) async {
    final response = await _supabase
        .from(_tableName)
        .select()
        .eq('estado', estado.toSupabaseString());

    return (response as List)
        .map((json) => AmbulanciaSupabaseModel.fromJson(json).toEntity())
        .toList();
  }

  @override
  Future<List<AmbulanciaEntity>> getAmbulanciasByEmpresa(
    String empresaId, {
    bool incluirTipo = true,
  }) async {
    var query = _supabase.from(_tableName).select(
        incluirTipo ? '*, amb_tipos_ambulancia(*)' : '*');

    query = query.eq('empresa_id', empresaId);

    final response = await query;

    return (response as List)
        .map((json) => AmbulanciaSupabaseModel.fromJson(json).toEntity())
        .toList();
  }

  @override
  Future<AmbulanciaEntity?> getAmbulanciaWithRelations(
    String id, {
    bool incluirTipo = true,
  }) async {
    var query = _supabase.from(_tableName).select(
        incluirTipo ? '*, amb_tipos_ambulancia(*)' : '*');

    query = query.eq('id', id);

    final response = await query.maybeSingle();

    if (response == null) return null;
    return AmbulanciaSupabaseModel.fromJson(response).toEntity();
  }

  // ==========================================
  // REVISIONES
  // ==========================================

  @override
  Future<List<RevisionEntity>> getRevisionesByAmbulancia(
    String ambulanciaId, {
    EstadoRevision? estado,
    bool incluirItems = false,
  }) async {
    final selectQuery = incluirItems
        ? '*, amb_ambulancias(*), amb_items_revision(*)'
        : '*, amb_ambulancias(*)';

    dynamic query = _supabase.from(_revisionesTableName).select(selectQuery);

    query = query.eq('ambulancia_id', ambulanciaId);

    if (estado != null) {
      query = query.eq('estado', estado.toSupabaseString());
    }

    query = query.order('fecha_programada', ascending: false);

    final response = await query;

    return (response as List)
        .map((json) => RevisionSupabaseModel.fromJson(json).toEntity())
        .toList();
  }

  @override
  Future<RevisionEntity?> getRevisionWithRelations(
    String id, {
    bool incluirAmbulancia = true,
    bool incluirItems = true,
  }) async {
    String selectQuery = '*';
    if (incluirAmbulancia) {
      selectQuery += ', amb_ambulancias(*, amb_tipos_ambulancia(*))';
    }
    if (incluirItems) {
      selectQuery += ', amb_items_revision(*)';
    }

    final response = await _supabase
        .from(_revisionesTableName)
        .select(selectQuery)
        .eq('id', id)
        .maybeSingle();

    if (response == null) return null;
    return RevisionSupabaseModel.fromJson(response).toEntity();
  }

  @override
  Future<RevisionEntity> createRevision(RevisionEntity revision) async {
    final data = RevisionSupabaseModel.fromEntity(revision).toJson();
    final response =
        await _supabase.from(_revisionesTableName).insert(data).select().single();

    return RevisionSupabaseModel.fromJson(response).toEntity();
  }

  @override
  Future<RevisionEntity> updateRevision(RevisionEntity revision) async {
    final data = RevisionSupabaseModel.fromEntity(revision).toJson();
    final response = await _supabase
        .from(_revisionesTableName)
        .update(data)
        .eq('id', revision.id)
        .select()
        .single();

    return RevisionSupabaseModel.fromJson(response).toEntity();
  }

  @override
  Future<RevisionEntity> completarRevision(
    String revisionId, {
    String? observaciones,
  }) async {
    final updateData = <String, dynamic>{
      'estado': EstadoRevision.completada.toSupabaseString(),
      'fecha_realizada': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    };

    if (observaciones != null) {
      updateData['observaciones'] = observaciones;
    }

    final response = await _supabase
        .from(_revisionesTableName)
        .update(updateData)
        .eq('id', revisionId)
        .select(
            '*, amb_ambulancias(*, amb_tipos_ambulancia(*)), amb_items_revision(*)')
        .single();

    return RevisionSupabaseModel.fromJson(response).toEntity();
  }

  @override
  Future<List<RevisionEntity>> getRevisionesPendientes(
      String ambulanciaId) async {
    final response = await _supabase
        .from(_revisionesTableName)
        .select('*, amb_ambulancias(*), amb_items_revision(*)')
        .eq('ambulancia_id', ambulanciaId)
        .inFilter('estado', [
          EstadoRevision.pendiente.toSupabaseString(),
          EstadoRevision.enProgreso.toSupabaseString(),
        ])
        .order('fecha_programada', ascending: true);

    return (response as List)
        .map((json) => RevisionSupabaseModel.fromJson(json).toEntity())
        .toList();
  }

  // ==========================================
  // ITEMS DE REVISIÓN
  // ==========================================

  @override
  Future<List<ItemRevisionEntity>> getItemsByRevision(String revisionId) async {
    final response = await _supabase
        .from(_itemsTableName)
        .select()
        .eq('revision_id', revisionId)
        .order('created_at', ascending: true);

    return (response as List)
        .map((json) => ItemRevisionSupabaseModel.fromJson(json).toEntity())
        .toList();
  }

  @override
  Future<ItemRevisionEntity?> getItemRevisionById(String id) async {
    final response =
        await _supabase.from(_itemsTableName).select().eq('id', id).maybeSingle();

    if (response == null) return null;
    return ItemRevisionSupabaseModel.fromJson(response).toEntity();
  }

  @override
  Future<ItemRevisionEntity> updateItemRevision(ItemRevisionEntity item) async {
    final data = ItemRevisionSupabaseModel.fromEntity(item).toJson();
    final response = await _supabase
        .from(_itemsTableName)
        .update(data)
        .eq('id', item.id)
        .select()
        .single();

    return ItemRevisionSupabaseModel.fromJson(response).toEntity();
  }

  @override
  Future<List<ItemRevisionEntity>> updateItemsRevisionBatch(
    List<ItemRevisionEntity> items,
  ) async {
    final dataList =
        items.map((item) => ItemRevisionSupabaseModel.fromEntity(item).toJson()).toList();

    final response =
        await _supabase.from(_itemsTableName).upsert(dataList).select();

    return (response as List)
        .map((json) => ItemRevisionSupabaseModel.fromJson(json).toEntity())
        .toList();
  }

  @override
  Future<ItemRevisionEntity> marcarItemComoVerificado(
    String itemId, {
    required bool conforme,
    int? cantidadEncontrada,
    String? observaciones,
    DateTime? fechaCaducidad,
    String? verificadoPor,
  }) async {
    final updateData = <String, dynamic>{
      'verificado': true,
      'conforme': conforme,
      'verificado_en': DateTime.now().toIso8601String(),
    };

    if (cantidadEncontrada != null) {
      updateData['cantidad_encontrada'] = cantidadEncontrada;
    }
    if (observaciones != null) {
      updateData['observaciones'] = observaciones;
    }
    if (fechaCaducidad != null) {
      updateData['fecha_caducidad'] = fechaCaducidad.toIso8601String();
      updateData['caducado'] = fechaCaducidad.isBefore(DateTime.now());
    }
    if (verificadoPor != null) {
      updateData['verificado_por'] = verificadoPor;
    }
    if (!conforme) {
      updateData['requiere_reposicion'] = true;
    }

    final response = await _supabase
        .from(_itemsTableName)
        .update(updateData)
        .eq('id', itemId)
        .select()
        .single();

    return ItemRevisionSupabaseModel.fromJson(response).toEntity();
  }

  // ==========================================
  // GENERACIÓN AUTOMÁTICA
  // ==========================================

  @override
  Future<void> generarRevisionesMes(
    String ambulanciaId,
    int mes,
    int anio,
  ) async {
    await _supabase.rpc('generar_revisiones_mes', params: {
      'p_ambulancia_id': ambulanciaId,
      'p_mes': mes,
      'p_anio': anio,
    });
  }

  @override
  Future<void> generarItemsRevision(String revisionId) async {
    await _supabase.rpc('generar_items_revision', params: {
      'p_revision_id': revisionId,
    });
  }
}
