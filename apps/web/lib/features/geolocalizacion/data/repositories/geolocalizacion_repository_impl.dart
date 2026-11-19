import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/features/geolocalizacion/domain/repositories/geolocalizacion_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

/// Implementación pass-through del seguimiento GPS
@LazySingleton(as: GeolocalizacionRepository)
class GeolocalizacionRepositoryImpl implements GeolocalizacionRepository {
  GeolocalizacionRepositoryImpl() : _dataSource = UbicacionesVehiculoDataSourceFactory.createSupabase();

  final UbicacionesVehiculoDataSource _dataSource;

  @override
  Future<List<UbicacionVehiculoEntity>> getUltimas() {
    debugPrint('📦 GeolocalizacionRepository: últimas posiciones...');
    return _dataSource.getUltimas();
  }

  @override
  Future<List<UbicacionVehiculoEntity>> getRecorrido(String vehiculoId, {required DateTime desde}) {
    return _dataSource.getRecorrido(vehiculoId, desde: desde);
  }

  @override
  Stream<UbicacionVehiculoEntity> watchNuevas() => _dataSource.watchNuevas();
}
