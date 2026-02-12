import 'dart:async';

import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../../auth/presentation/bloc/auth_state.dart';
import '../../../../notificaciones/domain/repositories/notificaciones_repository.dart';
import '../../../domain/repositories/incidencias_repository.dart';
import 'incidencias_event.dart';
import 'incidencias_state.dart';

/// BLoC para gestionar el estado de las incidencias del vehículo.
@injectable
class IncidenciasBloc extends Bloc<IncidenciasEvent, IncidenciasState> {
  IncidenciasBloc(
    this._repository,
    this._notificacionesRepository,
    this._authBloc,
  ) : super(const IncidenciasInitial()) {
    on<IncidenciasLoadRequested>(_onLoadRequested);
    on<IncidenciasLoadByVehiculoRequested>(_onLoadByVehiculoRequested);
    on<IncidenciasLoadByEstadoRequested>(_onLoadByEstadoRequested);
    on<IncidenciasCreateRequested>(_onCreateRequested);
    on<IncidenciasUpdateRequested>(_onUpdateRequested);
    on<IncidenciasDeleteRequested>(_onDeleteRequested);
    on<IncidenciasWatchByVehiculoRequested>(_onWatchByVehiculoRequested);
  }

  final IncidenciasRepository _repository;
  final NotificacionesRepository _notificacionesRepository;
  final AuthBloc _authBloc;
  StreamSubscription<List<IncidenciaVehiculoEntity>>? _watchSubscription;

  Future<void> _onLoadRequested(
    IncidenciasLoadRequested event,
    Emitter<IncidenciasState> emit,
  ) async {
    debugPrint('⚠️ IncidenciasBloc: Cargando todas las incidencias...');
    emit(const IncidenciasLoading());

    try {
      final incidencias = await _repository.getAll();
      debugPrint(
          '⚠️ IncidenciasBloc: ✅ ${incidencias.length} incidencias cargadas');
      emit(IncidenciasLoaded(incidencias: incidencias));
    } catch (e) {
      debugPrint('⚠️ IncidenciasBloc: ❌ Error: $e');
      emit(IncidenciasError(e.toString()));
    }
  }

  Future<void> _onLoadByVehiculoRequested(
    IncidenciasLoadByVehiculoRequested event,
    Emitter<IncidenciasState> emit,
  ) async {
    debugPrint(
        '⚠️ IncidenciasBloc: Cargando incidencias del vehículo: ${event.vehiculoId}');
    emit(const IncidenciasLoading());

    try {
      final incidencias = await _repository.getByVehiculoId(event.vehiculoId);
      debugPrint(
          '⚠️ IncidenciasBloc: ✅ ${incidencias.length} incidencias cargadas');
      emit(IncidenciasLoaded(
        incidencias: incidencias,
        filteredByVehiculo: event.vehiculoId,
      ));
    } catch (e) {
      debugPrint('⚠️ IncidenciasBloc: ❌ Error: $e');
      emit(IncidenciasError(e.toString()));
    }
  }

  Future<void> _onLoadByEstadoRequested(
    IncidenciasLoadByEstadoRequested event,
    Emitter<IncidenciasState> emit,
  ) async {
    debugPrint(
        '⚠️ IncidenciasBloc: Cargando incidencias con estado: ${event.estado.name}');
    emit(const IncidenciasLoading());

    try {
      final incidencias = await _repository.getByEstado(event.estado);
      debugPrint(
          '⚠️ IncidenciasBloc: ✅ ${incidencias.length} incidencias cargadas');
      emit(IncidenciasLoaded(
        incidencias: incidencias,
        filteredByEstado: event.estado,
      ));
    } catch (e) {
      debugPrint('⚠️ IncidenciasBloc: ❌ Error: $e');
      emit(IncidenciasError(e.toString()));
    }
  }

  Future<void> _onCreateRequested(
    IncidenciasCreateRequested event,
    Emitter<IncidenciasState> emit,
  ) async {
    debugPrint('⚠️ IncidenciasBloc: Creando incidencia...');
    emit(const IncidenciasLoading());

    try {
      final created = await _repository.create(event.incidencia);
      debugPrint('⚠️ IncidenciasBloc: ✅ Incidencia creada: ${created.id}');

      // Notificar a gestores de flota si la incidencia está reportada
      if (created.estado == EstadoIncidencia.reportada) {
        await _notificarNuevaIncidencia(created);
      }

      emit(IncidenciaCreated(created));

      // Recargar lista después de crear
      add(IncidenciasLoadByVehiculoRequested(created.vehiculoId));
    } catch (e) {
      debugPrint('⚠️ IncidenciasBloc: ❌ Error al crear: $e');
      emit(IncidenciasError(e.toString()));
    }
  }

