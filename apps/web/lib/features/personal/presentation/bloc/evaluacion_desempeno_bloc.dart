import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/features/personal/domain/repositories/evaluacion_desempeno_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import 'evaluacion_desempeno_event.dart';
import 'evaluacion_desempeno_state.dart';

/// BLoC de evaluaciones de desempeño (CRUD con recarga completa tras cada operación)
@injectable
class EvaluacionDesempenoBloc extends Bloc<EvaluacionDesempenoEvent, EvaluacionDesempenoState> {
  EvaluacionDesempenoBloc(this._repository) : super(const EvaluacionDesempenoInitial()) {
    on<EvaluacionDesempenoLoadRequested>(_onLoad);
    on<EvaluacionDesempenoCreateRequested>(
      (EvaluacionDesempenoCreateRequested e, Emitter<EvaluacionDesempenoState> emit) =>
          _mutate(emit, 'crear', () => _repository.create(e.entity)),
    );
    on<EvaluacionDesempenoUpdateRequested>(
      (EvaluacionDesempenoUpdateRequested e, Emitter<EvaluacionDesempenoState> emit) =>
          _mutate(emit, 'actualizar', () => _repository.update(e.entity)),
    );
    on<EvaluacionDesempenoDeleteRequested>(
      (EvaluacionDesempenoDeleteRequested e, Emitter<EvaluacionDesempenoState> emit) =>
          _mutate(emit, 'eliminar', () => _repository.delete(e.id)),
    );
  }

  final EvaluacionDesempenoRepository _repository;

  Future<void> _onLoad(EvaluacionDesempenoLoadRequested event, Emitter<EvaluacionDesempenoState> emit) async {
    emit(const EvaluacionDesempenoLoading());
    try {
      final List<EvaluacionDesempenoEntity> items = await _repository.getAll();
      debugPrint('🎯 EvaluacionDesempenoBloc: ✅ ${items.length} registros');
      emit(EvaluacionDesempenoLoaded(items));
    } catch (e) {
      debugPrint('🎯 EvaluacionDesempenoBloc: ❌ Error al cargar: $e');
      emit(EvaluacionDesempenoError(e.toString()));
    }
  }

  Future<void> _mutate(
    Emitter<EvaluacionDesempenoState> emit,
    String accion,
    Future<Object?> Function() operacion,
  ) async {
    try {
      await operacion();
      final List<EvaluacionDesempenoEntity> items = await _repository.getAll();
      emit(EvaluacionDesempenoLoaded(items));
    } catch (e) {
      debugPrint('🎯 EvaluacionDesempenoBloc: ❌ Error al $accion: $e');
      emit(EvaluacionDesempenoError(e.toString()));
    }
  }
}
