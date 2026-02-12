import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/features/vehiculos/domain/repositories/incidencia_vehiculo_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import 'incidencia_vehiculo_event.dart';
import 'incidencia_vehiculo_state.dart';

/// BLoC para gestión de incidencias de vehículos
@injectable
class IncidenciaVehiculoBloc
    extends Bloc<IncidenciaVehiculoEvent, IncidenciaVehiculoState> {
  IncidenciaVehiculoBloc(this._repository)
      : super(const IncidenciaVehiculoState.initial()) {
    on<IncidenciaVehiculoEvent>(_onEvent);
  }

  final IncidenciaVehiculoRepository _repository;
  static const int _itemsPerPage = 25;

  List<IncidenciaVehiculoEntity> _allIncidencias = <IncidenciaVehiculoEntity>[];
  EstadoIncidencia? _filtroEstado;
  PrioridadIncidencia? _filtroPrioridad;
  TipoIncidencia? _filtroTipo;

  Future<void> _onEvent(
    IncidenciaVehiculoEvent event,
    Emitter<IncidenciaVehiculoState> emit,
  ) async {
    await event.when<Future<void>>(
      started: () => _onStarted(emit),
      loadIncidencias: () => _onLoadIncidencias(emit),
      createIncidencia: (IncidenciaVehiculoEntity incidencia) =>
          _onCreateIncidencia(emit, incidencia: incidencia),
      updateIncidencia: (IncidenciaVehiculoEntity incidencia) =>
          _onUpdateIncidencia(emit, incidencia: incidencia),
      deleteIncidencia: (String id) => _onDeleteIncidencia(emit, id: id),
      filterByEstado: (EstadoIncidencia? estado) =>
          _onFilterByEstado(emit, estado: estado),
      filterByPrioridad: (PrioridadIncidencia? prioridad) =>
          _onFilterByPrioridad(emit, prioridad: prioridad),
      filterByTipo: (TipoIncidencia? tipo) => _onFilterByTipo(emit, tipo: tipo),
      clearFilters: () => _onClearFilters(emit),
      changePage: (int page) => _onChangePage(emit, page: page),
    );
  }

  Future<void> _onStarted(Emitter<IncidenciaVehiculoState> emit) async {
    debugPrint('🔷 IncidenciaVehiculoBloc: Iniciando...');
    emit(const IncidenciaVehiculoState.loading());
    await _loadAndEmit(emit);
  }

  Future<void> _onLoadIncidencias(
    Emitter<IncidenciaVehiculoState> emit,
  ) async {
    debugPrint('🔷 IncidenciaVehiculoBloc: Recargando incidencias...');
    emit(const IncidenciaVehiculoState.loading());
    await _loadAndEmit(emit);
  }

  Future<void> _onCreateIncidencia(
    Emitter<IncidenciaVehiculoState> emit, {
    required IncidenciaVehiculoEntity incidencia,
  }) async {
    debugPrint(
      '🔷 IncidenciaVehiculoBloc: Creando incidencia para vehículo: ${incidencia.vehiculoId}',
    );
    try {
      await _repository.create(incidencia);
      debugPrint('🔷 IncidenciaVehiculoBloc: ✅ Incidencia creada exitosamente');
      await _loadAndEmit(emit);
    } catch (e) {
      debugPrint('🔷 IncidenciaVehiculoBloc: ❌ Error al crear: $e');
      emit(IncidenciaVehiculoState.error(e.toString()));
    }
  }

  Future<void> _onUpdateIncidencia(
    Emitter<IncidenciaVehiculoState> emit, {
    required IncidenciaVehiculoEntity incidencia,
  }) async {
    debugPrint(
      '🔷 IncidenciaVehiculoBloc: Actualizando incidencia ID: ${incidencia.id}',
    );
    try {
      await _repository.update(incidencia);
      debugPrint(
        '🔷 IncidenciaVehiculoBloc: ✅ Incidencia actualizada exitosamente',
      );
      await _loadAndEmit(emit);
    } catch (e) {
      debugPrint('🔷 IncidenciaVehiculoBloc: ❌ Error al actualizar: $e');
      emit(IncidenciaVehiculoState.error(e.toString()));
    }
  }

  Future<void> _onDeleteIncidencia(
    Emitter<IncidenciaVehiculoState> emit, {
    required String id,
  }) async {
    debugPrint(
      '🔷 IncidenciaVehiculoBloc: Eliminando incidencia ID: $id',
    );
    try {
      await _repository.delete(id);
      debugPrint(
        '🔷 IncidenciaVehiculoBloc: ✅ Incidencia eliminada exitosamente',
      );
      await _loadAndEmit(emit);
    } catch (e) {
      debugPrint('🔷 IncidenciaVehiculoBloc: ❌ Error al eliminar: $e');
      emit(IncidenciaVehiculoState.error(e.toString()));
    }
  }

  Future<void> _onFilterByEstado(
    Emitter<IncidenciaVehiculoState> emit, {
    required EstadoIncidencia? estado,
  }) async {
    debugPrint(
      '🔷 IncidenciaVehiculoBloc: Filtrando por estado: ${estado?.nombre ?? "Todos"}',
    );
    _filtroEstado = estado;
    await _loadAndEmit(emit, resetPage: true);
  }

  Future<void> _onFilterByPrioridad(
    Emitter<IncidenciaVehiculoState> emit, {
    required PrioridadIncidencia? prioridad,
  }) async {
    debugPrint(
      '🔷 IncidenciaVehiculoBloc: Filtrando por prioridad: ${prioridad?.nombre ?? "Todas"}',
    );
    _filtroPrioridad = prioridad;
    await _loadAndEmit(emit, resetPage: true);
  }

  Future<void> _onFilterByTipo(
    Emitter<IncidenciaVehiculoState> emit, {
    required TipoIncidencia? tipo,
  }) async {
    debugPrint(
      '🔷 IncidenciaVehiculoBloc: Filtrando por tipo: ${tipo?.nombre ?? "Todos"}',
    );
    _filtroTipo = tipo;
    await _loadAndEmit(emit, resetPage: true);
  }

  Future<void> _onClearFilters(Emitter<IncidenciaVehiculoState> emit) async {
    debugPrint('🔷 IncidenciaVehiculoBloc: Limpiando filtros...');
    _filtroEstado = null;
    _filtroPrioridad = null;
    _filtroTipo = null;
    await _loadAndEmit(emit, resetPage: true);
  }

  Future<void> _onChangePage(
    Emitter<IncidenciaVehiculoState> emit, {
    required int page,
  }) async {
    debugPrint('🔷 IncidenciaVehiculoBloc: Cambiando a página $page');
    await _loadAndEmit(emit, pageOverride: page);
  }

  Future<void> _loadAndEmit(
    Emitter<IncidenciaVehiculoState> emit, {
    bool resetPage = false,
    int? pageOverride,
  }) async {
    try {
      _allIncidencias = await _repository.getAll();
      debugPrint(
        '🔷 IncidenciaVehiculoBloc: ✅ ${_allIncidencias.length} incidencias cargadas',
      );

      // Aplicar filtros
      List<IncidenciaVehiculoEntity> incidenciasFiltradas = _allIncidencias;

      if (_filtroEstado != null) {
        incidenciasFiltradas = incidenciasFiltradas
            .where((IncidenciaVehiculoEntity i) => i.estado == _filtroEstado)
            .toList();
        debugPrint(
          '🔷 IncidenciaVehiculoBloc: Filtro estado aplicado: ${incidenciasFiltradas.length} resultados',
        );
      }

      if (_filtroPrioridad != null) {
        incidenciasFiltradas = incidenciasFiltradas
            .where((IncidenciaVehiculoEntity i) => i.prioridad == _filtroPrioridad)
            .toList();
        debugPrint(
          '🔷 IncidenciaVehiculoBloc: Filtro prioridad aplicado: ${incidenciasFiltradas.length} resultados',
        );
      }

      if (_filtroTipo != null) {
        incidenciasFiltradas = incidenciasFiltradas
            .where((IncidenciaVehiculoEntity i) => i.tipo == _filtroTipo)
            .toList();
        debugPrint(
          '🔷 IncidenciaVehiculoBloc: Filtro tipo aplicado: ${incidenciasFiltradas.length} resultados',
        );
      }

      // Calcular paginación
      final int totalItems = incidenciasFiltradas.length;
      final int totalPages = (totalItems / _itemsPerPage).ceil();

      int currentPage = 1;
      if (resetPage) {
        currentPage = 1;
      } else if (pageOverride != null) {
        currentPage = pageOverride.clamp(1, totalPages > 0 ? totalPages : 1);
      } else {
        // Usar pattern matching de Freezed para acceder a currentPage del estado loaded
        currentPage = state.maybeWhen(
          loaded: (
            List<IncidenciaVehiculoEntity> incidencias,
            int currentPage,
            int totalPages,
            EstadoIncidencia? filtroEstado,
            PrioridadIncidencia? filtroPrioridad,
            TipoIncidencia? filtroTipo,
          ) =>
              currentPage,
          orElse: () => 1,
        );
        currentPage = currentPage.clamp(1, totalPages > 0 ? totalPages : 1);
      }

      // Obtener items de la página actual
      final int startIndex = (currentPage - 1) * _itemsPerPage;
      final int endIndex = (startIndex + _itemsPerPage).clamp(0, totalItems);

      final List<IncidenciaVehiculoEntity> paginatedItems =
          incidenciasFiltradas.sublist(
        startIndex.clamp(0, totalItems),
        endIndex,
      );

      debugPrint(
        '🔷 IncidenciaVehiculoBloc: Página $currentPage de $totalPages (${paginatedItems.length} items)',
      );

      emit(
        IncidenciaVehiculoState.loaded(
          incidencias: paginatedItems,
          currentPage: currentPage,
          totalPages: totalPages,
          filtroEstado: _filtroEstado,
          filtroPrioridad: _filtroPrioridad,
          filtroTipo: _filtroTipo,
        ),
      );
    } catch (e) {
      debugPrint('🔷 IncidenciaVehiculoBloc: ❌ Error al cargar: $e');
      emit(IncidenciaVehiculoState.error(e.toString()));
    }
  }
}
