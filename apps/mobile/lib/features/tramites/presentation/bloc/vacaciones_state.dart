import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:equatable/equatable.dart';

/// Estados del BLoC de vacaciones.
sealed class VacacionesState extends Equatable {
  const VacacionesState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial.
final class VacacionesInitial extends VacacionesState {
  const VacacionesInitial();
}

/// Cargando vacaciones.
final class VacacionesLoading extends VacacionesState {
  const VacacionesLoading();
}

/// Vacaciones cargadas exitosamente.
final class VacacionesLoaded extends VacacionesState {
  const VacacionesLoaded({
    required this.vacaciones,
    this.filteredByPersonal,
  });

  final List<VacacionesEntity> vacaciones;
  final String? filteredByPersonal;

  /// Obtener vacaciones pendientes.
  List<VacacionesEntity> get pendientes =>
      vacaciones.where((v) => v.estado == 'pendiente' && v.activo).toList();

  /// Obtener vacaciones aprobadas.
  List<VacacionesEntity> get aprobadas =>
      vacaciones.where((v) => v.estado == 'aprobada' && v.activo).toList();

  /// Obtener vacaciones rechazadas.
  List<VacacionesEntity> get rechazadas =>
      vacaciones.where((v) => v.estado == 'rechazada' && v.activo).toList();

  /// Obtener total de días de vacaciones.
  int get totalDias =>
      vacaciones.fold(0, (sum, v) => sum + (v.activo ? v.diasSolicitados : 0));

  @override
  List<Object?> get props => [vacaciones, filteredByPersonal];
}

/// Error al cargar vacaciones.
final class VacacionesError extends VacacionesState {
  const VacacionesError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

/// Vacación creada exitosamente.
final class VacacionCreated extends VacacionesState {
  const VacacionCreated(this.vacacion);

  final VacacionesEntity vacacion;

  @override
  List<Object?> get props => [vacacion];
}

/// Vacación actualizada exitosamente.
final class VacacionUpdated extends VacacionesState {
  const VacacionUpdated(this.vacacion);

  final VacacionesEntity vacacion;

  @override
  List<Object?> get props => [vacacion];
}

/// Vacación eliminada exitosamente.
final class VacacionDeleted extends VacacionesState {
  const VacacionDeleted(this.id);

  final String id;

  @override
  List<Object?> get props => [id];
}
