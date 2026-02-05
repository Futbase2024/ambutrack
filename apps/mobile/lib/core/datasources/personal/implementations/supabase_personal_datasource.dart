import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../entities/personal_entity.dart';
import '../models/personal_supabase_model.dart';
import '../personal_datasource_contract.dart';

/// Implementación del datasource de personal usando Supabase
class SupabasePersonalDataSource implements PersonalDataSource {
  SupabasePersonalDataSource(this._client);

  final SupabaseClient _client;

  @override
  Future<PersonalEntity?> getByUsuarioId(String usuarioId) async {
    try {
      debugPrint('🔍 [Personal] Buscando personal por usuario_id: $usuarioId');

      final response = await _client
          .from('tpersonal')
          .select()
          .eq('usuario_id', usuarioId)
          .maybeSingle();

      if (response == null) {
        debugPrint('⚠️ [Personal] No se encontró personal para usuario_id: $usuarioId');
        return null;
      }

      debugPrint('✅ [Personal] Personal encontrado: ${response['nombre']} ${response['apellidos']}');

      final model = PersonalSupabaseModel.fromJson(response);
      return model.toEntity();
    } catch (e) {
      debugPrint('❌ [Personal] Error al buscar personal por usuario_id: $e');
      return null;
    }
  }

  @override
  Future<PersonalEntity?> getById(String id) async {
    try {
      debugPrint('🔍 [Personal] Buscando personal por ID: $id');

      final response = await _client
          .from('tpersonal')
          .select()
          .eq('id', id)
          .maybeSingle();

      if (response == null) {
        debugPrint('⚠️ [Personal] No se encontró personal con ID: $id');
        return null;
      }

      debugPrint('✅ [Personal] Personal encontrado: ${response['nombre']} ${response['apellidos']}');

      final model = PersonalSupabaseModel.fromJson(response);
      return model.toEntity();
    } catch (e) {
      debugPrint('❌ [Personal] Error al buscar personal por ID: $e');
      return null;
    }
  }

  @override
  Future<List<PersonalEntity>> getAllActivos() async {
    try {
      debugPrint('📋 [Personal] Obteniendo todos los registros activos');

      final response = await _client
          .from('tpersonal')
          .select()
          .eq('activo', true)
          .order('apellidos', ascending: true);

      final personal = (response as List)
          .map((json) => PersonalSupabaseModel.fromJson(json).toEntity())
          .toList();

      debugPrint('✅ [Personal] ${personal.length} registros activos encontrados');

      return personal;
    } catch (e) {
      debugPrint('❌ [Personal] Error al obtener registros activos: $e');
      throw Exception('Error al obtener personal activo: $e');
    }
  }

  @override
  Future<List<PersonalEntity>> getAll() async {
    try {
      debugPrint('📋 [Personal] Obteniendo todos los registros');

      final response = await _client
          .from('tpersonal')
          .select()
          .order('apellidos', ascending: true);

      final personal = (response as List)
          .map((json) => PersonalSupabaseModel.fromJson(json).toEntity())
          .toList();

      debugPrint('✅ [Personal] ${personal.length} registros encontrados');

      return personal;
    } catch (e) {
      debugPrint('❌ [Personal] Error al obtener registros: $e');
      throw Exception('Error al obtener personal: $e');
    }
  }

  @override
  Future<PersonalEntity> create(PersonalEntity personal) async {
    try {
      debugPrint('➕ [Personal] Creando nuevo registro: ${personal.nombreCompleto}');

      final model = PersonalSupabaseModel.fromEntity(personal);
      final json = model.toJson();

      // Remover campos que se generan automáticamente
      json.remove('id');
      json.remove('created_at');
      json.remove('updated_at');

      final response = await _client
          .from('tpersonal')
          .insert(json)
          .select()
          .single();

      debugPrint('✅ [Personal] Registro creado exitosamente');

      final createdModel = PersonalSupabaseModel.fromJson(response);
      return createdModel.toEntity();
    } catch (e) {
      debugPrint('❌ [Personal] Error al crear registro: $e');
      throw Exception('Error al crear personal: $e');
    }
  }

  @override
  Future<PersonalEntity> update(PersonalEntity personal) async {
    try {
      debugPrint('📝 [Personal] Actualizando registro: ${personal.nombreCompleto}');

      final model = PersonalSupabaseModel.fromEntity(personal);
      final json = model.toJson();

      // Actualizar fecha de modificación
      json['updated_at'] = DateTime.now().toIso8601String();

      final response = await _client
          .from('tpersonal')
          .update(json)
          .eq('id', personal.id)
          .select()
          .single();

      debugPrint('✅ [Personal] Registro actualizado exitosamente');

      final updatedModel = PersonalSupabaseModel.fromJson(response);
      return updatedModel.toEntity();
    } catch (e) {
      debugPrint('❌ [Personal] Error al actualizar registro: $e');
      throw Exception('Error al actualizar personal: $e');
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      debugPrint('🗑️ [Personal] Marcando registro como inactivo: $id');

      await _client
          .from('tpersonal')
          .update({
            'activo': false,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', id);

      debugPrint('✅ [Personal] Registro marcado como inactivo');
    } catch (e) {
      debugPrint('❌ [Personal] Error al eliminar registro: $e');
      throw Exception('Error al eliminar personal: $e');
    }
  }
}
