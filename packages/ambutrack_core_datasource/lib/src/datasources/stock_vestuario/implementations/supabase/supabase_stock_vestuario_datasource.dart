import 'package:ambutrack_core_datasource/src/datasources/stock_vestuario/entities/stock_vestuario_entity.dart';
import 'package:ambutrack_core_datasource/src/datasources/stock_vestuario/models/stock_vestuario_supabase_model.dart';
import 'package:ambutrack_core_datasource/src/datasources/stock_vestuario/stock_vestuario_contract.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Implementación Supabase del DataSource de Stock de Vestuario
class SupabaseStockVestuarioDataSource implements StockVestuarioDataSource {
  SupabaseStockVestuarioDataSource() : _supabase = Supabase.instance.client;

  final SupabaseClient _supabase;
  static const String _tableName = 'stock_vestuario';

  @override
  Future<List<StockVestuarioEntity>> getAll() async {
    debugPrint('📦 StockVestuarioDataSource: Obteniendo todos los registros...');
    try {
      final List<Map<String, dynamic>> data = await _supabase
          .from(_tableName)
          .select()
          .order('prenda', ascending: true)
          .order('talla', ascending: true);

      debugPrint('📦 StockVestuarioDataSource: ✅ ${data.length} registros obtenidos');

      return data
          .map((Map<String, dynamic> json) =>
              StockVestuarioSupabaseModel.fromJson(json).toEntity())
          .toList();
    } catch (e) {
      debugPrint('📦 StockVestuarioDataSource: ❌ Error al obtener registros: $e');
      rethrow;
    }
  }

  @override
  Future<StockVestuarioEntity> getById(String id) async {
    debugPrint('📦 StockVestuarioDataSource: Obteniendo registro $id...');
    try {
      final Map<String, dynamic> data =
          await _supabase.from(_tableName).select().eq('id', id).single();

      debugPrint('📦 StockVestuarioDataSource: ✅ Registro obtenido');
      return StockVestuarioSupabaseModel.fromJson(data).toEntity();
    } catch (e) {
      debugPrint('📦 StockVestuarioDataSource: ❌ Error al obtener: $e');
      rethrow;
    }
  }

  @override
  Future<StockVestuarioEntity> create(StockVestuarioEntity item) async {
    debugPrint('📦 StockVestuarioDataSource: Creando registro: ${item.prenda}');
    try {
      final StockVestuarioSupabaseModel model =
          StockVestuarioSupabaseModel.fromEntity(item);
      final Map<String, dynamic> json = model.toJson();

      // Remover campos calculados y auto-generados
      json.remove('id');
      json.remove('cantidad_disponible'); // Calculado automáticamente
      json.remove('created_at');
      json.remove('updated_at');

      final Map<String, dynamic> data =
          await _supabase.from(_tableName).insert(json).select().single();

      debugPrint('📦 StockVestuarioDataSource: ✅ Registro creado');
      return StockVestuarioSupabaseModel.fromJson(data).toEntity();
    } catch (e) {
      debugPrint('📦 StockVestuarioDataSource: ❌ Error al crear: $e');
      rethrow;
    }
  }

  @override
  Future<StockVestuarioEntity> update(StockVestuarioEntity item) async {
    debugPrint('📦 StockVestuarioDataSource: Actualizando registro: ${item.id}');
    try {
      final StockVestuarioSupabaseModel model =
          StockVestuarioSupabaseModel.fromEntity(item);
      final Map<String, dynamic> json = model.toJson();

      // Remover campos calculados y auto-generados
      json.remove('id');
      json.remove('cantidad_disponible'); // Calculado automáticamente
      json.remove('created_at');
      json.remove('updated_at');

      final Map<String, dynamic> data = await _supabase
          .from(_tableName)
          .update(json)
          .eq('id', item.id)
          .select()
          .single();

      debugPrint('📦 StockVestuarioDataSource: ✅ Registro actualizado');
      return StockVestuarioSupabaseModel.fromJson(data).toEntity();
    } catch (e) {
      debugPrint('📦 StockVestuarioDataSource: ❌ Error al actualizar: $e');
      rethrow;
    }
  }

