import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/features/cuadrante/asignaciones/domain/repositories/asignacion_vehiculo_turno_repository.dart';
import 'package:ambutrack_web/features/cuadrante/asignaciones/presentation/bloc/asignaciones/asignaciones_event.dart';
import 'package:ambutrack_web/features/cuadrante/asignaciones/presentation/bloc/asignaciones/asignaciones_state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

@injectable
class AsignacionesBloc extends Bloc<AsignacionesEvent, AsignacionesState> {
  AsignacionesBloc(this._repository)
      : super(const AsignacionesState.initial()) {
    on<AsignacionesLoadAllRequested>(_onLoadAll);
    on<AsignacionesLoadByFechaRequested>(_onLoadByFecha);
    on<AsignacionesLoadByRangoRequested>(_onLoadByRango);
    on<AsignacionesLoadByVehiculoRequested>(_onLoadByVehiculo);
    on<AsignacionesLoadByEstadoRequested>(_onLoadByEstado);
    on<AsignacionCreateRequested>(_onCreate);
    on<AsignacionUpdateRequested>(_onUpdate);
    on<AsignacionDeleteRequested>(_onDelete);
  }

  final AsignacionVehiculoTurnoRepository _repository;

  Future<void> _onLoadAll(
    AsignacionesLoadAllRequested event,
    Emitter<AsignacionesState> emit,
  ) async {
    debugPrint('🔄 AsignacionesBloc: Cargando todas las asignaciones...');
    emit(const AsignacionesState.loading());

    try {
      final List<AsignacionVehiculoTurnoEntity> asignaciones = await _repository.getAll();
      debugPrint('✅ AsignacionesBloc: ${asignaciones.length} asignaciones cargadas');
      emit(AsignacionesState.loaded(asignaciones));
    } catch (e) {
      debugPrint('❌ AsignacionesBloc: Error al cargar asignaciones: $e');
      emit(AsignacionesState.error(e.toString()));
    }
  }

  Future<void> _onLoadByFecha(
    AsignacionesLoadByFechaRequested event,
    Emitter<AsignacionesState> emit,
  ) async {
    debugPrint('🔄 AsignacionesBloc: Cargando asignaciones por fecha ${event.fecha}...');
    emit(const AsignacionesState.loading());

    try {
      final List<AsignacionVehiculoTurnoEntity> asignaciones = await _repository.getByFecha(event.fecha);
      debugPrint('✅ AsignacionesBloc: ${asignaciones.length} asignaciones encontradas');
      emit(AsignacionesState.loaded(asignaciones));
    } catch (e) {
      debugPrint('❌ AsignacionesBloc: Error al cargar asignaciones por fecha: $e');
      emit(AsignacionesState.error(e.toString()));
    }
  }

  Future<void> _onLoadByRango(
    AsignacionesLoadByRangoRequested event,
    Emitter<AsignacionesState> emit,
  ) async {
    debugPrint('🔄 AsignacionesBloc: Cargando asignaciones por rango...');
    emit(const AsignacionesState.loading());

    try {
      final List<AsignacionVehiculoTurnoEntity> asignaciones = await _repository.getByRangoFechas(
        event.inicio,
        event.fin,
      );
      debugPrint('✅ AsignacionesBloc: ${asignaciones.length} asignaciones encontradas');
      emit(AsignacionesState.loaded(asignaciones));
    } catch (e) {
      debugPrint('❌ AsignacionesBloc: Error al cargar asignaciones por rango: $e');
      emit(AsignacionesState.error(e.toString()));
    }
  }

  Future<void> _onLoadByVehiculo(
    AsignacionesLoadByVehiculoRequested event,
    Emitter<AsignacionesState> emit,
  ) async {
    debugPrint('🔄 AsignacionesBloc: Cargando asignaciones por vehículo...');
    emit(const AsignacionesState.loading());

    try {
      final List<AsignacionVehiculoTurnoEntity> asignaciones = await _repository.getByVehiculo(
        event.vehiculoId,
        event.fecha,
      );
      debugPrint('✅ AsignacionesBloc: ${asignaciones.length} asignaciones encontradas');
      emit(AsignacionesState.loaded(asignaciones));
    } catch (e) {
      debugPrint('❌ AsignacionesBloc: Error al cargar asignaciones por vehículo: $e');
      emit(AsignacionesState.error(e.toString()));
    }
  }

