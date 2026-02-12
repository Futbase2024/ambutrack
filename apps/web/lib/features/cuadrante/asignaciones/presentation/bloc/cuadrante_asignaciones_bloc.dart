import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/features/cuadrante/asignaciones/domain/repositories/cuadrante_asignacion_repository.dart';
import 'package:ambutrack_web/features/cuadrante/asignaciones/presentation/bloc/cuadrante_asignaciones_event.dart';
import 'package:ambutrack_web/features/cuadrante/asignaciones/presentation/bloc/cuadrante_asignaciones_state.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

/// BLoC para gestión de asignaciones de cuadrante
@injectable
class CuadranteAsignacionesBloc extends Bloc<CuadranteAsignacionesEvent, CuadranteAsignacionesState> {
  CuadranteAsignacionesBloc(this._repository) : super(const CuadranteAsignacionesInitial()) {
    on<CuadranteAsignacionesLoadAllRequested>(_onLoadAllRequested);
    on<CuadranteAsignacionesLoadByFechaRequested>(_onLoadByFechaRequested);
    on<CuadranteAsignacionesLoadByRangoRequested>(_onLoadByRangoRequested);
    on<CuadranteAsignacionesLoadByPersonalRequested>(_onLoadByPersonalRequested);
    on<CuadranteAsignacionesLoadByVehiculoRequested>(_onLoadByVehiculoRequested);
    on<CuadranteAsignacionesLoadByDotacionRequested>(_onLoadByDotacionRequested);
    on<CuadranteAsignacionesCreateRequested>(_onCreateRequested);
    on<CuadranteAsignacionesUpdateRequested>(_onUpdateRequested);
    on<CuadranteAsignacionesDeleteRequested>(_onDeleteRequested);
    on<CuadranteAsignacionesConfirmarRequested>(_onConfirmarRequested);
    on<CuadranteAsignacionesCancelarRequested>(_onCancelarRequested);
    on<CuadranteAsignacionesCompletarRequested>(_onCompletarRequested);
    on<CuadranteAsignacionesCheckConflictPersonalRequested>(_onCheckConflictPersonalRequested);
    on<CuadranteAsignacionesCheckConflictVehiculoRequested>(_onCheckConflictVehiculoRequested);
  }

  final CuadranteAsignacionRepository _repository;

  /// Cargar todas las asignaciones
  Future<void> _onLoadAllRequested(
    CuadranteAsignacionesLoadAllRequested event,
    Emitter<CuadranteAsignacionesState> emit,
  ) async {
    try {
      emit(const CuadranteAsignacionesLoading());
      debugPrint('📦 BLoC: Cargando todas las asignaciones...');

      final List<CuadranteAsignacionEntity> asignaciones = await _repository.getAll();

      debugPrint('📦 BLoC: ✅ ${asignaciones.length} asignaciones cargadas');
      emit(CuadranteAsignacionesLoaded(asignaciones));
    } catch (e) {
      debugPrint('📦 BLoC: ❌ Error al cargar asignaciones: $e');
      emit(CuadranteAsignacionesError('Error al cargar asignaciones: $e'));
    }
  }

  /// Cargar asignaciones por fecha
  Future<void> _onLoadByFechaRequested(
    CuadranteAsignacionesLoadByFechaRequested event,
    Emitter<CuadranteAsignacionesState> emit,
  ) async {
    try {
      emit(const CuadranteAsignacionesLoading());
      debugPrint('📦 BLoC: Cargando asignaciones para fecha ${event.fecha}');

      final List<CuadranteAsignacionEntity> asignaciones = await _repository.getByFecha(event.fecha);

      debugPrint('📦 BLoC: ✅ ${asignaciones.length} asignaciones cargadas');
      emit(CuadranteAsignacionesLoaded(asignaciones));
    } catch (e) {
      debugPrint('📦 BLoC: ❌ Error: $e');
      emit(CuadranteAsignacionesError('Error al cargar asignaciones: $e'));
    }
  }

  /// Cargar asignaciones por rango de fechas
  Future<void> _onLoadByRangoRequested(
    CuadranteAsignacionesLoadByRangoRequested event,
    Emitter<CuadranteAsignacionesState> emit,
  ) async {
    try {
      emit(const CuadranteAsignacionesLoading());
      debugPrint('📦 BLoC: Cargando asignaciones del ${event.fechaInicio} al ${event.fechaFin}');

      final List<CuadranteAsignacionEntity> asignaciones = await _repository.getByRangoFechas(
        fechaInicio: event.fechaInicio,
        fechaFin: event.fechaFin,
      );

      debugPrint('📦 BLoC: ✅ ${asignaciones.length} asignaciones cargadas');
      emit(CuadranteAsignacionesLoaded(asignaciones));
    } catch (e) {
      debugPrint('📦 BLoC: ❌ Error: $e');
      emit(CuadranteAsignacionesError('Error al cargar asignaciones: $e'));
    }
  }

