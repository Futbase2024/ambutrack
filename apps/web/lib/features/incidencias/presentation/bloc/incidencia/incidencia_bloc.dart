import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart'
    hide EstadoIncidencia, PrioridadIncidencia;
import 'package:ambutrack_core_datasource/incidencias.dart';
import 'package:ambutrack_web/features/incidencias/domain/repositories/incidencia_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import 'incidencia_event.dart';
import 'incidencia_state.dart';

/// BLoC para gestión de incidencias generales
@injectable
class IncidenciaBloc extends Bloc<IncidenciaEvent, IncidenciaState> {
  IncidenciaBloc(this._repository)
      : super(const IncidenciaInitial()) {
    on<IncidenciaLoadAllRequested>(_onLoadAll);
    on<IncidenciaCreateRequested>(_onCreate);
    on<IncidenciaUpdateRequested>(_onUpdate);
    on<IncidenciaDeleteRequested>(_onDelete);
    on<IncidenciaFilterRequested>(_onFilter);
  }

  final IncidenciaRepository _repository;

  Future<void> _onLoadAll(
    IncidenciaLoadAllRequested event,
    Emitter<IncidenciaState> emit,
  ) async {
    emit(const IncidenciaLoading());
    try {
      final List<IncidenciaEntity> incidencias = await _repository.getAll();
      debugPrint(
        '📋 IncidenciaBloc: Cargadas ${incidencias.length} incidencias',
      );
      emit(IncidenciaLoaded(
        allIncidencias: incidencias,
        filteredIncidencias: incidencias,
        filters: const IncidenciaFilters(),
      ));
    } catch (e) {
      debugPrint('❌ IncidenciaBloc: Error al cargar: $e');
      emit(IncidenciaError(e.toString()));
    }
  }

  Future<void> _onCreate(
    IncidenciaCreateRequested event,
    Emitter<IncidenciaState> emit,
  ) async {
    try {
      debugPrint('📋 IncidenciaBloc: Creando incidencia');
      await _repository.create(event.incidencia);
      add(const IncidenciaLoadAllRequested());
    } catch (e) {
      debugPrint('❌ IncidenciaBloc: Error al crear: $e');
      emit(IncidenciaError(e.toString()));
    }
  }

  Future<void> _onUpdate(
    IncidenciaUpdateRequested event,
    Emitter<IncidenciaState> emit,
  ) async {
    try {
      debugPrint('📋 IncidenciaBloc: Actualizando incidencia');
      await _repository.update(event.incidencia);
      add(const IncidenciaLoadAllRequested());
    } catch (e) {
      debugPrint('❌ IncidenciaBloc: Error al actualizar: $e');
      emit(IncidenciaError(e.toString()));
    }
  }

  Future<void> _onDelete(
    IncidenciaDeleteRequested event,
    Emitter<IncidenciaState> emit,
  ) async {
    try {
      debugPrint('📋 IncidenciaBloc: Eliminando incidencia ${event.id}');
      await _repository.delete(event.id);
      add(const IncidenciaLoadAllRequested());
    } catch (e) {
      debugPrint('❌ IncidenciaBloc: Error al eliminar: $e');
      emit(IncidenciaError(e.toString()));
    }
  }

  Future<void> _onFilter(
    IncidenciaFilterRequested event,
    Emitter<IncidenciaState> emit,
  ) async {
    final IncidenciaState current = state;
    if (current is! IncidenciaLoaded) {
      return;
    }

    final List<IncidenciaEntity> filtered = _applyFilters(current.allIncidencias, event.filters);
    emit(IncidenciaLoaded(
      allIncidencias: current.allIncidencias,
      filteredIncidencias: filtered,
      filters: event.filters,
    ));
  }

  List<IncidenciaEntity> _applyFilters(
    List<IncidenciaEntity> items,
    IncidenciaFilters filters,
  ) {
    List<IncidenciaEntity> result = items;

    // Filtro por búsqueda (título, descripción, responsable)
    if (filters.searchQuery.isNotEmpty) {
      final String query = filters.searchQuery.toLowerCase();
      result = result.where((IncidenciaEntity item) {
        final String titulo = item.titulo.toLowerCase();
        final String descripcion = (item.descripcion ?? '').toLowerCase();
        final String responsable = (item.responsableNombre ?? '').toLowerCase();
        return titulo.contains(query) ||
            descripcion.contains(query) ||
            responsable.contains(query);
      }).toList();
    }

    // Filtro por categoría
    if (filters.categoria != null) {
      result = result
          .where((IncidenciaEntity item) => item.categoria == filters.categoria)
          .toList();
    }

    // Filtro por prioridad
    if (filters.prioridad != null) {
      result = result
          .where((IncidenciaEntity item) => item.prioridad == filters.prioridad)
          .toList();
    }

    // Filtro por estado
    if (filters.estado != null) {
      result =
          result.where((IncidenciaEntity item) => item.estado == filters.estado).toList();
    }

    // Filtro por fecha desde
    if (filters.fechaDesde != null) {
      result = result
          .where((IncidenciaEntity item) =>
              item.fechaIncidencia.isAfter(filters.fechaDesde!) ||
              item.fechaIncidencia.isAtSameMomentAs(filters.fechaDesde!))
          .toList();
    }

    // Filtro por fecha hasta
    if (filters.fechaHasta != null) {
      result = result
          .where((IncidenciaEntity item) =>
              item.fechaIncidencia.isBefore(filters.fechaHasta!) ||
              item.fechaIncidencia.isAtSameMomentAs(filters.fechaHasta!))
          .toList();
    }

    return result;
  }
}
