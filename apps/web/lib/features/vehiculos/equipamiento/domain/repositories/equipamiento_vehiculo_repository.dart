import 'dart:typed_data';

import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';

/// Repositorio de la dotación (equipamiento + documentación) de cada vehículo
abstract class EquipamientoVehiculoRepository {
  /// Dotación completa del vehículo ordenada por sección
  Future<List<StockVehiculoEntity>> getDotacion(String vehiculoId);

  /// Actualiza cantidad, caducidad, lote y observaciones de una línea
  Future<StockVehiculoEntity> actualizarLinea({
    required String id,
    required int cantidadActual,
    DateTime? fechaCaducidad,
    bool borrarCaducidad = false,
    String? lote,
    String? observaciones,
  });

  /// Excluye / incluye un item de plantilla en el vehículo
  Future<StockVehiculoEntity> setExcluido(String id, {required bool excluido});

  /// Añade un item extra que no está en la plantilla
  Future<StockVehiculoEntity> addExtra({
    required String vehiculoId,
    required String productoId,
    required int cantidad,
    DateTime? fechaCaducidad,
    String? lote,
    String? observaciones,
  });

  /// Elimina un item extra
  Future<void> eliminarExtra(String id);

  /// Sube o sustituye el adjunto de una línea
  Future<StockVehiculoEntity> subirAdjunto({
    required String id,
    required String vehiculoId,
    required Uint8List bytes,
    required String fileName,
    String? contentType,
  });

  /// Quita el adjunto de una línea
  Future<StockVehiculoEntity> eliminarAdjunto(String id);

  /// URL firmada temporal del adjunto
  Future<String> getUrlAdjunto(String documentoPath);
}
