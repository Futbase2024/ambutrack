import 'package:ambutrack_core/ambutrack_core.dart';
import 'package:equatable/equatable.dart';

/// Eventos del BLoC de Vacaciones
abstract class VacacionesEvent extends Equatable {
  const VacacionesEvent();

  @override
  List<Object?> get props => <Object?>[];
}

/// Solicitar carga de todas las vacaciones
class VacacionesLoadRequested extends VacacionesEvent {
  const VacacionesLoadRequested();
}

/// Solicitar carga de vacaciones de un año específico
class VacacionesLoadByYearRequested extends VacacionesEvent {
  const VacacionesLoadByYearRequested(this.year);

  final int year;

  @override
  List<Object?> get props => <Object?>[year];
}

/// Solicitar creación de una nueva vacación
class VacacionesCreateRequested extends VacacionesEvent {
  const VacacionesCreateRequested(this.vacacion);

  final VacacionesEntity vacacion;

  @override
  List<Object?> get props => <Object?>[vacacion];
}

/// Solicitar actualización de una vacación
class VacacionesUpdateRequested extends VacacionesEvent {
  const VacacionesUpdateRequested(this.vacacion);

  final VacacionesEntity vacacion;

  @override
  List<Object?> get props => <Object?>[vacacion];
}

/// Solicitar eliminación de una vacación
class VacacionesDeleteRequested extends VacacionesEvent {
  const VacacionesDeleteRequested(this.id);

  final String id;

  @override
  List<Object?> get props => <Object?>[id];
}

/// Solicitar filtrar por personal
class VacacionesFilterByPersonalRequested extends VacacionesEvent {
  const VacacionesFilterByPersonalRequested(this.idPersonal);

  final String? idPersonal;

  @override
  List<Object?> get props => <Object?>[idPersonal];
}

/// Solicitar eliminación parcial de días de una vacación
///
/// Permite eliminar un rango de días específico de una vacación existente.
/// Si se elimina desde el inicio, se ajusta la fechaInicio.
/// Si se elimina desde el final, se ajusta la fechaFin.
/// Si se elimina del medio, se divide en dos vacaciones.
class VacacionEliminarDiasParcialRequested extends VacacionesEvent {
  const VacacionEliminarDiasParcialRequested({
    required this.vacacion,
    required this.fechaInicioEliminar,
    required this.fechaFinEliminar,
  });

  final VacacionesEntity vacacion;
  final DateTime fechaInicioEliminar;
  final DateTime fechaFinEliminar;

  @override
  List<Object?> get props => <Object?>[vacacion, fechaInicioEliminar, fechaFinEliminar];
}
