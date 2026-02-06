import 'package:ambutrack_core/src/datasources/vestuario/entities/vestuario_entity.dart';
import 'package:ambutrack_core/src/datasources/vestuario/models/vestuario_supabase_model.dart';
import 'package:ambutrack_core/src/datasources/vestuario/vestuario_contract.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Implementación de VestuarioDataSource con Supabase
class SupabaseVestuarioDataSource implements VestuarioDataSource {
  SupabaseVestuarioDataSource() : _supabase = Supabase.instance.client;

  final SupabaseClient _supabase;
  static const String _tableName = 'vestuario';

  @override
  Future<List<VestuarioEntity>> getAll() async {
    debugPrint('📦 VestuarioDataSource: Obteniendo todos los registros...');
    try {
      final List<dynamic> data = await _supabase
          .from(_tableName)
          .select()
          .order('fecha_entrega', ascending: false);

      final List<VestuarioEntity> items = data
          .map((dynamic json) =>
              VestuarioSupabaseModel.fromJson(json as Map<String, dynamic>)
                  .toEntity())
          .toList();

      debugPrint('📦 VestuarioDataSource: ✅ ${items.length} registros obtenidos');
      return items;
    } catch (e) {
      debugPrint('📦 VestuarioDataSource: ❌ Error al obtener registros: $e');
      rethrow;
    }
  }

  @override
  Future<VestuarioEntity> getById(String id) async {
    debugPrint('📦 VestuarioDataSource: Obteniendo registro con ID: $id');
    try {
      final Map<String, dynamic> data = await _supabase
          .from(_tableName)
          .select()
          .eq('id', id)
          .single();

      final VestuarioEntity item =
          VestuarioSupabaseModel.fromJson(data).toEntity();

      debugPrint('📦 VestuarioDataSource: ✅ Registro obtenido: ${item.prenda}');
      return item;
    } catch (e) {
      debugPrint('📦 VestuarioDataSource: ❌ Error al obtener registro: $e');
      rethrow;
    }
  }

  @override
  Future<List<VestuarioEntity>> getByPersonalId(String personalId) async {
    debugPrint(
        '📦 VestuarioDataSource: Obteniendo vestuario del personal: $personalId');
    try {
      final List<dynamic> data = await _supabase
          .from(_tableName)
          .select()
          .eq('personal_id', personalId)
          .order('fecha_entrega', ascending: false);

      final List<VestuarioEntity> items = data
          .map((dynamic json) =>
              VestuarioSupabaseModel.fromJson(json as Map<String, dynamic>)
                  .toEntity())
          .toList();

      debugPrint('📦 VestuarioDataSource: ✅ ${items.length} items del personal');
      return items;
    } catch (e) {
      debugPrint('📦 VestuarioDataSource: ❌ Error: $e');
      rethrow;
    }
  }

  @override
  Future<List<VestuarioEntity>> getAsignado() async {
    debugPrint('📦 VestuarioDataSource: Obteniendo vestuario asignado...');
    try {
      final List<dynamic> data = await _supabase
          .from(_tableName)
          .select()
          .eq('activo', true)
          .isFilter('fecha_devolucion', null)
          .order('fecha_entrega', ascending: false);

      final List<VestuarioEntity> items = data
          .map((dynamic json) =>
              VestuarioSupabaseModel.fromJson(json as Map<String, dynamic>)
                  .toEntity())
          .toList();

      debugPrint('📦 VestuarioDataSource: ✅ ${items.length} items asignados');
      return items;
    } catch (e) {
      debugPrint('📦 VestuarioDataSource: ❌ Error: $e');
      rethrow;
    }
  }

  @override
  Future<List<VestuarioEntity>> getByPrenda(String prenda) async {
    debugPrint('📦 VestuarioDataSource: Obteniendo vestuario por prenda: $prenda');
    try {
      final List<dynamic> data = await _supabase
          .from(_tableName)
          .select()
          .eq('prenda', prenda)
          .order('fecha_entrega', ascending: false);

      final List<VestuarioEntity> items = data
          .map((dynamic json) =>
              VestuarioSupabaseModel.fromJson(json as Map<String, dynamic>)
                  .toEntity())
          .toList();

      debugPrint('📦 VestuarioDataSource: ✅ ${items.length} items de tipo $prenda');
      return items;
    } catch (e) {
      debugPrint('📦 VestuarioDataSource: ❌ Error: $e');
      rethrow;
    }
  }

  @override
  Future<VestuarioEntity> create(VestuarioEntity item) async {
    debugPrint('📦 VestuarioDataSource: Creando registro: ${item.prenda}');
    try {
      final VestuarioSupabaseModel model = VestuarioSupabaseModel.fromEntity(item);
      final Map<String, dynamic> data = await _supabase
          .from(_tableName)
          .insert(model.toJson())
          .select()
          .single();

      final VestuarioEntity created =
          VestuarioSupabaseModel.fromJson(data).toEntity();

      debugPrint('📦 VestuarioDataSource: ✅ Registro creado: ${created.id}');
      return created;
    } catch (e) {
      debugPrint('📦 VestuarioDataSource: ❌ Error al crear: $e');
      rethrow;
    }
  }

  @override
  Future<VestuarioEntity> update(VestuarioEntity item) async {
    debugPrint('📦 VestuarioDataSource: Actualizando registro: ${item.id}');
    try {
      final VestuarioSupabaseModel model = VestuarioSupabaseModel.fromEntity(item);
      final Map<String, dynamic> data = await _supabase
          .from(_tableName)
          .update(model.toJson())
          .eq('id', item.id)
          .select()
          .single();

      final VestuarioEntity updated =
          VestuarioSupabaseModel.fromJson(data).toEntity();

      debugPrint('📦 VestuarioDataSource: ✅ Registro actualizado');
      return updated;
    } catch (e) {
      debugPrint('📦 VestuarioDataSource: ❌ Error al actualizar: $e');
      rethrow;
    }
  }

  @override
  Future<void> delete(String id) async {
    debugPrint('📦 VestuarioDataSource: Eliminando registro: $id');
    try {
      await _supabase.from(_tableName).delete().eq('id', id);
      debugPrint('📦 VestuarioDataSource: ✅ Registro eliminado');
    } catch (e) {
      debugPrint('📦 VestuarioDataSource: ❌ Error al eliminar: $e');
      rethrow;
    }
  }

  @override
  Stream<List<VestuarioEntity>> watchAll() {
    debugPrint('📡 VestuarioDataSource: Iniciando stream de todos los registros');
    return _supabase
        .from(_tableName)
        .stream(primaryKey: <String>['id'])
        .order('fecha_entrega', ascending: false)
        .map((List<Map<String, dynamic>> data) {
      return data
          .map((Map<String, dynamic> json) =>
              VestuarioSupabaseModel.fromJson(json).toEntity())
          .toList();
    });
  }

  @override
  Stream<List<VestuarioEntity>> watchByPersonalId(String personalId) {
    debugPrint(
        '📡 VestuarioDataSource: Stream de vestuario del personal: $personalId');
    return _supabase
        .from(_tableName)
        .stream(primaryKey: <String>['id'])
        .eq('personal_id', personalId)
        .order('fecha_entrega', ascending: false)
        .map((List<Map<String, dynamic>> data) {
      return data
          .map((Map<String, dynamic> json) =>
              VestuarioSupabaseModel.fromJson(json).toEntity())
          .toList();
    });
  }
}
