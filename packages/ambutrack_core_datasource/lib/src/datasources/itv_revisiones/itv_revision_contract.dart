import '../../core/base_datasource.dart';
import 'entities/itv_revision_entity.dart';

/// Contrato para el DataSource de ITV y Revisiones
abstract class ItvRevisionDataSource extends BaseDatasource<ItvRevisionEntity> {
  /// Obtiene todas las ITV/Revisiones de un vehículo específico
  Future<List<ItvRevisionEntity>> getByVehiculo(String vehiculoId);

  /// Obtiene ITV/Revisiones próximas a vencer en los próximos [dias] días
  Future<List<ItvRevisionEntity>> getProximasVencer(int dias);
}
