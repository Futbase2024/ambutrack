import 'dart:async';

import 'package:ambutrack_core/ambutrack_core.dart';
import 'package:ambutrack_web/features/tablas/motivos_traslado/domain/repositories/motivo_traslado_repository.dart';
import 'package:ambutrack_web/features/tablas/motivos_traslado/presentation/bloc/motivo_traslado_event.dart';
import 'package:ambutrack_web/features/tablas/motivos_traslado/presentation/bloc/motivo_traslado_state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

/// BLoC de motivos de traslado
@injectable
class MotivoTrasladoBloc extends Bloc<MotivoTrasladoEvent, MotivoTrasladoState> {
  /// Constructor
  MotivoTrasladoBloc(this._repository) : super(const MotivoTrasladoInitial()) {
    on<MotivoTrasladoLoadAllRequested>(_onLoadAllRequested);
    on<MotivoTrasladoCreateRequested>(_onCreateRequested);
    on<MotivoTrasladoUpdateRequested>(_onUpdateRequested);
    on<MotivoTrasladoDeleteRequested>(_onDeleteRequested);
    on<MotivoTrasladoSubscribeRequested>(_onSubscribeRequested);
    on<MotivoTrasladoStreamUpdated>(_onStreamUpdated);
  }

  final MotivoTrasladoRepository _repository;
  StreamSubscription<List<MotivoTrasladoEntity>>? _streamSubscription;

  /// Maneja la carga de todos los motivos
  Future<void> _onLoadAllRequested(
    MotivoTrasladoLoadAllRequested event,
    Emitter<MotivoTrasladoState> emit,
  ) async {
    try {
      debugPrint('🔄 MotivoTrasladoBloc: Cargando motivos de traslado...');
      emit(const MotivoTrasladoLoading());

      final List<MotivoTrasladoEntity> motivos = await _repository.getAll();

      debugPrint('✅ MotivoTrasladoBloc: ${motivos.length} motivos cargados');
      emit(MotivoTrasladoLoaded(motivos));
    } catch (e, stackTrace) {
      debugPrint('❌ MotivoTrasladoBloc: Error al cargar motivos: $e');
      debugPrint('Stack trace: $stackTrace');
      emit(MotivoTrasladoError('Error al cargar motivos de traslado: $e'));
    }
  }

  /// Maneja la creación de un motivo
  Future<void> _onCreateRequested(
    MotivoTrasladoCreateRequested event,
    Emitter<MotivoTrasladoState> emit,
  ) async {
    final MotivoTrasladoState currentState = state;
    final List<MotivoTrasladoEntity> currentMotivos =
        currentState is MotivoTrasladoLoaded ? currentState.motivos : <MotivoTrasladoEntity>[];

    try {
      debugPrint('🔄 MotivoTrasladoBloc: Creando motivo: ${event.motivo.nombre}');
      emit(MotivoTrasladoOperationInProgress(currentMotivos));

      await _repository.create(event.motivo);

      final List<MotivoTrasladoEntity> updatedMotivos = await _repository.getAll();

      debugPrint('✅ MotivoTrasladoBloc: Motivo creado exitosamente');
      emit(MotivoTrasladoOperationSuccess(updatedMotivos, 'Motivo creado exitosamente'));
      emit(MotivoTrasladoLoaded(updatedMotivos));
    } catch (e, stackTrace) {
      debugPrint('❌ MotivoTrasladoBloc: Error al crear motivo: $e');
      debugPrint('Stack trace: $stackTrace');
      emit(MotivoTrasladoError('Error al crear motivo: $e'));
      emit(MotivoTrasladoLoaded(currentMotivos));
    }
  }

