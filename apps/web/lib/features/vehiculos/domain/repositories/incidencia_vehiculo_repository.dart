import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';

/// Repositorio abstracto de incidencias de vehículos
abstract class IncidenciaVehiculoRepository {
  /// Obtener todas las incidencias
  Future<List<IncidenciaVehiculoEntity>> getAll();

  /// Obtener una incidencia por ID
  Future<IncidenciaVehiculoEntity> getById(String id);

  /// Obtener incidencias de un vehículo específico
  Future<List<IncidenciaVehiculoEntity>> getByVehiculoId(String vehiculoId);

  /// Obtener incidencias filtradas por estado
  Future<List<IncidenciaVehiculoEntity>> getByEstado(EstadoIncidencia estado);

  /// Crear una nueva incidencia
  ///
  /// Valida que el kilometraje reportado NO sea inferior al kilometraje actual
  /// del vehículo y actualiza el kilometraje del vehículo automáticamente.
  ///
  /// Lanza [ArgumentError] si el kilometraje es inferior al actual.
  Future<IncidenciaVehiculoEntity> create(IncidenciaVehiculoEntity incidencia);

  /// Actualizar una incidencia existente
  Future<IncidenciaVehiculoEntity> update(IncidenciaVehiculoEntity incidencia);

  /// Eliminar una incidencia
  Future<void> delete(String id);

  /// Reenvía el aviso (notificación + push) de la avería a los gestores de flota.
  /// Devuelve a cuántos gestores se avisó.
  Future<int> reenviarAviso(String id);

  /// Stream en tiempo real de incidencias de un vehículo
  Stream<List<IncidenciaVehiculoEntity>> watchByVehiculoId(String vehiculoId);
}
