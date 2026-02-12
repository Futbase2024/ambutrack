import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/repositories/especialidad_repository.dart';
import 'especialidad_event.dart';
import 'especialidad_state.dart';

/// BLoC para gestionar especialidades médicas
@injectable
class EspecialidadBloc extends Bloc<EspecialidadEvent, EspecialidadState> {

  EspecialidadBloc(this._repository) : super(const EspecialidadInitial()) {
    on<EspecialidadLoadAllRequested>(_onLoadAllRequested);
    // on<EspecialidadSearchRequested>(_onSearchRequested); // Búsqueda se hace en frontend
    on<EspecialidadFilterByTipoRequested>(_onFilterByTipoRequested);
    on<EspecialidadCreateRequested>(_onCreateRequested);
    on<EspecialidadUpdateRequested>(_onUpdateRequested);
    on<EspecialidadDeleteRequested>(_onDeleteRequested);
  }
  final EspecialidadRepository _repository;

  /// Maneja la carga de todas las especialidades
  Future<void> _onLoadAllRequested(
    EspecialidadLoadAllRequested event,
    Emitter<EspecialidadState> emit,
  ) async {
    try {
      debugPrint('🔄 EspecialidadBloc: Cargando todas las especialidades...');
      emit(const EspecialidadLoading());

      final List<EspecialidadEntity> especialidades = await _repository.getAll();

      debugPrint('✅ EspecialidadBloc: ${especialidades.length} especialidades cargadas');
      emit(EspecialidadLoaded(especialidades));
    } catch (e) {
      debugPrint('❌ EspecialidadBloc._onLoadAllRequested: Error - $e');
      emit(EspecialidadError('Error al cargar especialidades: $e'));
    }
  }

  // NOTA: La búsqueda de especialidades se realiza en el frontend
  // filtrando la lista cargada, no es necesario un método separado
  // en el BLoC ni en el repository.

  /// Maneja el filtro por tipo
  Future<void> _onFilterByTipoRequested(
    EspecialidadFilterByTipoRequested event,
    Emitter<EspecialidadState> emit,
  ) async {
    try {
      debugPrint('🔄 EspecialidadBloc: Filtrando por tipo: ${event.tipo}');

      if (event.tipo.isEmpty || event.tipo == 'todos') {
        add(const EspecialidadLoadAllRequested());
        return;
      }

      emit(const EspecialidadLoading());

      final List<EspecialidadEntity> especialidades = await _repository.filterByTipo(event.tipo);

      debugPrint('✅ EspecialidadBloc: ${especialidades.length} especialidades filtradas');
      emit(EspecialidadLoaded(especialidades));
    } catch (e) {
      debugPrint('❌ EspecialidadBloc._onFilterByTipoRequested: Error - $e');
      emit(EspecialidadError('Error al filtrar especialidades: $e'));
    }
  }

  /// Maneja la creación de una especialidad
  Future<void> _onCreateRequested(
    EspecialidadCreateRequested event,
    Emitter<EspecialidadState> emit,
  ) async {
    try {
      debugPrint('🔄 EspecialidadBloc: Creando especialidad: ${event.especialidad.nombre}');
      emit(const EspecialidadCreating());

      await _repository.create(event.especialidad);

      debugPrint('✅ EspecialidadBloc: Especialidad creada exitosamente');

      // Recargar la lista
      final List<EspecialidadEntity> especialidades = await _repository.getAll();
      emit(EspecialidadLoaded(especialidades));
    } catch (e) {
      debugPrint('❌ EspecialidadBloc._onCreateRequested: Error - $e');
      emit(EspecialidadError('Error al crear especialidad: $e'));
    }
  }

  /// Maneja la actualización de una especialidad
  Future<void> _onUpdateRequested(
    EspecialidadUpdateRequested event,
    Emitter<EspecialidadState> emit,
  ) async {
    try {
      debugPrint('🔄 EspecialidadBloc: Actualizando especialidad: ${event.especialidad.id}');
      emit(const EspecialidadUpdating());

      await _repository.update(event.especialidad);

      debugPrint('✅ EspecialidadBloc: Especialidad actualizada exitosamente');

      // Recargar la lista
      final List<EspecialidadEntity> especialidades = await _repository.getAll();
      emit(EspecialidadLoaded(especialidades));
    } catch (e) {
      debugPrint('❌ EspecialidadBloc._onUpdateRequested: Error - $e');
      emit(EspecialidadError('Error al actualizar especialidad: $e'));
    }
  }

  /// Maneja la eliminación de una especialidad
  Future<void> _onDeleteRequested(
    EspecialidadDeleteRequested event,
    Emitter<EspecialidadState> emit,
  ) async {
    try {
      debugPrint('🔄 EspecialidadBloc: Eliminando especialidad: ${event.id}');
      emit(const EspecialidadDeleting());

      await _repository.delete(event.id);

      debugPrint('✅ EspecialidadBloc: Especialidad eliminada exitosamente');

      // Recargar la lista
      final List<EspecialidadEntity> especialidades = await _repository.getAll();
      emit(EspecialidadLoaded(especialidades));
    } catch (e) {
      debugPrint('❌ EspecialidadBloc._onDeleteRequested: Error - $e');
      emit(EspecialidadError('Error al eliminar especialidad: $e'));
    }
  }
}
