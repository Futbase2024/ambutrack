import '../../core/base_datasource.dart';
import 'entities/especialidad_entity.dart';

/// Contrato para operaciones de datasource de especialidades médicas
abstract class EspecialidadDataSource extends BaseDatasource<EspecialidadEntity> {
  /// Obtiene solo especialidades activas
  Future<List<EspecialidadEntity>> getActivas();

  /// Filtra especialidades por tipo
  Future<List<EspecialidadEntity>> filterByTipo(String tipo);
}
