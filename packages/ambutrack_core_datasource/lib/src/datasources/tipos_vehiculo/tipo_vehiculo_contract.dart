import '../../core/base_datasource.dart';
import 'entities/tipo_vehiculo_entity.dart';

/// Contrato para el datasource de tipos de vehículo
abstract class TipoVehiculoDataSource extends BaseDatasource<TipoVehiculoEntity> {
  /// Obtiene solo los tipos de vehículo activos
  Future<List<TipoVehiculoEntity>> getActivos();
}
