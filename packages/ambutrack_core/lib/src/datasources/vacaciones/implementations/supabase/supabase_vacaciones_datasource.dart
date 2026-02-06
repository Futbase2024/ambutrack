import 'package:ambutrack_core/src/datasources/vacaciones/entities/vacaciones_entity.dart';
import 'package:ambutrack_core/src/datasources/vacaciones/models/vacaciones_supabase_model.dart';
import 'package:ambutrack_core/src/datasources/vacaciones/vacaciones_contract.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Implementación del datasource de Vacaciones usando Supabase
class SupabaseVacacionesDataSource implements VacacionesDataSource {
  SupabaseVacacionesDataSource(this._supabase);

  final SupabaseClient _supabase;
  static const String _tableName = 'vacaciones';

  @override
  Future<List<VacacionesEntity>> getAll() async {
    final response = await _supabase
        .from(_tableName)
        .select()
        .eq('activo', true)
        .order('fecha_inicio', ascending: false);

    return (response as List)
        .map((json) => VacacionesSupabaseModel.fromJson(json).toEntity())
        .toList();
  }

  @override
  Future<VacacionesEntity> getById(String id) async {
    final response = await _supabase
        .from(_tableName)
        .select()
        .eq('id', id)
        .single();

    return VacacionesSupabaseModel.fromJson(response).toEntity();
  }

  @override
  Future<List<VacacionesEntity>> getByPersonalId(String idPersonal) async {
    final response = await _supabase
        .from(_tableName)
        .select()
        .eq('id_personal', idPersonal)
        .eq('activo', true)
        .order('fecha_inicio', ascending: false);

    return (response as List)
        .map((json) => VacacionesSupabaseModel.fromJson(json).toEntity())
        .toList();
  }

  @override
  Future<VacacionesEntity> create(VacacionesEntity entity) async {
    final model = VacacionesSupabaseModel.fromEntity(entity);
    final json = model.toJson();
    final now = DateTime.now().toIso8601String();

    // Eliminar id para que Supabase lo genere automáticamente (UUID por defecto)
    json.remove('id');

    // Establecer fecha de solicitud si no existe
    if (json['fecha_solicitud'] == null) {
      json['fecha_solicitud'] = now;
    }

    // Establecer created_at y updated_at (obligatorios en base de datos)
    json['created_at'] = now;
    json['updated_at'] = now;

    final response = await _supabase
        .from(_tableName)
        .insert(json)
        .select()
        .single();

    return VacacionesSupabaseModel.fromJson(response).toEntity();
  }

  @override
  Future<VacacionesEntity> update(VacacionesEntity entity) async {
    final model = VacacionesSupabaseModel.fromEntity(entity);
    final json = model.toJson();

    json['updated_at'] = DateTime.now().toIso8601String();

    final response = await _supabase
        .from(_tableName)
        .update(json)
        .eq('id', entity.id)
        .select()
        .single();

    return VacacionesSupabaseModel.fromJson(response).toEntity();
  }

  @override
  Future<void> delete(String id) async {
    await _supabase
        .from(_tableName)
        .update({'activo': false, 'updated_at': DateTime.now().toIso8601String()})
        .eq('id', id);
  }

  @override
  Stream<List<VacacionesEntity>> watchAll() {
    return _supabase
        .from(_tableName)
        .stream(primaryKey: ['id'])
        .order('fecha_inicio')
        .map((data) => (data as List)
            .where((json) => json['activo'] == true)
            .map((json) => VacacionesSupabaseModel.fromJson(json as Map<String, dynamic>).toEntity())
            .toList());
  }

  @override
  Stream<List<VacacionesEntity>> watchByPersonalId(String idPersonal) {
    return _supabase
        .from(_tableName)
        .stream(primaryKey: ['id'])
        .eq('id_personal', idPersonal)
        .order('fecha_inicio')
        .map((data) => (data as List)
            .where((json) => json['activo'] == true)
            .map((json) => VacacionesSupabaseModel.fromJson(json as Map<String, dynamic>).toEntity())
            .toList());
  }
}
