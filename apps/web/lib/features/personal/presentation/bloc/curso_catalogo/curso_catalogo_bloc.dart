import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/features/personal/domain/repositories/curso_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import 'curso_catalogo_event.dart';
import 'curso_catalogo_state.dart';

@injectable
class CursoCatalogoBloc extends Bloc<CursoCatalogoEvent, CursoCatalogoState> {
  CursoCatalogoBloc(this._repository) : super(const CursoCatalogoInitial()) {
    on<CursoCatalogoLoadRequested>(_onLoad);
    on<CursoCatalogoCreateRequested>(_onCreate);
    on<CursoCatalogoUpdateRequested>(_onUpdate);
    on<CursoCatalogoDeleteRequested>(_onDelete);
  }

  final CursoRepository _repository;

  Future<void> _onLoad(
    CursoCatalogoLoadRequested event,
    Emitter<CursoCatalogoState> emit,
  ) async {
    debugPrint('📋 CursoCatalogoBloc: Cargando cursos...');
    emit(const CursoCatalogoLoading());

    try {
      final List<CursoEntity> items = await _repository.getAll();
      debugPrint('📋 CursoCatalogoBloc: ✅ ${items.length} cursos');
      emit(CursoCatalogoLoaded(items));
    } catch (e) {
      debugPrint('📋 CursoCatalogoBloc: ❌ Error: $e');
      emit(CursoCatalogoError(e.toString()));
    }
  }

  Future<void> _onCreate(
    CursoCatalogoCreateRequested event,
    Emitter<CursoCatalogoState> emit,
  ) async {
    debugPrint('📋 CursoCatalogoBloc: Creando curso...');
    emit(const CursoCatalogoLoading());

    try {
      await _repository.create(event.entity);
      debugPrint('📋 CursoCatalogoBloc: ✅ Creado');
      add(const CursoCatalogoLoadRequested());
    } catch (e) {
      debugPrint('📋 CursoCatalogoBloc: ❌ Error al crear: $e');
      emit(CursoCatalogoError(e.toString()));
    }
  }

  Future<void> _onUpdate(
    CursoCatalogoUpdateRequested event,
    Emitter<CursoCatalogoState> emit,
  ) async {
    debugPrint('📋 CursoCatalogoBloc: Actualizando curso...');
    emit(const CursoCatalogoLoading());

    try {
      await _repository.update(event.entity);
      debugPrint('📋 CursoCatalogoBloc: ✅ Actualizado');
      add(const CursoCatalogoLoadRequested());
    } catch (e) {
      debugPrint('📋 CursoCatalogoBloc: ❌ Error al actualizar: $e');
      emit(CursoCatalogoError(e.toString()));
    }
  }

  Future<void> _onDelete(
    CursoCatalogoDeleteRequested event,
    Emitter<CursoCatalogoState> emit,
  ) async {
    debugPrint('📋 CursoCatalogoBloc: Eliminando curso: ${event.id}');
    emit(const CursoCatalogoLoading());

    try {
      await _repository.delete(event.id);
      debugPrint('📋 CursoCatalogoBloc: ✅ Eliminado');
      add(const CursoCatalogoLoadRequested());
    } catch (e) {
      debugPrint('📋 CursoCatalogoBloc: ❌ Error al eliminar: $e');
      emit(CursoCatalogoError(e.toString()));
    }
  }
}
