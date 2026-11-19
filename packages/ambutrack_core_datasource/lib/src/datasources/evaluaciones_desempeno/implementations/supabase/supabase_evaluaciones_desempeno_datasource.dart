import 'package:supabase_flutter/supabase_flutter.dart';

import '../../entities/evaluacion_desempeno_entity.dart';
import '../../evaluaciones_desempeno_contract.dart';
import '../../models/evaluacion_desempeno_supabase_model.dart';

/// Implementación Supabase del datasource de Evaluaciones de Desempeño
class SupabaseEvaluacionesDesempenoDataSource implements EvaluacionesDesempenoDataSource {
  SupabaseEvaluacionesDesempenoDataSource({
    SupabaseClient? supabase,
    String tableName = 'tevaluaciones_desempeno',
  })  : _supabase = supabase ?? Supabase.instance.client,
        _table = tableName;

  final SupabaseClient _supabase;
  final String _table;

  static const String _select = EvaluacionDesempenoSupabaseModel.selectWithJoins;

  EvaluacionDesempenoEntity _toEntity(Map<String, dynamic> json) =>
      EvaluacionDesempenoSupabaseModel.fromJson(json).toEntity();

  List<EvaluacionDesempenoEntity> _toList(List<Map<String, dynamic>> rows) =>
      rows.map(_toEntity).toList();

  @override
  Future<List<EvaluacionDesempenoEntity>> getAll() async {
    try {
      final List<Map<String, dynamic>> response =
          await _supabase.from(_table).select(_select).order('fecha', ascending: false);
      return _toList(response);
    } catch (e) {
      throw Exception('Error al obtener evaluaciones de desempeño: $e');
    }
  }

  @override
  Future<EvaluacionDesempenoEntity?> getById(String id) async {
    try {
      final Map<String, dynamic>? response =
          await _supabase.from(_table).select(_select).eq('id', id).maybeSingle();
      return response == null ? null : _toEntity(response);
    } catch (e) {
      throw Exception('Error al obtener evaluación por ID: $e');
    }
  }

  @override
  Future<List<EvaluacionDesempenoEntity>> getByPersonal(String personalId) async {
    try {
      final List<Map<String, dynamic>> response = await _supabase
          .from(_table)
          .select(_select)
          .eq('personal_id', personalId)
          .order('fecha', ascending: false);
      return _toList(response);
    } catch (e) {
      throw Exception('Error al obtener evaluaciones del trabajador: $e');
    }
  }

  @override
  Future<EvaluacionDesempenoEntity> create(EvaluacionDesempenoEntity entity) async {
    try {
      final Map<String, dynamic> response = await _supabase
          .from(_table)
          .insert(EvaluacionDesempenoSupabaseModel.fromEntity(entity).toJson())
          .select(_select)
          .single();
      return _toEntity(response);
    } catch (e) {
      throw Exception('Error al crear evaluación: $e');
    }
  }

  @override
  Future<EvaluacionDesempenoEntity> update(EvaluacionDesempenoEntity entity) async {
    try {
      final Map<String, dynamic> json = EvaluacionDesempenoSupabaseModel.fromEntity(entity).toJson()
        ..remove('id');
      final Map<String, dynamic> response =
          await _supabase.from(_table).update(json).eq('id', entity.id).select(_select).single();
      return _toEntity(response);
    } catch (e) {
      throw Exception('Error al actualizar evaluación: $e');
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      await _supabase.from(_table).delete().eq('id', id);
    } catch (e) {
      throw Exception('Error al eliminar evaluación: $e');
    }
  }
}
