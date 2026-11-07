import '../../core/base_datasource.dart';
import 'entities/tipo_traslado_entity.dart';

/// Contrato para el DataSource de tipos de traslado
abstract class TipoTrasladoDataSource implements BaseDatasource<TipoTrasladoEntity> {
  /// Obtiene todos los tipos de traslado activos
  Future<List<TipoTrasladoEntity>> getActivos();
}
