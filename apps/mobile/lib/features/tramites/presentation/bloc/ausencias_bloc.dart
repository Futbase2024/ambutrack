import 'dart:async';

import 'package:ambutrack_core/ambutrack_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/repositories/ausencias_repository.dart';
import '../../domain/repositories/tipos_ausencia_repository.dart';
import 'ausencias_event.dart';
import 'ausencias_state.dart';

/// BLoC para gestionar el estado de las ausencias.
@injectable
class AusenciasBloc extends Bloc<AusenciasEvent, AusenciasState> {
  AusenciasBloc(
    this._ausenciasRepository,
    this._tiposRepository,
  ) : super(const AusenciasInitial()) {
    on<AusenciasLoadRequested>(_onLoadRequested);
    on<AusenciasLoadByPersonalRequested>(_onLoadByPersonalRequested);
    on<AusenciasLoadByEstadoRequested>(_onLoadByEstadoRequested);
    on<AusenciasLoadByRangoFechasRequested>(_onLoadByRangoFechasRequested);
    on<AusenciaCreateRequested>(_onCreateRequested);
    on<AusenciaUpdateRequested>(_onUpdateRequested);
    on<AusenciaDeleteRequested>(_onDeleteRequested);
    on<TiposAusenciaLoadRequested>(_onTiposLoadRequested);
    on<AusenciasWatchRequested>(_onWatchRequested);
    on<AusenciasWatchByPersonalRequested>(_onWatchByPersonalRequested);
  }

  final AusenciasRepository _ausenciasRepository;
  final TiposAusenciaRepository _tiposRepository;
  StreamSubscription<List<AusenciaEntity>>? _watchSubscription;

  Future<void> _onLoadRequested(
    AusenciasLoadRequested event,
    Emitter<AusenciasState> emit,
  ) async {
    debugPrint('🏥 AusenciasBloc: Cargando todas las ausencias...');
    emit(const AusenciasLoading());

    try {
      final ausencias = await _ausenciasRepository.getAll();
      debugPrint(
          '🏥 AusenciasBloc: ✅ ${ausencias.length} ausencias cargadas');

      // Cargar también los tipos de ausencias si no están cargados
      List<TipoAusenciaEntity> tipos = [];
      if (state is AusenciasLoaded) {
        tipos = (state as AusenciasLoaded).tiposAusencia;
      }
      if (tipos.isEmpty) {
        try {
          tipos = await _tiposRepository.getAll();
          debugPrint('🏥 AusenciasBloc: ✅ ${tipos.length} tipos cargados');
        } catch (e) {
          debugPrint('🏥 AusenciasBloc: ⚠️ Error al cargar tipos: $e');
        }
      }

      emit(AusenciasLoaded(ausencias: ausencias, tiposAusencia: tipos));
    } catch (e) {
      debugPrint('🏥 AusenciasBloc: ❌ Error: $e');
      emit(AusenciasError(e.toString()));
    }
  }

  Future<void> _onLoadByPersonalRequested(
    AusenciasLoadByPersonalRequested event,
    Emitter<AusenciasState> emit,
  ) async {
    debugPrint(
        '🏥 AusenciasBloc: Cargando ausencias del personal: ${event.idPersonal}');
    emit(const AusenciasLoading());

    try {
      final ausencias = await _ausenciasRepository.getByPersonal(
        event.idPersonal,
      );
      debugPrint('🏥 AusenciasBloc: ✅ ${ausencias.length} ausencias cargadas');

      // Mantener tipos si ya están cargados
      List<TipoAusenciaEntity> tipos = [];
      if (state is AusenciasLoaded) {
        tipos = (state as AusenciasLoaded).tiposAusencia;
      }
      if (tipos.isEmpty) {
        try {
          tipos = await _tiposRepository.getAll();
          debugPrint('🏥 AusenciasBloc: ✅ ${tipos.length} tipos cargados');
        } catch (e) {
          debugPrint('🏥 AusenciasBloc: ⚠️ Error al cargar tipos: $e');
        }
      }

      emit(AusenciasLoaded(
        ausencias: ausencias,
        tiposAusencia: tipos,
        filteredByPersonal: event.idPersonal,
      ));
    } catch (e) {
      debugPrint('🏥 AusenciasBloc: ❌ Error: $e');
      emit(AusenciasError(e.toString()));
    }
  }

  Future<void> _onLoadByEstadoRequested(
    AusenciasLoadByEstadoRequested event,
    Emitter<AusenciasState> emit,
  ) async {
    debugPrint(
        '🏥 AusenciasBloc: Cargando ausencias con estado: ${event.estado}');
    emit(const AusenciasLoading());

    try {
      final ausencias = await _ausenciasRepository.getByEstado(event.estado);
      debugPrint('🏥 AusenciasBloc: ✅ ${ausencias.length} ausencias cargadas');

      // Mantener tipos si ya están cargados
      List<TipoAusenciaEntity> tipos = [];
      if (state is AusenciasLoaded) {
        tipos = (state as AusenciasLoaded).tiposAusencia;
      }

      emit(AusenciasLoaded(ausencias: ausencias, tiposAusencia: tipos));
    } catch (e) {
      debugPrint('🏥 AusenciasBloc: ❌ Error: $e');
      emit(AusenciasError(e.toString()));
    }
  }