  /// Notifica a los gestores de flota sobre una nueva incidencia reportada
  Future<void> _notificarNuevaIncidencia(IncidenciaVehiculoEntity incidencia) async {
    try {
      // Obtener datos del usuario autenticado
      final authState = _authBloc.state;
      if (authState is! AuthAuthenticated) {
        debugPrint('⚠️ IncidenciasBloc: ⚠️ No se puede notificar - usuario no autenticado');
        return;
      }

      final nombreReportante = incidencia.reportadoPorNombre;

      // Obtener matrícula del vehículo desde Supabase
      String matricula = 'Vehículo';
      try {
        final vehiculoData = await Supabase.instance.client
            .from('tvehiculos')
            .select('matricula')
            .eq('id', incidencia.vehiculoId)
            .maybeSingle();

        if (vehiculoData != null) {
          matricula = vehiculoData['matricula'] as String? ?? 'Vehículo';
        }
        debugPrint('⚠️ IncidenciasBloc: 🚗 Matrícula obtenida: $matricula');
      } catch (e) {
        debugPrint('⚠️ IncidenciasBloc: ⚠️ Error al obtener matrícula: $e');
      }

      // Obtener kilómetros del reporte
      final kilometros = incidencia.kilometrajeReporte;
      final kmTexto = kilometros != null ? '${kilometros.toStringAsFixed(0)} km' : 'km no especificados';

      // Determinar emoji según prioridad
      final prioridadEmoji = switch (incidencia.prioridad) {
        PrioridadIncidencia.critica => '🚨',
        PrioridadIncidencia.alta => '⚠️',
        PrioridadIncidencia.media => '🔧',
        PrioridadIncidencia.baja => 'ℹ️',
      };

      // Determinar texto de prioridad
      final prioridadTexto = switch (incidencia.prioridad) {
        PrioridadIncidencia.critica => 'CRÍTICA',
        PrioridadIncidencia.alta => 'Alta',
        PrioridadIncidencia.media => 'Media',
        PrioridadIncidencia.baja => 'Baja',
      };

      // Crear notificación para gestores de flota (excluir al usuario que reporta)
      await _notificacionesRepository.notificarGestoresFlota(
        tipo: 'incidencia_vehiculo_reportada',
        titulo: '$prioridadEmoji Nueva Incidencia de Vehículo - Prioridad $prioridadTexto',
        mensaje: '$nombreReportante reportó: ${incidencia.titulo}. ${incidencia.descripcion}\n\n🚗 Vehículo: $matricula\n📏 Kilometraje: $kmTexto',
        entidadTipo: 'incidencia_vehiculo',
        entidadId: incidencia.id,
        excluirUsuarioId: authState.user.id,
        metadata: {
          'vehiculo_id': incidencia.vehiculoId,
          'matricula': matricula,
          'kilometraje': kilometros,
          'reportado_por': incidencia.reportadoPor,
          'reportado_por_nombre': nombreReportante,
          'tipo': incidencia.tipo.name,
          'prioridad': incidencia.prioridad.name,
          'titulo': incidencia.titulo,
          'descripcion': incidencia.descripcion,
          'fecha_reporte': incidencia.fechaReporte.toIso8601String(),
        },
      );

      debugPrint('⚠️ IncidenciasBloc: ✅ Notificación enviada a gestores de flota');
    } catch (e) {
      debugPrint('⚠️ IncidenciasBloc: ❌ Error al enviar notificación: $e');
      // No fallar el flujo principal si falla la notificación
    }
  }

  Future<void> _onUpdateRequested(
    IncidenciasUpdateRequested event,
    Emitter<IncidenciasState> emit,
  ) async {
    debugPrint(
        '⚠️ IncidenciasBloc: Actualizando incidencia ID: ${event.incidencia.id}');
    emit(const IncidenciasLoading());

    try {
      final updated = await _repository.update(event.incidencia);
      debugPrint('⚠️ IncidenciasBloc: ✅ Incidencia actualizada');
      emit(IncidenciaUpdated(updated));

      // Recargar lista después de actualizar
      add(IncidenciasLoadByVehiculoRequested(updated.vehiculoId));
    } catch (e) {
      debugPrint('⚠️ IncidenciasBloc: ❌ Error al actualizar: $e');
      emit(IncidenciasError(e.toString()));
    }
  }

  Future<void> _onDeleteRequested(
    IncidenciasDeleteRequested event,
    Emitter<IncidenciasState> emit,
  ) async {
    debugPrint('⚠️ IncidenciasBloc: Eliminando incidencia ID: ${event.id}');
    emit(const IncidenciasLoading());

    try {
      await _repository.delete(event.id);
      debugPrint('⚠️ IncidenciasBloc: ✅ Incidencia eliminada');
      emit(IncidenciaDeleted(event.id));

      // Recargar lista después de eliminar
      if (state is IncidenciasLoaded) {
        final currentState = state as IncidenciasLoaded;
        if (currentState.filteredByVehiculo != null) {
          add(IncidenciasLoadByVehiculoRequested(
              currentState.filteredByVehiculo!));
        } else {
          add(const IncidenciasLoadRequested());
        }
      }
    } catch (e) {
      debugPrint('⚠️ IncidenciasBloc: ❌ Error al eliminar: $e');
      emit(IncidenciasError(e.toString()));
    }
  }

  Future<void> _onWatchByVehiculoRequested(
    IncidenciasWatchByVehiculoRequested event,
    Emitter<IncidenciasState> emit,
  ) async {
    debugPrint(
        '⚠️ IncidenciasBloc: Observando incidencias del vehículo: ${event.vehiculoId}');
    await _watchSubscription?.cancel();

    emit(const IncidenciasLoading());

    _watchSubscription =
        _repository.watchByVehiculoId(event.vehiculoId).listen(
      (incidencias) {
        debugPrint(
            '⚠️ IncidenciasBloc: 🔄 Actualización recibida: ${incidencias.length} incidencias');
        add(IncidenciasLoadByVehiculoRequested(event.vehiculoId));
      },
      onError: (error) {
        debugPrint('⚠️ IncidenciasBloc: ❌ Error en stream: $error');
        emit(IncidenciasError(error.toString()));
      },
    );
  }

  @override
  Future<void> close() {
    _watchSubscription?.cancel();
    return super.close();
  }
}
