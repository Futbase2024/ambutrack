import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:equatable/equatable.dart';

import 'incidencia_event.dart';

/// Estado base para el BLoC de incidencias
abstract class IncidenciaState extends Equatable {
  const IncidenciaState();

  @override
  List<Object?> get props => <Object?>[];
}

/// Estado inicial
class IncidenciaInitial extends IncidenciaState {
  const IncidenciaInitial();
}

/// Cargando datos
class IncidenciaLoading extends IncidenciaState {
  const IncidenciaLoading();
}

/// Datos cargados
class IncidenciaLoaded extends IncidenciaState {
  const IncidenciaLoaded({
    required this.allIncidencias,
    required this.filteredIncidencias,
    required this.filters,
  });

  final List<IncidenciaEntity> allIncidencias;
  final List<IncidenciaEntity> filteredIncidencias;
  final IncidenciaFilters filters;

  @override
  List<Object?> get props => <Object?>[allIncidencias, filteredIncidencias, filters];
}

/// Error
class IncidenciaError extends IncidenciaState {
  const IncidenciaError(this.message);

  final String message;

  @override
  List<Object?> get props => <Object?>[message];
}
