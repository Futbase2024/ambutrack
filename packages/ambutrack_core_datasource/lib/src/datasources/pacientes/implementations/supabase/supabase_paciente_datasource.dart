import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../entities/paciente_entity.dart';
import '../../models/paciente_supabase_model.dart';
import '../../paciente_contract.dart';

/// Implementación del DataSource de Pacientes usando Supabase
class SupabasePacienteDataSource implements PacienteDataSource {
  SupabasePacienteDataSource(this._supabase);

  final SupabaseClient _supabase;
  static const String _tableName = 'pacientes';

  @override
  Future<List<PacienteEntity>> getAll() async {
    try {
      debugPrint('📦 SupabasePacienteDataSource: Obteniendo todos los pacientes activos...');

      final response = await _supabase
          .from(_tableName)
          .select()
          .eq('activo', true)
          .order('created_at', ascending: false);

      debugPrint('📦 SupabasePacienteDataSource: ✅ ${response.length} pacientes obtenidos');

      return (response as List)
          .map((json) => PacienteSupabaseModel.fromJson(json as Map<String, dynamic>).toEntity())
          .toList();
    } catch (e) {
      debugPrint('📦 SupabasePacienteDataSource: ❌ Error al obtener pacientes: $e');
      rethrow;
    }
  }

  @override
  Future<PacienteEntity> getById(String id) async {
    try {
      debugPrint('📦 SupabasePacienteDataSource: Obteniendo paciente con ID: $id');

      final response = await _supabase.from(_tableName).select().eq('id', id).single();

      debugPrint('📦 SupabasePacienteDataSource: ✅ Paciente obtenido');

      return PacienteSupabaseModel.fromJson(response).toEntity();
    } catch (e) {
      debugPrint('📦 SupabasePacienteDataSource: ❌ Error al obtener paciente: $e');
      rethrow;
    }
  }

  @override
  Future<List<PacienteEntity>> search(String query) async {
    try {
      debugPrint('📦 SupabasePacienteDataSource: Buscando pacientes con query: "$query"');

      if (query.isEmpty) {
        return await getAll();
      }

      // Búsqueda por nombre, apellidos, documento o identificación
      final response = await _supabase.from(_tableName).select().or(
            'nombre.ilike.%$query%,'
            'primer_apellido.ilike.%$query%,'
            'segundo_apellido.ilike.%$query%,'
            'documento.ilike.%$query%,'
            'identificacion.ilike.%$query%',
          ).eq('activo', true).order('created_at', ascending: false);

      debugPrint('📦 SupabasePacienteDataSource: ✅ ${response.length} pacientes encontrados');

      return (response as List)
          .map((json) => PacienteSupabaseModel.fromJson(json as Map<String, dynamic>).toEntity())
          .toList();
    } catch (e) {
      debugPrint('📦 SupabasePacienteDataSource: ❌ Error en búsqueda: $e');
      rethrow;
    }
  }

  @override
  Future<PacienteEntity> create(PacienteEntity paciente) async {
    try {
      debugPrint('📦 SupabasePacienteDataSource: Creando paciente: ${paciente.nombreCompleto}');

      final model = PacienteSupabaseModel.fromEntity(paciente);
      final json = model.toJson();

      // Remover el ID para que Supabase lo genere automáticamente
      json.remove('id');
      json.remove('created_at');
      json.remove('updated_at');

      final response = await _supabase.from(_tableName).insert(json).select().single();

      debugPrint('📦 SupabasePacienteDataSource: ✅ Paciente creado exitosamente');

      return PacienteSupabaseModel.fromJson(response).toEntity();
    } catch (e) {
      debugPrint('📦 SupabasePacienteDataSource: ❌ Error al crear paciente: $e');
      rethrow;
    }
  }

  @override
  Future<PacienteEntity> update(PacienteEntity paciente) async {
    try {
      debugPrint(
          '📦 SupabasePacienteDataSource: Actualizando paciente: ${paciente.nombreCompleto}');

      final model = PacienteSupabaseModel.fromEntity(paciente);
      final json = model.toJson();

      // Remover campos de auditoría que no se deben actualizar manualmente
      json.remove('created_at');
      json.remove('created_by');
      json.remove('updated_at'); // Trigger lo actualiza automáticamente

      final response =
          await _supabase.from(_tableName).update(json).eq('id', paciente.id).select().single();

      debugPrint('📦 SupabasePacienteDataSource: ✅ Paciente actualizado exitosamente');

      return PacienteSupabaseModel.fromJson(response).toEntity();
    } catch (e) {
      debugPrint('📦 SupabasePacienteDataSource: ❌ Error al actualizar paciente: $e');
      rethrow;
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      debugPrint('📦 SupabasePacienteDataSource: Eliminando (soft delete) paciente con ID: $id');

      await _supabase.from(_tableName).update({'activo': false}).eq('id', id);

      debugPrint('📦 SupabasePacienteDataSource: ✅ Paciente desactivado exitosamente');
    } catch (e) {
      debugPrint('📦 SupabasePacienteDataSource: ❌ Error al eliminar paciente: $e');
      rethrow;
    }
  }

  @override
  Future<void> hardDelete(String id) async {
    try {
      debugPrint('📦 SupabasePacienteDataSource: Eliminando permanentemente paciente ID: $id');

      await _supabase.from(_tableName).delete().eq('id', id);

      debugPrint('📦 SupabasePacienteDataSource: ✅ Paciente eliminado permanentemente');
    } catch (e) {
      debugPrint('📦 SupabasePacienteDataSource: ❌ Error al eliminar permanentemente: $e');
      rethrow;
    }
  }

  @override
  Stream<List<PacienteEntity>> watchAll() {
    debugPrint('📦 SupabasePacienteDataSource: Iniciando stream de pacientes...');

    return _supabase
        .from(_tableName)
        .stream(primaryKey: ['id'])
        .eq('activo', true)
        .order('created_at', ascending: false)
        .map((data) {
          debugPrint('📦 SupabasePacienteDataSource: 🔄 Stream actualizó ${data.length} pacientes');
          return data
              .map((json) => PacienteSupabaseModel.fromJson(json).toEntity())
              .toList();
        });
  }

  @override
  Stream<PacienteEntity?> watchById(String id) {
    debugPrint('📦 SupabasePacienteDataSource: Iniciando stream del paciente ID: $id');

    return _supabase
        .from(_tableName)
        .stream(primaryKey: ['id'])
        .eq('id', id)
        .map((data) {
          debugPrint('📦 SupabasePacienteDataSource: 🔄 Stream actualizó paciente');
          if (data.isEmpty) return null;
          return PacienteSupabaseModel.fromJson(data.first).toEntity();
        });
  }
}
