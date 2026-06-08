import 'dart:async';

import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/core/services/auth_service.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/repositories/alerta_caducidad_repository.dart';
import 'alertas_caducidad_event.dart';
import 'alertas_caducidad_state.dart';

/// BLoC para gestionar las alertas de caducidad.
///
/// Maneja la carga, filtrado y estado de las alertas de caducidad
/// de vehiculos, seguros, ITV, homologaciones y mantenimientos.
///
/// Registrado como LazySingleton para mantener una sola instancia
/// durante toda la vida de la aplicación y evitar problemas con
/// el emitter cerrándose prematuramente.
@LazySingleton()
class AlertasCaducidadBloc
    extends Bloc<AlertasCaducidadEvent, AlertasCaducidadState> {

  /// Constructor con inyeccion de dependencias.
  AlertasCaducidadBloc(this._repository)
      : super(const AlertasCaducidadState.initial()) {
    on<AlertasCaducidadEvent>(_onEvent, transformer: sequential());
  }
  final AlertaCaducidadRepository _repository;

  /// Flag para prevenir múltiples cargas simultáneas
  bool _isLoading = false;

  /// Manejador de eventos usando when con callbacks async para soporte sequential.
  Future<void> _onEvent(
    AlertasCaducidadEvent event,
    Emitter<AlertasCaducidadState> emit,
  ) {
    return event.when<Future<void>>(
      started: () => _onStarted(emit),
      loadAlertas: (String? usuarioId, int? umbralSeguro, int? umbralItv, int? umbralHomologacion,
          int? umbralMantenimiento) {
        return _onLoadAlertas(
          emit,
          usuarioId: usuarioId,
          umbralSeguro: umbralSeguro,
          umbralItv: umbralItv,
          umbralHomologacion: umbralHomologacion,
          umbralMantenimiento: umbralMantenimiento,
        );
      },
      loadAlertasCriticas: (String? usuarioId) {
        return _onLoadAlertasCriticas(emit, usuarioId: usuarioId);
      },
      loadResumen: () => _onLoadResumen(emit),
      refresh: () => _onRefresh(emit),
      filterByTipo: (AlertaTipoFilter tipo) => _onFilterByTipo(emit, tipo),
      filterBySeveridad: (AlertaSeveridadFilter severidad) =>
          _onFilterBySeveridad(emit, severidad),
      markAsViewed: (String alertaId, AlertaTipo tipo, String entidadId) {
        _onMarkAsViewed(alertaId, tipo, entidadId);
        return Future<void>.value();
      },
      clearFilters: () => _onClearFilters(emit),
    );
  }

  /// Evento inicial - NO carga alertas automáticamente.
  ///
  /// La carga se maneja desde AuthAlertasListener que tiene acceso
  /// al usuarioId autenticado. El BLoC se crea antes de que el usuario
  /// se loguee, por lo que no podemos cargar aquí sin usuarioId.
  Future<void> _onStarted(Emitter<AlertasCaducidadState> emit) async {
    debugPrint('🚀 AlertasCaducidadBloc: BLoC iniciado. Esperando evento de carga con usuarioId...');
    // NO cargamos alertas aquí porque no tenemos usuarioId
    // El AuthAlertasListener se encargará de disparar loadAlertasCriticas
    // cuando el usuario se autentique.
  }

  /// Cargar todas las alertas activas
  Future<void> _onLoadAlertas(
    Emitter<AlertasCaducidadState> emit, {
    String? usuarioId,
    int? umbralSeguro,
    int? umbralItv,
    int? umbralHomologacion,
    int? umbralMantenimiento,
  }) async {
    // Prevenir múltiples cargas simultáneas
    if (_isLoading) {
      debugPrint('⏳ AlertasCaducidadBloc: Ya hay una carga en progreso, ignorando...');
      return;
    }

    _isLoading = true;
    emit(const AlertasCaducidadState.loading());

    try {
      final List<AlertaCaducidadEntity> alertas = await _repository.getAlertasActivas(
        usuarioId: usuarioId,
        umbralSeguro: umbralSeguro,
        umbralItv: umbralItv,
        umbralHomologacion: umbralHomologacion,
        umbralMantenimiento: umbralMantenimiento,
      );

      // Verificar que el event handler aún esté activo antes de emitir
      if (!emit.isDone) {
        final AlertasResumenEntity resumen = await _repository.getResumen();

        // Verificar nuevamente después de la segunda operación async
        if (!emit.isDone) {
          emit(AlertasCaducidadState.loaded(
            alertas: alertas,
            resumen: resumen,
          ));

          debugPrint(
            '✅ AlertasCaducidadBloc: ${alertas.length} alertas cargadas (Críticas: ${resumen.criticas}, Altas: ${resumen.altas})',
          );
        }
      }
    } catch (e) {
      debugPrint('❌ Error cargando alertas: $e');
      // Solo emitir error si el event handler aún está activo
      if (!emit.isDone) {
        emit(AlertasCaducidadState.error(message: e.toString()));
      }
    } finally {
      _isLoading = false;
    }
  }

  /// Cargar solo alertas críticas
  Future<void> _onLoadAlertasCriticas(
    Emitter<AlertasCaducidadState> emit, {
    String? usuarioId,
  }) async {
    // Prevenir múltiples cargas simultáneas
    if (_isLoading) {
      debugPrint('⏳ AlertasCaducidadBloc: Ya hay una carga en progreso, ignorando...');
      return;
    }

    _isLoading = true;
    debugPrint('🔵 BLoC: Antes de emit loading, isDone=${emit.isDone}');
    emit(const AlertasCaducidadState.loading());
    debugPrint('🔵 BLoC: Después de emit loading, isDone=${emit.isDone}');

    try {
      debugPrint('🟡 BLoC: Obteniendo alertas críticas del repositorio...');
      debugPrint('🟡 BLoC: Antes del await, isDone=${emit.isDone}');
      final List<AlertaCaducidadEntity> alertas = await _repository.getAlertasCriticas(
        usuarioId: usuarioId,
      );
      debugPrint('🟢 BLoC: ${alertas.length} alertas críticas obtenidas del repositorio');
      debugPrint('🟢 BLoC: Después del await, isDone=${emit.isDone}');

      // Emitir estado loaded inmediatamente con resumen por defecto
      // TEMPORAL: Eliminamos el cheque isDone para ver el error real
      final AlertasResumenEntity resumenPorDefecto = AlertasResumenEntity(
        criticas: alertas.where((AlertaCaducidadEntity a) => a.severidad == AlertaSeveridad.critica).length,
        altas: alertas.where((AlertaCaducidadEntity a) => a.severidad == AlertaSeveridad.alta).length,
        medias: alertas.where((AlertaCaducidadEntity a) => a.severidad == AlertaSeveridad.media).length,
        bajas: alertas.where((AlertaCaducidadEntity a) => a.severidad == AlertaSeveridad.baja).length,
        total: alertas.length,
      );

      debugPrint('🟢 BLoC: Antes de emit loaded, isDone=${emit.isDone}');
      emit(AlertasCaducidadState.loaded(
        alertas: alertas,
        resumen: resumenPorDefecto,
      ));
      debugPrint('✅ BLoC: ${alertas.length} alertas críticas cargadas (resumen por defecto)');

      // Intentar obtener resumen actualizado en background
      unawaited(_repository.getResumen().then((AlertasResumenEntity resumenActualizado) {
        if (!emit.isDone) {
          state.maybeWhen(
            loaded: (List<AlertaCaducidadEntity> alertas, _, AlertaTipoFilter filtroTipo, AlertaSeveridadFilter filtroSeveridad, _) {
              emit(AlertasCaducidadState.loaded(
                alertas: alertas,
                resumen: resumenActualizado,
                filtroTipo: filtroTipo,
                filtroSeveridad: filtroSeveridad,
              ));
              debugPrint('🔄 BLoC: Resumen actualizado aplicado');
            },
            orElse: () {},
          );
        }
      }).catchError((Object e) {
        debugPrint('⚠️ BLoC: Error obteniendo resumen actualizado: $e');
      }));
    } catch (e) {
      debugPrint('❌ Error cargando alertas críticas: $e');
      // Solo emitir error si el event handler aún está activo
      if (!emit.isDone) {
        emit(AlertasCaducidadState.error(message: e.toString()));
      }
    } finally {
      _isLoading = false;
    }
  }

  /// Cargar el resumen de alertas
  Future<void> _onLoadResumen(Emitter<AlertasCaducidadState> emit) async {
    try {
      final AlertasResumenEntity resumen = await _repository.getResumen();

      // Si ya tenemos alertas cargadas, actualizamos solo el resumen
      state.maybeWhen(
        loaded: (List<AlertaCaducidadEntity> alertas, _, AlertaTipoFilter filtroTipo, AlertaSeveridadFilter filtroSeveridad, _) {
          emit(AlertasCaducidadState.loaded(
            alertas: alertas,
            resumen: resumen,
            filtroTipo: filtroTipo,
            filtroSeveridad: filtroSeveridad,
          ));
        },
        orElse: () {},
      );
    } catch (e) {
      debugPrint('❌ Error cargando resumen: $e');
    }
  }

  /// Refrescar alertas (isRefreshing = true)
  Future<void> _onRefresh(Emitter<AlertasCaducidadState> emit) async {
    // Solo llamar a _onLoadAlertas que maneja toda la lógica
    await _onLoadAlertas(emit);
  }

  /// Filtrar por tipo
  Future<void> _onFilterByTipo(
    Emitter<AlertasCaducidadState> emit,
    AlertaTipoFilter tipo,
  ) async {
    state.maybeWhen(
      loaded: (List<AlertaCaducidadEntity> alertas, AlertasResumenEntity resumen, _, AlertaSeveridadFilter filtroSeveridad, _) {
        emit(AlertasCaducidadState.loaded(
          alertas: _applyFiltros(alertas, tipo, filtroSeveridad),
          resumen: resumen,
          filtroTipo: tipo,
          filtroSeveridad: filtroSeveridad,
        ));
      },
      orElse: () {},
    );
  }

  /// Filtrar por severidad
  Future<void> _onFilterBySeveridad(
    Emitter<AlertasCaducidadState> emit,
    AlertaSeveridadFilter severidad,
  ) async {
    state.maybeWhen(
      loaded: (List<AlertaCaducidadEntity> alertas, AlertasResumenEntity resumen, AlertaTipoFilter filtroTipo, _, _) {
        emit(AlertasCaducidadState.loaded(
          alertas: _applyFiltros(alertas, filtroTipo, severidad),
          resumen: resumen,
          filtroTipo: filtroTipo,
          filtroSeveridad: severidad,
        ));
      },
      orElse: () {},
    );
  }

  /// Limpiar todos los filtros
  Future<void> _onClearFilters(Emitter<AlertasCaducidadState> emit) async {
    state.maybeWhen(
      loaded: (List<AlertaCaducidadEntity> alertas, AlertasResumenEntity resumen, _, _, _) {
        emit(AlertasCaducidadState.loaded(
          alertas: alertas,
          resumen: resumen,
        ));
      },
      orElse: () {},
    );
  }

  /// Marcar alerta como vista para que no se muestre hoy
  Future<void> _onMarkAsViewed(
    String alertaId,
    AlertaTipo tipo,
    String entidadId,
  ) async {
    final AuthService authService = getIt<AuthService>();
    final String? usuarioId = authService.currentUser?.id;
    if (usuarioId == null) {
      debugPrint('⚠️ No se puede marcar alerta como vista: usuario no autenticado');
      return;
    }

    final String tipoAlerta = _tipoToString(tipo);
    debugPrint('👁️ Marcando alerta como vista: $alertaId ($tipoAlerta/$entidadId)');

    try {
      await _repository.marcarAlertaVista(
        usuarioId: usuarioId,
        tipoAlerta: tipoAlerta,
        entidadId: entidadId,
      );
      debugPrint('✅ Alerta marcada como vista: $alertaId');
    } catch (e) {
      debugPrint('❌ Error al marcar alerta como vista: $e');
    }
  }

  /// Convierte AlertaTipo a string para la RPC
  String _tipoToString(AlertaTipo tipo) {
    switch (tipo) {
      case AlertaTipo.seguro:
        return 'seguro';
      case AlertaTipo.itv:
        return 'itv';
      case AlertaTipo.homologacion:
        return 'homologacion';
      case AlertaTipo.revisionTecnica:
        return 'revision_tecnica';
      case AlertaTipo.revision:
        return 'revision';
      case AlertaTipo.mantenimiento:
        return 'mantenimiento';
    }
  }

  /// Aplicar filtros a la lista de alertas
  List<AlertaCaducidadEntity> _applyFiltros(
    List<AlertaCaducidadEntity> alertas,
    AlertaTipoFilter filtroTipo,
    AlertaSeveridadFilter filtroSeveridad,
  ) {
    List<AlertaCaducidadEntity> filtradas = alertas;

    // Filtrar por tipo
    if (filtroTipo != AlertaTipoFilter.all) {
      final AlertaTipo tipoEnum = _mapTipoFilterToEnum(filtroTipo);
      filtradas = filtradas.where((AlertaCaducidadEntity a) => a.tipo == tipoEnum).toList();
    }

    // Filtrar por severidad
    if (filtroSeveridad != AlertaSeveridadFilter.all) {
      final AlertaSeveridad severidadEnum = _mapSeveridadFilterToEnum(filtroSeveridad);
      filtradas = filtradas.where((AlertaCaducidadEntity a) => a.severidad == severidadEnum).toList();
    }

    return filtradas;
  }

  /// Mapear filtro de tipo a enum del domain
  AlertaTipo _mapTipoFilterToEnum(AlertaTipoFilter filtro) {
    switch (filtro) {
      case AlertaTipoFilter.seguro:
        return AlertaTipo.seguro;
      case AlertaTipoFilter.itv:
        return AlertaTipo.itv;
      case AlertaTipoFilter.homologacion:
        return AlertaTipo.homologacion;
      case AlertaTipoFilter.revisionTecnica:
        return AlertaTipo.revisionTecnica;
      case AlertaTipoFilter.revision:
        return AlertaTipo.revision;
      case AlertaTipoFilter.mantenimiento:
        return AlertaTipo.mantenimiento;
      case AlertaTipoFilter.all:
        return AlertaTipo.seguro; // Fallback, no deberia usarse
    }
  }

  /// Mapear filtro de severidad a enum del domain
  AlertaSeveridad _mapSeveridadFilterToEnum(AlertaSeveridadFilter filtro) {
    switch (filtro) {
      case AlertaSeveridadFilter.critica:
        return AlertaSeveridad.critica;
      case AlertaSeveridadFilter.alta:
        return AlertaSeveridad.alta;
      case AlertaSeveridadFilter.media:
        return AlertaSeveridad.media;
      case AlertaSeveridadFilter.baja:
        return AlertaSeveridad.baja;
      case AlertaSeveridadFilter.all:
        return AlertaSeveridad.baja; // Fallback, no deberia usarse
    }
  }

}
