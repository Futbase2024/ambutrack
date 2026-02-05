// Imports del core datasource (sistema nuevo de almacén - importación directa)
import 'package:ambutrack_core/ambutrack_core.dart';
import 'package:ambutrack_web/features/almacen/domain/repositories/movimiento_stock_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

/// Implementación del repositorio de Movimientos de Stock usando pass-through al datasource
///
/// Siguiendo el patrón establecido en el proyecto: el repositorio es un simple
/// pass-through sin conversiones Entity ↔ Entity ya que usamos las mismas
/// entidades del core datasource
@LazySingleton(as: MovimientoStockRepository)
class MovimientoStockRepositoryImpl implements MovimientoStockRepository {
  MovimientoStockRepositoryImpl()
      : _dataSource = MovimientoStockDataSourceFactory.createSupabase();

  final MovimientoStockDataSource _dataSource;

  @override
  Future<List<MovimientoStockEntity>> getAll({int limit = 100}) async {
    debugPrint(
        '📦 MovimientoStockRepository: Solicitando movimientos...');
    try {
      final List<MovimientoStockEntity> movimientos = await _dataSource.getAll();
      debugPrint(
          '📦 MovimientoStockRepository: ✅ ${movimientos.length} movimientos obtenidos');
      // NOTA: El datasource no soporta limit, aplicamos manualmente si es necesario
      return limit < movimientos.length ? movimientos.take(limit).toList() : movimientos;
    } catch (e) {
      debugPrint(
          '📦 MovimientoStockRepository: ❌ Error al obtener movimientos: $e');
      rethrow;
    }
  }

  @override
  Future<MovimientoStockEntity?> getById(String id) async {
    debugPrint('📦 MovimientoStockRepository: Solicitando movimiento: $id');
    try {
      final MovimientoStockEntity? movimiento = await _dataSource.getById(id);
      if (movimiento != null) {
        debugPrint('📦 MovimientoStockRepository: ✅ Movimiento obtenido');
      } else {
        debugPrint('📦 MovimientoStockRepository: ⚠️ Movimiento no encontrado');
      }
      return movimiento;
    } catch (e) {
      debugPrint(
          '📦 MovimientoStockRepository: ❌ Error al obtener movimiento: $e');
      rethrow;
    }
  }

  @override
  Future<List<MovimientoStockEntity>> getByProducto(String productoId) async {
    debugPrint(
        '📦 MovimientoStockRepository: Solicitando movimientos del producto: $productoId');
    try {
      final List<MovimientoStockEntity> movimientos = await _dataSource.getByProducto(productoId);
      debugPrint(
          '📦 MovimientoStockRepository: ✅ ${movimientos.length} movimientos obtenidos');
      return movimientos;
    } catch (e) {
      debugPrint(
          '📦 MovimientoStockRepository: ❌ Error al obtener movimientos por producto: $e');
      rethrow;
    }
  }

  @override
  Future<List<MovimientoStockEntity>> getByAlmacen(String almacenId) async {
    debugPrint(
        '📦 MovimientoStockRepository: Solicitando movimientos del almacén: $almacenId');
    try {
      // NOTA: El datasource distingue entre origen y destino, combinamos ambos
      final List<MovimientoStockEntity> origen = await _dataSource.getByAlmacenOrigen(almacenId);
      final List<MovimientoStockEntity> destino = await _dataSource.getByAlmacenDestino(almacenId);
      final List<MovimientoStockEntity> movimientos = <MovimientoStockEntity>[...origen, ...destino];
      debugPrint(
          '📦 MovimientoStockRepository: ✅ ${movimientos.length} movimientos obtenidos');
      return movimientos;
    } catch (e) {
      debugPrint(
          '📦 MovimientoStockRepository: ❌ Error al obtener movimientos por almacén: $e');
      rethrow;
    }
  }

  @override
  Future<List<MovimientoStockEntity>> getByTipo(
      TipoMovimientoStock tipo) async {
    debugPrint(
        '📦 MovimientoStockRepository: Solicitando movimientos de tipo: ${tipo.label}');
    try {
      final List<MovimientoStockEntity> movimientos = await _dataSource.getByTipo(tipo);
      debugPrint(
          '📦 MovimientoStockRepository: ✅ ${movimientos.length} movimientos obtenidos');
      return movimientos;
    } catch (e) {
      debugPrint(
          '📦 MovimientoStockRepository: ❌ Error al obtener movimientos por tipo: $e');
      rethrow;
    }
  }

  @override
  Future<List<MovimientoStockEntity>> getByFechas({
    required DateTime fechaInicio,
    required DateTime fechaFin,
  }) async {
    debugPrint(
        '📦 MovimientoStockRepository: Solicitando movimientos entre ${fechaInicio.toIso8601String()} y ${fechaFin.toIso8601String()}');
    try {
      final List<MovimientoStockEntity> movimientos = await _dataSource.getByFechaRange(
        desde: fechaInicio,
        hasta: fechaFin,
      );
      debugPrint(
          '📦 MovimientoStockRepository: ✅ ${movimientos.length} movimientos obtenidos');
      return movimientos;
    } catch (e) {
      debugPrint(
          '📦 MovimientoStockRepository: ❌ Error al obtener movimientos por fechas: $e');
      rethrow;
    }
  }

  @override
  Future<MovimientoStockEntity> create(MovimientoStockEntity movimiento) async {
    debugPrint(
        '📦 MovimientoStockRepository: Creando movimiento de tipo: ${movimiento.tipo.name}');
    try {
      // NOTA: El datasource tiene métodos específicos por tipo de movimiento
      // Para simplificar, usamos registrarAjusteInventario que es genérico
      final MovimientoStockEntity created = await _dataSource.registrarAjusteInventario(
        idProducto: movimiento.idProducto,
        idAlmacen: movimiento.idAlmacenOrigen ?? movimiento.idAlmacenDestino ?? '',
        cantidad: movimiento.cantidad,
        motivo: 'Movimiento genérico: ${movimiento.tipo.name}',
      );
      debugPrint(
          '📦 MovimientoStockRepository: ✅ Movimiento creado con ID: ${created.id}');
      return created;
    } catch (e) {
      debugPrint(
          '📦 MovimientoStockRepository: ❌ Error al crear movimiento: $e');
      rethrow;
    }
  }

  @override
  Future<void> delete(String id) async {
    debugPrint('📦 MovimientoStockRepository: Eliminando movimiento: $id');
    try {
      // NOTA: El datasource NO soporta delete (movimientos son inmutables por trazabilidad)
      // Lanzamos excepción explicativa
      throw UnsupportedError(
        'Los movimientos de stock no pueden eliminarse una vez creados. '
        'Son inmutables para mantener la trazabilidad del inventario.',
      );
    } catch (e) {
      debugPrint(
          '📦 MovimientoStockRepository: ❌ Error al eliminar movimiento: $e');
      rethrow;
    }
  }

  @override
  Stream<List<MovimientoStockEntity>> watchAll() {
    debugPrint(
        '📦 MovimientoStockRepository: Iniciando stream de todos los movimientos');
    return _dataSource.watchAll();
  }

  @override
  Stream<List<MovimientoStockEntity>> watchByAlmacen(String almacenId) {
    debugPrint(
        '📦 MovimientoStockRepository: Iniciando stream de movimientos del almacén: $almacenId');
    return _dataSource.watchByAlmacen(almacenId);
  }
}
