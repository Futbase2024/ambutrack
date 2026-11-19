import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/features/personal/domain/repositories/certificacion_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import 'certificacion_catalogo_event.dart';
import 'certificacion_catalogo_state.dart';

@injectable
class CertificacionCatalogoBloc extends Bloc<CertificacionCatalogoEvent, CertificacionCatalogoState> {
  CertificacionCatalogoBloc(this._repository) : super(const CertificacionCatalogoInitial()) {
    on<CertificacionCatalogoLoadRequested>(_onLoad);
    on<CertificacionCatalogoCreateRequested>(_onCreate);
    on<CertificacionCatalogoUpdateRequested>(_onUpdate);
    on<CertificacionCatalogoDeleteRequested>(_onDelete);
  }

  final CertificacionRepository _repository;

  Future<void> _onLoad(
    CertificacionCatalogoLoadRequested event,
    Emitter<CertificacionCatalogoState> emit,
  ) async {
    debugPrint('📋 CertificacionCatalogoBloc: Cargando certificaciones...');
    emit(const CertificacionCatalogoLoading());

    try {
      final List<CertificacionEntity> items = await _repository.getAll();
      debugPrint('📋 CertificacionCatalogoBloc: ✅ ${items.length} certificaciones');
      emit(CertificacionCatalogoLoaded(items));
    } catch (e) {
      debugPrint('📋 CertificacionCatalogoBloc: ❌ Error: $e');
      emit(CertificacionCatalogoError(e.toString()));
    }
  }

  Future<void> _onCreate(
    CertificacionCatalogoCreateRequested event,
    Emitter<CertificacionCatalogoState> emit,
  ) async {
    debugPrint('📋 CertificacionCatalogoBloc: Creando certificación...');
    emit(const CertificacionCatalogoLoading());

    try {
      await _repository.create(event.entity);
      debugPrint('📋 CertificacionCatalogoBloc: ✅ Creada');
      add(const CertificacionCatalogoLoadRequested());
    } catch (e) {
      debugPrint('📋 CertificacionCatalogoBloc: ❌ Error al crear: $e');
      emit(CertificacionCatalogoError(e.toString()));
    }
  }

  Future<void> _onUpdate(
    CertificacionCatalogoUpdateRequested event,
    Emitter<CertificacionCatalogoState> emit,
  ) async {
    debugPrint('📋 CertificacionCatalogoBloc: Actualizando certificación...');
    emit(const CertificacionCatalogoLoading());

    try {
      await _repository.update(event.entity);
      debugPrint('📋 CertificacionCatalogoBloc: ✅ Actualizada');
      add(const CertificacionCatalogoLoadRequested());
    } catch (e) {
      debugPrint('📋 CertificacionCatalogoBloc: ❌ Error al actualizar: $e');
      emit(CertificacionCatalogoError(e.toString()));
    }
  }

  Future<void> _onDelete(
    CertificacionCatalogoDeleteRequested event,
    Emitter<CertificacionCatalogoState> emit,
  ) async {
    debugPrint('📋 CertificacionCatalogoBloc: Eliminando certificación: ${event.id}');
    emit(const CertificacionCatalogoLoading());

    try {
      await _repository.delete(event.id);
      debugPrint('📋 CertificacionCatalogoBloc: ✅ Eliminada');
      add(const CertificacionCatalogoLoadRequested());
    } catch (e) {
      debugPrint('📋 CertificacionCatalogoBloc: ❌ Error al eliminar: $e');
      emit(CertificacionCatalogoError(e.toString()));
    }
  }
}
