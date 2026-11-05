import 'dart:async';

import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/repositories/agenda_pendiente_repository.dart';
import 'agenda_pendiente_event.dart';
import 'agenda_pendiente_state.dart';

/// BLoC para gestionar la agenda de pendientes
@injectable
class AgendaPendienteBloc
    extends Bloc<AgendaPendienteEvent, AgendaPendienteState> {
  AgendaPendienteBloc({
    required AgendaPendienteRepository repository,
  })  : _repository = repository,
        super(const AgendaPendienteInitial()) {
    on<AgendaPendienteLoadRequested>(_onLoadRequested);
    on<AgendaPendienteLoadHoyRequested>(_onLoadHoyRequested);
    on<AgendaPendienteCreateRequested>(_onCreateRequested);
    on<AgendaPendienteUpdateRequested>(_onUpdateRequested);
    on<AgendaPendienteDeleteRequested>(_onDeleteRequested);
    on<AgendaPendienteCompletadoToggled>(_onCompletadoToggled);
    on<AgendaPendienteSearchChanged>(_onSearchChanged);
    on<AgendaPendienteRealtimeUpdated>(_onRealtimeUpdated);
  }

  final AgendaPendienteRepository _repository;

  /// Suscripción en tiempo real para el banner del dashboard
  StreamSubscription<List<AgendaPendienteEntity>>? _realtimeSubscription;

  /// Empresa actual para filtrar en la suscripción real-time
  String? _currentEmpresaId;

  /// Ventana de aviso del popup/banner de agenda: hoy + próximos días.
  static const int _kDiasVentanaAgenda = 7;

  Future<void> _onLoadRequested(
    AgendaPendienteLoadRequested event,
    Emitter<AgendaPendienteState> emit,
  ) async {
    emit(const AgendaPendienteLoading());
    try {
      final List<AgendaPendienteEntity> pendientes =
          await _repository.getByEmpresa(event.empresaId);
      final List<AgendaPendienteEntity> pendientesHoy =
          await _repository.getPendientesHoy(event.empresaId);

      emit(AgendaPendienteLoaded(
        pendientes: pendientes,
        pendientesHoy: pendientesHoy,
      ));
    } catch (e) {
      emit(AgendaPendienteError(message: e.toString()));
    }
  }

  Future<void> _onLoadHoyRequested(
    AgendaPendienteLoadHoyRequested event,
    Emitter<AgendaPendienteState> emit,
  ) async {
    _currentEmpresaId = event.empresaId;

    // Cancelar suscripción anterior si existe
    await _realtimeSubscription?.cancel();

    try {
      // Carga inicial: pendientes no completados en ventana de aviso
      // (hoy + próximos 7 días). Antes se traían TODOS los no completados.
      final List<AgendaPendienteEntity> allPendientes =
          await _repository.getByEmpresa(event.empresaId);
      final List<AgendaPendienteEntity> pendientesProximos = allPendientes
          .where((AgendaPendienteEntity p) =>
              !p.completado && _esFechaEnVentana(p.fecha))
          .toList();

      emit(AgendaPendienteLoaded(
        pendientesHoy: pendientesProximos,
      ));

      // Suscribirse a cambios en tiempo real
      _realtimeSubscription = _repository.watchAll().listen(
        _handleRealtimeUpdate,
        onError: (Object error) {
          debugPrint(
            '📋 AgendaPendienteBloc: Error en stream real-time: $error',
          );
        },
      );

      debugPrint(
        '📋 AgendaPendienteBloc: Suscripción real-time activada '
        'para empresa ${event.empresaId}',
      );
    } catch (e) {
      emit(AgendaPendienteError(message: e.toString()));
    }
  }

  /// Filtra los pendientes activos (no completados) desde el stream real-time
  void _handleRealtimeUpdate(List<AgendaPendienteEntity> allPendientes) {
    if (_currentEmpresaId == null) {
      return;
    }

    final List<AgendaPendienteEntity> pendientesProximos = allPendientes
        .where((AgendaPendienteEntity p) =>
            p.empresaId == _currentEmpresaId &&
            !p.completado &&
            _esFechaEnVentana(p.fecha))
        .toList();

    add(AgendaPendienteRealtimeUpdated(pendientesHoy: pendientesProximos));
  }

  /// Maneja las actualizaciones recibidas del stream real-time
  void _onRealtimeUpdated(
    AgendaPendienteRealtimeUpdated event,
    Emitter<AgendaPendienteState> emit,
  ) {
    if (state is AgendaPendienteLoaded) {
      final AgendaPendienteLoaded current = state as AgendaPendienteLoaded;
      emit(current.copyWith(pendientesHoy: event.pendientesHoy));
    } else {
      emit(AgendaPendienteLoaded(pendientesHoy: event.pendientesHoy));
    }
  }

  Future<void> _onCreateRequested(
    AgendaPendienteCreateRequested event,
    Emitter<AgendaPendienteState> emit,
  ) async {
    final AgendaPendienteLoaded? current = state is AgendaPendienteLoaded
        ? state as AgendaPendienteLoaded
        : null;

    if (current != null) {
      emit(current.copyWith(isSaving: true));
    }

    try {
      await _repository.create(event.pendiente);

      // Recargar datos de la empresa
      final List<AgendaPendienteEntity> pendientes =
          await _repository.getByEmpresa(event.pendiente.empresaId);
      final List<AgendaPendienteEntity> pendientesHoy =
          await _repository.getPendientesHoy(event.pendiente.empresaId);

      emit(AgendaPendienteLoaded(
        pendientes: pendientes,
        pendientesHoy: pendientesHoy,
        message: 'Pendiente creado correctamente',
      ));
    } catch (e) {
      if (current != null) {
        emit(current.copyWith(
          isSaving: false,
          message: 'Error al crear: $e',
        ));
      } else {
        emit(AgendaPendienteError(message: e.toString()));
      }
    }
  }

  Future<void> _onUpdateRequested(
    AgendaPendienteUpdateRequested event,
    Emitter<AgendaPendienteState> emit,
  ) async {
    final AgendaPendienteLoaded? current = state is AgendaPendienteLoaded
        ? state as AgendaPendienteLoaded
        : null;

    if (current != null) {
      emit(current.copyWith(isSaving: true));
    }

    try {
      await _repository.update(event.pendiente);

      final List<AgendaPendienteEntity> pendientes =
          await _repository.getByEmpresa(event.pendiente.empresaId);
      final List<AgendaPendienteEntity> pendientesHoy =
          await _repository.getPendientesHoy(event.pendiente.empresaId);

      emit(AgendaPendienteLoaded(
        pendientes: pendientes,
        pendientesHoy: pendientesHoy,
        message: 'Pendiente actualizado correctamente',
      ));
    } catch (e) {
      if (current != null) {
        emit(current.copyWith(
          isSaving: false,
          message: 'Error al actualizar: $e',
        ));
      } else {
        emit(AgendaPendienteError(message: e.toString()));
      }
    }
  }

  Future<void> _onDeleteRequested(
    AgendaPendienteDeleteRequested event,
    Emitter<AgendaPendienteState> emit,
  ) async {
    try {
      await _repository.delete(event.id);

      // Recargar desde el estado actual
      final AgendaPendienteLoaded? current = state is AgendaPendienteLoaded
          ? state as AgendaPendienteLoaded
          : null;

      if (current != null && current.pendientes.isNotEmpty) {
        final String empresaId = current.pendientes.first.empresaId;
        final List<AgendaPendienteEntity> pendientes =
            await _repository.getByEmpresa(empresaId);
        final List<AgendaPendienteEntity> pendientesHoy =
            await _repository.getPendientesHoy(empresaId);

        emit(AgendaPendienteLoaded(
          pendientes: pendientes,
          pendientesHoy: pendientesHoy,
          message: 'Pendiente eliminado correctamente',
        ));
      }
    } catch (e) {
      emit(AgendaPendienteError(message: e.toString()));
    }
  }

  Future<void> _onCompletadoToggled(
    AgendaPendienteCompletadoToggled event,
    Emitter<AgendaPendienteState> emit,
  ) async {
    try {
      await _repository.marcarCompletado(
        event.id,
        completado: event.completado,
      );

      // Recargar desde el estado actual
      final AgendaPendienteLoaded? current = state is AgendaPendienteLoaded
          ? state as AgendaPendienteLoaded
          : null;

      if (current != null && current.pendientes.isNotEmpty) {
        final String empresaId = current.pendientes.first.empresaId;
        final List<AgendaPendienteEntity> pendientes =
            await _repository.getByEmpresa(empresaId);
        final List<AgendaPendienteEntity> pendientesHoy =
            await _repository.getPendientesHoy(empresaId);

        emit(AgendaPendienteLoaded(
          pendientes: pendientes,
          pendientesHoy: pendientesHoy,
        ));
      }
    } catch (e) {
      emit(AgendaPendienteError(message: e.toString()));
    }
  }

  void _onSearchChanged(
    AgendaPendienteSearchChanged event,
    Emitter<AgendaPendienteState> emit,
  ) {
    final AgendaPendienteLoaded? current = state is AgendaPendienteLoaded
        ? state as AgendaPendienteLoaded
        : null;

    if (current != null) {
      emit(current.copyWith(searchQuery: event.query));
    }
  }

  /// `true` si [fecha] cae dentro de [hoy, hoy + ventana] (inclusive).
  ///
  /// Normaliza a local-midnight para evitar off-by-one cuando el DateTime
  /// proviene de un `date` de Postgres (puede llegar como UTC).
  bool _esFechaEnVentana(DateTime fecha) {
    final DateTime ahora = DateTime.now();
    final DateTime hoy = DateTime(ahora.year, ahora.month, ahora.day);
    final DateTime fechaNormalizada =
        DateTime(fecha.year, fecha.month, fecha.day);
    final int diferencia = fechaNormalizada.difference(hoy).inDays;
    return diferencia >= 0 && diferencia <= _kDiasVentanaAgenda;
  }

  @override
  Future<void> close() {
    _realtimeSubscription?.cancel();
    debugPrint('📋 AgendaPendienteBloc: Suscripción real-time cancelada');
    return super.close();
  }
}
