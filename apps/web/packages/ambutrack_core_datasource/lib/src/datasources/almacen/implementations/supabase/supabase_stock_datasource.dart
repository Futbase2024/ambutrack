import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../entities/stock_entity.dart';
import '../../models/stock_supabase_model.dart';
import '../../stock_contract.dart';

/// Implementación de StockDataSource usando Supabase
class SupabaseStockDataSource implements StockDataSource {
  SupabaseStockDataSource(this._supabase);

  final SupabaseClient _supabase;
  static const String _tableName = 'stock';

  @override
  Future<List<StockEntity>> getAll({int? limit, int? offset}) async {
    try {
      debugPrint('📦 Stock DS: Obteniendo todo el stock (limit: $limit, offset: $offset)');

      var query = _supabase.from(_tableName).select().order('created_at', ascending: false);

      if (limit != null) {
        query = query.limit(limit);
      }

      if (offset != null) {
        query = query.range(offset, offset + (limit ?? 1000) - 1);
      }

      final List<dynamic> data = await query;

      final List<StockEntity> stock = data
          .map((json) => StockSupabaseModel.fromJson(json).toEntity())
          .toList();

      debugPrint('📦 Stock DS: ✅ ${stock.length} registros obtenidos');
      return stock;
    } catch (e) {
      debugPrint('📦 Stock DS: ❌ Error al obtener stock: $e');
      rethrow;
    }
  }

  @override
  Future<StockEntity?> getById(String id) async {
    try {
      debugPrint('📦 Stock DS: Obteniendo stock por ID: $id');

      final Map<String, dynamic>? data =
          await _supabase.from(_tableName).select().eq('id', id).maybeSingle();

      if (data == null) {
        debugPrint('📦 Stock DS: ❌ Stock no encontrado');
        return null;
      }

      final StockEntity stock = StockSupabaseModel.fromJson(data).toEntity();

      debugPrint('📦 Stock DS: ✅ Stock obtenido');
      return stock;
    } catch (e) {
      debugPrint('📦 Stock DS: ❌ Error al obtener stock por ID: $e');
      rethrow;
    }
  }

  @override
  Future<List<StockEntity>> getByAlmacen(String idAlmacen) async {
    try {
      debugPrint('📦 Stock DS: Obteniendo stock del almacén: $idAlmacen');

      final List<dynamic> data = await _supabase
          .from(_tableName)
          .select()
          .eq('id_almacen', idAlmacen)
          .order('created_at', ascending: false);

      final List<StockEntity> stock = data
          .map((json) => StockSupabaseModel.fromJson(json).toEntity())
          .toList();

      debugPrint('📦 Stock DS: ✅ ${stock.length} productos en almacén');
      return stock;
    } catch (e) {
      debugPrint('📦 Stock DS: ❌ Error al obtener stock del almacén: $e');
      rethrow;
    }
  }

  @override
  Future<List<StockEntity>> getByProducto(String idProducto) async {
    try {
      debugPrint('📦 Stock DS: Obteniendo stock del producto: $idProducto');

      final List<dynamic> data = await _supabase
          .from(_tableName)
          .select()
          .eq('id_producto', idProducto)
          .order('id_almacen', ascending: true);

      final List<StockEntity> stock = data
          .map((json) => StockSupabaseModel.fromJson(json).toEntity())
          .toList();

      debugPrint('📦 Stock DS: ✅ ${stock.length} registros del producto');
      return stock;
    } catch (e) {
      debugPrint('📦 Stock DS: ❌ Error al obtener stock del producto: $e');
      rethrow;
    }
  }

  @override
  Future<StockEntity?> getByProductoAndAlmacen(
    String idProducto,
    String idAlmacen,
  ) async {
    try {
      debugPrint(
          '📦 Stock DS: Obteniendo stock producto $idProducto en almacén $idAlmacen');

      final Map<String, dynamic>? data = await _supabase
          .from(_tableName)
          .select()
          .eq('id_producto', idProducto)
          .eq('id_almacen', idAlmacen)
          .maybeSingle();

      if (data == null) {
        debugPrint('📦 Stock DS: ❌ Stock no encontrado');
        return null;
      }

      final StockEntity stock = StockSupabaseModel.fromJson(data).toEntity();

      debugPrint('📦 Stock DS: ✅ Stock obtenido');
      return stock;
    } catch (e) {
      debugPrint('📦 Stock DS: ❌ Error al obtener stock: $e');
      rethrow;
    }
  }