  /// Maneja la actualización de un motivo
  Future<void> _onUpdateRequested(
    MotivoTrasladoUpdateRequested event,
    Emitter<MotivoTrasladoState> emit,
  ) async {
    final MotivoTrasladoState currentState = state;
    final List<MotivoTrasladoEntity> currentMotivos =
        currentState is MotivoTrasladoLoaded ? currentState.motivos : <MotivoTrasladoEntity>[];

    try {
      debugPrint('🔄 MotivoTrasladoBloc: Actualizando motivo ID: ${event.motivo.id}');
      emit(MotivoTrasladoOperationInProgress(currentMotivos));

      await _repository.update(event.motivo);

      final List<MotivoTrasladoEntity> updatedMotivos = await _repository.getAll();

      debugPrint('✅ MotivoTrasladoBloc: Motivo actualizado exitosamente');
      emit(MotivoTrasladoOperationSuccess(updatedMotivos, 'Motivo actualizado exitosamente'));
      emit(MotivoTrasladoLoaded(updatedMotivos));
    } catch (e, stackTrace) {
      debugPrint('❌ MotivoTrasladoBloc: Error al actualizar motivo: $e');
      debugPrint('Stack trace: $stackTrace');
      emit(MotivoTrasladoError('Error al actualizar motivo: $e'));
      emit(MotivoTrasladoLoaded(currentMotivos));
    }
  }

  /// Maneja la eliminación de un motivo
  Future<void> _onDeleteRequested(
    MotivoTrasladoDeleteRequested event,
    Emitter<MotivoTrasladoState> emit,
  ) async {
    final MotivoTrasladoState currentState = state;
    final List<MotivoTrasladoEntity> currentMotivos =
        currentState is MotivoTrasladoLoaded ? currentState.motivos : <MotivoTrasladoEntity>[];

    try {
      debugPrint('🔄 MotivoTrasladoBloc: Eliminando motivo ID: ${event.id}');
      emit(MotivoTrasladoOperationInProgress(currentMotivos));

      await _repository.delete(event.id);

      final List<MotivoTrasladoEntity> updatedMotivos = await _repository.getAll();

      debugPrint('✅ MotivoTrasladoBloc: Motivo eliminado exitosamente');
      emit(MotivoTrasladoOperationSuccess(updatedMotivos, 'Motivo eliminado exitosamente'));
      emit(MotivoTrasladoLoaded(updatedMotivos));
    } catch (e, stackTrace) {
      debugPrint('❌ MotivoTrasladoBloc: Error al eliminar motivo: $e');
      debugPrint('Stack trace: $stackTrace');
      emit(MotivoTrasladoError('Error al eliminar motivo: $e'));
      emit(MotivoTrasladoLoaded(currentMotivos));
    }
  }

  /// Maneja la suscripción a cambios en tiempo real
  Future<void> _onSubscribeRequested(
    MotivoTrasladoSubscribeRequested event,
    Emitter<MotivoTrasladoState> emit,
  ) async {
    try {
      debugPrint('🔄 MotivoTrasladoBloc: Suscribiendo a cambios en tiempo real...');

      await _streamSubscription?.cancel();

      _streamSubscription = _repository.watchAll().listen(
        (List<MotivoTrasladoEntity> motivos) {
          add(MotivoTrasladoStreamUpdated(motivos));
        },
        onError: (Object error) {
          debugPrint('❌ MotivoTrasladoBloc: Error en stream: $error');
          add(const MotivoTrasladoLoadAllRequested());
        },
      );

      debugPrint('✅ MotivoTrasladoBloc: Suscripción establecida');
    } catch (e, stackTrace) {
      debugPrint('❌ MotivoTrasladoBloc: Error al suscribirse: $e');
      debugPrint('Stack trace: $stackTrace');
      emit(MotivoTrasladoError('Error al establecer suscripción: $e'));
    }
  }

  /// Maneja las actualizaciones del stream
  void _onStreamUpdated(
    MotivoTrasladoStreamUpdated event,
    Emitter<MotivoTrasladoState> emit,
  ) {
    debugPrint('📡 MotivoTrasladoBloc: Stream actualizado con ${event.motivos.length} motivos');
    emit(MotivoTrasladoLoaded(event.motivos));
  }

  @override
  Future<void> close() {
    _streamSubscription?.cancel();
    return super.close();
  }
}
