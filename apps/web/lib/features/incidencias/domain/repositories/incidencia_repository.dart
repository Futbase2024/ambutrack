import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';

/// Repositorio abstracto de incidencias
abstract class IncidenciaRepository {
  /// Obtener todas las incidencias
  Future<List<IncidenciaEntity>> getAll();

  /// Obtener una incidencia por ID
  Future<IncidenciaEntity?> getById(String id);

  /// Crear una nueva incidencia
  Future<IncidenciaEntity> create(IncidenciaEntity incidencia);

  /// Actualizar una incidencia existente
  Future<IncidenciaEntity> update(IncidenciaEntity incidencia);

  /// Eliminar una incidencia
  Future<void> delete(String id);

  /// Stream en tiempo real de todas las incidencias
  Stream<List<IncidenciaEntity>> watchAll();
}
