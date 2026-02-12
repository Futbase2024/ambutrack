import '../../core/base_datasource.dart';
import 'entities/base_entity.dart';

/// Contrato para operaciones de datasource de bases/centros operativos
///
/// Extiende [BaseDatasource] con operaciones específicas de bases
/// Todas las implementaciones deben adherirse a este contrato
abstract class BasesDataSource extends BaseDatasource<BaseCentroEntity> {
  /// Obtiene solo bases activas
  ///
  /// Devuelve lista de bases con activo = true
  Future<List<BaseCentroEntity>> getActivas();

  /// Obtiene bases por población
  ///
  /// [poblacionId] - ID de la población/localidad
  /// Devuelve lista de bases en esa población
  Future<List<BaseCentroEntity>> getByPoblacion(String poblacionId);

  /// Desactiva una base
  ///
  /// Establece activo a false sin eliminar los datos de la base
  Future<BaseCentroEntity> deactivateBase(String baseId);

  /// Reactiva una base
  ///
  /// Establece activo a true
  Future<BaseCentroEntity> reactivateBase(String baseId);
}