  /// Cargar asignaciones por personal
  Future<void> _onLoadByPersonalRequested(
    CuadranteAsignacionesLoadByPersonalRequested event,
    Emitter<CuadranteAsignacionesState> emit,
  ) async {
    try {
      emit(const CuadranteAsignacionesLoading());
      debugPrint('📦 BLoC: Cargando asignaciones del personal ${event.idPersonal}');

      final List<CuadranteAsignacionEntity> asignaciones = await _repository.getByPersonal(
        idPersonal: event.idPersonal,
        fecha: event.fecha,
      );

      debugPrint('📦 BLoC: ✅ ${asignaciones.length} asignaciones cargadas');
      emit(CuadranteAsignacionesLoaded(asignaciones));
    } catch (e) {
      debugPrint('📦 BLoC: ❌ Error: $e');
      emit(CuadranteAsignacionesError('Error al cargar asignaciones: $e'));
    }
  }

  /// Cargar asignaciones por vehículo
  Future<void> _onLoadByVehiculoRequested(
    CuadranteAsignacionesLoadByVehiculoRequested event,
    Emitter<CuadranteAsignacionesState> emit,
  ) async {
    try {
      emit(const CuadranteAsignacionesLoading());
      debugPrint('📦 BLoC: Cargando asignaciones del vehículo ${event.idVehiculo}');

      final List<CuadranteAsignacionEntity> asignaciones = await _repository.getByVehiculo(
        idVehiculo: event.idVehiculo,
        fecha: event.fecha,
      );

      debugPrint('📦 BLoC: ✅ ${asignaciones.length} asignaciones cargadas');
      emit(CuadranteAsignacionesLoaded(asignaciones));
    } catch (e) {
      debugPrint('📦 BLoC: ❌ Error: $e');
      emit(CuadranteAsignacionesError('Error al cargar asignaciones: $e'));
    }
  }

  /// Cargar asignaciones por dotación
  Future<void> _onLoadByDotacionRequested(
    CuadranteAsignacionesLoadByDotacionRequested event,
    Emitter<CuadranteAsignacionesState> emit,
  ) async {
    try {
      emit(const CuadranteAsignacionesLoading());
      debugPrint('📦 BLoC: Cargando asignaciones de dotación ${event.idDotacion}');

      final List<CuadranteAsignacionEntity> asignaciones = await _repository.getByDotacion(
        idDotacion: event.idDotacion,
        fecha: event.fecha,
      );

      debugPrint('📦 BLoC: ✅ ${asignaciones.length} asignaciones cargadas');
      emit(CuadranteAsignacionesLoaded(asignaciones));
    } catch (e) {
      debugPrint('📦 BLoC: ❌ Error: $e');
      emit(CuadranteAsignacionesError('Error al cargar asignaciones: $e'));
    }
  }

  /// Crear nueva asignación
  Future<void> _onCreateRequested(
    CuadranteAsignacionesCreateRequested event,
    Emitter<CuadranteAsignacionesState> emit,
  ) async {
    try {
      emit(const CuadranteAsignacionesLoading());
      debugPrint('📦 BLoC: Creando asignación...');

      final CuadranteAsignacionEntity asignacion = await _repository.create(event.asignacion);

      debugPrint('📦 BLoC: ✅ Asignación creada: ${asignacion.id}');
      emit(CuadranteAsignacionesOperationSuccess(
        message: 'Asignación creada exitosamente',
        asignacion: asignacion,
      ));
    } catch (e) {
      debugPrint('📦 BLoC: ❌ Error al crear: $e');
      emit(CuadranteAsignacionesError('Error al crear asignación: $e'));
    }
  }

  /// Actualizar asignación
  Future<void> _onUpdateRequested(
    CuadranteAsignacionesUpdateRequested event,
    Emitter<CuadranteAsignacionesState> emit,
  ) async {
    try {
      emit(const CuadranteAsignacionesLoading());
      debugPrint('📦 BLoC: Actualizando asignación ${event.asignacion.id}');

      final CuadranteAsignacionEntity asignacion = await _repository.update(event.asignacion);

      debugPrint('📦 BLoC: ✅ Asignación actualizada');
      emit(CuadranteAsignacionesOperationSuccess(
        message: 'Asignación actualizada exitosamente',
        asignacion: asignacion,
      ));
    } catch (e) {
      debugPrint('📦 BLoC: ❌ Error al actualizar: $e');
      emit(CuadranteAsignacionesError('Error al actualizar asignación: $e'));
    }
  }

  /// Eliminar asignación
  Future<void> _onDeleteRequested(
    CuadranteAsignacionesDeleteRequested event,
    Emitter<CuadranteAsignacionesState> emit,
  ) async {
    try {
      emit(const CuadranteAsignacionesLoading());
      debugPrint('📦 BLoC: Eliminando asignación ${event.id}');

      await _repository.delete(event.id);

      debugPrint('📦 BLoC: ✅ Asignación eliminada');
      emit(const CuadranteAsignacionesOperationSuccess(
        message: 'Asignación eliminada exitosamente',
      ));
    } catch (e) {
      debugPrint('📦 BLoC: ❌ Error al eliminar: $e');
      emit(CuadranteAsignacionesError('Error al eliminar asignación: $e'));
    }
  }

