import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';

/// Seguimiento GPS de la flota
abstract class GeolocalizacionRepository {
  Future<List<UbicacionVehiculoEntity>> getUltimas();

  Future<List<UbicacionVehiculoEntity>> getRecorrido(String vehiculoId, {required DateTime desde});

  Stream<UbicacionVehiculoEntity> watchNuevas();
}
