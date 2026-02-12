import '../incidencias_vehiculo/entities/incidencia_vehiculo_entity.dart';

/// Contrato de operaciones para Incidencias de Vehículos
abstract class IncidenciaVehiculoDataSource {
  /// Obtiene todas las incidencias
  Future<List<IncidenciaVehiculoEntity>> getAll();

  /// Obtiene una incidencia por ID
  Future<IncidenciaVehiculoEntity> getById(String id);

  /// Obtiene incidencias de un vehículo específico
  Future<List<IncidenciaVehiculoEntity>> getByVehiculoId(String vehiculoId);

  /// Obtiene incidencias filtradas por estado
  Future<List<IncidenciaVehiculoEntity>> getByEstado(EstadoIncidencia estado);

  /// Crea una nueva incidencia
  Future<IncidenciaVehiculoEntity> create(IncidenciaVehiculoEntity entity);

  /// Actualiza una incidencia existente
  Future<IncidenciaVehiculoEntity> update(IncidenciaVehiculoEntity entity);

  /// Elimina una incidencia
  Future<void> delete(String id);

  /// Stream en tiempo real de incidencias de un vehículo
  Stream<List<IncidenciaVehiculoEntity>> watchByVehiculoId(String vehiculoId);
}
