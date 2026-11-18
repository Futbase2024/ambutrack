import 'package:supabase_flutter/supabase_flutter.dart';

import '../../entities/protocolo_normativa_entity.dart';
import '../../models/protocolo_normativa_supabase_model.dart';
import '../../protocolos_normativas_contract.dart';

/// Implementación Supabase del datasource de Protocolos y Normativas
class SupabaseProtocolosNormativasDataSource implements ProtocolosNormativasDataSource {
  SupabaseProtocolosNormativasDataSource({
    SupabaseClient? supabase,
    String tableName = 'tprotocolos_normativas',
  })  : _supabase = supabase ?? Supabase.instance.client,
        _table = tableName;

  final SupabaseClient _supabase;
  final String _table;

  ProtocoloNormativaEntity _toEntity(Map<String, dynamic> json) =>
      ProtocoloNormativaSupabaseModel.fromJson(json).toEntity();

  List<ProtocoloNormativaEntity> _toList(List<Map<String, dynamic>> rows) =>
      rows.map(_toEntity).toList();

  @override
  Future<List<ProtocoloNormativaEntity>> getAll() async {
    try {
      final List<Map<String, dynamic>> response =
          await _supabase.from(_table).select().order('titulo', ascending: true);
      return _toList(response);
    } catch (e) {
      throw Exception('Error al obtener protocolos y normativas: $e');
    }
  }

  @override
  Future<ProtocoloNormativaEntity?> getById(String id) async {
    try {
      final Map<String, dynamic>? response =
          await _supabase.from(_table).select().eq('id', id).maybeSingle();
      return response == null ? null : _toEntity(response);
    } catch (e) {
      throw Exception('Error al obtener protocolo por ID: $e');
    }
  }

  @override
  Future<List<ProtocoloNormativaEntity>> getActivos() async {
    try {
      final List<Map<String, dynamic>> response = await _supabase
          .from(_table)
          .select()
          .eq('activo', true)
          .order('titulo', ascending: true);
      return _toList(response);
    } catch (e) {
      throw Exception('Error al obtener protocolos activos: $e');
    }
  }

  @override
  Future<ProtocoloNormativaEntity> create(ProtocoloNormativaEntity entity) async {
    try {
      final Map<String, dynamic> response = await _supabase
          .from(_table)
          .insert(ProtocoloNormativaSupabaseModel.fromEntity(entity).toJson())
          .select()
          .single();
      return _toEntity(response);
    } catch (e) {
      throw Exception('Error al crear protocolo: $e');
    }
  }

  @override
  Future<ProtocoloNormativaEntity> update(ProtocoloNormativaEntity entity) async {
    try {
      final Map<String, dynamic> json = ProtocoloNormativaSupabaseModel.fromEntity(entity).toJson()
        ..remove('id');
      final Map<String, dynamic> response =
          await _supabase.from(_table).update(json).eq('id', entity.id).select().single();
      return _toEntity(response);
    } catch (e) {
      throw Exception('Error al actualizar protocolo: $e');
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      await _supabase.from(_table).delete().eq('id', id);
    } catch (e) {
      throw Exception('Error al eliminar protocolo: $e');
    }
  }
}
