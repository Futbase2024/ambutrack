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
      : super(const AsignacionesInitial()) {
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

  /// Fecha actual para recargar después de CUD
  DateTime _currentFecha = DateTime.now();

  Future<void> _onLoadAll(
    AsignacionesLoadAllRequested event,
    Emitter<AsignacionesState> emit,
  ) async {
    try {
      debugPrint('🔄 AsignacionesBloc: Cargando todas las asignaciones...');
      emit(const AsignacionesLoading());

      final List<AsignacionVehiculoTurnoEntity> asignaciones =
          await _repository.getAll();
      debugPrint(
        '✅ AsignacionesBloc: ${asignaciones.length} asignaciones cargadas',
      );
      emit(AsignacionesLoaded(asignaciones));
    } catch (e) {
      debugPrint('❌ AsignacionesBloc: Error al cargar: $e');
      emit(AsignacionesError(e.toString()));
    }
  }

  Future<void> _onLoadByFecha(
    AsignacionesLoadByFechaRequested event,
    Emitter<AsignacionesState> emit,
  ) async {
    _currentFecha = event.fecha;
    try {
      debugPrint(
        '🔄 AsignacionesBloc: Cargando por fecha ${event.fecha}...',
      );
      emit(const AsignacionesLoading());

      final List<AsignacionVehiculoTurnoEntity> asignaciones =
          await _repository.getByFecha(event.fecha);
      debugPrint(
        '✅ AsignacionesBloc: ${asignaciones.length} asignaciones encontradas',
      );
      emit(AsignacionesLoaded(asignaciones));
    } catch (e) {
      debugPrint('❌ AsignacionesBloc: Error al cargar por fecha: $e');
      emit(AsignacionesError(e.toString()));
    }
  }

  Future<void> _onLoadByRango(
    AsignacionesLoadByRangoRequested event,
    Emitter<AsignacionesState> emit,
  ) async {
    try {
      debugPrint('🔄 AsignacionesBloc: Cargando por rango...');
      emit(const AsignacionesLoading());

      final List<AsignacionVehiculoTurnoEntity> asignaciones =
          await _repository.getByRangoFechas(event.inicio, event.fin);
      debugPrint(
        '✅ AsignacionesBloc: ${asignaciones.length} asignaciones encontradas',
      );
      emit(AsignacionesLoaded(asignaciones));
    } catch (e) {
      debugPrint('❌ AsignacionesBloc: Error al cargar por rango: $e');
      emit(AsignacionesError(e.toString()));
    }
  }

  Future<void> _onLoadByVehiculo(
    AsignacionesLoadByVehiculoRequested event,
    Emitter<AsignacionesState> emit,
  ) async {
    try {
      debugPrint('🔄 AsignacionesBloc: Cargando por vehículo...');
      emit(const AsignacionesLoading());

      final List<AsignacionVehiculoTurnoEntity> asignaciones =
          await _repository.getByVehiculo(event.vehiculoId, event.fecha);
      debugPrint(
        '✅ AsignacionesBloc: ${asignaciones.length} asignaciones encontradas',
      );
      emit(AsignacionesLoaded(asignaciones));
    } catch (e) {
      debugPrint('❌ AsignacionesBloc: Error al cargar por vehículo: $e');
      emit(AsignacionesError(e.toString()));
    }
  }

  Future<void> _onLoadByEstado(
    AsignacionesLoadByEstadoRequested event,
    Emitter<AsignacionesState> emit,
  ) async {
    try {
      debugPrint('🔄 AsignacionesBloc: Cargando por estado...');
      emit(const AsignacionesLoading());

      final List<AsignacionVehiculoTurnoEntity> asignaciones =
          await _repository.getByEstado(event.estado);
      debugPrint(
        '✅ AsignacionesBloc: ${asignaciones.length} asignaciones encontradas',
      );
      emit(AsignacionesLoaded(asignaciones));
    } catch (e) {
      debugPrint('❌ AsignacionesBloc: Error al cargar por estado: $e');
      emit(AsignacionesError(e.toString()));
    }
  }

  Future<void> _onCreate(
    AsignacionCreateRequested event,
    Emitter<AsignacionesState> emit,
  ) async {
    try {
      debugPrint('🔄 AsignacionesBloc: Creando asignación...');
      await _repository.create(event.asignacion);
      debugPrint('✅ AsignacionesBloc: Asignación creada');
      add(AsignacionesLoadByFechaRequested(event.asignacion.fecha));
    } catch (e) {
      debugPrint('❌ AsignacionesBloc: Error al crear: $e');
      emit(AsignacionesError(e.toString()));
    }
  }

  Future<void> _onUpdate(
    AsignacionUpdateRequested event,
    Emitter<AsignacionesState> emit,
  ) async {
    try {
      debugPrint('🔄 AsignacionesBloc: Actualizando asignación...');
      await _repository.update(event.asignacion);
      debugPrint('✅ AsignacionesBloc: Asignación actualizada');
      add(AsignacionesLoadByFechaRequested(event.asignacion.fecha));
    } catch (e) {
      debugPrint('❌ AsignacionesBloc: Error al actualizar: $e');
      emit(AsignacionesError(e.toString()));
    }
  }

  Future<void> _onDelete(
    AsignacionDeleteRequested event,
    Emitter<AsignacionesState> emit,
  ) async {
    try {
      debugPrint('🔄 AsignacionesBloc: Eliminando asignación...');
      await _repository.delete(event.id);
      debugPrint('✅ AsignacionesBloc: Asignación eliminada');
      add(AsignacionesLoadByFechaRequested(_currentFecha));
    } catch (e) {
      debugPrint('❌ AsignacionesBloc: Error al eliminar: $e');
      emit(AsignacionesError(e.toString()));
    }
  }
}
