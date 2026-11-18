import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/features/tablas/protocolos_normativas/domain/repositories/protocolo_normativa_repository.dart';
import 'package:ambutrack_web/features/tablas/protocolos_normativas/presentation/bloc/protocolo_normativa_event.dart';
import 'package:ambutrack_web/features/tablas/protocolos_normativas/presentation/bloc/protocolo_normativa_state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// BLoC para la gestión de protocolos y normativas
class ProtocoloNormativaBloc extends Bloc<ProtocoloNormativaEvent, ProtocoloNormativaState> {
  ProtocoloNormativaBloc(this._repository) : super(const ProtocoloNormativaInitial()) {
    on<ProtocoloNormativaLoadAllRequested>(_onLoadAll);
    on<ProtocoloNormativaCreateRequested>(_onCreate);
    on<ProtocoloNormativaUpdateRequested>(_onUpdate);
    on<ProtocoloNormativaDeleteRequested>(_onDelete);
  }

  final ProtocoloNormativaRepository _repository;

  Future<void> _onLoadAll(
    ProtocoloNormativaLoadAllRequested event,
    Emitter<ProtocoloNormativaState> emit,
  ) async {
    try {
      emit(const ProtocoloNormativaLoading());
      final List<ProtocoloNormativaEntity> protocolos = await _repository.getAll();
      debugPrint('✅ ProtocoloNormativaBloc: ${protocolos.length} protocolos cargados');
      emit(ProtocoloNormativaLoaded(protocolos));
    } catch (e) {
      debugPrint('❌ ProtocoloNormativaBloc: Error al cargar: $e');
      emit(ProtocoloNormativaError(e.toString()));
    }
  }

  Future<void> _onCreate(
    ProtocoloNormativaCreateRequested event,
    Emitter<ProtocoloNormativaState> emit,
  ) async {
    try {
      emit(const ProtocoloNormativaSaving());
      await _repository.create(event.protocolo);
      add(const ProtocoloNormativaLoadAllRequested());
    } catch (e) {
      debugPrint('❌ ProtocoloNormativaBloc: Error al crear: $e');
      emit(ProtocoloNormativaError(e.toString()));
    }
  }

  Future<void> _onUpdate(
    ProtocoloNormativaUpdateRequested event,
    Emitter<ProtocoloNormativaState> emit,
  ) async {
    try {
      emit(const ProtocoloNormativaSaving());
      await _repository.update(event.protocolo);
      add(const ProtocoloNormativaLoadAllRequested());
    } catch (e) {
      debugPrint('❌ ProtocoloNormativaBloc: Error al actualizar: $e');
      emit(ProtocoloNormativaError(e.toString()));
    }
  }

  Future<void> _onDelete(
    ProtocoloNormativaDeleteRequested event,
    Emitter<ProtocoloNormativaState> emit,
  ) async {
    try {
      emit(const ProtocoloNormativaSaving());
      await _repository.delete(event.id);
      emit(const ProtocoloNormativaDeleted());
      add(const ProtocoloNormativaLoadAllRequested());
    } catch (e) {
      debugPrint('❌ ProtocoloNormativaBloc: Error al eliminar: $e');
      emit(ProtocoloNormativaError(e.toString()));
    }
  }
}
