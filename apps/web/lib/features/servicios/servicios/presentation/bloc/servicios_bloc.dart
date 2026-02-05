import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/servicio_entity.dart';
import '../../domain/repositories/servicio_repository.dart';
import 'servicios_event.dart';
import 'servicios_state.dart';

/// BLoC para gestión de servicios
@injectable
class ServiciosBloc extends Bloc<ServiciosEvent, ServiciosState> {
  ServiciosBloc({
    required ServicioRepository repository,
  })  : _repository = repository,
        super(const ServiciosState.initial()) {
    on<ServiciosEvent>(_onEvent);
  }

  final ServicioRepository _repository;

  Future<void> _onEvent(ServiciosEvent event, Emitter<ServiciosState> emit) async {
    await event.when(
      started: () => _onStarted(emit),
      loadRequested: () => _onLoadRequested(emit),
      refreshRequested: () => _onRefreshRequested(emit),
      searchChanged: (String query) => _onSearchChanged(emit, query: query),
      yearFilterChanged: (int? year) => _onYearFilterChanged(emit, year: year),
      estadoFilterChanged: (String? estado) => _onEstadoFilterChanged(emit, estado: estado),
      updateEstadoRequested: (String id, String estado) =>
          _onUpdateEstadoRequested(emit, id: id, estado: estado),
      reanudarRequested: (String id) => _onReanudarRequested(emit, id: id),
      deleteRequested: (String id) => _onDeleteRequested(emit, id: id),
      loadServicioDetailsRequested: (String id) =>
          _onLoadServicioDetailsRequested(emit, id: id),
    );
  }

  Future<void> _onStarted(Emitter<ServiciosState> emit) async {
    debugPrint('🎯 ServiciosBloc: Iniciando...');
    emit(const ServiciosState.loading());
    await _loadServicios(emit);
  }

  Future<void> _onLoadRequested(Emitter<ServiciosState> emit) async {
    debugPrint('🎯 ServiciosBloc: Carga solicitada');
    emit(const ServiciosState.loading());
    await _loadServicios(emit);
  }

  Future<void> _onRefreshRequested(Emitter<ServiciosState> emit) async {
    debugPrint('🎯 ServiciosBloc: Refresco solicitado');
    await state.whenOrNull(
      loaded: (
        List<ServicioEntity> servicios,
        String searchQuery,
        int? yearFilter,
        String? estadoFilter,
        bool isRefreshing,
        ServicioEntity? selectedServicio,
        bool isLoadingDetails,
      ) {
        emit(ServiciosState.loaded(
          servicios: servicios,
          searchQuery: searchQuery,
          yearFilter: yearFilter,
          estadoFilter: estadoFilter,
          isRefreshing: true,
          selectedServicio: selectedServicio,
          isLoadingDetails: isLoadingDetails,
        ));
        return _loadServicios(emit);
      },
    );
  }

  Future<void> _onSearchChanged(Emitter<ServiciosState> emit, {required String query}) async {
    debugPrint('🎯 ServiciosBloc: Búsqueda: $query');

    // Usar maybeWhen para obtener los filtros actuales si estamos en estado loaded
    final int? currentYearFilter = state.maybeWhen(
      loaded: (
        List<ServicioEntity> servicios,
        String searchQuery,
        int? yearFilter,
        String? estadoFilter,
        bool isRefreshing,
        ServicioEntity? selectedServicio,
        bool isLoadingDetails,
      ) =>
          yearFilter,
      orElse: () => null,
    );

    final String? currentEstadoFilter = state.maybeWhen(
      loaded: (
        List<ServicioEntity> servicios,
        String searchQuery,
        int? yearFilter,
        String? estadoFilter,
        bool isRefreshing,
        ServicioEntity? selectedServicio,
        bool isLoadingDetails,
      ) =>
          estadoFilter,
      orElse: () => null,
    );

    emit(const ServiciosState.loading());

    try {
      final List<ServicioEntity> servicios = query.isEmpty
          ? await _repository.getAll()
          : await _repository.search(query);

      emit(ServiciosState.loaded(
        servicios: servicios,
        searchQuery: query,
        yearFilter: currentYearFilter,
        estadoFilter: currentEstadoFilter,
      ));
    } catch (e) {
      debugPrint('🎯 ServiciosBloc: ❌ Error en búsqueda: $e');

      final List<ServicioEntity>? previousServicios = state.maybeWhen(
        loaded: (
          List<ServicioEntity> servicios,
          String searchQuery,
          int? yearFilter,
          String? estadoFilter,
          bool isRefreshing,
          ServicioEntity? selectedServicio,
          bool isLoadingDetails,
        ) =>
            servicios,
        orElse: () => null,
      );

      emit(ServiciosState.error(
        message: e.toString(),
        previousServicios: previousServicios,
      ));
    }
  }

