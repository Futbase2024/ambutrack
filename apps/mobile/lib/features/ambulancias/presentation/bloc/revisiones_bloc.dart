import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/repositories/ambulancias_repository.dart';
import 'revisiones_event.dart';
import 'revisiones_state.dart';

/// BLoC para gestionar el estado de las revisiones de ambulancias.
@injectable
class RevisionesBloc extends Bloc<RevisionesEvent, RevisionesState> {
  RevisionesBloc(this._repository) : super(const RevisionesInitial()) {
    on<RevisionesLoadByAmbulanciaRequested>(_onLoadByAmbulanciaRequested);
    on<RevisionLoadByIdRequested>(_onLoadByIdRequested);
    on<RevisionesPendientesLoadRequested>(_onPendientesLoadRequested);
    on<RevisionCreateRequested>(_onCreateRequested);
    on<RevisionUpdateRequested>(_onUpdateRequested);
    on<RevisionCompletarRequested>(_onCompletarRequested);
    on<ItemsRevisionLoadRequested>(_onItemsLoadRequested);
    on<ItemRevisionMarcarVerificadoRequested>(_onItemMarcarVerificadoRequested);
    on<ItemRevisionUpdateRequested>(_onItemUpdateRequested);
    on<ItemsRevisionBatchUpdateRequested>(_onItemsBatchUpdateRequested);
    on<RevisionesGenerarMesRequested>(_onGenerarMesRequested);
    on<ItemsRevisionGenerarRequested>(_onItemsGenerarRequested);
  }

  final AmbulanciasRepository _repository;

  Future<void> _onLoadByAmbulanciaRequested(
    RevisionesLoadByAmbulanciaRequested event,
    Emitter<RevisionesState> emit,
  ) async {
    debugPrint('📋 RevisionesBloc: Cargando revisiones de ambulancia: ${event.ambulanciaId}');
    emit(const RevisionesLoading());

    try {
      final revisiones = await _repository.getRevisionesByAmbulancia(
        event.ambulanciaId,
        estado: event.estado,
        incluirItems: event.incluirItems,
      );
      debugPrint('📋 RevisionesBloc: ✅ ${revisiones.length} revisiones cargadas');
      emit(RevisionesLoaded(revisiones: revisiones));
    } catch (e) {
      debugPrint('📋 RevisionesBloc: ❌ Error: $e');
      emit(RevisionesError(e.toString()));
    }
  }

  Future<void> _onLoadByIdRequested(
    RevisionLoadByIdRequested event,
    Emitter<RevisionesState> emit,
  ) async {
    debugPrint('📋 RevisionesBloc: Cargando revisión: ${event.id}');
    emit(const RevisionesLoading());

    try {
      final revision = await _repository.getRevisionWithRelations(
        event.id,
        incluirAmbulancia: event.incluirAmbulancia,
        incluirItems: event.incluirItems,
      );

      if (revision == null) {
        emit(const RevisionesError('Revisión no encontrada'));
        return;
      }

      debugPrint('📋 RevisionesBloc: ✅ Revisión cargada: ${revision.periodo}');
      emit(RevisionDetailLoaded(
        revision: revision,
        items: revision.items ?? [],
      ));
    } catch (e) {
      debugPrint('📋 RevisionesBloc: ❌ Error: $e');
      emit(RevisionesError(e.toString()));
    }
  }

  Future<void> _onPendientesLoadRequested(
    RevisionesPendientesLoadRequested event,
    Emitter<RevisionesState> emit,
  ) async {
    debugPrint('📋 RevisionesBloc: Cargando revisiones pendientes: ${event.ambulanciaId}');
    emit(const RevisionesLoading());

    try {
      final revisiones = await _repository.getRevisionesPendientes(event.ambulanciaId);
      debugPrint('📋 RevisionesBloc: ✅ ${revisiones.length} revisiones pendientes');
      emit(RevisionesLoaded(revisiones: revisiones));
    } catch (e) {
      debugPrint('📋 RevisionesBloc: ❌ Error: $e');
      emit(RevisionesError(e.toString()));
    }
  }

  Future<void> _onCreateRequested(
    RevisionCreateRequested event,
    Emitter<RevisionesState> emit,
  ) async {
    debugPrint('📋 RevisionesBloc: Creando revisión...');
    emit(const RevisionesLoading());

    try {
      final revision = await _repository.createRevision(event.revision);
      debugPrint('📋 RevisionesBloc: ✅ Revisión creada: ${revision.periodo}');
      emit(RevisionCreated(revision));
    } catch (e) {
      debugPrint('📋 RevisionesBloc: ❌ Error: $e');
      emit(RevisionesError(e.toString()));
    }
  }

  Future<void> _onUpdateRequested(
    RevisionUpdateRequested event,
    Emitter<RevisionesState> emit,
  ) async {
    debugPrint('📋 RevisionesBloc: Actualizando revisión: ${event.revision.id}');
    emit(const RevisionesLoading());

    try {
      final revision = await _repository.updateRevision(event.revision);
      debugPrint('📋 RevisionesBloc: ✅ Revisión actualizada');
      emit(RevisionUpdated(revision));
    } catch (e) {
      debugPrint('📋 RevisionesBloc: ❌ Error: $e');
      emit(RevisionesError(e.toString()));
    }
  }