  @override
  Future<void> delete(String id) async {
    debugPrint('📦 StockVestuarioDataSource: Eliminando registro: $id');
    try {
      await _supabase.from(_tableName).delete().eq('id', id);
      debugPrint('📦 StockVestuarioDataSource: ✅ Registro eliminado');
    } catch (e) {
      debugPrint('📦 StockVestuarioDataSource: ❌ Error al eliminar: $e');
      rethrow;
    }
  }

  @override
  Stream<List<StockVestuarioEntity>> watchAll() {
    debugPrint('📦 StockVestuarioDataSource: Iniciando stream...');
    return _supabase
        .from(_tableName)
        .stream(primaryKey: <String>['id'])
        .order('prenda', ascending: true)
        .order('talla', ascending: true)
        .map((List<Map<String, dynamic>> data) {
          return data
              .map((Map<String, dynamic> json) =>
                  StockVestuarioSupabaseModel.fromJson(json).toEntity())
              .toList();
        });
  }

  @override
  Future<List<StockVestuarioEntity>> getStockBajo() async {
    debugPrint('📦 StockVestuarioDataSource: Obteniendo artículos con stock bajo...');
    try {
      final List<Map<String, dynamic>> data = await _supabase
          .from(_tableName)
          .select()
          .lte('cantidad_disponible', 5) // cantidad_disponible <= stock_minimo
          .eq('activo', true)
          .order('cantidad_disponible', ascending: true);

      debugPrint('📦 StockVestuarioDataSource: ✅ ${data.length} artículos con stock bajo');

      return data
          .map((Map<String, dynamic> json) =>
              StockVestuarioSupabaseModel.fromJson(json).toEntity())
          .toList();
    } catch (e) {
      debugPrint('📦 StockVestuarioDataSource: ❌ Error: $e');
      rethrow;
    }
  }

  @override
  Future<List<StockVestuarioEntity>> getDisponibles() async {
    debugPrint('📦 StockVestuarioDataSource: Obteniendo artículos disponibles...');
    try {
      final List<Map<String, dynamic>> data = await _supabase
          .from(_tableName)
          .select()
          .gt('cantidad_disponible', 0)
          .eq('activo', true)
          .order('prenda', ascending: true)
          .order('talla', ascending: true);

      debugPrint('📦 StockVestuarioDataSource: ✅ ${data.length} artículos disponibles');

      return data
          .map((Map<String, dynamic> json) =>
              StockVestuarioSupabaseModel.fromJson(json).toEntity())
          .toList();
    } catch (e) {
      debugPrint('📦 StockVestuarioDataSource: ❌ Error: $e');
      rethrow;
    }
  }

  @override
  Future<void> incrementarAsignada(String id, int cantidad) async {
    debugPrint('📦 StockVestuarioDataSource: Incrementando asignada +$cantidad en $id');
    try {
      // Obtener cantidad actual
      final Map<String, dynamic> current =
          await _supabase.from(_tableName).select('cantidad_asignada').eq('id', id).single();

      final int nuevaCantidad = (current['cantidad_asignada'] as int) + cantidad;

      await _supabase
          .from(_tableName)
          .update(<String, dynamic>{'cantidad_asignada': nuevaCantidad})
          .eq('id', id);

      debugPrint('📦 StockVestuarioDataSource: ✅ Cantidad asignada actualizada');
    } catch (e) {
      debugPrint('📦 StockVestuarioDataSource: ❌ Error: $e');
      rethrow;
    }
  }

  @override
  Future<void> decrementarAsignada(String id, int cantidad) async {
    debugPrint('📦 StockVestuarioDataSource: Decrementando asignada -$cantidad en $id');
    try {
      // Obtener cantidad actual
      final Map<String, dynamic> current =
          await _supabase.from(_tableName).select('cantidad_asignada').eq('id', id).single();

      final int nuevaCantidad = (current['cantidad_asignada'] as int) - cantidad;

      // Validar que no sea negativo
      if (nuevaCantidad < 0) {
        throw Exception('No se puede decrementar: cantidad asignada quedaría negativa');
      }

      await _supabase
          .from(_tableName)
          .update(<String, dynamic>{'cantidad_asignada': nuevaCantidad})
          .eq('id', id);

      debugPrint('📦 StockVestuarioDataSource: ✅ Cantidad asignada actualizada');
    } catch (e) {
      debugPrint('📦 StockVestuarioDataSource: ❌ Error: $e');
      rethrow;
    }
  }
}
