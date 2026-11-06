import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/features/vehiculos/equipamiento/domain/repositories/equipamiento_vehiculo_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

/// Implementación pass-through al datasource core de equipamiento de vehículo
@LazySingleton(as: EquipamientoVehiculoRepository)
class EquipamientoVehiculoRepositoryImpl implements EquipamientoVehiculoRepository {
  EquipamientoVehiculoRepositoryImpl()
      : _dataSource = EquipamientoVehiculoDataSourceFactory.createSupabase();

  final EquipamientoVehiculoDataSource _dataSource;

  @override
  Future<List<StockVehiculoEntity>> getDotacion(String vehiculoId) {
    debugPrint('📦 EquipamientoVehiculoRepository: dotación de $vehiculoId');
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
  Future<StockVehiculoEntity> setExcluido(String id, {required bool excluido}) {
    return _dataSource.setExcluido(id, excluido: excluido);
  }

  @override
  Future<StockVehiculoEntity> addExtra({
    required String vehiculoId,
    required String productoId,
    required int cantidad,
    DateTime? fechaCaducidad,
    String? lote,
    String? observaciones,
  }) {
    return _dataSource.addExtra(
      vehiculoId: vehiculoId,
      productoId: productoId,
      cantidad: cantidad,
      fechaCaducidad: fechaCaducidad,
      lote: lote,
      observaciones: observaciones,
    );
  }

  @override
  Future<void> eliminarExtra(String id) => _dataSource.eliminarExtra(id);

  @override
  Future<StockVehiculoEntity> subirAdjunto({
    required String id,
    required String vehiculoId,
    required Uint8List bytes,
    required String fileName,
    String? contentType,
  }) {
    return _dataSource.subirAdjunto(
      id: id,
      vehiculoId: vehiculoId,
      bytes: bytes,
      fileName: fileName,
      contentType: contentType,
    );
  }

  @override
  Future<StockVehiculoEntity> eliminarAdjunto(String id) => _dataSource.eliminarAdjunto(id);

  @override
  Future<String> getUrlAdjunto(String documentoPath) => _dataSource.getUrlAdjunto(documentoPath);
}