  /// Confirmar asignación
  Future<void> _onConfirmarRequested(
    CuadranteAsignacionesConfirmarRequested event,
    Emitter<CuadranteAsignacionesState> emit,
  ) async {
    try {
      emit(const CuadranteAsignacionesLoading());
      debugPrint('📦 BLoC: Confirmando asignación ${event.id}');

      final CuadranteAsignacionEntity asignacion = await _repository.confirmar(
        id: event.id,
        confirmadaPor: event.confirmadaPor,
      );

      debugPrint('📦 BLoC: ✅ Asignación confirmada');
      emit(CuadranteAsignacionesOperationSuccess(
        message: 'Asignación confirmada exitosamente',
        asignacion: asignacion,
      ));
    } catch (e) {
      debugPrint('📦 BLoC: ❌ Error al confirmar: $e');
      emit(CuadranteAsignacionesError('Error al confirmar asignación: $e'));
    }
  }

  /// Cancelar asignación
  Future<void> _onCancelarRequested(
    CuadranteAsignacionesCancelarRequested event,
    Emitter<CuadranteAsignacionesState> emit,
  ) async {
    try {
      emit(const CuadranteAsignacionesLoading());
      debugPrint('📦 BLoC: Cancelando asignación ${event.id}');

      final CuadranteAsignacionEntity asignacion = await _repository.cancelar(event.id);

      debugPrint('📦 BLoC: ✅ Asignación cancelada');
      emit(CuadranteAsignacionesOperationSuccess(
        message: 'Asignación cancelada exitosamente',
        asignacion: asignacion,
      ));
    } catch (e) {
      debugPrint('📦 BLoC: ❌ Error al cancelar: $e');
      emit(CuadranteAsignacionesError('Error al cancelar asignación: $e'));
    }
  }

  /// Completar asignación
  Future<void> _onCompletarRequested(
    CuadranteAsignacionesCompletarRequested event,
    Emitter<CuadranteAsignacionesState> emit,
  ) async {
    try {
      emit(const CuadranteAsignacionesLoading());
      debugPrint('📦 BLoC: Completando asignación ${event.id}');

      final CuadranteAsignacionEntity asignacion = await _repository.completar(
        id: event.id,
        kmFinal: event.kmFinal,
        serviciosRealizados: event.serviciosRealizados,
        observaciones: event.observaciones,
      );

      debugPrint('📦 BLoC: ✅ Asignación completada');
      emit(CuadranteAsignacionesOperationSuccess(
        message: 'Asignación completada exitosamente',
        asignacion: asignacion,
      ));
    } catch (e) {
      debugPrint('📦 BLoC: ❌ Error al completar: $e');
      emit(CuadranteAsignacionesError('Error al completar asignación: $e'));
    }
  }

  /// Verificar conflicto de personal
  Future<void> _onCheckConflictPersonalRequested(
    CuadranteAsignacionesCheckConflictPersonalRequested event,
    Emitter<CuadranteAsignacionesState> emit,
  ) async {
    try {
      debugPrint('📦 BLoC: Verificando conflictos de personal ${event.idPersonal}');

      final bool hasConflict = await _repository.hasConflictPersonal(
        idPersonal: event.idPersonal,
        fecha: event.fecha,
        horaInicio: event.horaInicio,
        horaFin: event.horaFin,
        cruzaMedianoche: event.cruzaMedianoche,
        excludeId: event.excludeId,
      );

      debugPrint('📦 BLoC: ${hasConflict ? '⚠️ Conflicto detectado' : '✅ Sin conflictos'}');
      emit(CuadranteAsignacionesConflictChecked(
        hasConflict: hasConflict,
        conflictMessage: hasConflict
            ? 'El personal ya tiene una asignación en este horario'
            : null,
      ));
    } catch (e) {
      debugPrint('📦 BLoC: ❌ Error al verificar conflictos: $e');
      emit(CuadranteAsignacionesError('Error al verificar conflictos: $e'));
    }
  }

  /// Verificar conflicto de vehículo
  Future<void> _onCheckConflictVehiculoRequested(
    CuadranteAsignacionesCheckConflictVehiculoRequested event,
    Emitter<CuadranteAsignacionesState> emit,
  ) async {
    try {
      debugPrint('📦 BLoC: Verificando conflictos de vehículo ${event.idVehiculo}');

      final bool hasConflict = await _repository.hasConflictVehiculo(
        idVehiculo: event.idVehiculo,
        fecha: event.fecha,
        horaInicio: event.horaInicio,
        horaFin: event.horaFin,
        cruzaMedianoche: event.cruzaMedianoche,
        excludeId: event.excludeId,
      );

      debugPrint('📦 BLoC: ${hasConflict ? '⚠️ Conflicto detectado' : '✅ Sin conflictos'}');
      emit(CuadranteAsignacionesConflictChecked(
        hasConflict: hasConflict,
        conflictMessage: hasConflict
            ? 'El vehículo ya está asignado en este horario'
            : null,
      ));
    } catch (e) {
      debugPrint('📦 BLoC: ❌ Error al verificar conflictos: $e');
      emit(CuadranteAsignacionesError('Error al verificar conflictos: $e'));
    }
  }
}
