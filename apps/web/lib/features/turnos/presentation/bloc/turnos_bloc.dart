import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/features/turnos/domain/entities/validation_result_entity.dart';
import 'package:ambutrack_web/features/turnos/domain/repositories/turnos_repository.dart';
import 'package:ambutrack_web/features/turnos/domain/services/turno_validation_service.dart';
import 'package:ambutrack_web/features/turnos/presentation/bloc/turnos_event.dart';
import 'package:ambutrack_web/features/turnos/presentation/bloc/turnos_state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

/// BLoC para gestión de turnos del personal
@injectable
class TurnosBloc extends Bloc<TurnosEvent, TurnosState> {
  TurnosBloc(
    this._repository,
    this._validationService,
  ) : super(const TurnosInitial()) {
    on<TurnosLoadRequested>(_onLoadRequested);
    on<TurnosLoadByDateRangeRequested>(_onLoadByDateRangeRequested);
    on<TurnosLoadByPersonalRequested>(_onLoadByPersonalRequested);
    on<TurnoCreateRequested>(_onCreateRequested);
    on<TurnoUpdateRequested>(_onUpdateRequested);
    on<TurnoDeleteRequested>(_onDeleteRequested);
    on<TurnoValidarRequested>(_onValidarRequested);
    on<TurnosCheckConflictsRequested>(_onCheckConflictsRequested);
  }

  final TurnosRepository _repository;
  final TurnoValidationService _validationService;

  Future<void> _onLoadRequested(
    TurnosLoadRequested event,
    Emitter<TurnosState> emit,
  ) async {
    emit(const TurnosLoading());
    try {
      debugPrint('🚀 TurnosBloc: Cargando todos los turnos...');
      final List<TurnoEntity> turnos = await _repository.getAll();
      debugPrint('✅ TurnosBloc: ${turnos.length} turnos cargados');
      emit(TurnosLoaded(turnos));
    } catch (e) {
      debugPrint('❌ TurnosBloc: Error al cargar turnos: $e');
      emit(TurnosError('Error al cargar turnos: $e'));
    }
  }

  Future<void> _onLoadByDateRangeRequested(
    TurnosLoadByDateRangeRequested event,
    Emitter<TurnosState> emit,
  ) async {
    emit(const TurnosLoading());
    try {
      debugPrint(
        '🚀 TurnosBloc: Cargando turnos desde ${event.startDate} hasta ${event.endDate}',
      );
      final List<TurnoEntity> turnos = await _repository.getByDateRange(
        startDate: event.startDate,
        endDate: event.endDate,
      );
      debugPrint('✅ TurnosBloc: ${turnos.length} turnos cargados');
      emit(TurnosLoaded(turnos));
    } catch (e) {
      debugPrint('❌ TurnosBloc: Error al cargar turnos por rango: $e');
      emit(TurnosError('Error al cargar turnos: $e'));
    }
  }

  Future<void> _onLoadByPersonalRequested(
    TurnosLoadByPersonalRequested event,
    Emitter<TurnosState> emit,
  ) async {
    emit(const TurnosLoading());
    try {
      debugPrint('🚀 TurnosBloc: Cargando turnos del personal ${event.idPersonal}');
      final List<TurnoEntity> turnos = await _repository.getByPersonal(event.idPersonal);
      debugPrint('✅ TurnosBloc: ${turnos.length} turnos cargados');
      emit(TurnosLoaded(turnos));
    } catch (e) {
      debugPrint('❌ TurnosBloc: Error al cargar turnos del personal: $e');
      emit(TurnosError('Error al cargar turnos: $e'));
    }
  }

