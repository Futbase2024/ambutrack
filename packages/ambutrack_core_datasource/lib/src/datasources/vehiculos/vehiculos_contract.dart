import '../../core/base_datasource.dart';
import 'entities/vehiculos_entity.dart';

/// Contrato para operaciones de datasource de vehículos
///
/// Extiende [BaseDatasource] con operaciones específicas de vehículos
/// Todas las implementaciones deben adherirse a este contrato
abstract class VehiculoDataSource extends BaseDatasource<VehiculoEntity> {
  /// Busca vehículos por matrícula (búsqueda parcial)
  ///
  /// [matricula] - Matrícula a buscar (permite búsqueda parcial)
  /// Devuelve lista de vehículos que coinciden
  Future<List<VehiculoEntity>> searchByMatricula(String matricula);

  /// Obtiene vehículos por estado
  ///
  /// [estado] - Estado del vehículo
  /// Devuelve lista de vehículos que coinciden con el estado
  Future<List<VehiculoEntity>> getByEstado(VehiculoEstado estado);

}
