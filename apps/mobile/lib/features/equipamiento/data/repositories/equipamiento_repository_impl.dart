import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:flutter/foundation.dart';

import '../../domain/repositories/equipamiento_repository.dart';

/// Implementación pass-through al datasource core de equipamiento de vehículo
class EquipamientoRepositoryImpl implements EquipamientoRepository {
  EquipamientoRepositoryImpl() : _dataSource = EquipamientoVehiculoDataSourceFactory.createSupabase();

  final EquipamientoVehiculoDataSource _dataSource;

  @override
  Future<List<StockVehiculoEntity>> getDotacion(String vehiculoId) {
    debugPrint('📦 EquipamientoRepository: dotación de $vehiculoId');
    return _dataSource.getDotacion(vehiculoId);
  }

  @override
  Future<StockVehiculoEntity> actualizarLinea({
    required String id,
    required int cantidadActual,
    DateTime? fechaCaducidad,
    bool borrarCaducidad = false,
    String? lote,
    String? observaciones,
  }) {
    return _dataSource.actualizarLinea(
      id: id,
      cantidadActual: cantidadActual,
      fechaCaducidad: fechaCaducidad,
      borrarCaducidad: borrarCaducidad,
      lote: lote,
      observaciones: observaciones,
    );
  }

  @override
  Future<String> getUrlAdjunto(String documentoPath) => _dataSource.getUrlAdjunto(documentoPath);
}
