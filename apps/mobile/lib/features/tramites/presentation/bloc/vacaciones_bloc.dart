import 'dart:async';

import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../notificaciones/domain/repositories/notificaciones_repository.dart';
import '../../domain/repositories/vacaciones_repository.dart';
import 'vacaciones_event.dart';
import 'vacaciones_state.dart';

/// BLoC para gestionar el estado de las vacaciones.
@injectable
class VacacionesBloc extends Bloc<VacacionesEvent, VacacionesState> {
  VacacionesBloc(
    this._repository,
    this._notificacionesRepository,
    this._authBloc,
  ) : super(const VacacionesInitial()) {
    on<VacacionesLoadRequested>(_onLoadRequested);
    on<VacacionesLoadByPersonalRequested>(_onLoadByPersonalRequested);
    on<VacacionesCreateRequested>(_onCreateRequested);
    on<VacacionesUpdateRequested>(_onUpdateRequested);
    on<VacacionesDeleteRequested>(_onDeleteRequested);
    on<VacacionesWatchRequested>(_onWatchRequested);
    on<VacacionesWatchByPersonalRequested>(_onWatchByPersonalRequested);
  }

  final VacacionesRepository _repository;
  final NotificacionesRepository _notificacionesRepository;
  final AuthBloc _authBloc;
  StreamSubscription<List<VacacionesEntity>>? _watchSubscription;

  Future<void> _onLoadRequested(
    VacacionesLoadRequested event,
    Emitter<VacacionesState> emit,
  ) async {
    debugPrint('🏖️ VacacionesBloc: Cargando todas las vacaciones...');
    emit(const VacacionesLoading());

    try {
      final vacaciones = await _repository.getAll();
      debugPrint(
          '🏖️ VacacionesBloc: ✅ ${vacaciones.length} vacaciones cargadas');
      emit(VacacionesLoaded(vacaciones: vacaciones));
    } catch (e) {
      debugPrint('🏖️ VacacionesBloc: ❌ Error: $e');
      emit(VacacionesError(e.toString()));
    }
  }

  Future<void> _onLoadByPersonalRequested(
    VacacionesLoadByPersonalRequested event,
    Emitter<VacacionesState> emit,
  ) async {
    debugPrint(
        '🏖️ VacacionesBloc: Cargando vacaciones del personal: ${event.idPersonal}');
    emit(const VacacionesLoading());

    try {
      final vacaciones = await _repository.getByPersonalId(event.idPersonal);
      debugPrint(
          '🏖️ VacacionesBloc: ✅ ${vacaciones.length} vacaciones cargadas');
      emit(VacacionesLoaded(
        vacaciones: vacaciones,
        filteredByPersonal: event.idPersonal,
      ));
    } catch (e) {
      debugPrint('🏖️ VacacionesBloc: ❌ Error: $e');
      emit(VacacionesError(e.toString()));
    }
  }

  Future<void> _onCreateRequested(
    VacacionesCreateRequested event,
    Emitter<VacacionesState> emit,
  ) async {
    debugPrint('🏖️ VacacionesBloc: Creando vacación...');
    emit(const VacacionesLoading());

    try {
      final created = await _repository.create(event.vacacion);
      debugPrint('🏖️ VacacionesBloc: ✅ Vacación creada: ${created.id}');

      // Notificar a jefes de personal si está pendiente
      if (created.estado == 'pendiente') {
        await _notificarNuevaVacacion(created);
      }

      emit(VacacionCreated(created));

      // Recargar lista después de crear
      add(VacacionesLoadByPersonalRequested(created.idPersonal));
    } catch (e) {
      debugPrint('🏖️ VacacionesBloc: ❌ Error al crear: $e');
      emit(VacacionesError(e.toString()));
    }
  }

