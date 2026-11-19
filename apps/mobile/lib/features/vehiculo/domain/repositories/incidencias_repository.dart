import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';

/// Contrato del repositorio de incidencias del vehículo.
abstract class IncidenciasRepository {
  /// Obtener todas las incidencias.
  Future<List<IncidenciaVehiculoEntity>> getAll();

  /// Obtener incidencia por ID.
  Future<IncidenciaVehiculoEntity> getById(String id);

  /// Obtener incidencias de un vehículo específico.
  Future<List<IncidenciaVehiculoEntity>> getByVehiculoId(String vehiculoId);

  /// Obtener incidencias por estado.
  Future<List<IncidenciaVehiculoEntity>> getByEstado(EstadoIncidencia estado);

  /// Crear una nueva incidencia.
  Future<IncidenciaVehiculoEntity> create(IncidenciaVehiculoEntity incidencia);

  /// Actualizar una incidencia existente.
  Future<IncidenciaVehiculoEntity> update(IncidenciaVehiculoEntity incidencia);

  /// Eliminar una incidencia.
  Future<void> delete(String id);

  /// Observar incidencias de un vehículo en tiempo real.
  Stream<List<IncidenciaVehiculoEntity>> watchByVehiculoId(String vehiculoId);
}
