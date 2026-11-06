import 'dart:typed_data';

import '../stock/entities/stock_vehiculo_entity.dart';

/// Contrato del datasource de dotación (equipamiento + documentación) de cada vehículo
///
/// Trabaja sobre `stock_vehiculo` y la vista `v_stock_vehiculo_estado`.
/// - Técnicos: cantidad, caducidad, lote, observaciones y adjunto.
/// - `admin` / `jefe_mantenimiento`: además excluir items y añadir/quitar extras
///   (lo garantiza un trigger en Supabase).
abstract class EquipamientoVehiculoDataSource {
  /// Dotación completa del vehículo ordenada por sección y orden de la plantilla
  Future<List<StockVehiculoEntity>> getDotacion(String vehiculoId);

  /// Una línea concreta (con los campos calculados de la vista)
  Future<StockVehiculoEntity?> getLinea(String id);

  /// Actualiza los datos que registra el técnico.
  /// [borrarCaducidad] = true deja la fecha de caducidad vacía.
  Future<StockVehiculoEntity> actualizarLinea({
    required String id,
    required int cantidadActual,
    DateTime? fechaCaducidad,
    bool borrarCaducidad = false,
    String? lote,
    String? observaciones,
  });

  /// Excluye / vuelve a incluir un item de plantilla en este vehículo
  Future<StockVehiculoEntity> setExcluido(String id, {required bool excluido});

  /// Añade un item extra (origen `manual`) que no está en la plantilla
  Future<StockVehiculoEntity> addExtra({
    required String vehiculoId,
    required String productoId,
    required int cantidad,
    DateTime? fechaCaducidad,
    String? lote,
    String? observaciones,
  });

  /// Elimina un item extra. Las líneas de plantilla no se borran: se excluyen.
  Future<void> eliminarExtra(String id);

  /// Sube (o sustituye) el documento adjunto de la línea
  Future<StockVehiculoEntity> subirAdjunto({
    required String id,
    required String vehiculoId,
    required Uint8List bytes,
    required String fileName,
    String? contentType,
  });

  /// Quita el documento adjunto de la línea
  Future<StockVehiculoEntity> eliminarAdjunto(String id);

  /// URL firmada temporal para ver/descargar el adjunto (bucket privado)
  Future<String> getUrlAdjunto(String documentoPath, {int expiresInSeconds = 3600});
}