  /// Notifica a los jefes de personal sobre una nueva solicitud de vacaciones
  Future<void> _notificarNuevaVacacion(VacacionesEntity vacacion) async {
    try {
      // Obtener datos del usuario autenticado
      final authState = _authBloc.state;
      if (authState is! AuthAuthenticated || authState.personal == null) {
        debugPrint('🏖️ VacacionesBloc: ⚠️ No se puede notificar - usuario no autenticado');
        return;
      }

      final personal = authState.personal!;
      final nombrePersonal = personal.nombreCompleto;
      final fechaInicioStr = '${vacacion.fechaInicio.day}/${vacacion.fechaInicio.month}/${vacacion.fechaInicio.year}';
      final fechaFinStr = '${vacacion.fechaFin.day}/${vacacion.fechaFin.month}/${vacacion.fechaFin.year}';

      // Crear notificación para jefes de personal
      await _notificacionesRepository.notificarJefesPersonal(
        tipo: 'vacacion_solicitada',
        titulo: 'Nueva Solicitud de Vacaciones',
        mensaje: '$nombrePersonal ha solicitado ${vacacion.diasSolicitados} días de vacaciones ($fechaInicioStr - $fechaFinStr)',
        entidadTipo: 'vacacion',
        entidadId: vacacion.id,
        metadata: {
          'personal_id': vacacion.idPersonal,
          'personal_nombre': nombrePersonal,
          'fecha_inicio': vacacion.fechaInicio.toIso8601String(),
          'fecha_fin': vacacion.fechaFin.toIso8601String(),
          'dias': vacacion.diasSolicitados,
        },
      );

      debugPrint('🏖️ VacacionesBloc: ✅ Notificación enviada a jefes de personal');
    } catch (e) {
      debugPrint('🏖️ VacacionesBloc: ❌ Error al enviar notificación: $e');
      // No fallar el flujo principal si falla la notificación
    }
  }

  Future<void> _onUpdateRequested(
    VacacionesUpdateRequested event,
    Emitter<VacacionesState> emit,
  ) async {
    debugPrint(
        '🏖️ VacacionesBloc: Actualizando vacación ID: ${event.vacacion.id}');
    emit(const VacacionesLoading());

    try {
      final updated = await _repository.update(event.vacacion);
      debugPrint('🏖️ VacacionesBloc: ✅ Vacación actualizada');
      emit(VacacionUpdated(updated));

      // Recargar lista después de actualizar
      add(VacacionesLoadByPersonalRequested(updated.idPersonal));
    } catch (e) {
      debugPrint('🏖️ VacacionesBloc: ❌ Error al actualizar: $e');
      emit(VacacionesError(e.toString()));
    }
  }

  Future<void> _onDeleteRequested(
    VacacionesDeleteRequested event,
    Emitter<VacacionesState> emit,
  ) async {
    debugPrint('🏖️ VacacionesBloc: Eliminando vacación ID: ${event.id}');
    emit(const VacacionesLoading());

    try {
      await _repository.delete(event.id);
      debugPrint('🏖️ VacacionesBloc: ✅ Vacación eliminada');
      emit(VacacionDeleted(event.id));

      // Recargar lista después de eliminar
      if (state is VacacionesLoaded) {
        final currentState = state as VacacionesLoaded;
        if (currentState.filteredByPersonal != null) {
          add(VacacionesLoadByPersonalRequested(
              currentState.filteredByPersonal!));
        } else {
          add(const VacacionesLoadRequested());
        }
      }
    } catch (e) {
      debugPrint('🏖️ VacacionesBloc: ❌ Error al eliminar: $e');
      emit(VacacionesError(e.toString()));
    }
  }

  Future<void> _onWatchRequested(
    VacacionesWatchRequested event,
    Emitter<VacacionesState> emit,
  ) async {
    debugPrint('🏖️ VacacionesBloc: Observando todas las vacaciones...');
    await _watchSubscription?.cancel();

    emit(const VacacionesLoading());

    _watchSubscription = _repository.watchAll().listen(
      (vacaciones) {
        debugPrint(
            '🏖️ VacacionesBloc: 🔄 Actualización recibida: ${vacaciones.length} vacaciones');
        add(const VacacionesLoadRequested());
      },
      onError: (error) {
        debugPrint('🏖️ VacacionesBloc: ❌ Error en stream: $error');
        emit(VacacionesError(error.toString()));
      },
    );
  }

  Future<void> _onWatchByPersonalRequested(
    VacacionesWatchByPersonalRequested event,
    Emitter<VacacionesState> emit,
  ) async {
    debugPrint(
        '🏖️ VacacionesBloc: Observando vacaciones del personal: ${event.idPersonal}');
    await _watchSubscription?.cancel();

    emit(const VacacionesLoading());

    _watchSubscription = _repository.watchByPersonalId(event.idPersonal).listen(
      (vacaciones) {
        debugPrint(
            '🏖️ VacacionesBloc: 🔄 Actualización recibida: ${vacaciones.length} vacaciones');
        add(VacacionesLoadByPersonalRequested(event.idPersonal));
      },
      onError: (error) {
        debugPrint('🏖️ VacacionesBloc: ❌ Error en stream: $error');
        emit(VacacionesError(error.toString()));
      },
    );
  }

  @override
  Future<void> close() {
    _watchSubscription?.cancel();
    return super.close();
  }
}
