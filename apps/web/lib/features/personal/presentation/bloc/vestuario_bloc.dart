import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/features/personal/domain/repositories/vestuario_repository.dart';
import 'package:ambutrack_web/features/personal/presentation/bloc/vestuario_event.dart';
import 'package:ambutrack_web/features/personal/presentation/bloc/vestuario_state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

/// BLoC para gestionar el estado de Vestuario
@injectable
class VestuarioBloc extends Bloc<VestuarioEvent, VestuarioState> {
  VestuarioBloc(this._repository) : super(const VestuarioInitial()) {
    on<VestuarioLoadRequested>(_onLoadRequested);
    on<VestuarioLoadByPersonalRequested>(_onLoadByPersonalRequested);
    on<VestuarioLoadAsignadoRequested>(_onLoadAsignadoRequested);
    on<VestuarioLoadByPrendaRequested>(_onLoadByPrendaRequested);
    on<VestuarioCreateRequested>(_onCreateRequested);
    on<VestuarioUpdateRequested>(_onUpdateRequested);
    on<VestuarioDeleteRequested>(_onDeleteRequested);
  }

  final VestuarioRepository _repository;

  Future<void> _onLoadRequested(
    VestuarioLoadRequested event,
    Emitter<VestuarioState> emit,
  ) async {
    debugPrint('🚀 VestuarioBloc: Cargando todos los registros...');
    emit(const VestuarioLoading());
    try {
      final List<VestuarioEntity> items = await _repository.getAll();
      debugPrint('✅ VestuarioBloc: ${items.length} registros cargados');
      emit(VestuarioLoaded(items));
    } catch (e) {
      debugPrint('❌ VestuarioBloc: Error al cargar: $e');
      emit(VestuarioError(e.toString()));
    }
  }

  Future<void> _onLoadByPersonalRequested(
    VestuarioLoadByPersonalRequested event,
    Emitter<VestuarioState> emit,
  ) async {
    debugPrint('🚀 VestuarioBloc: Cargando por personal: ${event.personalId}');
    emit(const VestuarioLoading());
    try {
      final List<VestuarioEntity> items = await _repository.getByPersonalId(event.personalId);
      emit(VestuarioLoaded(items));
    } catch (e) {
      emit(VestuarioError(e.toString()));
    }
  }

  Future<void> _onLoadAsignadoRequested(
    VestuarioLoadAsignadoRequested event,
    Emitter<VestuarioState> emit,
  ) async {
    debugPrint('🚀 VestuarioBloc: Cargando vestuario asignado...');
    emit(const VestuarioLoading());
    try {
      final List<VestuarioEntity> items = await _repository.getAsignado();
      emit(VestuarioLoaded(items));
    } catch (e) {
      emit(VestuarioError(e.toString()));
    }
  }

  Future<void> _onLoadByPrendaRequested(
    VestuarioLoadByPrendaRequested event,
    Emitter<VestuarioState> emit,
  ) async {
    debugPrint('🚀 VestuarioBloc: Cargando por prenda: ${event.prenda}');
    emit(const VestuarioLoading());
    try {
      final List<VestuarioEntity> items = await _repository.getByPrenda(event.prenda);
      emit(VestuarioLoaded(items));
    } catch (e) {
      emit(VestuarioError(e.toString()));
    }
  }

  Future<void> _onCreateRequested(
    VestuarioCreateRequested event,
    Emitter<VestuarioState> emit,
  ) async {
    debugPrint('🚀 VestuarioBloc: Creando registro...');
    emit(const VestuarioLoading());
    try {
      await _repository.create(event.item);
      final List<VestuarioEntity> items = await _repository.getAll();
      debugPrint('✅ VestuarioBloc: Registro creado exitosamente');
      emit(VestuarioLoaded(items));
    } catch (e) {
      debugPrint('❌ VestuarioBloc: Error al crear: $e');
      emit(VestuarioError(e.toString()));
    }
  }

  Future<void> _onUpdateRequested(
    VestuarioUpdateRequested event,
    Emitter<VestuarioState> emit,
  ) async {
    debugPrint('🚀 VestuarioBloc: Actualizando registro...');
    emit(const VestuarioLoading());
    try {
      await _repository.update(event.item);
      final List<VestuarioEntity> items = await _repository.getAll();
      debugPrint('✅ VestuarioBloc: Registro actualizado exitosamente');
      emit(VestuarioLoaded(items));
    } catch (e) {
      debugPrint('❌ VestuarioBloc: Error al actualizar: $e');
      emit(VestuarioError(e.toString()));
    }
  }

  Future<void> _onDeleteRequested(
    VestuarioDeleteRequested event,
    Emitter<VestuarioState> emit,
  ) async {
    debugPrint('🚀 VestuarioBloc: Eliminando registro...');
    emit(const VestuarioLoading());
    try {
      await _repository.delete(event.id);
      final List<VestuarioEntity> items = await _repository.getAll();
      debugPrint('✅ VestuarioBloc: Registro eliminado exitosamente');
      emit(VestuarioLoaded(items));
    } catch (e) {
      debugPrint('❌ VestuarioBloc: Error al eliminar: $e');
      emit(VestuarioError(e.toString()));
    }
  }
}
