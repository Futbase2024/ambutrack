import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../entities/plantilla_equipamiento_entity.dart';
import '../../entities/plantilla_equipamiento_item_entity.dart';
import '../../models/plantilla_equipamiento_item_supabase_model.dart';
import '../../models/plantilla_equipamiento_supabase_model.dart';
import '../../plantillas_equipamiento_contract.dart';

/// Implementación Supabase de [PlantillasEquipamientoDataSource]
class SupabasePlantillasEquipamientoDataSource implements PlantillasEquipamientoDataSource {
  SupabasePlantillasEquipamientoDataSource(this._client);

  final SupabaseClient _client;

  static const String _tablaPlantillas = 'plantillas_equipamiento';
  static const String _tablaItems = 'plantilla_equipamiento_items';
  static const String _selectPlantilla = '*, plantilla_equipamiento_items(count)';
  static const String _selectItem = '*, productos(nombre, codigo)';

  // ---------------------------------------------------------------- Plantillas

  @override
  Future<List<PlantillaEquipamientoEntity>> getAll() async {
    try {
      debugPrint('🧰 PlantillasEquipamiento: obteniendo plantillas...');
      final List<Map<String, dynamic>> response =
          await _client.from(_tablaPlantillas).select(_selectPlantilla).order('nombre');
      return response.map(_toPlantilla).toList();
    } catch (e) {
      debugPrint('🧰 PlantillasEquipamiento: ❌ Error getAll: $e');
      rethrow;
    }
  }

  @override
  Future<PlantillaEquipamientoEntity?> getById(String id) async {
    try {
      final Map<String, dynamic>? response = await _client
          .from(_tablaPlantillas)
          .select(_selectPlantilla)
          .eq('id', id)
          .maybeSingle();
      return response == null ? null : _toPlantilla(response);
    } catch (e) {
      debugPrint('🧰 PlantillasEquipamiento: ❌ Error getById: $e');
      rethrow;
    }
  }

  @override
  Future<PlantillaEquipamientoEntity> create(PlantillaEquipamientoEntity plantilla) async {
    try {
      debugPrint('🧰 PlantillasEquipamiento: creando "${plantilla.nombre}"...');
      final Map<String, dynamic> response = await _client
          .from(_tablaPlantillas)
          .insert(PlantillaEquipamientoSupabaseModel.fromEntity(plantilla).toWriteJson())
          .select(_selectPlantilla)
          .single();
      return _toPlantilla(response);
    } catch (e) {
      debugPrint('🧰 PlantillasEquipamiento: ❌ Error create: $e');
      rethrow;
    }
  }

  @override
  Future<PlantillaEquipamientoEntity> update(PlantillaEquipamientoEntity plantilla) async {
    try {
      debugPrint('🧰 PlantillasEquipamiento: actualizando ${plantilla.id}...');
      final Map<String, dynamic> response = await _client
          .from(_tablaPlantillas)
          .update(PlantillaEquipamientoSupabaseModel.fromEntity(plantilla).toWriteJson())
          .eq('id', plantilla.id)
          .select(_selectPlantilla)
          .single();
      return _toPlantilla(response);
    } catch (e) {
      debugPrint('🧰 PlantillasEquipamiento: ❌ Error update: $e');
      rethrow;
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      debugPrint('🧰 PlantillasEquipamiento: eliminando $id...');
      await _client.from(_tablaPlantillas).delete().eq('id', id);
    } catch (e) {
      debugPrint('🧰 PlantillasEquipamiento: ❌ Error delete: $e');
      rethrow;
    }
  }

  @override
  Future<int> reaplicar(String plantillaId) async {
    try {
      debugPrint('🧰 PlantillasEquipamiento: reaplicando $plantillaId...');
      final dynamic result = await _client.rpc(
        'rpc_aplicar_plantilla_equipamiento',
        params: <String, dynamic>{'p_plantilla_id': plantillaId},
      );
      final int lineas = result is int ? result : int.tryParse('$result') ?? 0;
      debugPrint('🧰 PlantillasEquipamiento: ✅ $lineas líneas creadas/adoptadas');
      return lineas;
    } catch (e) {
      debugPrint('🧰 PlantillasEquipamiento: ❌ Error reaplicar: $e');
      rethrow;
    }
  }

  // --------------------------------------------------------------------- Items

  @override
  Future<List<PlantillaEquipamientoItemEntity>> getItems(
    String plantillaId, {
    bool soloActivos = false,
  }) async {
    try {
      PostgrestFilterBuilder<List<Map<String, dynamic>>> query =
          _client.from(_tablaItems).select(_selectItem).eq('plantilla_id', plantillaId);
      if (soloActivos) {
        query = query.eq('activo', true);
      }
      final List<Map<String, dynamic>> response =
          await query.order('seccion_orden').order('orden');
      return response.map(_toItem).toList();
    } catch (e) {
      debugPrint('🧰 PlantillasEquipamiento: ❌ Error getItems: $e');
      rethrow;
    }
  }

  @override
  Future<PlantillaEquipamientoItemEntity> createItem(PlantillaEquipamientoItemEntity item) async {
    try {
      debugPrint('🧰 PlantillasEquipamiento: añadiendo item ${item.productoId}...');
      final Map<String, dynamic> response = await _client
          .from(_tablaItems)
          .insert(PlantillaEquipamientoItemSupabaseModel.fromEntity(item).toInsertJson())
          .select(_selectItem)
          .single();
      return _toItem(response);
    } catch (e) {
      debugPrint('🧰 PlantillasEquipamiento: ❌ Error createItem: $e');
      rethrow;
    }
  }

  @override
  Future<PlantillaEquipamientoItemEntity> updateItem(PlantillaEquipamientoItemEntity item) async {
    try {
      final Map<String, dynamic> response = await _client
          .from(_tablaItems)
          .update(PlantillaEquipamientoItemSupabaseModel.fromEntity(item).toUpdateJson())
          .eq('id', item.id)
          .select(_selectItem)
          .single();
      return _toItem(response);
    } catch (e) {
      debugPrint('🧰 PlantillasEquipamiento: ❌ Error updateItem: $e');
      rethrow;
    }
  }

  @override
  Future<void> setItemActivo(String itemId, {required bool activo}) async {
    try {
      await _client.from(_tablaItems).update(<String, dynamic>{'activo': activo}).eq('id', itemId);
    } catch (e) {
      debugPrint('🧰 PlantillasEquipamiento: ❌ Error setItemActivo: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteItem(String itemId) async {
    try {
      await _client.from(_tablaItems).delete().eq('id', itemId);
    } catch (e) {
      debugPrint('🧰 PlantillasEquipamiento: ❌ Error deleteItem: $e');
      rethrow;
    }
  }

  // ------------------------------------------------------------------ Helpers

  PlantillaEquipamientoEntity _toPlantilla(Map<String, dynamic> json) =>
      PlantillaEquipamientoSupabaseModel.fromJson(json).toEntity();

  PlantillaEquipamientoItemEntity _toItem(Map<String, dynamic> json) =>
      PlantillaEquipamientoItemSupabaseModel.fromJson(json).toEntity();
}
