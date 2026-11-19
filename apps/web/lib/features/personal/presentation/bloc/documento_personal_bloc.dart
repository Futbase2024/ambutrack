import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/features/personal/domain/repositories/documento_personal_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import 'documento_personal_event.dart';
import 'documento_personal_state.dart';

/// BLoC de documentación del personal (CRUD con recarga completa tras cada operación)
@injectable
class DocumentoPersonalBloc extends Bloc<DocumentoPersonalEvent, DocumentoPersonalState> {
  DocumentoPersonalBloc(this._repository) : super(const DocumentoPersonalInitial()) {
    on<DocumentoPersonalLoadRequested>(_onLoad);
    on<DocumentoPersonalCreateRequested>(
      (DocumentoPersonalCreateRequested e, Emitter<DocumentoPersonalState> emit) =>
          _mutate(emit, 'crear', () => _repository.create(e.entity)),
    );
    on<DocumentoPersonalUpdateRequested>(
      (DocumentoPersonalUpdateRequested e, Emitter<DocumentoPersonalState> emit) =>
          _mutate(emit, 'actualizar', () => _repository.update(e.entity)),
    );
    on<DocumentoPersonalDeleteRequested>(
      (DocumentoPersonalDeleteRequested e, Emitter<DocumentoPersonalState> emit) =>
          _mutate(emit, 'eliminar', () => _repository.delete(e.id)),
    );
  }

  final DocumentoPersonalRepository _repository;

  Future<void> _onLoad(DocumentoPersonalLoadRequested event, Emitter<DocumentoPersonalState> emit) async {
    emit(const DocumentoPersonalLoading());
    try {
      final List<DocumentoPersonalEntity> items = await _repository.getAll();
      debugPrint('🎯 DocumentoPersonalBloc: ✅ ${items.length} registros');
      emit(DocumentoPersonalLoaded(items));
    } catch (e) {
      debugPrint('🎯 DocumentoPersonalBloc: ❌ Error al cargar: $e');
      emit(DocumentoPersonalError(e.toString()));
    }
  }

  Future<void> _mutate(
    Emitter<DocumentoPersonalState> emit,
    String accion,
    Future<Object?> Function() operacion,
  ) async {
    try {
      await operacion();
      final List<DocumentoPersonalEntity> items = await _repository.getAll();
      emit(DocumentoPersonalLoaded(items));
    } catch (e) {
      debugPrint('🎯 DocumentoPersonalBloc: ❌ Error al $accion: $e');
      emit(DocumentoPersonalError(e.toString()));
    }
  }
}
