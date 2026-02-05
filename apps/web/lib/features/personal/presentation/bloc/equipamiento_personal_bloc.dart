import 'package:ambutrack_core/ambutrack_core.dart';
import 'package:ambutrack_web/features/personal/domain/repositories/equipamiento_personal_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import 'equipamiento_personal_event.dart';
import 'equipamiento_personal_state.dart';

/// BLoC para gestionar el estado de equipamiento personal
@injectable
class EquipamientoPersonalBloc
    extends Bloc<EquipamientoPersonalEvent, EquipamientoPersonalState> {
  EquipamientoPersonalBloc(this._repository) : super(const EquipamientoPersonalInitial()) {
    on<EquipamientoPersonalLoadRequested>(_onLoadRequested);
    on<EquipamientoPersonalLoadByPersonalRequested>(_onLoadByPersonalRequested);
    on<EquipamientoPersonalLoadAsignadoRequested>(_onLoadAsignadoRequested);
    on<EquipamientoPersonalLoadByTipoRequested>(_onLoadByTipoRequested);
    on<EquipamientoPersonalCreateRequested>(_onCreateRequested);
    on<EquipamientoPersonalUpdateRequested>(_onUpdateRequested);
    on<EquipamientoPersonalDeleteRequested>(_onDeleteRequested);
  }

  final EquipamientoPersonalRepository _repository;

  Future<void> _onLoadRequested(
    EquipamientoPersonalLoadRequested event,
    Emitter<EquipamientoPersonalState> emit,
  ) async {
    debugPrint('🎯 EquipamientoPersonalBloc: Cargando todos los registros...');
    emit(const EquipamientoPersonalLoading());

    try {
      final List<EquipamientoPersonalEntity> items = await _repository.getAll();
      debugPrint('🎯 EquipamientoPersonalBloc: ✅ ${items.length} items cargados');
      emit(EquipamientoPersonalLoaded(items));
    } catch (e) {
      debugPrint('🎯 EquipamientoPersonalBloc: ❌ Error al cargar: $e');
      emit(EquipamientoPersonalError(e.toString()));
    }
  }

  Future<void> _onLoadByPersonalRequested(
    EquipamientoPersonalLoadByPersonalRequested event,
    Emitter<EquipamientoPersonalState> emit,
  ) async {
    debugPrint('🎯 EquipamientoPersonalBloc: Cargando por personal: ${event.personalId}');
    emit(const EquipamientoPersonalLoading());

    try {
      final List<EquipamientoPersonalEntity> items =
          await _repository.getByPersonalId(event.personalId);
      debugPrint('🎯 EquipamientoPersonalBloc: ✅ ${items.length} items cargados');
      emit(EquipamientoPersonalLoaded(items));
    } catch (e) {
      debugPrint('🎯 EquipamientoPersonalBloc: ❌ Error: $e');
      emit(EquipamientoPersonalError(e.toString()));
    }
  }

  Future<void> _onLoadAsignadoRequested(
    EquipamientoPersonalLoadAsignadoRequested event,
    Emitter<EquipamientoPersonalState> emit,
  ) async {
    debugPrint('🎯 EquipamientoPersonalBloc: Cargando equipamiento asignado...');
    emit(const EquipamientoPersonalLoading());

    try {
      final List<EquipamientoPersonalEntity> items = await _repository.getAsignado();
      debugPrint('🎯 EquipamientoPersonalBloc: ✅ ${items.length} items asignados');
      emit(EquipamientoPersonalLoaded(items));
    } catch (e) {
      debugPrint('🎯 EquipamientoPersonalBloc: ❌ Error: $e');
      emit(EquipamientoPersonalError(e.toString()));
    }
  }

  Future<void> _onLoadByTipoRequested(
    EquipamientoPersonalLoadByTipoRequested event,
    Emitter<EquipamientoPersonalState> emit,
  ) async {
    debugPrint('🎯 EquipamientoPersonalBloc: Cargando por tipo: ${event.tipo}');
    emit(const EquipamientoPersonalLoading());

    try {
      final List<EquipamientoPersonalEntity> items = await _repository.getByTipo(event.tipo);
      debugPrint('🎯 EquipamientoPersonalBloc: ✅ ${items.length} items cargados');
      emit(EquipamientoPersonalLoaded(items));
    } catch (e) {
      debugPrint('🎯 EquipamientoPersonalBloc: ❌ Error: $e');
      emit(EquipamientoPersonalError(e.toString()));
    }
  }

  Future<void> _onCreateRequested(
    EquipamientoPersonalCreateRequested event,
    Emitter<EquipamientoPersonalState> emit,
  ) async {
    debugPrint('🎯 EquipamientoPersonalBloc: Creando registro...');

    try {
      await _repository.create(event.entity);
      debugPrint('🎯 EquipamientoPersonalBloc: ✅ Registro creado, recargando...');

      final List<EquipamientoPersonalEntity> items = await _repository.getAll();
      emit(EquipamientoPersonalLoaded(items));
    } catch (e) {
      debugPrint('🎯 EquipamientoPersonalBloc: ❌ Error al crear: $e');
      emit(EquipamientoPersonalError(e.toString()));
    }
  }

  Future<void> _onUpdateRequested(
    EquipamientoPersonalUpdateRequested event,
    Emitter<EquipamientoPersonalState> emit,
  ) async {
    debugPrint('🎯 EquipamientoPersonalBloc: Actualizando registro: ${event.entity.id}');

    try {
      await _repository.update(event.entity);
      debugPrint('🎯 EquipamientoPersonalBloc: ✅ Registro actualizado, recargando...');

      final List<EquipamientoPersonalEntity> items = await _repository.getAll();
      emit(EquipamientoPersonalLoaded(items));
    } catch (e) {
      debugPrint('🎯 EquipamientoPersonalBloc: ❌ Error al actualizar: $e');
      emit(EquipamientoPersonalError(e.toString()));
    }
  }

  Future<void> _onDeleteRequested(
    EquipamientoPersonalDeleteRequested event,
    Emitter<EquipamientoPersonalState> emit,
  ) async {
    debugPrint('🎯 EquipamientoPersonalBloc: Eliminando registro: ${event.id}');

    try {
      await _repository.delete(event.id);
      debugPrint('🎯 EquipamientoPersonalBloc: ✅ Registro eliminado, recargando...');

      final List<EquipamientoPersonalEntity> items = await _repository.getAll();
      emit(EquipamientoPersonalLoaded(items));
    } catch (e) {
      debugPrint('🎯 EquipamientoPersonalBloc: ❌ Error al eliminar: $e');
      emit(EquipamientoPersonalError(e.toString()));
    }
  }
}