  @override
  Future<StockEntity?> getByLote(
    String idProducto,
    String idAlmacen,
    String lote,
  ) async {
    try {
      debugPrint('📦 Stock DS: Obteniendo stock por lote: $lote');

      final Map<String, dynamic>? data = await _supabase
          .from(_tableName)
          .select()
          .eq('id_producto', idProducto)
          .eq('id_almacen', idAlmacen)
          .eq('lote', lote)
          .maybeSingle();

      if (data == null) {
        debugPrint('📦 Stock DS: ❌ Lote no encontrado');
        return null;
      }

      final StockEntity stock = StockSupabaseModel.fromJson(data).toEntity();

      debugPrint('📦 Stock DS: ✅ Lote obtenido');
      return stock;
    } catch (e) {
      debugPrint('📦 Stock DS: ❌ Error al obtener stock por lote: $e');
      rethrow;
    }
  }

  @override
  Future<StockEntity?> getByNumeroSerie(
    String idProducto,
    String numeroSerie,
  ) async {
    try {
      debugPrint('📦 Stock DS: Obteniendo stock por nº serie: $numeroSerie');

      final Map<String, dynamic>? data = await _supabase
          .from(_tableName)
          .select()
          .eq('id_producto', idProducto)
          .eq('numero_serie', numeroSerie)
          .maybeSingle();

      if (data == null) {
        debugPrint('📦 Stock DS: ❌ Número de serie no encontrado');
        return null;
      }

      final StockEntity stock = StockSupabaseModel.fromJson(data).toEntity();

      debugPrint('📦 Stock DS: ✅ Equipo obtenido');
      return stock;
    } catch (e) {
      debugPrint('📦 Stock DS: ❌ Error al obtener stock por nº serie: $e');
      rethrow;
    }
  }

  @override
  Future<List<StockEntity>> getStockBajo(String idAlmacen) async {
    try {
      debugPrint('📦 Stock DS: Obteniendo stock bajo en almacén: $idAlmacen');

      final List<dynamic> data = await _supabase
          .from(_tableName)
          .select()
          .eq('id_almacen', idAlmacen)
          .filter('cantidad_actual', 'lt', 'cantidad_minima')
          .order('cantidad_actual', ascending: true);

      final List<StockEntity> stockBajo = data
          .map((json) => StockSupabaseModel.fromJson(json).toEntity())
          .toList();

      debugPrint('📦 Stock DS: ✅ ${stockBajo.length} productos con stock bajo');
      return stockBajo;
    } catch (e) {
      debugPrint('📦 Stock DS: ❌ Error al obtener stock bajo: $e');
      rethrow;
    }
  }

  @override
  Future<List<StockEntity>> getStockProximoACaducar({int dias = 30}) async {
    try {
      debugPrint('📦 Stock DS: Obteniendo stock próximo a caducar ($dias días)');

      final DateTime limite = DateTime.now().add(Duration(days: dias));

      final List<dynamic> data = await _supabase
          .from(_tableName)
          .select()
          .not('fecha_caducidad', 'is', null)
          .lte('fecha_caducidad', limite.toIso8601String())
          .order('fecha_caducidad', ascending: true);

      final List<StockEntity> stockCaducando = data
          .map((json) => StockSupabaseModel.fromJson(json).toEntity())
          .toList();

      debugPrint(
          '📦 Stock DS: ✅ ${stockCaducando.length} productos próximos a caducar');
      return stockCaducando;
    } catch (e) {
      debugPrint('📦 Stock DS: ❌ Error al obtener stock próximo a caducar: $e');
      rethrow;
    }
  }

