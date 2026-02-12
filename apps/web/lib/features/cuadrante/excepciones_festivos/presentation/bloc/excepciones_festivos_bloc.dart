import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/features/cuadrante/excepciones_festivos/domain/repositories/excepcion_festivo_repository.dart';
import 'package:ambutrack_web/features/cuadrante/excepciones_festivos/presentation/bloc/excepciones_festivos_event.dart';
import 'package:ambutrack_web/features/cuadrante/excepciones_festivos/presentation/bloc/excepciones_festivos_state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

/// BLoC para gestión de Excepciones/Festivos
@injectable
class ExcepcionesFestivosBloc extends Bloc<ExcepcionesFestivosEvent, ExcepcionesFestivosState> {
  ExcepcionesFestivosBloc(this._repository) : super(const ExcepcionesFestivosInitial()) {
    on<ExcepcionesFestivosLoadRequested>(_onLoadRequested);
    on<ExcepcionFestivoCreateRequested>(_onCreateRequested);
    on<ExcepcionFestivoUpdateRequested>(_onUpdateRequested);
    on<ExcepcionFestivoDeleteRequested>(_onDeleteRequested);
    on<ExcepcionFestivoToggleActivoRequested>(_onToggleActivoRequested);
  }

  final ExcepcionFestivoRepository _repository;

  /// Maneja la carga de excepciones/festivos
  Future<void> _onLoadRequested(
    ExcepcionesFestivosLoadRequested event,
    Emitter<ExcepcionesFestivosState> emit,
  ) async {
    try {
      debugPrint('🔄 BLoC: Cargando excepciones/festivos...');
      emit(const ExcepcionesFestivosLoading());

      final List<ExcepcionFestivoEntity> items = await _repository.getAll();

      debugPrint('✅ BLoC: ${items.length} excepciones/festivos cargadas');
      emit(ExcepcionesFestivosLoaded(items));
    } catch (e, stackTrace) {
      debugPrint('❌ BLoC: Error al cargar: $e');
      debugPrint('Stack trace: $stackTrace');
      emit(ExcepcionesFestivosError('Error al cargar excepciones/festivos: ${e.toString()}'));
    }
  }

  /// Maneja la creación de una excepción/festivo
  Future<void> _onCreateRequested(
    ExcepcionFestivoCreateRequested event,
    Emitter<ExcepcionesFestivosState> emit,
  ) async {
    try {
      debugPrint('🔄 BLoC: Creando excepción/festivo: ${event.item.nombre}');

      await _repository.create(event.item);

      debugPrint('✅ BLoC: Excepción/festivo creada');

      // Recargar lista
      final List<ExcepcionFestivoEntity> items = await _repository.getAll();
      emit(ExcepcionesFestivosLoaded(items));
    } catch (e, stackTrace) {
      debugPrint('❌ BLoC: Error al crear: $e');
      debugPrint('Stack trace: $stackTrace');
      emit(ExcepcionesFestivosError('Error al crear excepción/festivo: ${e.toString()}'));

      // Recargar lista para mantener estado consistente
      try {
        final List<ExcepcionFestivoEntity> items = await _repository.getAll();
        emit(ExcepcionesFestivosLoaded(items));
      } catch (_) {
        // Si falla la recarga, mantener estado de error
      }
    }
  }

  /// Maneja la actualización de una excepción/festivo
  Future<void> _onUpdateRequested(
    ExcepcionFestivoUpdateRequested event,
    Emitter<ExcepcionesFestivosState> emit,
  ) async {
    try {
      debugPrint('🔄 BLoC: Actualizando excepción/festivo: ${event.item.nombre}');

      await _repository.update(event.item);

      debugPrint('✅ BLoC: Excepción/festivo actualizada');

      // Recargar lista
      final List<ExcepcionFestivoEntity> items = await _repository.getAll();
      emit(ExcepcionesFestivosLoaded(items));
    } catch (e, stackTrace) {
      debugPrint('❌ BLoC: Error al actualizar: $e');
      debugPrint('Stack trace: $stackTrace');
      emit(ExcepcionesFestivosError('Error al actualizar excepción/festivo: ${e.toString()}'));

      // Recargar lista para mantener estado consistente
      try {
        final List<ExcepcionFestivoEntity> items = await _repository.getAll();
        emit(ExcepcionesFestivosLoaded(items));
      } catch (_) {
        // Si falla la recarga, mantener estado de error
      }
    }
  }

  /// Maneja la eliminación de una excepción/festivo
  Future<void> _onDeleteRequested(
    ExcepcionFestivoDeleteRequested event,
    Emitter<ExcepcionesFestivosState> emit,
  ) async {
    try {
      debugPrint('🔄 BLoC: Eliminando excepción/festivo con ID: ${event.id}');

      await _repository.delete(event.id);

      debugPrint('✅ BLoC: Excepción/festivo eliminada');

      // Recargar lista y emitir estado de éxito
      final List<ExcepcionFestivoEntity> items = await _repository.getAll();
      emit(ExcepcionFestivoOperationSuccess(items, 'Excepción/festivo eliminada exitosamente'));
    } catch (e, stackTrace) {
      debugPrint('❌ BLoC: Error al eliminar: $e');
      debugPrint('Stack trace: $stackTrace');
      emit(ExcepcionesFestivosError('Error al eliminar excepción/festivo: ${e.toString()}'));

      // Recargar lista para mantener estado consistente
      try {
        final List<ExcepcionFestivoEntity> items = await _repository.getAll();
        emit(ExcepcionesFestivosLoaded(items));
      } catch (_) {
        // Si falla la recarga, mantener estado de error
      }
    }
  }

  /// Maneja el cambio de estado activo
  Future<void> _onToggleActivoRequested(
    ExcepcionFestivoToggleActivoRequested event,
    Emitter<ExcepcionesFestivosState> emit,
  ) async {
    try {
      debugPrint('🔄 BLoC: Cambiando estado activo: ${event.activo}');

      await _repository.toggleActivo(event.id, activo: event.activo);

      debugPrint('✅ BLoC: Estado actualizado');

      // Recargar lista
      final List<ExcepcionFestivoEntity> items = await _repository.getAll();
      emit(ExcepcionesFestivosLoaded(items));
    } catch (e, stackTrace) {
      debugPrint('❌ BLoC: Error al cambiar estado: $e');
      debugPrint('Stack trace: $stackTrace');
      emit(ExcepcionesFestivosError('Error al cambiar estado: ${e.toString()}'));

      // Recargar lista para mantener estado consistente
      try {
        final List<ExcepcionFestivoEntity> items = await _repository.getAll();
        emit(ExcepcionesFestivosLoaded(items));
      } catch (_) {
        // Si falla la recarga, mantener estado de error
      }
    }
  }
}
