import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';

/// Repositorio de la dotación del vehículo para el técnico
abstract class EquipamientoRepository {
  /// Dotación completa del vehículo ordenada por sección
  Future<List<StockVehiculoEntity>> getDotacion(String vehiculoId);

  /// Registra cantidad, caducidad, lote y observaciones de una línea
  Future<StockVehiculoEntity> actualizarLinea({
    required String id,
    required int cantidadActual,
    DateTime? fechaCaducidad,
    bool borrarCaducidad = false,
    String? lote,
    String? observaciones,
  });
}
