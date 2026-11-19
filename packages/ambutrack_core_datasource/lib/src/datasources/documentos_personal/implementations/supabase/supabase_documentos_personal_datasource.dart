import 'package:supabase_flutter/supabase_flutter.dart';

import '../../documentos_personal_contract.dart';
import '../../entities/documento_personal_entity.dart';
import '../../models/documento_personal_supabase_model.dart';

/// Implementación Supabase del datasource de Documentación del Personal
class SupabaseDocumentosPersonalDataSource implements DocumentosPersonalDataSource {
  SupabaseDocumentosPersonalDataSource({
    SupabaseClient? supabase,
    String tableName = 'tdocumentos_personal',
  })  : _supabase = supabase ?? Supabase.instance.client,
        _table = tableName;

  final SupabaseClient _supabase;
  final String _table;

  static const String _select = DocumentoPersonalSupabaseModel.selectWithJoins;

  DocumentoPersonalEntity _toEntity(Map<String, dynamic> json) =>
      DocumentoPersonalSupabaseModel.fromJson(json).toEntity();

  List<DocumentoPersonalEntity> _toList(List<Map<String, dynamic>> rows) =>
      rows.map(_toEntity).toList();

  @override
  Future<List<DocumentoPersonalEntity>> getAll() async {
    try {
      final List<Map<String, dynamic>> response = await _supabase
          .from(_table)
          .select(_select)
          .order('fecha_caducidad', ascending: true, nullsFirst: false);
      return _toList(response);
    } catch (e) {
      throw Exception('Error al obtener documentos del personal: $e');
    }
  }

  @override
  Future<DocumentoPersonalEntity?> getById(String id) async {
    try {
      final Map<String, dynamic>? response =
          await _supabase.from(_table).select(_select).eq('id', id).maybeSingle();
      return response == null ? null : _toEntity(response);
    } catch (e) {
      throw Exception('Error al obtener documento por ID: $e');
    }
  }

  @override
  Future<List<DocumentoPersonalEntity>> getByPersonal(String personalId) async {
    try {
      final List<Map<String, dynamic>> response = await _supabase
          .from(_table)
          .select(_select)
          .eq('personal_id', personalId)
          .order('fecha_caducidad', ascending: true, nullsFirst: false);
      return _toList(response);
    } catch (e) {
      throw Exception('Error al obtener documentos del trabajador: $e');
    }
  }

  @override
  Future<DocumentoPersonalEntity> create(DocumentoPersonalEntity entity) async {
    try {
      final Map<String, dynamic> response = await _supabase
          .from(_table)
          .insert(DocumentoPersonalSupabaseModel.fromEntity(entity).toJson())
          .select(_select)
          .single();
      return _toEntity(response);
    } catch (e) {
      throw Exception('Error al crear documento: $e');
    }
  }

  @override
  Future<DocumentoPersonalEntity> update(DocumentoPersonalEntity entity) async {
    try {
      final Map<String, dynamic> json = DocumentoPersonalSupabaseModel.fromEntity(entity).toJson()
        ..remove('id');
      final Map<String, dynamic> response =
          await _supabase.from(_table).update(json).eq('id', entity.id).select(_select).single();
      return _toEntity(response);
    } catch (e) {
      throw Exception('Error al actualizar documento: $e');
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      await _supabase.from(_table).delete().eq('id', id);
    } catch (e) {
      throw Exception('Error al eliminar documento: $e');
    }
  }
}
