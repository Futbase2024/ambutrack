import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../almacen_contract.dart';
import '../../entities/almacen_entity.dart';
import '../../models/almacen_supabase_model.dart';

/// Implementación de AlmacenDataSource usando Supabase
class SupabaseAlmacenDataSource implements AlmacenDataSource {
  SupabaseAlmacenDataSource(this._supabase);

  final SupabaseClient _supabase;
  static const String _tableName = 'almacenes';

  @override
  Future<List<AlmacenEntity>> getAll() async {
    try {
      debugPrint('📦 Almacén DS: Obteniendo todos los almacenes...');

      final List<dynamic> data = await _supabase
          .from(_tableName)
          .select()
          .eq('activo', true)
          .order('nombre', ascending: true);

      final List<AlmacenEntity> almacenes = data
          .map((json) =>
              AlmacenSupabaseModel.fromJson(json as Map<String, dynamic>)
                  .toEntity())
          .toList();

      debugPrint('📦 Almacén DS: ✅ ${almacenes.length} almacenes obtenidos');
      return almacenes;
    } catch (e) {
      debugPrint('📦 Almacén DS: ❌ Error al obtener almacenes: $e');
      rethrow;
    }
  }

  @override
  Future<AlmacenEntity?> getById(String id) async {
    try {
      debugPrint('📦 Almacén DS: Obteniendo almacén con ID: $id');

      final Map<String, dynamic>? data =
          await _supabase.from(_tableName).select().eq('id', id).maybeSingle();

      if (data == null) {
        debugPrint('📦 Almacén DS: ⚠️ Almacén no encontrado');
        return null;
      }

      final AlmacenEntity almacen =
          AlmacenSupabaseModel.fromJson(data).toEntity();

      debugPrint('📦 Almacén DS: ✅ Almacén obtenido: ${almacen.nombre}');
      return almacen;
    } catch (e) {
      debugPrint('📦 Almacén DS: ❌ Error al obtener almacén: $e');
      rethrow;
    }
  }

  @override
  Future<AlmacenEntity?> getBaseCentral() async {
    try {
      debugPrint('📦 Almacén DS: Obteniendo Base Central...');

      final Map<String, dynamic>? data = await _supabase
          .from(_tableName)
          .select()
          .eq('tipo', 'BASE_CENTRAL')
          .eq('activo', true)
          .maybeSingle();

      if (data == null) {
        debugPrint('📦 Almacén DS: ⚠️ Base Central no encontrada');
        return null;
      }

      final AlmacenEntity baseCentral =
          AlmacenSupabaseModel.fromJson(data).toEntity();

      debugPrint(
          '📦 Almacén DS: ✅ Base Central obtenida: ${baseCentral.nombre}');
      return baseCentral;
    } catch (e) {
      debugPrint('📦 Almacén DS: ❌ Error al obtener Base Central: $e');
      rethrow;
    }
  }

  @override
  Future<List<AlmacenEntity>> getAlmacenesVehiculos() async {
    try {
      debugPrint('📦 Almacén DS: Obteniendo almacenes de vehículos...');

      final List<dynamic> data = await _supabase
          .from(_tableName)
          .select()
          .eq('tipo', 'VEHICULO')
          .eq('activo', true)
          .order('nombre', ascending: true);

      final List<AlmacenEntity> almacenes = data
          .map((json) =>
              AlmacenSupabaseModel.fromJson(json as Map<String, dynamic>)
                  .toEntity())
          .toList();

      debugPrint(
          '📦 Almacén DS: ✅ ${almacenes.length} almacenes de vehículos obtenidos');
      return almacenes;
    } catch (e) {
      debugPrint(
          '📦 Almacén DS: ❌ Error al obtener almacenes de vehículos: $e');
      rethrow;
    }
  }

  @override
  Future<AlmacenEntity?> getByVehiculoId(String idVehiculo) async {
    try {
      debugPrint(
          '📦 Almacén DS: Obteniendo almacén del vehículo: $idVehiculo');

      final Map<String, dynamic>? data = await _supabase
          .from(_tableName)
          .select()
          .eq('id_vehiculo', idVehiculo)
          .eq('activo', true)
          .maybeSingle();

      if (data == null) {
        debugPrint('📦 Almacén DS: ⚠️ Almacén del vehículo no encontrado');
        return null;
      }

      final AlmacenEntity almacen =
          AlmacenSupabaseModel.fromJson(data).toEntity();

      debugPrint('📦 Almacén DS: ✅ Almacén del vehículo obtenido');
      return almacen;
    } catch (e) {
      debugPrint(
          '📦 Almacén DS: ❌ Error al obtener almacén del vehículo: $e');
      rethrow;
    }
  }

  @override
  Future<AlmacenEntity> create(AlmacenEntity almacen) async {
    try {
      debugPrint('📦 Almacén DS: Creando almacén: ${almacen.nombre}');

      final AlmacenSupabaseModel model =
          AlmacenSupabaseModel.fromEntity(almacen);
      final Map<String, dynamic> data =
          await _supabase.from(_tableName).insert(model.toJson()).select().single();

      final AlmacenEntity createdAlmacen =
          AlmacenSupabaseModel.fromJson(data).toEntity();

      debugPrint('📦 Almacén DS: ✅ Almacén creado: ${createdAlmacen.nombre}');
      return createdAlmacen;
    } catch (e) {
      debugPrint('📦 Almacén DS: ❌ Error al crear almacén: $e');
      rethrow;
    }
  }

  @override
  Future<AlmacenEntity> update(AlmacenEntity almacen) async {
    try {
      debugPrint('📦 Almacén DS: Actualizando almacén: ${almacen.nombre}');

      final AlmacenSupabaseModel model =
          AlmacenSupabaseModel.fromEntity(almacen);
      final Map<String, dynamic> data = await _supabase
          .from(_tableName)
          .update(model.toJson())
          .eq('id', almacen.id)
          .select()
          .single();

      final AlmacenEntity updatedAlmacen =
          AlmacenSupabaseModel.fromJson(data).toEntity();

      debugPrint(
          '📦 Almacén DS: ✅ Almacén actualizado: ${updatedAlmacen.nombre}');
      return updatedAlmacen;
    } catch (e) {
      debugPrint('📦 Almacén DS: ❌ Error al actualizar almacén: $e');
      rethrow;
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      debugPrint('📦 Almacén DS: Eliminando almacén (soft delete): $id');

      await _supabase
          .from(_tableName)
          .update({'activo': false}).eq('id', id);

      debugPrint('📦 Almacén DS: ✅ Almacén eliminado');
    } catch (e) {
      debugPrint('📦 Almacén DS: ❌ Error al eliminar almacén: $e');
      rethrow;
    }
  }

  @override
  Stream<List<AlmacenEntity>> watchAll() {
    debugPrint('📦 Almacén DS: Observando cambios en almacenes...');

    return _supabase
        .from(_tableName)
        .stream(primaryKey: ['id'])
        .eq('activo', true)
        .order('nombre', ascending: true)
        .map((data) => data
            .map((json) =>
                AlmacenSupabaseModel.fromJson(json).toEntity())
            .toList());
  }

  @override
  Stream<AlmacenEntity?> watchById(String id) {
    debugPrint('📦 Almacén DS: Observando cambios en almacén: $id');

    return _supabase
        .from(_tableName)
        .stream(primaryKey: ['id'])
        .eq('id', id)
        .map((data) {
          if (data.isEmpty) return null;
          return AlmacenSupabaseModel.fromJson(data.first).toEntity();
        });
  }
}
