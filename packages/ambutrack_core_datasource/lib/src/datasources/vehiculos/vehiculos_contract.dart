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

  /// Marca o quita la silla eléctrica de [vehiculoIds] modificando su stock
  /// (producto SILLA SUBE-ESCALERAS ELÉCTRICA). `tiene_silla_electrica` se
  /// recalcula en BD por trigger.
  Future<void> setSillaElectrica(List<String> vehiculoIds, {required bool tiene});
}
