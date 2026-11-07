import 'package:supabase_flutter/supabase_flutter.dart';

import '../../tpersonal_contract.dart';
import '../../entities/tpersonal_entity.dart';
import '../../models/tpersonal_supabase_model.dart';

/// Implementación de Supabase para el datasource de tpersonal
class SupabaseTPersonalDataSource implements TPersonalDataSource {
  SupabaseTPersonalDataSource({
    SupabaseClient? supabase,
    String tableName = 'tpersonal',
  })  : _supabase = supabase ?? Supabase.instance.client,
        _tableName = tableName;

  final SupabaseClient _supabase;
  final String _tableName;

  @override
  Future<TPersonalEntity?> getById(String id) async {
    try {
      final response = await _supabase
          .from(_tableName)
          .select()
          .eq('id', id)
          .maybeSingle();

      if (response == null) return null;
      return TPersonalSupabaseModel.fromJson(response).toEntity();
    } catch (e) {
      throw Exception('Error al obtener personal por ID: $e');
    }
  }

  @override
  Future<TPersonalEntity?> getByUsuarioId(String usuarioId) async {
    try {
      final response = await _supabase
          .from(_tableName)
          .select()
          .eq('usuario_id', usuarioId)
          .maybeSingle();

      if (response == null) return null;
      return TPersonalSupabaseModel.fromJson(response).toEntity();
    } catch (e) {
      throw Exception('Error al obtener personal por usuario_id: $e');
    }
  }

  @override
  Future<List<TPersonalEntity>> getAll() async {
    try {
      final response = await _supabase
          .from(_tableName)
          .select()
          .order('nombre', ascending: true);

      return (response as List)
          .map((json) => TPersonalSupabaseModel.fromJson(json).toEntity())
          .toList();
    } catch (e) {
      throw Exception('Error al obtener todos los registros de personal: $e');
    }
  }

  @override
  Future<List<TPersonalEntity>> getActivos() async {
    try {
      final response = await _supabase
          .from(_tableName)
          .select()
          .eq('activo', true)
          .order('nombre', ascending: true);

      return (response as List)
          .map((json) => TPersonalSupabaseModel.fromJson(json).toEntity())
          .toList();
    } catch (e) {
      throw Exception('Error al obtener personal activo: $e');
    }
  }

  @override
  Future<TPersonalEntity?> getByDni(String dni) async {
    try {
      final response = await _supabase
          .from(_tableName)
          .select()
          .ilike('dni', dni)
          .maybeSingle();

      if (response == null) return null;
      return TPersonalSupabaseModel.fromJson(response).toEntity();
    } catch (e) {
      throw Exception('Error al buscar personal por DNI: $e');
    }
  }

  @override
  Future<TPersonalEntity?> getByEmail(String email) async {
    try {
      final response = await _supabase
          .from(_tableName)
          .select()
          .ilike('email', email)
          .maybeSingle();

      if (response == null) return null;
      return TPersonalSupabaseModel.fromJson(response).toEntity();
    } catch (e) {
      throw Exception('Error al buscar personal por email: $e');
    }
  }
}