  Future<void> _onLoadByRangoFechasRequested(
    AusenciasLoadByRangoFechasRequested event,
    Emitter<AusenciasState> emit,
  ) async {
    debugPrint(
        '🏥 AusenciasBloc: Cargando ausencias entre ${event.fechaInicio} y ${event.fechaFin}');
    emit(const AusenciasLoading());

    try {
      final ausencias = await _ausenciasRepository.getByRangoFechas(
        fechaInicio: event.fechaInicio,
        fechaFin: event.fechaFin,
      );
      debugPrint('🏥 AusenciasBloc: ✅ ${ausencias.length} ausencias cargadas');

      // Mantener tipos si ya están cargados
      List<TipoAusenciaEntity> tipos = [];
      if (state is AusenciasLoaded) {
        tipos = (state as AusenciasLoaded).tiposAusencia;
      }

      emit(AusenciasLoaded(ausencias: ausencias, tiposAusencia: tipos));
    } catch (e) {
      debugPrint('🏥 AusenciasBloc: ❌ Error: $e');
      emit(AusenciasError(e.toString()));
    }
  }

  Future<void> _onCreateRequested(
    AusenciaCreateRequested event,
    Emitter<AusenciasState> emit,
  ) async {
    debugPrint('🏥 AusenciasBloc: Creando ausencia...');
    emit(const AusenciasLoading());

    try {
      final created = await _ausenciasRepository.create(event.ausencia);
      debugPrint('🏥 AusenciasBloc: ✅ Ausencia creada: ${created.id}');
      emit(AusenciaCreated(created));

      // Recargar lista después de crear
      add(AusenciasLoadByPersonalRequested(created.idPersonal));
    } catch (e) {
      debugPrint('🏥 AusenciasBloc: ❌ Error al crear: $e');
      emit(AusenciasError(e.toString()));
    }
  }

  Future<void> _onUpdateRequested(
    AusenciaUpdateRequested event,
    Emitter<AusenciasState> emit,
  ) async {
    debugPrint(
        '🏥 AusenciasBloc: Actualizando ausencia ID: ${event.ausencia.id}');
    emit(const AusenciasLoading());

    try {
      final updated = await _ausenciasRepository.update(event.ausencia);
      debugPrint('🏥 AusenciasBloc: ✅ Ausencia actualizada');
      emit(AusenciaUpdated(updated));

      // Recargar lista después de actualizar
      add(AusenciasLoadByPersonalRequested(updated.idPersonal));
    } catch (e) {
      debugPrint('🏥 AusenciasBloc: ❌ Error al actualizar: $e');
      emit(AusenciasError(e.toString()));
    }
  }

  Future<void> _onDeleteRequested(
    AusenciaDeleteRequested event,
    Emitter<AusenciasState> emit,
  ) async {
    debugPrint('🏥 AusenciasBloc: Eliminando ausencia ID: ${event.id}');
    emit(const AusenciasLoading());

    try {
      await _ausenciasRepository.delete(event.id);
      debugPrint('🏥 AusenciasBloc: ✅ Ausencia eliminada');
      emit(AusenciaDeleted(event.id));

      // Recargar lista después de eliminar
      if (state is AusenciasLoaded) {
        final currentState = state as AusenciasLoaded;
        if (currentState.filteredByPersonal != null) {
          add(AusenciasLoadByPersonalRequested(
              currentState.filteredByPersonal!));
        } else {
          add(const AusenciasLoadRequested());
        }
      }
    } catch (e) {
      debugPrint('🏥 AusenciasBloc: ❌ Error al eliminar: $e');
      emit(AusenciasError(e.toString()));
    }
  }

  Future<void> _onTiposLoadRequested(
    TiposAusenciaLoadRequested event,
    Emitter<AusenciasState> emit,
  ) async {
    debugPrint('🏥 AusenciasBloc: Cargando tipos de ausencias...');

    try {
      final tipos = await _tiposRepository.getAll();
      debugPrint('🏥 AusenciasBloc: ✅ ${tipos.length} tipos cargados');

      // Si ya hay ausencias cargadas, mantenerlas
      if (state is AusenciasLoaded) {
        final currentState = state as AusenciasLoaded;
        emit(currentState.copyWith(tiposAusencia: tipos));
      } else {
        emit(TiposAusenciaLoaded(tipos));
      }
    } catch (e) {
      debugPrint('🏥 AusenciasBloc: ❌ Error al cargar tipos: $e');
      emit(AusenciasError(e.toString()));
    }
  }

  Future<void> _onWatchRequested(
    AusenciasWatchRequested event,
    Emitter<AusenciasState> emit,
  ) async {
    debugPrint('🏥 AusenciasBloc: Observando todas las ausencias...');
    await _watchSubscription?.cancel();

    emit(const AusenciasLoading());

    _watchSubscription = _ausenciasRepository.watchAll().listen(
      (ausencias) {
        debugPrint(
            '🏥 AusenciasBloc: 🔄 Actualización recibida: ${ausencias.length} ausencias');
        add(const AusenciasLoadRequested());
      },
      onError: (error) {
        debugPrint('🏥 AusenciasBloc: ❌ Error en stream: $error');
        emit(AusenciasError(error.toString()));
      },
    );
  }

  Future<void> _onWatchByPersonalRequested(
    AusenciasWatchByPersonalRequested event,
    Emitter<AusenciasState> emit,
  ) async {
    debugPrint(
        '🏥 AusenciasBloc: Observando ausencias del personal: ${event.idPersonal}');
    await _watchSubscription?.cancel();

    emit(const AusenciasLoading());

    _watchSubscription =
        _ausenciasRepository.watchByPersonal(event.idPersonal).listen(
      (ausencias) {
        debugPrint(
            '🏥 AusenciasBloc: 🔄 Actualización recibida: ${ausencias.length} ausencias');
        add(AusenciasLoadByPersonalRequested(event.idPersonal));
      },
      onError: (error) {
        debugPrint('🏥 AusenciasBloc: ❌ Error en stream: $error');
        emit(AusenciasError(error.toString()));
      },
    );
  }

  @override
  Future<void> close() {
    _watchSubscription?.cancel();
    return super.close();
  }
}