  @override
  Future<StockEntity> create(StockEntity stock) async {
    try {
      debugPrint('📦 Stock DS: Creando registro de stock...');

      final StockSupabaseModel model = StockSupabaseModel.fromEntity(stock);
      final Map<String, dynamic> data =
          await _supabase.from(_tableName).insert(model.toJson()).select().single();

      final StockEntity createdStock =
          StockSupabaseModel.fromJson(data).toEntity();

      debugPrint('📦 Stock DS: ✅ Stock creado');
      return createdStock;
    } catch (e) {
      debugPrint('📦 Stock DS: ❌ Error al crear stock: $e');
      rethrow;
    }
  }

  @override
  Future<StockEntity> update(StockEntity stock) async {
    try {
      debugPrint('📦 Stock DS: Actualizando stock...');

      final StockSupabaseModel model = StockSupabaseModel.fromEntity(stock);
      final Map<String, dynamic> data = await _supabase
          .from(_tableName)
          .update(model.toJson())
          .eq('id', stock.id)
          .select()
          .single();

      final StockEntity updatedStock =
          StockSupabaseModel.fromJson(data).toEntity();

      debugPrint('📦 Stock DS: ✅ Stock actualizado');
      return updatedStock;
    } catch (e) {
      debugPrint('📦 Stock DS: ❌ Error al actualizar stock: $e');
      rethrow;
    }
  }

  @override
  Future<StockEntity> ajustarCantidad({
    required String idStock,
    required double cantidadAjuste,
    String? motivo,
  }) async {
    try {
      debugPrint(
          '📦 Stock DS: Ajustando cantidad: $cantidadAjuste (motivo: $motivo)');

      final Map<String, dynamic> currentData =
          await _supabase.from(_tableName).select().eq('id', idStock).single();

      final StockEntity currentStock =
          StockSupabaseModel.fromJson(currentData).toEntity();

      final double nuevaCantidad = currentStock.cantidadActual + cantidadAjuste;

      if (nuevaCantidad < 0) {
        throw Exception('La cantidad resultante no puede ser negativa');
      }

      final Map<String, dynamic> updatedData = await _supabase
          .from(_tableName)
          .update({'cantidad_actual': nuevaCantidad})
          .eq('id', idStock)
          .select()
          .single();

      final StockEntity updatedStock =
          StockSupabaseModel.fromJson(updatedData).toEntity();

      debugPrint('📦 Stock DS: ✅ Cantidad ajustada: $nuevaCantidad');
      return updatedStock;
    } catch (e) {
      debugPrint('📦 Stock DS: ❌ Error al ajustar cantidad: $e');
      rethrow;
    }
  }

  @override
  Future<StockEntity> reservarCantidad({
    required String idStock,
    required double cantidad,
  }) async {
    try {
      debugPrint('📦 Stock DS: Reservando cantidad: $cantidad');

      final Map<String, dynamic> currentData =
          await _supabase.from(_tableName).select().eq('id', idStock).single();

      final StockEntity currentStock =
          StockSupabaseModel.fromJson(currentData).toEntity();

      if (currentStock.cantidadDisponible < cantidad) {
        throw Exception(
            'Cantidad insuficiente. Disponible: ${currentStock.cantidadDisponible}');
      }

      final double nuevaReservada = currentStock.cantidadReservada + cantidad;

      final Map<String, dynamic> updatedData = await _supabase
          .from(_tableName)
          .update({'cantidad_reservada': nuevaReservada})
          .eq('id', idStock)
          .select()
          .single();

      final StockEntity updatedStock =
          StockSupabaseModel.fromJson(updatedData).toEntity();

      debugPrint('📦 Stock DS: ✅ Cantidad reservada: $cantidad');
      return updatedStock;
    } catch (e) {
      debugPrint('📦 Stock DS: ❌ Error al reservar cantidad: $e');
      rethrow;
    }
  }

