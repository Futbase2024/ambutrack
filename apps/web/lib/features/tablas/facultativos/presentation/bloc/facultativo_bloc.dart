import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/features/tablas/facultativos/domain/repositories/facultativo_repository.dart';
import 'package:ambutrack_web/features/tablas/facultativos/presentation/bloc/facultativo_event.dart';
import 'package:ambutrack_web/features/tablas/facultativos/presentation/bloc/facultativo_state.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

/// BLoC para gestionar el estado de Facultativos
@injectable
class FacultativoBloc extends Bloc<FacultativoEvent, FacultativoState> {
  FacultativoBloc(this._repository) : super(const FacultativoInitial()) {
    on<FacultativoLoadAllRequested>(_onLoadAllRequested);
    on<FacultativoCreateRequested>(_onCreateRequested);
    on<FacultativoUpdateRequested>(_onUpdateRequested);
    on<FacultativoDeleteRequested>(_onDeleteRequested);
  }

  final FacultativoRepository _repository;

  Future<void> _onLoadAllRequested(
    FacultativoLoadAllRequested event,
    Emitter<FacultativoState> emit,
  ) async {
    try {
      debugPrint('🚀 FacultativoBloc: Cargando facultativos...');
      emit(const FacultativoLoading());

      final List<FacultativoEntity> facultativos = await _repository.getAll();

      debugPrint('✅ FacultativoBloc: ${facultativos.length} facultativos cargados');
      emit(FacultativoLoaded(facultativos));
    } catch (e) {
      debugPrint('❌ FacultativoBloc.loadAll: Error: $e');
      emit(FacultativoError(e.toString()));
    }
  }

  Future<void> _onCreateRequested(
    FacultativoCreateRequested event,
    Emitter<FacultativoState> emit,
  ) async {
    try {
      debugPrint('🚀 FacultativoBloc: Creando facultativo: ${event.facultativo.nombreCompleto}');
      emit(const FacultativoLoading());

      await _repository.create(event.facultativo);

      debugPrint('✅ FacultativoBloc: Facultativo creado exitosamente');

      // Recargar lista
      final List<FacultativoEntity> facultativos = await _repository.getAll();
      emit(FacultativoLoaded(facultativos));
    } catch (e) {
      debugPrint('❌ FacultativoBloc.create: Error: $e');
      emit(FacultativoError(e.toString()));
    }
  }

  Future<void> _onUpdateRequested(
    FacultativoUpdateRequested event,
    Emitter<FacultativoState> emit,
  ) async {
    try {
      debugPrint('🚀 FacultativoBloc: Actualizando facultativo: ${event.facultativo.id}');
      emit(const FacultativoLoading());

      await _repository.update(event.facultativo);

      debugPrint('✅ FacultativoBloc: Facultativo actualizado exitosamente');

      // Recargar lista
      final List<FacultativoEntity> facultativos = await _repository.getAll();
      emit(FacultativoLoaded(facultativos));
    } catch (e) {
      debugPrint('❌ FacultativoBloc.update: Error: $e');
      emit(FacultativoError(e.toString()));
    }
  }

  Future<void> _onDeleteRequested(
    FacultativoDeleteRequested event,
    Emitter<FacultativoState> emit,
  ) async {
    try {
      debugPrint('🚀 FacultativoBloc: Eliminando facultativo: ${event.id}');
      emit(const FacultativoLoading());

      await _repository.delete(event.id);

      debugPrint('✅ FacultativoBloc: Facultativo eliminado exitosamente');

      // Recargar lista
      final List<FacultativoEntity> facultativos = await _repository.getAll();
      emit(FacultativoLoaded(facultativos));
    } catch (e) {
      debugPrint('❌ FacultativoBloc.delete: Error: $e');
      emit(FacultativoError(e.toString()));
    }
  }
}
