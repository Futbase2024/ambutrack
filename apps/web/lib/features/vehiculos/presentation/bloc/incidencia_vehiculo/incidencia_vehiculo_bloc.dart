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
    _emitFiltered(emit);
  }

  Future<void> _onFilterByPrioridad(
    Emitter<IncidenciaVehiculoState> emit, {
    required PrioridadIncidencia? prioridad,
  }) async {
    debugPrint(
      '🔷 IncidenciaVehiculoBloc: Filtrando por prioridad: ${prioridad?.nombre ?? "Todas"}',
    );
    _filtroPrioridad = prioridad;
    _emitFiltered(emit);
  }

  Future<void> _onFilterByTipo(
    Emitter<IncidenciaVehiculoState> emit, {
    required TipoIncidencia? tipo,
  }) async {
    debugPrint(
      '🔷 IncidenciaVehiculoBloc: Filtrando por tipo: ${tipo?.nombre ?? "Todos"}',
    );
    _filtroTipo = tipo;
    _emitFiltered(emit);
  }

  Future<void> _onClearFilters(Emitter<IncidenciaVehiculoState> emit) async {
    debugPrint('🔷 IncidenciaVehiculoBloc: Limpiando filtros...');
    _filtroEstado = null;
    _filtroPrioridad = null;
    _filtroTipo = null;
    _emitFiltered(emit);
  }

  /// La paginación se hace en la vista (client-side) sobre el listado completo:
  /// el evento se mantiene por compatibilidad y solo reemite el estado actual.
  Future<void> _onChangePage(
    Emitter<IncidenciaVehiculoState> emit, {
    required int page,
  }) async {
    debugPrint('🔷 IncidenciaVehiculoBloc: changePage($page) ignorado (paginación en la vista)');
    _emitFiltered(emit);
  }

  /// Recarga todas las incidencias del repositorio y emite el listado filtrado
  Future<void> _loadAndEmit(Emitter<IncidenciaVehiculoState> emit) async {
    try {
      _allIncidencias = await _repository.getAll();
      debugPrint(
        '🔷 IncidenciaVehiculoBloc: ✅ ${_allIncidencias.length} incidencias cargadas',
      );
      _emitFiltered(emit);
    } catch (e) {
      debugPrint('🔷 IncidenciaVehiculoBloc: ❌ Error al cargar: $e');
      emit(IncidenciaVehiculoState.error(e.toString()));
    }
  }

  /// Emite el listado COMPLETO filtrado por estado/prioridad/tipo.
  ///
  /// `currentPage`/`totalPages` se fijan a 1: la vista pagina en cliente.
  void _emitFiltered(Emitter<IncidenciaVehiculoState> emit) {
    final List<IncidenciaVehiculoEntity> filtradas = _allIncidencias
        .where(
          (IncidenciaVehiculoEntity i) =>
              (_filtroEstado == null || i.estado == _filtroEstado) &&
              (_filtroPrioridad == null || i.prioridad == _filtroPrioridad) &&
              (_filtroTipo == null || i.tipo == _filtroTipo),
        )
        .toList();
    debugPrint(
      '🔷 IncidenciaVehiculoBloc: ${filtradas.length} de ${_allIncidencias.length} incidencias tras filtros',
    );
    emit(
      IncidenciaVehiculoState.loaded(
        incidencias: filtradas,
        currentPage: 1,
        totalPages: 1,
        filtroEstado: _filtroEstado,
        filtroPrioridad: _filtroPrioridad,
        filtroTipo: _filtroTipo,
      ),
    );
  }
}
