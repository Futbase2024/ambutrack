import 'package:ambutrack_core/ambutrack_core.dart';
import 'package:ambutrack_web/features/turnos/domain/repositories/plantilla_turno_repository.dart';
import 'package:ambutrack_web/features/turnos/presentation/bloc/plantillas_turnos_event.dart';
import 'package:ambutrack_web/features/turnos/presentation/bloc/plantillas_turnos_state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

/// BLoC para gestión de plantillas de turnos
@injectable
class PlantillasTurnosBloc
    extends Bloc<PlantillasTurnosEvent, PlantillasTurnosState> {
  PlantillasTurnosBloc(this._repository)
      : super(const PlantillasTurnosInitial()) {
    on<PlantillasTurnosLoadRequested>(_onLoadRequested);
    on<PlantillasTurnosRefreshRequested>(_onRefreshRequested);
    on<PlantillaTurnoCreateRequested>(_onCreateRequested);
    on<PlantillaTurnoUpdateRequested>(_onUpdateRequested);
    on<PlantillaTurnoDeleteRequested>(_onDeleteRequested);
    on<PlantillaTurnoDuplicateRequested>(_onDuplicateRequested);
  }

  final PlantillaTurnoRepository _repository;

  /// Carga todas las plantillas
  Future<void> _onLoadRequested(
    PlantillasTurnosLoadRequested event,
    Emitter<PlantillasTurnosState> emit,
  ) async {
    debugPrint('🚀 PlantillasTurnosBloc: Cargando plantillas...');
    emit(const PlantillasTurnosLoading());

    try {
      final List<PlantillaTurnoEntity> plantillas =
          await _repository.getAll();
      debugPrint('   ✅ Plantillas cargadas: ${plantillas.length}');
      emit(PlantillasTurnosLoaded(plantillas));
    } catch (e) {
      debugPrint('   ❌ Error al cargar plantillas: $e');
      emit(PlantillasTurnosError(e.toString()));
    }
  }

  /// Refresca las plantillas
  Future<void> _onRefreshRequested(
    PlantillasTurnosRefreshRequested event,
    Emitter<PlantillasTurnosState> emit,
  ) async {
    debugPrint('🔄 PlantillasTurnosBloc: Refrescando plantillas...');
    add(const PlantillasTurnosLoadRequested());
  }

  /// Crea una nueva plantilla
  Future<void> _onCreateRequested(
    PlantillaTurnoCreateRequested event,
    Emitter<PlantillasTurnosState> emit,
  ) async {
    debugPrint(
      '🆕 PlantillasTurnosBloc: Creando plantilla "${event.plantilla.nombre}"',
    );

    try {
      final PlantillaTurnoEntity creada =
          await _repository.create(event.plantilla);
      debugPrint('   ✅ Plantilla creada: ${creada.id}');

      emit(PlantillaTurnoCreated(creada));

      // Recargar lista
      add(const PlantillasTurnosLoadRequested());
    } catch (e) {
      debugPrint('   ❌ Error al crear plantilla: $e');
      emit(PlantillasTurnosError(e.toString()));
    }
  }

  /// Actualiza una plantilla existente
  Future<void> _onUpdateRequested(
    PlantillaTurnoUpdateRequested event,
    Emitter<PlantillasTurnosState> emit,
  ) async {
    debugPrint(
      '✏️ PlantillasTurnosBloc: Actualizando plantilla "${event.plantilla.nombre}"',
    );

    try {
      await _repository.update(event.plantilla);
      debugPrint('   ✅ Plantilla actualizada: ${event.plantilla.id}');

      emit(PlantillaTurnoUpdated(event.plantilla));

      // Recargar lista
      add(const PlantillasTurnosLoadRequested());
    } catch (e) {
      debugPrint('   ❌ Error al actualizar plantilla: $e');
      emit(PlantillasTurnosError(e.toString()));
    }
  }

  /// Elimina una plantilla (soft delete)
  Future<void> _onDeleteRequested(
    PlantillaTurnoDeleteRequested event,
    Emitter<PlantillasTurnosState> emit,
  ) async {
    debugPrint('🗑️ PlantillasTurnosBloc: Eliminando plantilla ${event.id}');

    try {
      await _repository.delete(event.id);
      debugPrint('   ✅ Plantilla eliminada: ${event.id}');

      emit(PlantillaTurnoDeleted(event.id));

      // Recargar lista
      add(const PlantillasTurnosLoadRequested());
    } catch (e) {
      debugPrint('   ❌ Error al eliminar plantilla: $e');
      emit(PlantillasTurnosError(e.toString()));
    }
  }

  /// Duplica una plantilla existente
  Future<void> _onDuplicateRequested(
    PlantillaTurnoDuplicateRequested event,
    Emitter<PlantillasTurnosState> emit,
  ) async {
    debugPrint('📋 PlantillasTurnosBloc: Duplicando plantilla ${event.id}');

    try {
      final PlantillaTurnoEntity duplicada =
          await _repository.duplicate(event.id);
      debugPrint('   ✅ Plantilla duplicada: ${duplicada.id}');

      emit(PlantillaTurnoDuplicated(duplicada));

      // Recargar lista
      add(const PlantillasTurnosLoadRequested());
    } catch (e) {
      debugPrint('   ❌ Error al duplicar plantilla: $e');
      emit(PlantillasTurnosError(e.toString()));
    }
  }
}
