// Imports del core datasource (ocultando conflictos con stock de vehículos)
import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart' hide MovimientoStockEntity, StockDataSource, StockDataSourceFactory;
// Imports específicos para almacén
import 'package:ambutrack_core_datasource/src/datasources/almacen/stock_contract.dart';
import 'package:ambutrack_core_datasource/src/datasources/almacen/stock_factory.dart';
import 'package:ambutrack_web/features/almacen/domain/repositories/stock_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

/// Implementación del repositorio de Stock usando pass-through al datasource
///
/// Siguiendo el patrón establecido en el proyecto: el repositorio es un simple
/// pass-through sin conversiones Entity ↔ Entity ya que usamos las mismas
/// entidades del core datasource
@LazySingleton(as: StockRepository)
class StockRepositoryImpl implements StockRepository {
  StockRepositoryImpl() : _dataSource = StockDataSourceFactory.createSupabase();

  final StockDataSource _dataSource;

  @override
  Future<List<StockEntity>> getAll() async {
    debugPrint('📦 StockRepository: Solicitando todo el stock...');
    try {
      final List<StockEntity> stock = await _dataSource.getAll();
      debugPrint('📦 StockRepository: ✅ ${stock.length} registros obtenidos');
      return stock;
    } catch (e) {
      debugPrint('📦 StockRepository: ❌ Error al obtener stock: $e');
      rethrow;
    }
  }

  @override
  Future<List<StockEntity>> getByProducto(String productoId) async {
    debugPrint('📦 StockRepository: Solicitando stock del producto: $productoId');
    try {
      final List<StockEntity> stock = await _dataSource.getByProducto(productoId);
      debugPrint('📦 StockRepository: ✅ ${stock.length} registros obtenidos');
      return stock;
    } catch (e) {
      debugPrint('📦 StockRepository: ❌ Error al obtener stock por producto: $e');
      rethrow;
    }
  }

  @override
  Future<List<StockEntity>> getByAlmacen(String almacenId) async {
    debugPrint('📦 StockRepository: Solicitando stock del almacén: $almacenId');
    try {
      final List<StockEntity> stock = await _dataSource.getByAlmacen(almacenId);
      debugPrint('📦 StockRepository: ✅ ${stock.length} registros obtenidos');
      return stock;
    } catch (e) {
      debugPrint('📦 StockRepository: ❌ Error al obtener stock por almacén: $e');
      rethrow;
    }
  }

  @override
  Future<List<StockEntity>> getByVehiculo(String vehiculoId) async {
    debugPrint('📦 StockRepository: Solicitando stock del vehículo: $vehiculoId');
    try {
      // StockEntity usa idAlmacen tanto para almacenes como para vehículos
      // El vehículo se identifica por su ID de almacén
      final List<StockEntity> stock = await _dataSource.getByAlmacen(vehiculoId);
      debugPrint('📦 StockRepository: ✅ ${stock.length} registros obtenidos');
      return stock;
    } catch (e) {
      debugPrint('📦 StockRepository: ❌ Error al obtener stock por vehículo: $e');
      rethrow;
    }
  }

  @override
  Future<List<StockEntity>> getStockBajo(String almacenId) async {
    debugPrint('📦 StockRepository: Solicitando stock bajo del almacén: $almacenId');
    try {
      final List<StockEntity> stock = await _dataSource.getStockBajo(almacenId);
      debugPrint('📦 StockRepository: ✅ ${stock.length} registros con stock bajo');
      return stock;
    } catch (e) {
      debugPrint('📦 StockRepository: ❌ Error al obtener stock bajo: $e');
      rethrow;
    }
  }

  @override
  Future<List<StockEntity>> getProximoACaducar({int diasAntes = 30}) async {
    debugPrint('📦 StockRepository: Solicitando productos próximos a caducar ($diasAntes días)...');
    try {
      final List<StockEntity> stock = await _dataSource.getStockProximoACaducar(dias: diasAntes);
      debugPrint('📦 StockRepository: ✅ ${stock.length} registros próximos a caducar');
      return stock;
    } catch (e) {
      debugPrint('📦 StockRepository: ❌ Error al obtener productos próximos a caducar: $e');
      rethrow;
    }
  }

  @override
  Future<StockEntity?> getById(String id) async {
    debugPrint('📦 StockRepository: Solicitando stock con ID: $id');
    try {
      final StockEntity? stock = await _dataSource.getById(id);
      if (stock != null) {
        debugPrint('📦 StockRepository: ✅ Stock obtenido');
      } else {
        debugPrint('📦 StockRepository: ⚠️ Stock no encontrado');
      }
      return stock;
    } catch (e) {
      debugPrint('📦 StockRepository: ❌ Error al obtener stock: $e');
      rethrow;
    }
  }

