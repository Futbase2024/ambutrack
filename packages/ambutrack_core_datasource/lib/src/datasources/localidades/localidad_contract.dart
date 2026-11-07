import '../../core/base_datasource.dart';
import 'entities/localidad_entity.dart';

/// Contrato para operaciones de datasource de localidades
abstract class LocalidadDataSource extends BaseDatasource<LocalidadEntity> {
  /// Obtiene localidades filtradas por provincia
  Future<List<LocalidadEntity>> getByProvincia(String provinciaId);
}
