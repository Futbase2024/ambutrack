import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:equatable/equatable.dart';

/// Eventos del BLoC de incidencias del vehículo.
sealed class IncidenciasEvent extends Equatable {
  const IncidenciasEvent();

  @override
  List<Object?> get props => [];
}

/// Cargar todas las incidencias.
final class IncidenciasLoadRequested extends IncidenciasEvent {
  const IncidenciasLoadRequested();
}

/// Cargar incidencias de un vehículo específico.
final class IncidenciasLoadByVehiculoRequested extends IncidenciasEvent {
  const IncidenciasLoadByVehiculoRequested(this.vehiculoId);

  final String vehiculoId;

  @override
  List<Object?> get props => [vehiculoId];
}

/// Cargar incidencias por estado.
final class IncidenciasLoadByEstadoRequested extends IncidenciasEvent {
  const IncidenciasLoadByEstadoRequested(this.estado);

  final EstadoIncidencia estado;

  @override
  List<Object?> get props => [estado];
}

/// Crear una nueva incidencia.
final class IncidenciasCreateRequested extends IncidenciasEvent {
  const IncidenciasCreateRequested(this.incidencia);

  final IncidenciaVehiculoEntity incidencia;

  @override
  List<Object?> get props => [incidencia];
}

/// Actualizar una incidencia.
final class IncidenciasUpdateRequested extends IncidenciasEvent {
  const IncidenciasUpdateRequested(this.incidencia);

  final IncidenciaVehiculoEntity incidencia;

  @override
  List<Object?> get props => [incidencia];
}

/// Eliminar una incidencia.
final class IncidenciasDeleteRequested extends IncidenciasEvent {
  const IncidenciasDeleteRequested(this.id);

  final String id;

  @override
  List<Object?> get props => [id];
}

/// Observar incidencias de un vehículo en tiempo real.
final class IncidenciasWatchByVehiculoRequested extends IncidenciasEvent {
  const IncidenciasWatchByVehiculoRequested(this.vehiculoId);

  final String vehiculoId;

  @override
  List<Object?> get props => [vehiculoId];
}
