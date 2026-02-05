import 'package:ambutrack_core/ambutrack_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/repositories/historial_medico_repository.dart';
import 'historial_medico_event.dart';
import 'historial_medico_state.dart';

/// BLoC para gestionar el Historial Médico del Personal
@injectable
class HistorialMedicoBloc extends Bloc<HistorialMedicoEvent, HistorialMedicoState> {
  HistorialMedicoBloc(this._repository) : super(const HistorialMedicoInitial()) {
    on<HistorialMedicoLoadRequested>(_onLoadRequested);
    on<HistorialMedicoLoadByPersonalRequested>(_onLoadByPersonalRequested);
    on<HistorialMedicoLoadProximosACaducarRequested>(_onLoadProximosACaducarRequested);
    on<HistorialMedicoLoadCaducadosRequested>(_onLoadCaducadosRequested);
    on<HistorialMedicoCreateRequested>(_onCreateRequested);
    on<HistorialMedicoUpdateRequested>(_onUpdateRequested);
    on<HistorialMedicoDeleteRequested>(_onDeleteRequested);
  }

  final HistorialMedicoRepository _repository;

  Future<void> _onLoadRequested(
    HistorialMedicoLoadRequested event,
    Emitter<HistorialMedicoState> emit,
  ) async {
    debugPrint('🚀 HistorialMedicoBloc: Cargando todos los registros...');
    emit(const HistorialMedicoLoading());

    try {
      final List<HistorialMedicoEntity> items = await _repository.getAll();
      debugPrint('✅ HistorialMedicoBloc: ${items.length} registros cargados');
      emit(HistorialMedicoLoaded(items));
    } catch (e) {
      debugPrint('❌ HistorialMedicoBloc: Error al cargar: $e');
      emit(HistorialMedicoError(e.toString()));
    }
  }

  Future<void> _onLoadByPersonalRequested(
    HistorialMedicoLoadByPersonalRequested event,
    Emitter<HistorialMedicoState> emit,
  ) async {
    debugPrint('🚀 HistorialMedicoBloc: Cargando historial del personal ${event.personalId}...');
    emit(const HistorialMedicoLoading());

    try {
      final List<HistorialMedicoEntity> items = await _repository.getByPersonalId(event.personalId);
      debugPrint('✅ HistorialMedicoBloc: ${items.length} registros cargados');
      emit(HistorialMedicoLoaded(items));
    } catch (e) {
      debugPrint('❌ HistorialMedicoBloc: Error al cargar: $e');
      emit(HistorialMedicoError(e.toString()));
    }
  }

  Future<void> _onLoadProximosACaducarRequested(
    HistorialMedicoLoadProximosACaducarRequested event,
    Emitter<HistorialMedicoState> emit,
  ) async {
    debugPrint('🚀 HistorialMedicoBloc: Cargando reconocimientos próximos a caducar...');
    emit(const HistorialMedicoLoading());

    try {
      final List<HistorialMedicoEntity> items = await _repository.getProximosACaducar();
      debugPrint('✅ HistorialMedicoBloc: ${items.length} reconocimientos próximos a caducar');
      emit(HistorialMedicoLoaded(items));
    } catch (e) {
      debugPrint('❌ HistorialMedicoBloc: Error al cargar: $e');
      emit(HistorialMedicoError(e.toString()));
    }
  }

  Future<void> _onLoadCaducadosRequested(
    HistorialMedicoLoadCaducadosRequested event,
    Emitter<HistorialMedicoState> emit,
  ) async {
    debugPrint('🚀 HistorialMedicoBloc: Cargando reconocimientos caducados...');
    emit(const HistorialMedicoLoading());

    try {
      final List<HistorialMedicoEntity> items = await _repository.getCaducados();
      debugPrint('✅ HistorialMedicoBloc: ${items.length} reconocimientos caducados');
      emit(HistorialMedicoLoaded(items));
    } catch (e) {
      debugPrint('❌ HistorialMedicoBloc: Error al cargar: $e');
      emit(HistorialMedicoError(e.toString()));
    }
  }

  Future<void> _onCreateRequested(
    HistorialMedicoCreateRequested event,
    Emitter<HistorialMedicoState> emit,
  ) async {
    debugPrint('🚀 HistorialMedicoBloc: Creando nuevo registro...');

    try {
      await _repository.create(event.entity);
      debugPrint('✅ HistorialMedicoBloc: Registro creado exitosamente');

      // Recargar todos los registros
      final List<HistorialMedicoEntity> items = await _repository.getAll();
      emit(HistorialMedicoLoaded(items));
    } catch (e) {
      debugPrint('❌ HistorialMedicoBloc: Error al crear: $e');
      emit(HistorialMedicoError(e.toString()));
    }
  }

  Future<void> _onUpdateRequested(
    HistorialMedicoUpdateRequested event,
    Emitter<HistorialMedicoState> emit,
  ) async {
    debugPrint('🚀 HistorialMedicoBloc: Actualizando registro ${event.entity.id}...');

    try {
      await _repository.update(event.entity);
      debugPrint('✅ HistorialMedicoBloc: Registro actualizado exitosamente');

      // Recargar todos los registros
      final List<HistorialMedicoEntity> items = await _repository.getAll();
      emit(HistorialMedicoLoaded(items));
    } catch (e) {
      debugPrint('❌ HistorialMedicoBloc: Error al actualizar: $e');
      emit(HistorialMedicoError(e.toString()));
    }
  }

  Future<void> _onDeleteRequested(
    HistorialMedicoDeleteRequested event,
    Emitter<HistorialMedicoState> emit,
  ) async {
    debugPrint('🚀 HistorialMedicoBloc: Eliminando registro ${event.id}...');

    try {
      await _repository.delete(event.id);
      debugPrint('✅ HistorialMedicoBloc: Registro eliminado exitosamente');

      // Recargar todos los registros
      final List<HistorialMedicoEntity> items = await _repository.getAll();
      emit(HistorialMedicoLoaded(items));
    } catch (e) {
      debugPrint('❌ HistorialMedicoBloc: Error al eliminar: $e');
      emit(HistorialMedicoError(e.toString()));
    }
  }
}