  Future<void> _onYearFilterChanged(Emitter<ServiciosState> emit, {required int? year}) async {
    debugPrint('🎯 ServiciosBloc: Filtro año: $year');

    // Usar maybeWhen para obtener los filtros actuales
    final String currentSearchQuery = state.maybeWhen(
      loaded: (
        List<ServicioEntity> servicios,
        String searchQuery,
        int? yearFilter,
        String? estadoFilter,
        bool isRefreshing,
        ServicioEntity? selectedServicio,
        bool isLoadingDetails,
      ) =>
          searchQuery,
      orElse: () => '',
    );

    final String? currentEstadoFilter = state.maybeWhen(
      loaded: (
        List<ServicioEntity> servicios,
        String searchQuery,
        int? yearFilter,
        String? estadoFilter,
        bool isRefreshing,
        ServicioEntity? selectedServicio,
        bool isLoadingDetails,
      ) =>
          estadoFilter,
      orElse: () => null,
    );

    emit(const ServiciosState.loading());

    try {
      final List<ServicioEntity> servicios =
          year == null ? await _repository.getAll() : await _repository.getByYear(year);

      emit(ServiciosState.loaded(
        servicios: servicios,
        searchQuery: currentSearchQuery,
        yearFilter: year,
        estadoFilter: currentEstadoFilter,
      ));
    } catch (e) {
      debugPrint('🎯 ServiciosBloc: ❌ Error en filtro año: $e');

      final List<ServicioEntity>? previousServicios = state.maybeWhen(
        loaded: (
          List<ServicioEntity> servicios,
          String searchQuery,
          int? yearFilter,
          String? estadoFilter,
          bool isRefreshing,
          ServicioEntity? selectedServicio,
          bool isLoadingDetails,
        ) =>
            servicios,
        orElse: () => null,
      );

      emit(ServiciosState.error(
        message: e.toString(),
        previousServicios: previousServicios,
      ));
    }
  }

  Future<void> _onEstadoFilterChanged(Emitter<ServiciosState> emit,
      {required String? estado}) async {
    debugPrint('🎯 ServiciosBloc: Filtro estado: $estado');

    // Usar maybeWhen para obtener los filtros actuales
    final String currentSearchQuery = state.maybeWhen(
      loaded: (
        List<ServicioEntity> servicios,
        String searchQuery,
        int? yearFilter,
        String? estadoFilter,
        bool isRefreshing,
        ServicioEntity? selectedServicio,
        bool isLoadingDetails,
      ) =>
          searchQuery,
      orElse: () => '',
    );

    final int? currentYearFilter = state.maybeWhen(
      loaded: (
        List<ServicioEntity> servicios,
        String searchQuery,
        int? yearFilter,
        String? estadoFilter,
        bool isRefreshing,
        ServicioEntity? selectedServicio,
        bool isLoadingDetails,
      ) =>
          yearFilter,
      orElse: () => null,
    );

    emit(const ServiciosState.loading());

    try {
      final List<ServicioEntity> servicios =
          estado == null ? await _repository.getAll() : await _repository.getByEstado(estado);

      emit(ServiciosState.loaded(
        servicios: servicios,
        searchQuery: currentSearchQuery,
        yearFilter: currentYearFilter,
        estadoFilter: estado,
      ));
    } catch (e) {
      debugPrint('🎯 ServiciosBloc: ❌ Error en filtro estado: $e');

      final List<ServicioEntity>? previousServicios = state.maybeWhen(
        loaded: (
          List<ServicioEntity> servicios,
          String searchQuery,
          int? yearFilter,
          String? estadoFilter,
          bool isRefreshing,
          ServicioEntity? selectedServicio,
          bool isLoadingDetails,
        ) =>
            servicios,
        orElse: () => null,
      );

      emit(ServiciosState.error(
        message: e.toString(),
        previousServicios: previousServicios,
      ));
    }
  }

  Future<void> _onUpdateEstadoRequested(Emitter<ServiciosState> emit,
      {required String id, required String estado}) async {
    debugPrint('🎯 ServiciosBloc: Actualizando estado de $id a $estado');

    try {
      // Si el estado es SUSPENDIDO o FINALIZADO, eliminar traslados futuros
      if (estado.toUpperCase() == 'SUSPENDIDO') {
        debugPrint('⏸️ ServiciosBloc: Suspendiendo servicio (elimina traslados futuros)...');
        await _repository.suspend(id);
        debugPrint('✅ ServiciosBloc: Servicio suspendido y traslados futuros eliminados');
      } else if (estado.toUpperCase() == 'FINALIZADO') {
        debugPrint('🏁 ServiciosBloc: Finalizando servicio (elimina traslados futuros)...');
        // Usar el mismo método suspend() que elimina traslados futuros
        await _repository.suspend(id);
        // Luego cambiar el estado a FINALIZADO
        await _repository.updateEstado(id, 'FINALIZADO');
        debugPrint('✅ ServiciosBloc: Servicio finalizado y traslados futuros eliminados');
      } else {
        // Para otros estados (ACTIVO, etc.), solo actualizar el estado
        await _repository.updateEstado(id, estado);
      }

      add(const ServiciosEvent.loadRequested());
    } catch (e) {
      debugPrint('🎯 ServiciosBloc: ❌ Error al actualizar estado: $e');
      emit(ServiciosState.error(message: e.toString()));
    }
  }

