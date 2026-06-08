import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/features/cuadrante/dotaciones/domain/repositories/dotaciones_repository.dart';
import 'package:ambutrack_web/features/cuadrante/dotaciones/presentation/bloc/dotaciones_event.dart';
import 'package:ambutrack_web/features/cuadrante/dotaciones/presentation/bloc/dotaciones_state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

/// BLoC para la gestión de Dotaciones
@injectable
class DotacionesBloc extends Bloc<DotacionesEvent, DotacionesState> {
  DotacionesBloc(this._repository) : super(const DotacionesInitial()) {
    on<DotacionesLoadRequested>(_onLoadRequested);
    on<DotacionesRefreshRequested>(_onRefreshRequested);
    on<DotacionCreateRequested>(_onCreateRequested);
    on<DotacionUpdateRequested>(_onUpdateRequested);
    on<DotacionDeleteRequested>(_onDeleteRequested);
  }

  final DotacionesRepository _repository;

  /// Carga todas las dotaciones
  Future<void> _onLoadRequested(
    DotacionesLoadRequested event,
    Emitter<DotacionesState> emit,
  ) async {
    debugPrint('🚀 DotacionesBloc: Cargando todas las dotaciones...');
    emit(const DotacionesLoading());

    try {
      final List<DotacionEntity> dotaciones = await _repository.getAll();
      debugPrint(
        '✅ DotacionesBloc: ${dotaciones.length} dotaciones cargadas',
      );
      emit(DotacionesLoaded(dotaciones));
    } catch (e) {
      debugPrint('❌ DotacionesBloc: Error al cargar dotaciones - $e');
      emit(DotacionesError('Error al cargar dotaciones: $e'));
    }
  }

  /// Refresca los datos sin mostrar loading
  Future<void> _onRefreshRequested(
    DotacionesRefreshRequested event,
    Emitter<DotacionesState> emit,
  ) async {
    try {
      final List<DotacionEntity> dotaciones = await _repository.getAll();
      debugPrint(
        '✅ DotacionesBloc: ${dotaciones.length} dotaciones refrescadas',
      );
      emit(DotacionesLoaded(dotaciones));
    } catch (e) {
      debugPrint('❌ DotacionesBloc: Error al refrescar dotaciones - $e');
      emit(DotacionesError('Error al refrescar dotaciones: $e'));
    }
  }

  /// Crea una nueva dotación
  Future<void> _onCreateRequested(
    DotacionCreateRequested event,
    Emitter<DotacionesState> emit,
  ) async {
    debugPrint(
      '🚀 DotacionesBloc: Creando dotación ${event.dotacion.nombre}...',
    );

    try {
      await _repository.create(event.dotacion);
      debugPrint(
        '✅ DotacionesBloc: Dotación "${event.dotacion.nombre}" creada',
      );
      add(const DotacionesLoadRequested());
    } catch (e) {
      debugPrint('❌ DotacionesBloc: Error al crear dotación - $e');
      emit(DotacionesError('Error al crear dotación: $e'));
    }
  }

  /// Actualiza una dotación existente
  Future<void> _onUpdateRequested(
    DotacionUpdateRequested event,
    Emitter<DotacionesState> emit,
  ) async {
    debugPrint(
      '🚀 DotacionesBloc: Actualizando dotación ${event.dotacion.nombre}...',
    );

    try {
      await _repository.update(event.dotacion);
      debugPrint(
        '✅ DotacionesBloc: Dotación "${event.dotacion.nombre}" actualizada',
      );
      add(const DotacionesLoadRequested());
    } catch (e) {
      debugPrint('❌ DotacionesBloc: Error al actualizar dotación - $e');
      emit(DotacionesError('Error al actualizar dotación: $e'));
    }
  }

  /// Elimina una dotación
  Future<void> _onDeleteRequested(
    DotacionDeleteRequested event,
    Emitter<DotacionesState> emit,
  ) async {
    debugPrint('🚀 DotacionesBloc: Eliminando dotación ${event.dotacionId}...');

    try {
      await _repository.delete(event.dotacionId);
      debugPrint(
        '✅ DotacionesBloc: Dotación ${event.dotacionId} eliminada',
      );
      add(const DotacionesLoadRequested());
    } catch (e) {
      debugPrint('❌ DotacionesBloc: Error al eliminar dotación - $e');
      emit(DotacionesError('Error al eliminar dotación: $e'));
    }
  }
}
