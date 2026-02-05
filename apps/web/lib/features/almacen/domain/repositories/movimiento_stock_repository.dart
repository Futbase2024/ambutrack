// Imports del core datasource (sistema nuevo de almacén - imports directos necesarios)
// NOTA: Usamos imports directos /src/ porque el barrel file exporta sistema legacy
import 'package:ambutrack_core/ambutrack_core.dart';

/// Repositorio para operaciones de Movimientos de Stock
///
/// Actúa como pass-through al datasource sin conversiones Entity ↔ Entity
/// Gestiona la trazabilidad de todos los movimientos de stock
abstract class MovimientoStockRepository {
  /// Obtiene todos los movimientos
  Future<List<MovimientoStockEntity>> getAll({int limit = 100});

  /// Obtiene un movimiento por su ID
  Future<MovimientoStockEntity?> getById(String id);

  /// Obtiene movimientos de un producto específico
  Future<List<MovimientoStockEntity>> getByProducto(String productoId);

  /// Obtiene movimientos de un almacén (origen o destino)
  Future<List<MovimientoStockEntity>> getByAlmacen(String almacenId);

  /// Obtiene movimientos por tipo
  Future<List<MovimientoStockEntity>> getByTipo(TipoMovimientoStock tipo);

  /// Obtiene movimientos en un rango de fechas
  Future<List<MovimientoStockEntity>> getByFechas({
    required DateTime fechaInicio,
    required DateTime fechaFin,
  });

  /// Crea un nuevo movimiento de stock
  /// Nota: Esto actualiza automáticamente el stock en el datasource
  Future<MovimientoStockEntity> create(MovimientoStockEntity movimiento);

  /// Elimina un movimiento (hard delete - no se permite modificar historial)
  Future<void> delete(String id);

  /// Stream para observar todos los movimientos
  Stream<List<MovimientoStockEntity>> watchAll();

  /// Stream para observar movimientos de un almacén
  Stream<List<MovimientoStockEntity>> watchByAlmacen(String almacenId);
}