  Future<void> _onReanudarRequested(Emitter<ServiciosState> emit, {required String id}) async {
    debugPrint('▶️ ServiciosBloc: Reanudando servicio $id');

    try {
      // Llamar al método reanudar() que:
      // 1. Cambia el estado a 'activo'
      // 2. Regenera los traslados desde hoy en adelante
      final int trasladosGenerados = await _repository.reanudar(id);
      debugPrint('✅ ServiciosBloc: Servicio reanudado. $trasladosGenerados traslados generados');

      add(const ServiciosEvent.loadRequested());
    } catch (e) {
      debugPrint('❌ ServiciosBloc: Error al reanudar servicio: $e');
      emit(ServiciosState.error(message: e.toString()));
    }
  }

  Future<void> _onDeleteRequested(Emitter<ServiciosState> emit, {required String id}) async {
    debugPrint('🗑️ ServiciosBloc: ELIMINACIÓN PERMANENTE del servicio $id');

    try {
      // Usar hardDelete para eliminación en cascada:
      // - Servicio
      // - Servicio recurrente (si existe)
      // - Todos los traslados asociados
      await _repository.hardDelete(id);

      debugPrint('🎯 ServiciosBloc: ✅ Servicio y datos relacionados eliminados PERMANENTEMENTE');

      add(const ServiciosEvent.loadRequested());
    } catch (e) {
      debugPrint('🎯 ServiciosBloc: ❌ Error al eliminar: $e');
      emit(ServiciosState.error(message: e.toString()));
    }
  }

  Future<void> _onLoadServicioDetailsRequested(Emitter<ServiciosState> emit, {required String id}) async {
    debugPrint('🎯 ServiciosBloc: Cargando detalles del servicio $id');

    // Extraer estado actual usando maybeWhen
    final ({String? estadoFilter, bool isLoadingDetails, bool isRefreshing, String searchQuery, ServicioEntity? selectedServicio, List<ServicioEntity> servicios, int? yearFilter})? loadedState = state.maybeWhen(
      loaded: (List<ServicioEntity> servicios, String searchQuery, int? yearFilter, String? estadoFilter, bool isRefreshing, ServicioEntity? selectedServicio, bool isLoadingDetails) =>
        (servicios: servicios, searchQuery: searchQuery, yearFilter: yearFilter, estadoFilter: estadoFilter, isRefreshing: isRefreshing, selectedServicio: selectedServicio, isLoadingDetails: isLoadingDetails),
      orElse: () => null,
    );

    if (loadedState == null) {
      return;
    }

    emit(ServiciosState.loaded(
      servicios: loadedState.servicios,
      searchQuery: loadedState.searchQuery,
      yearFilter: loadedState.yearFilter,
      estadoFilter: loadedState.estadoFilter,
      isRefreshing: loadedState.isRefreshing,
      selectedServicio: loadedState.selectedServicio,
      isLoadingDetails: true,
    ));

    try {
      final ServicioEntity? servicio = await _repository.getById(id);
      debugPrint('🎯 ServiciosBloc: ✅ Detalles cargados para servicio $id');

      emit(ServiciosState.loaded(
        servicios: loadedState.servicios,
        searchQuery: loadedState.searchQuery,
        yearFilter: loadedState.yearFilter,
        estadoFilter: loadedState.estadoFilter,
        isRefreshing: loadedState.isRefreshing,
        selectedServicio: servicio,
      ));
    } catch (e) {
      debugPrint('🎯 ServiciosBloc: ❌ Error al cargar detalles: $e');
      emit(ServiciosState.loaded(
        servicios: loadedState.servicios,
        searchQuery: loadedState.searchQuery,
        yearFilter: loadedState.yearFilter,
        estadoFilter: loadedState.estadoFilter,
        isRefreshing: loadedState.isRefreshing,
      ));
    }
  }

  Future<void> _loadServicios(Emitter<ServiciosState> emit) async {
    try {
      final List<ServicioEntity> servicios = await _repository.getAll();
      debugPrint('🎯 ServiciosBloc: ✅ ${servicios.length} servicios cargados');

      emit(ServiciosState.loaded(
        servicios: servicios,
      ));
    } catch (e) {
      debugPrint('🎯 ServiciosBloc: ❌ Error: $e');
      emit(ServiciosState.error(message: e.toString()));
    }
  }
}
