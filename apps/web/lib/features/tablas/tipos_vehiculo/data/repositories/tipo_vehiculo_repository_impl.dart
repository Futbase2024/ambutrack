import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/features/tablas/tipos_vehiculo/domain/repositories/tipo_vehiculo_repository.dart';
import 'package:injectable/injectable.dart';

/// Implementación del repositorio de tipos de vehículo (pass-through a core datasource)
@LazySingleton(as: TipoVehiculoRepository)
class TipoVehiculoRepositoryImpl implements TipoVehiculoRepository {
  TipoVehiculoRepositoryImpl()
      : _dataSource = TipoVehiculoDataSourceFactory.createSupabase();

  final TipoVehiculoDataSource _dataSource;

  @override
  Future<List<TipoVehiculoEntity>> getAll() async {
    return _dataSource.getAll();
  }

  @override
  Future<TipoVehiculoEntity?> getById(String id) async {
    return _dataSource.getById(id);
  }

  @override
  Future<TipoVehiculoEntity> create(TipoVehiculoEntity tipoVehiculo) async {
    return _dataSource.create(tipoVehiculo);
  }

  @override
  Future<TipoVehiculoEntity> update(TipoVehiculoEntity tipoVehiculo) async {
    return _dataSource.update(tipoVehiculo);
  }

  @override
  Future<void> delete(String id) async {
    return _dataSource.delete(id);
  }

  @override
  Future<List<TipoVehiculoEntity>> getActivos() async {
    return _dataSource.getActivos();
  }
}