  @override
  Future<StockEntity?> getStockEspecifico({
    required String productoId,
    String? almacenId,
    String? vehiculoId,
  }) async {
    debugPrint('📦 StockRepository: Solicitando stock específico...');
    try {
      // StockEntity usa idAlmacen tanto para almacenes como para vehículos
      final String targetAlmacenId = almacenId ?? vehiculoId ?? '';

      if (targetAlmacenId.isEmpty) {
        throw Exception('Se requiere almacenId o vehiculoId');
      }

      final StockEntity? stock = await _dataSource.getByProductoAndAlmacen(productoId, targetAlmacenId);

      if (stock != null) {
        debugPrint('📦 StockRepository: ✅ Stock específico encontrado');
      } else {
        debugPrint('📦 StockRepository: ⚠️ Stock específico no encontrado');
      }
      return stock;
    } catch (e) {
      debugPrint('📦 StockRepository: ❌ Error al obtener stock específico: $e');
      rethrow;
    }
  }

  @override
  Future<StockEntity> create(StockEntity stock) async {
    debugPrint('📦 StockRepository: Creando registro de stock...');
    try {
      final StockEntity created = await _dataSource.create(stock);
      debugPrint('📦 StockRepository: ✅ Stock creado con ID: ${created.id}');
      return created;
    } catch (e) {
      debugPrint('📦 StockRepository: ❌ Error al crear stock: $e');
      rethrow;
    }
  }

  @override
  Future<StockEntity> update(StockEntity stock) async {
    debugPrint('📦 StockRepository: Actualizando stock: ${stock.id}');
    try {
      final StockEntity updated = await _dataSource.update(stock);
      debugPrint('📦 StockRepository: ✅ Stock actualizado');
      return updated;
    } catch (e) {
      debugPrint('📦 StockRepository: ❌ Error al actualizar stock: $e');
      rethrow;
    }
  }

  @override
  Future<void> delete(String id) async {
    debugPrint('📦 StockRepository: Eliminando stock: $id');
    try {
      await _dataSource.delete(id);
      debugPrint('📦 StockRepository: ✅ Stock desactivado (soft delete)');
    } catch (e) {
      debugPrint('📦 StockRepository: ❌ Error al eliminar stock: $e');
      rethrow;
    }
  }

  @override
  Future<StockEntity> ajustarCantidad({
    required String stockId,
    required double nuevaCantidad,
    required String motivo,
  }) async {
    debugPrint('📦 StockRepository: Ajustando cantidad de stock $stockId a $nuevaCantidad...');
    try {
      // El datasource espera: idStock, cantidadAjuste (diferencia), motivo
      // Necesitamos obtener la cantidad actual primero
      final StockEntity? currentStock = await _dataSource.getById(stockId);
      if (currentStock == null) {
        throw Exception('Stock no encontrado: $stockId');
      }

      final double cantidadAjuste = nuevaCantidad - currentStock.cantidadActual;

      final StockEntity adjusted = await _dataSource.ajustarCantidad(
        idStock: stockId,
        cantidadAjuste: cantidadAjuste,
        motivo: motivo,
      );
      debugPrint('📦 StockRepository: ✅ Cantidad ajustada');
      return adjusted;
    } catch (e) {
      debugPrint('📦 StockRepository: ❌ Error al ajustar cantidad: $e');
      rethrow;
    }
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
    debugPrint('📦 StockRepository: Transfiriendo $cantidad unidades a vehículo $vehiculoId...');
    try {
      final StockEntity transferred = await _dataSource.transferirAVehiculo(
        idStock: idStock,
        vehiculoId: vehiculoId,
        cantidad: cantidad,
        motivo: motivo,
        lote: lote,
        fechaCaducidad: fechaCaducidad,
      );
      debugPrint('📦 StockRepository: ✅ Transferencia a vehículo exitosa');
      return transferred;
    } catch (e) {
      debugPrint('📦 StockRepository: ❌ Error al transferir a vehículo: $e');
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
    debugPrint('📦 StockRepository: Transfiriendo $cantidad unidades entre almacenes...');
    try {
      final StockEntity transferred = await _dataSource.transferirEntreAlmacenes(
        idStockOrigen: idStockOrigen,
        almacenDestinoId: almacenDestinoId,
        cantidad: cantidad,
        motivo: motivo,
      );
      debugPrint('📦 StockRepository: ✅ Transferencia entre almacenes exitosa');
      return transferred;
    } catch (e) {
      debugPrint('📦 StockRepository: ❌ Error al transferir entre almacenes: $e');
      rethrow;
    }
  }

  @override
  Stream<List<StockEntity>> watchAll() {
    debugPrint('📦 StockRepository: Iniciando stream de todo el stock');
    return _dataSource.watchAll();
  }

  @override
  Stream<List<StockEntity>> watchByAlmacen(String almacenId) {
    debugPrint('📦 StockRepository: Iniciando stream de stock del almacén: $almacenId');
    return _dataSource.watchByAlmacen(almacenId);
  }

  @override
  Stream<List<StockEntity>> watchByVehiculo(String vehiculoId) {
    debugPrint('📦 StockRepository: Iniciando stream de stock del vehículo: $vehiculoId');
    // StockEntity usa idAlmacen tanto para almacenes como para vehículos
    return _dataSource.watchByAlmacen(vehiculoId);
  }
}
