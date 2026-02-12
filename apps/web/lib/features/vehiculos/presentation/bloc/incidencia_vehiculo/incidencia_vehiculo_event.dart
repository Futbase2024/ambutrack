import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'incidencia_vehiculo_event.freezed.dart';

/// Eventos del BLoC de incidencias de vehículos
@freezed
class IncidenciaVehiculoEvent with _$IncidenciaVehiculoEvent {
  /// Evento inicial - Carga incidencias al iniciar
  const factory IncidenciaVehiculoEvent.started() = _Started;

  /// Recargar incidencias desde el repositorio
  const factory IncidenciaVehiculoEvent.loadIncidencias() = _LoadIncidencias;

  /// Crear nueva incidencia
  const factory IncidenciaVehiculoEvent.createIncidencia(
    IncidenciaVehiculoEntity incidencia,
  ) = _CreateIncidencia;

  /// Actualizar incidencia existente
  const factory IncidenciaVehiculoEvent.updateIncidencia(
    IncidenciaVehiculoEntity incidencia,
  ) = _UpdateIncidencia;

  /// Eliminar incidencia por ID
  const factory IncidenciaVehiculoEvent.deleteIncidencia(String id) =
      _DeleteIncidencia;

  /// Filtrar por estado
  const factory IncidenciaVehiculoEvent.filterByEstado(
    EstadoIncidencia? estado,
  ) = _FilterByEstado;

  /// Filtrar por prioridad
  const factory IncidenciaVehiculoEvent.filterByPrioridad(
    PrioridadIncidencia? prioridad,
  ) = _FilterByPrioridad;

  /// Filtrar por tipo
  const factory IncidenciaVehiculoEvent.filterByTipo(
    TipoIncidencia? tipo,
  ) = _FilterByTipo;

  /// Limpiar todos los filtros
  const factory IncidenciaVehiculoEvent.clearFilters() = _ClearFilters;

  /// Cambiar página de la paginación
  const factory IncidenciaVehiculoEvent.changePage(int page) = _ChangePage;
}
