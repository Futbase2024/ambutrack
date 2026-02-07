import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:equatable/equatable.dart';

/// Estados del BLoC de incidencias del vehículo.
sealed class IncidenciasState extends Equatable {
  const IncidenciasState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial.
final class IncidenciasInitial extends IncidenciasState {
  const IncidenciasInitial();
}

/// Cargando incidencias.
final class IncidenciasLoading extends IncidenciasState {
  const IncidenciasLoading();
}

/// Incidencias cargadas exitosamente.
final class IncidenciasLoaded extends IncidenciasState {
  const IncidenciasLoaded({
    required this.incidencias,
    this.filteredByVehiculo,
    this.filteredByEstado,
  });

  final List<IncidenciaVehiculoEntity> incidencias;
  final String? filteredByVehiculo;
  final EstadoIncidencia? filteredByEstado;

  /// Obtener incidencias reportadas.
  List<IncidenciaVehiculoEntity> get reportadas =>
      incidencias.where((i) => i.estado == EstadoIncidencia.reportada).toList();

  /// Obtener incidencias en revisión.
  List<IncidenciaVehiculoEntity> get enRevision => incidencias
      .where((i) => i.estado == EstadoIncidencia.enRevision)
      .toList();

  /// Obtener incidencias en reparación.
  List<IncidenciaVehiculoEntity> get enReparacion => incidencias
      .where((i) => i.estado == EstadoIncidencia.enReparacion)
      .toList();

  /// Obtener incidencias resueltas.
  List<IncidenciaVehiculoEntity> get resueltas =>
      incidencias.where((i) => i.estado == EstadoIncidencia.resuelta).toList();

  /// Obtener incidencias cerradas.
  List<IncidenciaVehiculoEntity> get cerradas =>
      incidencias.where((i) => i.estado == EstadoIncidencia.cerrada).toList();

  /// Obtener incidencias por prioridad crítica.
  List<IncidenciaVehiculoEntity> get criticas => incidencias
      .where((i) => i.prioridad == PrioridadIncidencia.critica)
      .toList();

  /// Obtener incidencias por prioridad alta.
  List<IncidenciaVehiculoEntity> get altas =>
      incidencias.where((i) => i.prioridad == PrioridadIncidencia.alta).toList();

  @override
  List<Object?> get props => [incidencias, filteredByVehiculo, filteredByEstado];
}

/// Error al cargar incidencias.
final class IncidenciasError extends IncidenciasState {
  const IncidenciasError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

/// Incidencia creada exitosamente.
final class IncidenciaCreated extends IncidenciasState {
  const IncidenciaCreated(this.incidencia);

  final IncidenciaVehiculoEntity incidencia;

  @override
  List<Object?> get props => [incidencia];
}

/// Incidencia actualizada exitosamente.
final class IncidenciaUpdated extends IncidenciasState {
  const IncidenciaUpdated(this.incidencia);

  final IncidenciaVehiculoEntity incidencia;

  @override
  List<Object?> get props => [incidencia];
}

/// Incidencia eliminada exitosamente.
final class IncidenciaDeleted extends IncidenciasState {
  const IncidenciaDeleted(this.id);

  final String id;

  @override
  List<Object?> get props => [id];
}
