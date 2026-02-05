import '../../core/base_datasource.dart';
import 'entities/facultativo_entity.dart';

/// Contrato para el datasource de facultativos médicos
///
/// Extiende BaseDatasource para operaciones CRUD estándar y define
/// métodos específicos para facultativos.
abstract class FacultativoDataSource
    implements BaseDatasource<FacultativoEntity> {
  /// Obtiene todos los facultativos activos
  ///
  /// Incluye el JOIN con tespecialidades para obtener el nombre de la especialidad.
  /// Retorna una lista de facultativos con activo = true.
  Future<List<FacultativoEntity>> getActivos();

  /// Filtra facultativos por especialidad
  ///
  /// [especialidadId] - ID de la especialidad a filtrar
  /// Incluye el JOIN con tespecialidades para obtener el nombre de la especialidad.
  Future<List<FacultativoEntity>> filterByEspecialidad(String especialidadId);
}