  Future<void> _onCompletarRequested(
    RevisionCompletarRequested event,
    Emitter<RevisionesState> emit,
  ) async {
    debugPrint('📋 RevisionesBloc: Completando revisión: ${event.revisionId}');
    emit(const RevisionesLoading());

    try {
      final revision = await _repository.completarRevision(
        event.revisionId,
        observaciones: event.observaciones,
      );
      debugPrint('📋 RevisionesBloc: ✅ Revisión completada');
      emit(RevisionCompleted(revision));
    } catch (e) {
      debugPrint('📋 RevisionesBloc: ❌ Error: $e');
      emit(RevisionesError(e.toString()));
    }
  }

  Future<void> _onItemsLoadRequested(
    ItemsRevisionLoadRequested event,
    Emitter<RevisionesState> emit,
  ) async {
    debugPrint('📋 RevisionesBloc: Cargando items de revisión: ${event.revisionId}');

    try {
      final items = await _repository.getItemsByRevision(event.revisionId);
      debugPrint('📋 RevisionesBloc: ✅ ${items.length} items cargados');
      emit(ItemsRevisionLoaded(items));
    } catch (e) {
      debugPrint('📋 RevisionesBloc: ❌ Error: $e');
      emit(RevisionesError(e.toString()));
    }
  }

  Future<void> _onItemMarcarVerificadoRequested(
    ItemRevisionMarcarVerificadoRequested event,
    Emitter<RevisionesState> emit,
  ) async {
    debugPrint('📋 RevisionesBloc: Marcando item como verificado: ${event.itemId}');

    try {
      final item = await _repository.marcarItemComoVerificado(
        event.itemId,
        conforme: event.conforme,
        cantidadEncontrada: event.cantidadEncontrada,
        observaciones: event.observaciones,
        fechaCaducidad: event.fechaCaducidad,
        verificadoPor: event.verificadoPor,
      );
      debugPrint('📋 RevisionesBloc: ✅ Item verificado (conforme: ${event.conforme})');
      emit(ItemRevisionUpdated(item));
    } catch (e) {
      debugPrint('📋 RevisionesBloc: ❌ Error: $e');
      emit(RevisionesError(e.toString()));
    }
  }

  Future<void> _onItemUpdateRequested(
    ItemRevisionUpdateRequested event,
    Emitter<RevisionesState> emit,
  ) async {
    debugPrint('📋 RevisionesBloc: Actualizando item: ${event.item.id}');

    try {
      final item = await _repository.updateItemRevision(event.item);
      debugPrint('📋 RevisionesBloc: ✅ Item actualizado');
      emit(ItemRevisionUpdated(item));
    } catch (e) {
      debugPrint('📋 RevisionesBloc: ❌ Error: $e');
      emit(RevisionesError(e.toString()));
    }
  }

  Future<void> _onItemsBatchUpdateRequested(
    ItemsRevisionBatchUpdateRequested event,
    Emitter<RevisionesState> emit,
  ) async {
    debugPrint('📋 RevisionesBloc: Actualizando ${event.items.length} items en lote');
    emit(const RevisionesLoading());

    try {
      final items = await _repository.updateItemsRevisionBatch(event.items);
      debugPrint('📋 RevisionesBloc: ✅ Items actualizados en lote');
      emit(ItemsRevisionBatchUpdated(items));
    } catch (e) {
      debugPrint('📋 RevisionesBloc: ❌ Error: $e');
      emit(RevisionesError(e.toString()));
    }
  }

  Future<void> _onGenerarMesRequested(
    RevisionesGenerarMesRequested event,
    Emitter<RevisionesState> emit,
  ) async {
    debugPrint('📋 RevisionesBloc: Generando revisiones del mes ${event.mes}/${event.anio}');
    emit(const RevisionesLoading());

    try {
      await _repository.generarRevisionesMes(
        event.ambulanciaId,
        event.mes,
        event.anio,
      );
      debugPrint('📋 RevisionesBloc: ✅ Revisiones generadas');
      emit(const RevisionesGenerated());
    } catch (e) {
      debugPrint('📋 RevisionesBloc: ❌ Error: $e');
      emit(RevisionesError(e.toString()));
    }
  }

  Future<void> _onItemsGenerarRequested(
    ItemsRevisionGenerarRequested event,
    Emitter<RevisionesState> emit,
  ) async {
    debugPrint('📋 RevisionesBloc: Generando items para revisión: ${event.revisionId}');
    emit(const RevisionesLoading());

    try {
      await _repository.generarItemsRevision(event.revisionId);
      debugPrint('📋 RevisionesBloc: ✅ Items generados');
      emit(const ItemsRevisionGenerated());
    } catch (e) {
      debugPrint('📋 RevisionesBloc: ❌ Error: $e');
      emit(RevisionesError(e.toString()));
    }
  }
}
