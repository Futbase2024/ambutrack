import 'package:ambutrack_core/ambutrack_core.dart';
import 'package:ambutrack_web/features/tablas/localidades/domain/repositories/localidad_repository.dart';
import 'package:ambutrack_web/features/tablas/localidades/presentation/bloc/localidad_event.dart';
import 'package:ambutrack_web/features/tablas/localidades/presentation/bloc/localidad_state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

/// BLoC para gestión de localidades
@injectable
class LocalidadBloc extends Bloc<LocalidadEvent, LocalidadState> {
  LocalidadBloc(this._repository) : super(const LocalidadInitial()) {
    on<LocalidadLoadAllRequested>(_onLoadAllRequested);
    on<LocalidadCreateRequested>(_onCreateRequested);
    on<LocalidadUpdateRequested>(_onUpdateRequested);
    on<LocalidadDeleteRequested>(_onDeleteRequested);
  }

  final LocalidadRepository _repository;

  /// Maneja la carga de todas las localidades
  Future<void> _onLoadAllRequested(
    LocalidadLoadAllRequested event,
    Emitter<LocalidadState> emit,
  ) async {
    try {
      debugPrint('🚀 LocalidadBloc: Cargando todas las localidades...');
      emit(const LocalidadLoading());

      final List<LocalidadEntity> localidades = await _repository.getAll();

      debugPrint('✅ LocalidadBloc: ${localidades.length} localidades cargadas');
      emit(LocalidadLoaded(localidades));
    } catch (e) {
      debugPrint('❌ LocalidadBloc: Error al cargar localidades: $e');
      emit(LocalidadError(e.toString()));
    }
  }

  /// Maneja la creación de una localidad
  Future<void> _onCreateRequested(
    LocalidadCreateRequested event,
    Emitter<LocalidadState> emit,
  ) async {
    try {
      debugPrint('🚀 LocalidadBloc: Creando localidad: ${event.localidad.nombre}');
      emit(const LocalidadCreating());

      final LocalidadEntity localidad = await _repository.create(event.localidad);

      debugPrint('✅ LocalidadBloc: Localidad creada con ID: ${localidad.id}');
      emit(LocalidadCreated(localidad));
      // Recargar la lista después de crear
      add(const LocalidadLoadAllRequested());
    } catch (e) {
      debugPrint('❌ LocalidadBloc: Error al crear localidad: $e');
      emit(LocalidadError(e.toString()));
    }
  }

  /// Maneja la actualización de una localidad
  Future<void> _onUpdateRequested(
    LocalidadUpdateRequested event,
    Emitter<LocalidadState> emit,
  ) async {
    try {
      debugPrint('🚀 LocalidadBloc: Actualizando localidad: ${event.localidad.id}');
      emit(const LocalidadUpdating());

      final LocalidadEntity localidad = await _repository.update(event.localidad);

      debugPrint('✅ LocalidadBloc: Localidad actualizada');
      emit(LocalidadUpdated(localidad));
      // Recargar la lista después de actualizar
      add(const LocalidadLoadAllRequested());
    } catch (e) {
      debugPrint('❌ LocalidadBloc: Error al actualizar localidad: $e');
      emit(LocalidadError(e.toString()));
    }
  }

  /// Maneja la eliminación de una localidad
  Future<void> _onDeleteRequested(
    LocalidadDeleteRequested event,
    Emitter<LocalidadState> emit,
  ) async {
    try {
      debugPrint('🚀 LocalidadBloc: Eliminando localidad: ${event.id}');
      emit(const LocalidadDeleting());

      await _repository.delete(event.id);

      debugPrint('✅ LocalidadBloc: Localidad eliminada');
      emit(const LocalidadDeleted());
      // Recargar la lista después de eliminar
      add(const LocalidadLoadAllRequested());
    } catch (e) {
      debugPrint('❌ LocalidadBloc: Error al eliminar localidad: $e');
      emit(LocalidadError(e.toString()));
    }
  }
}
