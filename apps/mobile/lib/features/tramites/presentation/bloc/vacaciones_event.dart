import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:equatable/equatable.dart';

/// Eventos del BLoC de vacaciones.
sealed class VacacionesEvent extends Equatable {
  const VacacionesEvent();

  @override
  List<Object?> get props => [];
}

/// Cargar todas las vacaciones.
final class VacacionesLoadRequested extends VacacionesEvent {
  const VacacionesLoadRequested();
}

/// Cargar vacaciones de un personal específico.
final class VacacionesLoadByPersonalRequested extends VacacionesEvent {
  const VacacionesLoadByPersonalRequested(this.idPersonal);

  final String idPersonal;

  @override
  List<Object?> get props => [idPersonal];
}

/// Crear una nueva solicitud de vacaciones.
final class VacacionesCreateRequested extends VacacionesEvent {
  const VacacionesCreateRequested(this.vacacion);

  final VacacionesEntity vacacion;

  @override
  List<Object?> get props => [vacacion];
}

/// Actualizar una solicitud de vacaciones.
final class VacacionesUpdateRequested extends VacacionesEvent {
  const VacacionesUpdateRequested(this.vacacion);

  final VacacionesEntity vacacion;

  @override
  List<Object?> get props => [vacacion];
}

/// Eliminar/Cancelar una solicitud de vacaciones.
final class VacacionesDeleteRequested extends VacacionesEvent {
  const VacacionesDeleteRequested(this.id);

  final String id;

  @override
  List<Object?> get props => [id];
}

/// Observar vacaciones en tiempo real.
final class VacacionesWatchRequested extends VacacionesEvent {
  const VacacionesWatchRequested();
}

/// Observar vacaciones de un personal en tiempo real.
final class VacacionesWatchByPersonalRequested extends VacacionesEvent {
  const VacacionesWatchByPersonalRequested(this.idPersonal);

  final String idPersonal;

  @override
  List<Object?> get props => [idPersonal];
}