  @override
  Future<StockEntity> liberarReservada({
    required String idStock,
    required double cantidad,
  }) async {
    try {
      debugPrint('📦 Stock DS: Liberando cantidad reservada: $cantidad');

      final Map<String, dynamic> currentData =
          await _supabase.from(_tableName).select().eq('id', idStock).single();

      final StockEntity currentStock =
          StockSupabaseModel.fromJson(currentData).toEntity();

      final double nuevaReservada =
          (currentStock.cantidadReservada - cantidad).clamp(0.0, double.infinity);

      final Map<String, dynamic> updatedData = await _supabase
          .from(_tableName)
          .update({'cantidad_reservada': nuevaReservada})
          .eq('id', idStock)
          .select()
          .single();

      final StockEntity updatedStock =
          StockSupabaseModel.fromJson(updatedData).toEntity();

      debugPrint('📦 Stock DS: ✅ Cantidad liberada: $cantidad');
      return updatedStock;
    } catch (e) {
      debugPrint('📦 Stock DS: ❌ Error al liberar cantidad: $e');
      rethrow;
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      debugPrint('📦 Stock DS: Eliminando stock: $id');

      await _supabase.from(_tableName).delete().eq('id', id);

      debugPrint('📦 Stock DS: ✅ Stock eliminado');
    } catch (e) {
      debugPrint('📦 Stock DS: ❌ Error al eliminar stock: $e');
      rethrow;
    }
  }

  @override
  Future<bool> exists(String id) async {
    try {
      final Map<String, dynamic>? data =
          await _supabase.from(_tableName).select('id').eq('id', id).maybeSingle();

      return data != null;
    } catch (e) {
      debugPrint('📦 Stock DS: ❌ Error al verificar existencia: $e');
      return false;
    }
  }

  @override
  Future<List<StockEntity>> createBatch(List<StockEntity> entities) async {
    try {
      debugPrint('📦 Stock DS: Creando ${entities.length} registros de stock...');

      final List<Map<String, dynamic>> data = entities
          .map((e) => StockSupabaseModel.fromEntity(e).toJson())
          .toList();

      final List<dynamic> result =
          await _supabase.from(_tableName).insert(data).select();

      final List<StockEntity> created = result
          .map((json) => StockSupabaseModel.fromJson(json).toEntity())
          .toList();

      debugPrint('📦 Stock DS: ✅ ${created.length} registros creados');
      return created;
    } catch (e) {
      debugPrint('📦 Stock DS: ❌ Error al crear batch: $e');
      rethrow;
    }
  }

