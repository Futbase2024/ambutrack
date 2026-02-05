import 'package:ambutrack_core/ambutrack_core.dart';
import 'package:ambutrack_web/features/tablas/provincias/domain/repositories/provincia_repository.dart';
import 'package:ambutrack_web/features/tablas/provincias/presentation/bloc/provincia_event.dart';
import 'package:ambutrack_web/features/tablas/provincias/presentation/bloc/provincia_state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

/// BLoC para gestión de provincias
@injectable
class ProvinciaBloc extends Bloc<ProvinciaEvent, ProvinciaState> {
  ProvinciaBloc(this._repository) : super(const ProvinciaInitial()) {
    on<ProvinciaLoadAllRequested>(_onLoadAllRequested);
    on<ProvinciaCreateRequested>(_onCreateRequested);
    on<ProvinciaUpdateRequested>(_onUpdateRequested);
    on<ProvinciaDeleteRequested>(_onDeleteRequested);
  }

  final ProvinciaRepository _repository;

  /// Maneja la carga de todas las provincias
  Future<void> _onLoadAllRequested(
    ProvinciaLoadAllRequested event,
    Emitter<ProvinciaState> emit,
  ) async {
    try {
      debugPrint('🚀 ProvinciaBloc: Cargando todas las provincias...');
      emit(const ProvinciaLoading());

      final List<ProvinciaEntity> provincias = await _repository.getAll();

      debugPrint('✅ ProvinciaBloc: ${provincias.length} provincias cargadas');
      emit(ProvinciaLoaded(provincias));
    } catch (e) {
      debugPrint('❌ ProvinciaBloc: Error al cargar provincias: $e');
      emit(ProvinciaError(e.toString()));
    }
  }

  /// Maneja la creación de una provincia
  Future<void> _onCreateRequested(
    ProvinciaCreateRequested event,
    Emitter<ProvinciaState> emit,
  ) async {
    try {
      debugPrint('🚀 ProvinciaBloc: Creando provincia: ${event.provincia.nombre}');
      emit(const ProvinciaCreating());

      final ProvinciaEntity provincia = await _repository.create(event.provincia);

      debugPrint('✅ ProvinciaBloc: Provincia creada con ID: ${provincia.id}');
      emit(ProvinciaCreated(provincia));
      // Recargar la lista después de crear
      add(const ProvinciaLoadAllRequested());
    } catch (e) {
      debugPrint('❌ ProvinciaBloc: Error al crear provincia: $e');
      emit(ProvinciaError(e.toString()));
    }
  }

  /// Maneja la actualización de una provincia
  Future<void> _onUpdateRequested(
    ProvinciaUpdateRequested event,
    Emitter<ProvinciaState> emit,
  ) async {
    try {
      debugPrint('🚀 ProvinciaBloc: Actualizando provincia: ${event.provincia.id}');
      emit(const ProvinciaUpdating());

      final ProvinciaEntity provincia = await _repository.update(event.provincia);

      debugPrint('✅ ProvinciaBloc: Provincia actualizada');
      emit(ProvinciaUpdated(provincia));
      // Recargar la lista después de actualizar
      add(const ProvinciaLoadAllRequested());
    } catch (e) {
      debugPrint('❌ ProvinciaBloc: Error al actualizar provincia: $e');
      emit(ProvinciaError(e.toString()));
    }
  }

  /// Maneja la eliminación de una provincia
  Future<void> _onDeleteRequested(
    ProvinciaDeleteRequested event,
    Emitter<ProvinciaState> emit,
  ) async {
    try {
      debugPrint('🚀 ProvinciaBloc: Eliminando provincia: ${event.id}');
      emit(const ProvinciaDeleting());

      await _repository.delete(event.id);

      debugPrint('✅ ProvinciaBloc: Provincia eliminada');
      emit(const ProvinciaDeleted());
      // Recargar la lista después de eliminar
      add(const ProvinciaLoadAllRequested());
    } catch (e) {
      debugPrint('❌ ProvinciaBloc: Error al eliminar provincia: $e');
      emit(ProvinciaError(e.toString()));
    }
  }
}
