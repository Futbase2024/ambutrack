import 'dart:async';

import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../domain/repositories/incidencias_repository.dart';
import 'incidencias_event.dart';
import 'incidencias_state.dart';

/// BLoC para gestionar el estado de las incidencias del vehículo.
@injectable
class IncidenciasBloc extends Bloc<IncidenciasEvent, IncidenciasState> {
  IncidenciasBloc(this._repository) : super(const IncidenciasInitial()) {
    on<IncidenciasLoadRequested>(_onLoadRequested);
    on<IncidenciasLoadByVehiculoRequested>(_onLoadByVehiculoRequested);
    on<IncidenciasLoadByEstadoRequested>(_onLoadByEstadoRequested);
    on<IncidenciasCreateRequested>(_onCreateRequested);
    on<IncidenciasUpdateRequested>(_onUpdateRequested);
    on<IncidenciasDeleteRequested>(_onDeleteRequested);
    on<IncidenciasWatchByVehiculoRequested>(_onWatchByVehiculoRequested);
  }

  final IncidenciasRepository _repository;
  StreamSubscription<List<IncidenciaVehiculoEntity>>? _watchSubscription;

  Future<void> _onLoadRequested(
    IncidenciasLoadRequested event,
    Emitter<IncidenciasState> emit,
  ) async {
    debugPrint('⚠️ IncidenciasBloc: Cargando todas las incidencias...');
    emit(const IncidenciasLoading());

    try {
      final incidencias = await _repository.getAll();
      debugPrint(
          '⚠️ IncidenciasBloc: ✅ ${incidencias.length} incidencias cargadas');
      emit(IncidenciasLoaded(incidencias: incidencias));
    } catch (e) {
      debugPrint('⚠️ IncidenciasBloc: ❌ Error: $e');
      emit(IncidenciasError(e.toString()));
    }
  }

  Future<void> _onLoadByVehiculoRequested(
    IncidenciasLoadByVehiculoRequested event,
    Emitter<IncidenciasState> emit,
  ) async {
    debugPrint(
        '⚠️ IncidenciasBloc: Cargando incidencias del vehículo: ${event.vehiculoId}');
    emit(const IncidenciasLoading());

    try {
      final incidencias = await _repository.getByVehiculoId(event.vehiculoId);
      debugPrint(
          '⚠️ IncidenciasBloc: ✅ ${incidencias.length} incidencias cargadas');
      emit(IncidenciasLoaded(
        incidencias: incidencias,
        filteredByVehiculo: event.vehiculoId,
      ));
    } catch (e) {
      debugPrint('⚠️ IncidenciasBloc: ❌ Error: $e');
      emit(IncidenciasError(e.toString()));
    }
  }

  Future<void> _onLoadByEstadoRequested(
    IncidenciasLoadByEstadoRequested event,
    Emitter<IncidenciasState> emit,
  ) async {
    debugPrint(
        '⚠️ IncidenciasBloc: Cargando incidencias con estado: ${event.estado.name}');
    emit(const IncidenciasLoading());

    try {
      final incidencias = await _repository.getByEstado(event.estado);
      debugPrint(
          '⚠️ IncidenciasBloc: ✅ ${incidencias.length} incidencias cargadas');
      emit(IncidenciasLoaded(
        incidencias: incidencias,
        filteredByEstado: event.estado,
      ));
    } catch (e) {
      debugPrint('⚠️ IncidenciasBloc: ❌ Error: $e');
      emit(IncidenciasError(e.toString()));
    }
  }

  Future<void> _onCreateRequested(
    IncidenciasCreateRequested event,
    Emitter<IncidenciasState> emit,
  ) async {
    debugPrint('⚠️ IncidenciasBloc: Creando incidencia...');
    emit(const IncidenciasLoading());

    try {
      final created = await _repository.create(event.incidencia);
      debugPrint('⚠️ IncidenciasBloc: ✅ Incidencia creada: ${created.id}');
      emit(IncidenciaCreated(created));

      // Recargar lista después de crear
      add(IncidenciasLoadByVehiculoRequested(created.vehiculoId));
    } catch (e) {
      debugPrint('⚠️ IncidenciasBloc: ❌ Error al crear: $e');
      emit(IncidenciasError(e.toString()));
    }
  }

  Future<void> _onUpdateRequested(
    IncidenciasUpdateRequested event,
    Emitter<IncidenciasState> emit,
  ) async {
    debugPrint(
        '⚠️ IncidenciasBloc: Actualizando incidencia ID: ${event.incidencia.id}');
    emit(const IncidenciasLoading());

    try {
      final updated = await _repository.update(event.incidencia);
      debugPrint('⚠️ IncidenciasBloc: ✅ Incidencia actualizada');
      emit(IncidenciaUpdated(updated));

      // Recargar lista después de actualizar
      add(IncidenciasLoadByVehiculoRequested(updated.vehiculoId));
    } catch (e) {
      debugPrint('⚠️ IncidenciasBloc: ❌ Error al actualizar: $e');
      emit(IncidenciasError(e.toString()));
    }
  }

  Future<void> _onDeleteRequested(
    IncidenciasDeleteRequested event,
    Emitter<IncidenciasState> emit,
  ) async {
    debugPrint('⚠️ IncidenciasBloc: Eliminando incidencia ID: ${event.id}');
    emit(const IncidenciasLoading());

    try {
      await _repository.delete(event.id);
      debugPrint('⚠️ IncidenciasBloc: ✅ Incidencia eliminada');
      emit(IncidenciaDeleted(event.id));

      // Recargar lista después de eliminar
      if (state is IncidenciasLoaded) {
        final currentState = state as IncidenciasLoaded;
        if (currentState.filteredByVehiculo != null) {
          add(IncidenciasLoadByVehiculoRequested(
              currentState.filteredByVehiculo!));
        } else {
          add(const IncidenciasLoadRequested());
        }
      }
    } catch (e) {
      debugPrint('⚠️ IncidenciasBloc: ❌ Error al eliminar: $e');
      emit(IncidenciasError(e.toString()));
    }
  }

  Future<void> _onWatchByVehiculoRequested(
    IncidenciasWatchByVehiculoRequested event,
    Emitter<IncidenciasState> emit,
  ) async {
    debugPrint(
        '⚠️ IncidenciasBloc: Observando incidencias del vehículo: ${event.vehiculoId}');
    await _watchSubscription?.cancel();

    emit(const IncidenciasLoading());

    _watchSubscription =
        _repository.watchByVehiculoId(event.vehiculoId).listen(
      (incidencias) {
        debugPrint(
            '⚠️ IncidenciasBloc: 🔄 Actualización recibida: ${incidencias.length} incidencias');
        add(IncidenciasLoadByVehiculoRequested(event.vehiculoId));
      },
      onError: (error) {
        debugPrint('⚠️ IncidenciasBloc: ❌ Error en stream: $error');
        emit(IncidenciasError(error.toString()));
      },
    );
  }

  @override
  Future<void> close() {
    _watchSubscription?.cancel();
    return super.close();
  }
}
