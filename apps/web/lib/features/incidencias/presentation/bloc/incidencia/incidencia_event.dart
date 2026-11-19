import 'package:ambutrack_core_datasource/incidencias.dart';
import 'package:equatable/equatable.dart';

/// Filtros para incidencias
class IncidenciaFilters extends Equatable {

  const IncidenciaFilters({
    this.searchQuery = '',
    this.categoria,
    this.prioridad,
    this.estado,
    this.fechaDesde,
    this.fechaHasta,
  });
  final String searchQuery;
  final CategoriaIncidencia? categoria;
  final PrioridadIncidencia? prioridad;
  final EstadoIncidencia? estado;
  final DateTime? fechaDesde;
  final DateTime? fechaHasta;

  bool get hasActiveFilters =>
      searchQuery.isNotEmpty ||
      categoria != null ||
      prioridad != null ||
      estado != null ||
      fechaDesde != null ||
      fechaHasta != null;

  IncidenciaFilters copyWith({
    String? Function()? searchQuery,
    CategoriaIncidencia? Function()? categoria,
    PrioridadIncidencia? Function()? prioridad,
    EstadoIncidencia? Function()? estado,
    DateTime? Function()? fechaDesde,
    DateTime? Function()? fechaHasta,
  }) {
    return IncidenciaFilters(
      searchQuery: searchQuery != null ? searchQuery() ?? '' : this.searchQuery,
      categoria: categoria != null ? categoria() : this.categoria,
      prioridad: prioridad != null ? prioridad() : this.prioridad,
      estado: estado != null ? estado() : this.estado,
      fechaDesde: fechaDesde != null ? fechaDesde() : this.fechaDesde,
      fechaHasta: fechaHasta != null ? fechaHasta() : this.fechaHasta,
    );
  }

  @override
  List<Object?> get props => <Object?>[
        searchQuery,
        categoria,
        prioridad,
        estado,
        fechaDesde,
        fechaHasta,
      ];
}

/// Evento base para el BLoC de incidencias
abstract class IncidenciaEvent extends Equatable {
  const IncidenciaEvent();

  @override
  List<Object?> get props => <Object?>[];
}

/// Cargar todas las incidencias
class IncidenciaLoadAllRequested extends IncidenciaEvent {
  const IncidenciaLoadAllRequested();
}

/// Crear una nueva incidencia
class IncidenciaCreateRequested extends IncidenciaEvent {
  const IncidenciaCreateRequested(this.incidencia);

  final IncidenciaEntity incidencia;

  @override
  List<Object?> get props => <Object?>[incidencia];
}

/// Actualizar una incidencia existente
class IncidenciaUpdateRequested extends IncidenciaEvent {
  const IncidenciaUpdateRequested(this.incidencia);

  final IncidenciaEntity incidencia;

  @override
  List<Object?> get props => <Object?>[incidencia];
}

/// Eliminar una incidencia
class IncidenciaDeleteRequested extends IncidenciaEvent {
  const IncidenciaDeleteRequested(this.id);

  final String id;

  @override
  List<Object?> get props => <Object?>[id];
}

/// Aplicar filtros a las incidencias
class IncidenciaFilterRequested extends IncidenciaEvent {
  const IncidenciaFilterRequested(this.filters);

  final IncidenciaFilters filters;

  @override
  List<Object?> get props => <Object?>[filters];
}