  @override
  Future<List<StockEntity>> updateBatch(List<StockEntity> entities) async {
    try {
      debugPrint('📦 Stock DS: Actualizando ${entities.length} registros...');

      final List<StockEntity> updated = [];

      for (final entity in entities) {
        final result = await update(entity);
        updated.add(result);
      }

      debugPrint('📦 Stock DS: ✅ ${updated.length} registros actualizados');
      return updated;
    } catch (e) {
      debugPrint('📦 Stock DS: ❌ Error al actualizar batch: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteBatch(List<String> ids) async {
    try {
      debugPrint('📦 Stock DS: Eliminando ${ids.length} registros...');

      await _supabase.from(_tableName).delete().inFilter('id', ids);

      debugPrint('📦 Stock DS: ✅ ${ids.length} registros eliminados');
    } catch (e) {
      debugPrint('📦 Stock DS: ❌ Error al eliminar batch: $e');
      rethrow;
    }
  }

  @override
  Future<int> count() async {
    try {
      final response = await _supabase
          .from(_tableName)
          .select('id')
          .count(CountOption.exact);

      return response.count;
    } catch (e) {
      debugPrint('📦 Stock DS: ❌ Error al contar registros: $e');
      rethrow;
    }
  }

  @override
  Future<void> clear() async {
    try {
      debugPrint('📦 Stock DS: ⚠️ Eliminando TODOS los registros...');

      await _supabase.from(_tableName).delete().neq('id', '');

      debugPrint('📦 Stock DS: ✅ Tabla limpiada');
    } catch (e) {
      debugPrint('📦 Stock DS: ❌ Error al limpiar tabla: $e');
      rethrow;
    }
  }

  @override
  Stream<List<StockEntity>> watchAll() {
    debugPrint('📦 Stock DS: Observando cambios en todo el stock...');

    return _supabase
        .from(_tableName)
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .map((data) =>
            data.map((json) => StockSupabaseModel.fromJson(json).toEntity()).toList());
  }

  @override
  Stream<StockEntity?> watchById(String id) {
    debugPrint('📦 Stock DS: Observando cambios en stock: $id');

    return _supabase
        .from(_tableName)
        .stream(primaryKey: ['id'])
        .eq('id', id)
        .map((data) => data.isEmpty
            ? null
            : StockSupabaseModel.fromJson(data.first).toEntity());
  }

  @override
  Stream<List<StockEntity>> watchByAlmacen(String idAlmacen) {
    debugPrint('📦 Stock DS: Observando cambios en almacén: $idAlmacen');

    return _supabase
        .from(_tableName)
        .stream(primaryKey: ['id'])
        .eq('id_almacen', idAlmacen)
        .order('created_at', ascending: false)
        .map((data) =>
            data.map((json) => StockSupabaseModel.fromJson(json).toEntity()).toList());
  }

  @override
  Stream<List<StockEntity>> watchByProducto(String idProducto) {
    debugPrint('📦 Stock DS: Observando cambios en producto: $idProducto');

    return _supabase
        .from(_tableName)
        .stream(primaryKey: ['id'])
        .eq('id_producto', idProducto)
        .order('id_almacen', ascending: true)
        .map((data) =>
            data.map((json) => StockSupabaseModel.fromJson(json).toEntity()).toList());
  }

  @override
  Future<StockEntity> transferirAVehiculo({
    required String idStock,
    required String vehiculoId,
    required double cantidad,
    required String motivo,
    String? lote,
    DateTime? fechaCaducidad,
  }) async {
    try {
      debugPrint('📦 Stock DS: Transfiriendo stock a vehículo');
      debugPrint('   - Stock ID: $idStock');
      debugPrint('   - Vehículo: $vehiculoId');
      debugPrint('   - Cantidad: $cantidad');
      debugPrint('   - Motivo: $motivo');

      // Llamar a la función RPC de Supabase para transferir stock
      await _supabase.rpc(
        'transferir_stock_a_vehiculo',
        params: <String, dynamic>{
          'p_stock_id': idStock,
          'p_vehiculo_id': vehiculoId,
          'p_cantidad': cantidad,
          'p_motivo': motivo,
          'p_lote': lote,
          'p_fecha_caducidad': fechaCaducidad?.toIso8601String(),
        },
      );

      debugPrint('📦 Stock DS: ✅ Transferencia exitosa');

      // Obtener el stock actualizado
      final StockEntity? stockActualizado = await getById(idStock);

      if (stockActualizado == null) {
        throw Exception('No se pudo obtener el stock actualizado');
      }

      return stockActualizado;
    } catch (e) {
      debugPrint('📦 Stock DS: ❌ Error al transferir a vehículo: $e');
      rethrow;
    }
  }

  @override
  Future<StockEntity> transferirEntreAlmacenes({
    required String idStockOrigen,
    required String almacenDestinoId,
    required double cantidad,
    required String motivo,
  }) async {
    try {
      debugPrint('📦 Stock DS: Transfiriendo stock entre almacenes');
      debugPrint('   - Stock origen ID: $idStockOrigen');
      debugPrint('   - Almacén destino: $almacenDestinoId');
      debugPrint('   - Cantidad: $cantidad');
      debugPrint('   - Motivo: $motivo');

      // Llamar a la función RPC de Supabase para transferir entre almacenes
      await _supabase.rpc(
        'transferir_stock_entre_almacenes',
        params: <String, dynamic>{
          'p_stock_origen_id': idStockOrigen,
          'p_almacen_destino_id': almacenDestinoId,
          'p_cantidad': cantidad,
          'p_motivo': motivo,
        },
      );

      debugPrint('📦 Stock DS: ✅ Transferencia exitosa');

      // Obtener el stock actualizado
      final StockEntity? stockActualizado = await getById(idStockOrigen);

      if (stockActualizado == null) {
        throw Exception('No se pudo obtener el stock actualizado');
      }

      return stockActualizado;
    } catch (e) {
      debugPrint('📦 Stock DS: ❌ Error al transferir entre almacenes: $e');
      rethrow;
    }
  }
}