  Future<void> _onLoadByEstado(
    AsignacionesLoadByEstadoRequested event,
    Emitter<AsignacionesState> emit,
  ) async {
    debugPrint('🔄 AsignacionesBloc: Cargando asignaciones por estado...');
    emit(const AsignacionesState.loading());

    try {
      final List<AsignacionVehiculoTurnoEntity> asignaciones = await _repository.getByEstado(event.estado);
      debugPrint('✅ AsignacionesBloc: ${asignaciones.length} asignaciones encontradas');
      emit(AsignacionesState.loaded(asignaciones));
    } catch (e) {
      debugPrint('❌ AsignacionesBloc: Error al cargar asignaciones por estado: $e');
      emit(AsignacionesState.error(e.toString()));
    }
  }

  Future<void> _onCreate(
    AsignacionCreateRequested event,
    Emitter<AsignacionesState> emit,
  ) async {
    debugPrint('🔄 AsignacionesBloc: Creando asignación...');

    try {
      await _repository.create(event.asignacion);
      debugPrint('✅ AsignacionesBloc: Asignación creada exitosamente');

      // Recargar lista después de crear
      final List<AsignacionVehiculoTurnoEntity> asignaciones = await _repository.getByFecha(event.asignacion.fecha);
      emit(AsignacionesState.loaded(asignaciones));
    } catch (e) {
      debugPrint('❌ AsignacionesBloc: Error al crear asignación: $e');
      emit(AsignacionesState.error(e.toString()));
    }
  }

  Future<void> _onUpdate(
    AsignacionUpdateRequested event,
    Emitter<AsignacionesState> emit,
  ) async {
    debugPrint('🔄 AsignacionesBloc: Actualizando asignación...');

    try {
      await _repository.update(event.asignacion);
      debugPrint('✅ AsignacionesBloc: Asignación actualizada exitosamente');

      // Recargar lista después de actualizar
      final List<AsignacionVehiculoTurnoEntity> asignaciones = await _repository.getByFecha(event.asignacion.fecha);
      emit(AsignacionesState.loaded(asignaciones));
    } catch (e) {
      debugPrint('❌ AsignacionesBloc: Error al actualizar asignación: $e');
      emit(AsignacionesState.error(e.toString()));
    }
  }

  Future<void> _onDelete(
    AsignacionDeleteRequested event,
    Emitter<AsignacionesState> emit,
  ) async {
    debugPrint('🔄 AsignacionesBloc: Eliminando asignación...');

    try {
      await _repository.delete(event.id);
      debugPrint('✅ AsignacionesBloc: Asignación eliminada exitosamente');

      // Recargar lista después de eliminar
      final AsignacionesState currentState = state;
      if (currentState is AsignacionesLoaded) {
        final List<AsignacionVehiculoTurnoEntity> asignaciones = currentState.asignaciones
            .where((AsignacionVehiculoTurnoEntity a) => a.id != event.id)
            .toList();
        emit(
          AsignacionesState.operationSuccess(
            message: 'Asignación eliminada exitosamente',
            asignaciones: asignaciones,
          ),
        );
      } else if (currentState is AsignacionOperationSuccess) {
        final List<AsignacionVehiculoTurnoEntity> asignaciones = currentState.asignaciones
            .where((AsignacionVehiculoTurnoEntity a) => a.id != event.id)
            .toList();
        emit(
          AsignacionesState.operationSuccess(
            message: 'Asignación eliminada exitosamente',
            asignaciones: asignaciones,
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ AsignacionesBloc: Error al eliminar asignación: $e');
      emit(AsignacionesState.error(e.toString()));
    }
  }
}
