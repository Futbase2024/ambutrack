import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/features/cuadrante/excepciones_festivos/domain/repositories/excepcion_festivo_repository.dart';
import 'package:ambutrack_web/features/cuadrante/excepciones_festivos/presentation/bloc/excepciones_festivos_event.dart';
import 'package:ambutrack_web/features/cuadrante/excepciones_festivos/presentation/bloc/excepciones_festivos_state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

/// BLoC para gestión de Excepciones/Festivos
@injectable
class ExcepcionesFestivosBloc
    extends Bloc<ExcepcionesFestivosEvent, ExcepcionesFestivosState> {
  ExcepcionesFestivosBloc(this._repository)
      : super(const ExcepcionesFestivosInitial()) {
    on<ExcepcionesFestivosLoadRequested>(_onLoadRequested);
    on<ExcepcionFestivoCreateRequested>(_onCreateRequested);
    on<ExcepcionFestivoUpdateRequested>(_onUpdateRequested);
    on<ExcepcionFestivoDeleteRequested>(_onDeleteRequested);
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
      emit(ExcepcionesFestivosError(
        'Error al cargar excepciones/festivos: ${e.toString()}',
      ));
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
      add(const ExcepcionesFestivosLoadRequested());
    } catch (e, stackTrace) {
      debugPrint('❌ BLoC: Error al crear: $e');
      debugPrint('Stack trace: $stackTrace');
      emit(ExcepcionesFestivosError(
        'Error al crear excepción/festivo: ${e.toString()}',
      ));
    }
  }

  /// Maneja la actualización de una excepción/festivo
  Future<void> _onUpdateRequested(
    ExcepcionFestivoUpdateRequested event,
    Emitter<ExcepcionesFestivosState> emit,
  ) async {
    try {
      debugPrint(
        '🔄 BLoC: Actualizando excepción/festivo: ${event.item.nombre}',
      );
      await _repository.update(event.item);
      debugPrint('✅ BLoC: Excepción/festivo actualizada');
      add(const ExcepcionesFestivosLoadRequested());
    } catch (e, stackTrace) {
      debugPrint('❌ BLoC: Error al actualizar: $e');
      debugPrint('Stack trace: $stackTrace');
      emit(ExcepcionesFestivosError(
        'Error al actualizar excepción/festivo: ${e.toString()}',
      ));
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
      add(const ExcepcionesFestivosLoadRequested());
    } catch (e, stackTrace) {
      debugPrint('❌ BLoC: Error al eliminar: $e');
      debugPrint('Stack trace: $stackTrace');
      emit(ExcepcionesFestivosError(
        'Error al eliminar excepción/festivo: ${e.toString()}',
      ));
    }
  }
}