  Future<void> _onCreateRequested(
    TurnoCreateRequested event,
    Emitter<TurnosState> emit,
  ) async {
    try {
      debugPrint('🚀 TurnosBloc: Creando turno para ${event.turno.nombrePersonal}');

      // Obtener turnos existentes del personal
      final List<TurnoEntity> turnosExistentes =
          await _repository.getByPersonal(event.turno.idPersonal);

      // Validar el turno
      final ValidationResult validationResult =
          await _validationService.validateTurno(
        turnoNuevo: event.turno,
        idPersonal: event.turno.idPersonal,
        turnosExistentes: turnosExistentes,
      );

      // Si tiene errores críticos, no permitir crear
      if (validationResult.hasErrors) {
        debugPrint('❌ TurnosBloc: Validación fallida con ${validationResult.errors.length} errores');
        final String errorMessages = validationResult.errors
            .map((ValidationIssue issue) => issue.message)
            .join('\n');
        emit(TurnosValidationFailed(validationResult));
        emit(TurnosError(errorMessages));
        return;
      }

      // Si solo tiene advertencias, permitir pero informar
      if (validationResult.hasWarnings) {
        debugPrint('⚠️ TurnosBloc: Validación con ${validationResult.warnings.length} advertencias');
        emit(TurnosValidationWarnings(validationResult));
      }

      final TurnoEntity createdTurno = await _repository.create(event.turno);
      debugPrint('✅ TurnosBloc: Turno creado exitosamente');
      emit(TurnoCreated(createdTurno));
    } catch (e) {
      debugPrint('❌ TurnosBloc: Error al crear turno: $e');
      emit(TurnosError('Error al crear turno: $e'));
    }
  }

  Future<void> _onUpdateRequested(
    TurnoUpdateRequested event,
    Emitter<TurnosState> emit,
  ) async {
    try {
      debugPrint('🚀 TurnosBloc: Actualizando turno ${event.turno.id}');

      // Verificar conflictos excluyendo el turno actual
      final bool hasConflicts = await _repository.hasConflicts(
        idPersonal: event.turno.idPersonal,
        fechaInicio: event.turno.fechaInicio,
        fechaFin: event.turno.fechaFin,
        excludeTurnoId: event.turno.id,
        horaInicio: event.turno.horaInicio,
        horaFin: event.turno.horaFin,
      );

      if (hasConflicts) {
        debugPrint('⚠️ TurnosBloc: Conflicto detectado al actualizar turno');
        emit(const TurnosError('Ya existe un turno asignado en ese horario'));
        return;
      }

      await _repository.update(event.turno);
      debugPrint('✅ TurnosBloc: Turno actualizado exitosamente');
      emit(TurnoUpdated(event.turno));
    } catch (e) {
      debugPrint('❌ TurnosBloc: Error al actualizar turno: $e');
      emit(TurnosError('Error al actualizar turno: $e'));
    }
  }

  Future<void> _onDeleteRequested(
    TurnoDeleteRequested event,
    Emitter<TurnosState> emit,
  ) async {
    try {
      debugPrint('🚀 TurnosBloc: Eliminando turno ${event.id}');
      await _repository.delete(event.id);
      debugPrint('✅ TurnosBloc: Turno eliminado exitosamente');
      emit(TurnoDeleted(event.id));
    } catch (e) {
      debugPrint('❌ TurnosBloc: Error al eliminar turno: $e');
      emit(TurnosError('Error al eliminar turno: $e'));
    }
  }

  Future<void> _onValidarRequested(
    TurnoValidarRequested event,
    Emitter<TurnosState> emit,
  ) async {
    try {
      debugPrint('🚀 TurnosBloc: Validando turno ${event.id}');
      final TurnoEntity turno = await _repository.validar(event.id);
      emit(TurnoUpdated(turno));
    } catch (e) {
      debugPrint('❌ TurnosBloc: Error al validar turno: $e');
      emit(TurnosError('Error al validar turno: $e'));
    }
  }

  Future<void> _onCheckConflictsRequested(
    TurnosCheckConflictsRequested event,
    Emitter<TurnosState> emit,
  ) async {
    try {
      debugPrint('🔍 TurnosBloc: Verificando conflictos de turnos');
      debugPrint('   Horario: ${event.horaInicio ?? 'N/A'} - ${event.horaFin ?? 'N/A'}');
      final bool hasConflicts = await _repository.hasConflicts(
        idPersonal: event.idPersonal,
        fechaInicio: event.fechaInicio,
        fechaFin: event.fechaFin,
        excludeTurnoId: event.excludeTurnoId,
        horaInicio: event.horaInicio,
        horaFin: event.horaFin,
      );

      debugPrint(
        hasConflicts
            ? '⚠️ TurnosBloc: Conflicto detectado'
            : '✅ TurnosBloc: No hay conflictos',
      );

      emit(TurnosConflictDetected(hasConflict: hasConflicts));
    } catch (e) {
      debugPrint('❌ TurnosBloc: Error al verificar conflictos: $e');
      emit(TurnosError('Error al verificar conflictos: $e'));
    }
  }
}
