import 'dart:async';

import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/features/servicios/servicios/domain/repositories/traslado_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'trafico_diario_event.dart';
import 'trafico_diario_state.dart';

/// BLoC para gestión de tráfico diario (planificación de traslados)
@injectable
class TraficoDiarioBloc extends Bloc<TraficoDiarioEvent, TraficoDiarioState> {
  TraficoDiarioBloc(this._trasladoRepository) : super(const TraficoDiarioState.initial()) {
    on<TraficoDiarioEvent>(_onEvent);
  }

  /// Suscripción al stream Realtime de traslados
  StreamSubscription<List<TrasladoEntity>>? _realtimeSubscription;

  Future<void> _onEvent(TraficoDiarioEvent event, Emitter<TraficoDiarioState> emit) async {
    await event.map(
      // ignore: always_specify_types
      started: (_) => _onStarted(emit),
      // ignore: always_specify_types
      loadTrasladosRequested: (e) => _onLoadTrasladosRequested(emit, idsServiciosRecurrentes: e.idsServiciosRecurrentes, fecha: e.fecha),
      // ignore: always_specify_types
      refreshRequested: (_) => _onRefreshRequested(emit),
      // ignore: always_specify_types
      generarTrasladosRequested: (_) => _onGenerarTrasladosRequested(emit),
      // ignore: always_specify_types
      asignarConductorRequested: (e) => _onAsignarConductorRequested(emit, idTraslado: e.idTraslado, idConductor: e.idConductor, idVehiculo: e.idVehiculo, matriculaVehiculo: e.matriculaVehiculo),
      // ignore: always_specify_types
      asignarConductorMasivoRequested: (e) => _onAsignarConductorMasivoRequested(emit, idTraslados: e.idTraslados, idConductor: e.idConductor, idVehiculo: e.idVehiculo, matriculaVehiculo: e.matriculaVehiculo),
      // ignore: always_specify_types
      filterByEstadoChanged: (e) => _onFilterByEstadoChanged(emit, estado: e.estado),
      // ignore: always_specify_types
      filterByCentroChanged: (e) => _onFilterByCentroChanged(emit, idCentro: e.idCentro),
      // ignore: always_specify_types
      searchChanged: (e) => _onSearchChanged(emit, query: e.query),
      // ignore: always_specify_types
      desasignarConductorRequested: (e) => _onDesasignarConductorRequested(emit, idTraslado: e.idTraslado),
      // ignore: always_specify_types
      desasignarConductorMasivoRequested: (e) => _onDesasignarConductorMasivoRequested(emit, idTraslados: e.idTraslados),
      // ignore: always_specify_types
      modificarHoraRequested: (e) => _onModificarHoraRequested(emit, idTraslado: e.idTraslado, nuevaHora: e.nuevaHora),
      // ignore: always_specify_types
      cancelarTrasladoRequested: (e) => _onCancelarTrasladoRequested(emit, idTraslado: e.idTraslado, motivoCancelacion: e.motivoCancelacion),
      // ignore: always_specify_types
      trasladoActualizadoFromRealtime: (e) => _onTrasladoActualizadoFromRealtime(emit, traslado: e.traslado),
    );
  }

  @override
  Future<void> close() {
    debugPrint('🔌 TraficoDiarioBloc: Cerrando BLoC y cancelando suscripción Realtime');
    _realtimeSubscription?.cancel();
    return super.close();
  }

  final TrasladoRepository _trasladoRepository;

  Future<void> _onStarted(Emitter<TraficoDiarioState> emit) async {
    emit(const TraficoDiarioState.initial());
  }

  Future<void> _onLoadTrasladosRequested(
    Emitter<TraficoDiarioState> emit, {
    required List<String> idsServiciosRecurrentes,
    required DateTime fecha,
  }) async {
    debugPrint('📅 TraficoDiarioBloc: Cargando traslados de ${idsServiciosRecurrentes.length} servicios para fecha ${fecha.toIso8601String().split('T')[0]}');

    // Cancelar suscripción Realtime anterior al cambiar de fecha/servicios
    unawaited(_realtimeSubscription?.cancel());

    emit(const TraficoDiarioState.loading());

    try {
      if (idsServiciosRecurrentes.isEmpty) {
        debugPrint('📅 TraficoDiarioBloc: No hay servicios para cargar traslados');
        emit(const TraficoDiarioState.loaded(traslados: <TrasladoEntity>[]));
        return;
      }

      final List<TrasladoEntity> trasladosCargados = await _trasladoRepository.getByServiciosYFecha(
        idsServiciosRecurrentes: idsServiciosRecurrentes,
        fecha: fecha,
      );

      debugPrint('📅 TraficoDiarioBloc: ✅ ${trasladosCargados.length} traslados cargados para fecha ${fecha.toIso8601String().split('T')[0]}');

      // Debug: Mostrar fechas de los primeros 3 traslados para verificar si llegan
      for (int i = 0; i < trasladosCargados.length && i < 3; i++) {
        final TrasladoEntity t = trasladosCargados[i];
        final String estadoLabel = EstadoTraslado.fromValue(t.estado)?.label ?? t.estado ?? 'Desconocido';
        debugPrint('   📊 Traslado ${i + 1} [${t.codigo ?? 'Sin código'}] estado=$estadoLabel:');
        debugPrint('      - fechaEnviado: ${t.fechaEnviado}');
        debugPrint('      - fechaEnOrigen: ${t.fechaEnOrigen}');
        debugPrint('      - fechaSaliendoOrigen: ${t.fechaSaliendoOrigen}');
        debugPrint('      - fechaEnDestino: ${t.fechaEnDestino}');
        debugPrint('      - fechaFinalizado: ${t.fechaFinalizado}');
      }

      emit(TraficoDiarioState.loaded(traslados: trasladosCargados));

      // Iniciar suscripción Realtime para recibir actualizaciones de estado/horas desde mobile
      _iniciarSuscripcionRealtime(trasladosCargados);
    } catch (e) {
      debugPrint('📅 TraficoDiarioBloc: ❌ Error al cargar traslados: $e');
      emit(TraficoDiarioState.error(message: e.toString()));
    }
  }

  Future<void> _onRefreshRequested(Emitter<TraficoDiarioState> emit) async {
    debugPrint('🔄 TraficoDiarioBloc: Refrescando traslados');

    // Obtener estado actual
    state.whenOrNull(
      loaded: (
        List<TrasladoEntity> traslados,
        String searchQuery,
        String? estadoFilter,
        String? centroFilter,
        bool isRefreshing,
        bool isGenerating,
        DateTime? trasladosGeneradosHasta,
      ) {
        // Marcar como refrescando
        emit(
          TraficoDiarioState.loaded(
            traslados: traslados,
            searchQuery: searchQuery,
            estadoFilter: estadoFilter,
            centroFilter: centroFilter,
            isRefreshing: true,
            isGenerating: isGenerating,
            trasladosGeneradosHasta: trasladosGeneradosHasta,
          ),
        );

        // Aquí necesitarías volver a cargar los traslados
        // Por ahora solo marcamos como no refrescando
        emit(
          TraficoDiarioState.loaded(
            traslados: traslados,
            searchQuery: searchQuery,
            estadoFilter: estadoFilter,
            centroFilter: centroFilter,
            isGenerating: isGenerating,
            trasladosGeneradosHasta: trasladosGeneradosHasta,
          ),
        );
      },
    );
  }

  Future<void> _onGenerarTrasladosRequested(Emitter<TraficoDiarioState> emit) async {
    debugPrint('🔄 TraficoDiarioBloc: Generando traslados para los próximos 14 días');

    // Calcular la fecha hasta la cual se generarán los traslados
    final DateTime fechaHasta = DateTime.now().add(const Duration(days: 14));

    // Capturar el estado actual para preservar los datos
    state.whenOrNull(
      loaded: (
        List<TrasladoEntity> traslados,
        String searchQuery,
        String? estadoFilter,
        String? centroFilter,
        bool isRefreshing,
        bool isGenerating,
        DateTime? trasladosGeneradosHasta,
      ) {
        // Establecer isGenerating en true
        emit(
          TraficoDiarioState.loaded(
            traslados: traslados,
            searchQuery: searchQuery,
            estadoFilter: estadoFilter,
            centroFilter: centroFilter,
            isRefreshing: isRefreshing,
            isGenerating: true,
            trasladosGeneradosHasta: trasladosGeneradosHasta,
          ),
        );
      },
    );

    try {
      // Llamar a la función RPC de Supabase para generar traslados
      final SupabaseClient client = Supabase.instance.client;

      final Map<String, dynamic> response = await client.rpc<Map<String, dynamic>>(
        'generar_traslados_periodo',
        params: <String, dynamic>{
          'p_fecha_desde': DateTime.now().toIso8601String().split('T')[0],
          'p_fecha_hasta': fechaHasta.toIso8601String().split('T')[0],
        },
      );

      debugPrint('✅ TraficoDiarioBloc: Traslados generados correctamente');
      debugPrint('   - Servicios procesados: ${response['servicios_procesados']}');
      debugPrint('   - Traslados generados: ${response['traslados_generados']}');

      // Emitir estado de éxito o error según el resultado
      final int? serviciosConError = response['servicios_con_error'] as int?;
      if (serviciosConError != null && serviciosConError > 0) {
        debugPrint('⚠️ TraficoDiarioBloc: Hubo errores durante la generación');
        final List<dynamic>? errores = response['errores'] as List<dynamic>?;
        if (errores != null) {
          for (final dynamic error in errores) {
            debugPrint('   - $error');
          }
        }
      }

      // Establecer isGenerating en false y actualizar trasladosGeneradosHasta
      state.whenOrNull(
        loaded: (
          List<TrasladoEntity> traslados,
          String searchQuery,
          String? estadoFilter,
          String? centroFilter,
          bool isRefreshing,
          bool isGenerating,
          DateTime? trasladosGeneradosHasta,
        ) {
          emit(
            TraficoDiarioState.loaded(
              traslados: traslados,
              searchQuery: searchQuery,
              estadoFilter: estadoFilter,
              centroFilter: centroFilter,
              isRefreshing: isRefreshing,
              trasladosGeneradosHasta: fechaHasta,
            ),
          );
        },
      );

      // Emitir evento de refresh para recargar los datos
      add(const TraficoDiarioEvent.refreshRequested());
    } catch (e) {
      debugPrint('❌ TraficoDiarioBloc: Error al generar traslados: $e');

      // Establecer isGenerating en false incluso si hay error
      state.whenOrNull(
        loaded: (
          List<TrasladoEntity> traslados,
          String searchQuery,
          String? estadoFilter,
          String? centroFilter,
          bool isRefreshing,
          bool isGenerating,
          DateTime? trasladosGeneradosHasta,
        ) {
          emit(
            TraficoDiarioState.loaded(
              traslados: traslados,
              searchQuery: searchQuery,
              estadoFilter: estadoFilter,
              centroFilter: centroFilter,
              isRefreshing: isRefreshing,
              trasladosGeneradosHasta: trasladosGeneradosHasta,
            ),
          );
        },
      );
    }
  }

  Future<void> _onAsignarConductorRequested(
    Emitter<TraficoDiarioState> emit, {
    required String idTraslado,
    required String idConductor,
    required String idVehiculo,
    required String matriculaVehiculo,
  }) async {
    debugPrint('🚗 TraficoDiarioBloc: Asignando conductor $idConductor, vehículo $idVehiculo ($matriculaVehiculo) al traslado $idTraslado');

    try {
      // Asignar el conductor, vehículo Y matrícula al traslado usando el repositorio
      // Capturamos la entidad actualizada que devuelve el repositorio
      final TrasladoEntity trasladoActualizado = await _trasladoRepository.asignarRecursos(
        id: idTraslado,
        idConductor: idConductor,
        idVehiculo: idVehiculo,
        matriculaVehiculo: matriculaVehiculo,
      );

      debugPrint('✅ TraficoDiarioBloc: Conductor, vehículo y matrícula asignados exitosamente');
      debugPrint('   - Nuevo estado: ${trasladoActualizado.estado}');
      debugPrint('   - Conductor asignado: ${trasladoActualizado.idConductor}');

      // Actualizar la lista de traslados en el estado con la entidad actualizada
      state.whenOrNull(
        loaded: (
          List<TrasladoEntity> traslados,
          String searchQuery,
          String? estadoFilter,
          String? centroFilter,
          bool isRefreshing,
          bool isGenerating,
        DateTime? trasladosGeneradosHasta,
        ) {
          // Actualizar el traslado en la lista con la entidad actualizada
          final List<TrasladoEntity> trasladosActualizados = traslados.map((TrasladoEntity t) {
            if (t.id == idTraslado) {
              return trasladoActualizado;
            }
            return t;
          }).toList();

          emit(
            TraficoDiarioState.loaded(
              traslados: trasladosActualizados,
              searchQuery: searchQuery,
              estadoFilter: estadoFilter,
              centroFilter: centroFilter,
              isGenerating: isGenerating,
            trasladosGeneradosHasta: trasladosGeneradosHasta,
            ),
          );
        },
      );
    } catch (e) {
      debugPrint('❌ TraficoDiarioBloc: Error al asignar conductor, vehículo y matrícula: $e');
      emit(TraficoDiarioState.error(message: e.toString()));
    }
  }

  Future<void> _onAsignarConductorMasivoRequested(
    Emitter<TraficoDiarioState> emit, {
    required List<String> idTraslados,
    required String idConductor,
    required String idVehiculo,
    required String matriculaVehiculo,
  }) async {
    debugPrint('🚗🚗 TraficoDiarioBloc: Asignando conductor $idConductor, vehículo $idVehiculo ($matriculaVehiculo) a ${idTraslados.length} traslados');
    debugPrint('🚗🚗 IDs de traslados a asignar: $idTraslados');

    // Capturar el estado actual ANTES de empezar las operaciones
    List<TrasladoEntity> trasladosActuales = <TrasladoEntity>[];
    String searchQuery = '';
    String? estadoFilter;
    String? centroFilter;

    state.whenOrNull(
      loaded: (
        List<TrasladoEntity> traslados,
        String sq,
        String? ef,
        String? cf,
        bool isRefreshing,
        bool isGenerating,
        DateTime? trasladosGeneradosHasta,
      ) {
        trasladosActuales = List<TrasladoEntity>.from(traslados);
        searchQuery = sq;
        estadoFilter = ef;
        centroFilter = cf;
      },
    );

    if (trasladosActuales.isEmpty) {
      debugPrint('⚠️ TraficoDiarioBloc: No hay traslados cargados, abortando asignación masiva');
      return;
    }

    // Map para guardar las entidades actualizadas (ID limpio -> entidad)
    final Map<String, TrasladoEntity> trasladosActualizadosMap = <String, TrasladoEntity>{};
    final List<String> errores = <String>[];

    // Asignar el conductor, vehículo Y matrícula a cada traslado
    for (final String idTrasladoConSufijo in idTraslados) {
      // Limpiar sufijos _ida o _vuelta del ID antes de enviar al repositorio
      final String idTraslado = idTrasladoConSufijo.replaceAll('_ida', '').replaceAll('_vuelta', '');

      debugPrint('  🚗 Asignando conductor, vehículo y matrícula a traslado: $idTraslado (original: $idTrasladoConSufijo)');

      try {
        final TrasladoEntity trasladoActualizado = await _trasladoRepository.asignarRecursos(
          id: idTraslado,
          idConductor: idConductor,
          idVehiculo: idVehiculo,
          matriculaVehiculo: matriculaVehiculo,
        );

        trasladosActualizadosMap[idTraslado] = trasladoActualizado;
        debugPrint('  ✅ Traslado $idTraslado asignado correctamente');
      } catch (e) {
        debugPrint('  ❌ Error asignando traslado $idTraslado: $e');
        errores.add('Traslado $idTraslado: $e');
      }
    }

    debugPrint('✅ TraficoDiarioBloc: ${trasladosActualizadosMap.length}/${idTraslados.length} traslados asignados exitosamente');

    // Actualizar la lista de traslados con las entidades actualizadas
    if (trasladosActualizadosMap.isNotEmpty) {
      final List<TrasladoEntity> trasladosActualizados = trasladosActuales.map((TrasladoEntity t) {
        if (trasladosActualizadosMap.containsKey(t.id)) {
          debugPrint('  📝 Actualizando traslado ${t.id} en el estado');
          return trasladosActualizadosMap[t.id]!;
        }
        return t;
      }).toList();

      emit(
        TraficoDiarioState.loaded(
          traslados: trasladosActualizados,
          searchQuery: searchQuery,
          estadoFilter: estadoFilter,
          centroFilter: centroFilter,
        ),
      );
    }

    // Si hubo errores, loguearlos pero no emitir estado de error
    // ya que algunos traslados sí se asignaron correctamente
    if (errores.isNotEmpty) {
      debugPrint('⚠️ TraficoDiarioBloc: Hubo ${errores.length} errores durante la asignación masiva');
      for (final String error in errores) {
        debugPrint('  - $error');
      }
    }
  }

  Future<void> _onFilterByEstadoChanged(
    Emitter<TraficoDiarioState> emit, {
    String? estado,
  }) async {
    debugPrint('🔍 TraficoDiarioBloc: Filtrando por estado: ${estado ?? "todos"}');

    state.whenOrNull(
      loaded: (
        List<TrasladoEntity> traslados,
        String searchQuery,
        String? estadoFilter,
        String? centroFilter,
        bool isRefreshing,
        bool isGenerating,
        DateTime? trasladosGeneradosHasta,
      ) {
        emit(
          TraficoDiarioState.loaded(
            traslados: traslados,
            searchQuery: searchQuery,
            estadoFilter: estado,
            centroFilter: centroFilter,
            isRefreshing: isRefreshing,
          ),
        );
      },
    );
  }

  Future<void> _onFilterByCentroChanged(
    Emitter<TraficoDiarioState> emit, {
    String? idCentro,
  }) async {
    debugPrint('🏥 TraficoDiarioBloc: Filtrando por centro: ${idCentro ?? "todos"}');

    state.whenOrNull(
      loaded: (
        List<TrasladoEntity> traslados,
        String searchQuery,
        String? estadoFilter,
        String? centroFilter,
        bool isRefreshing,
        bool isGenerating,
        DateTime? trasladosGeneradosHasta,
      ) {
        emit(
          TraficoDiarioState.loaded(
            traslados: traslados,
            searchQuery: searchQuery,
            estadoFilter: estadoFilter,
            centroFilter: idCentro,
            isRefreshing: isRefreshing,
          ),
        );
      },
    );
  }

  Future<void> _onSearchChanged(
    Emitter<TraficoDiarioState> emit, {
    required String query,
  }) async {
    debugPrint('🔎 TraficoDiarioBloc: Búsqueda: "$query"');

    state.whenOrNull(
      loaded: (
        List<TrasladoEntity> traslados,
        String searchQuery,
        String? estadoFilter,
        String? centroFilter,
        bool isRefreshing,
        bool isGenerating,
        DateTime? trasladosGeneradosHasta,
      ) {
        emit(
          TraficoDiarioState.loaded(
            traslados: traslados,
            searchQuery: query,
            estadoFilter: estadoFilter,
            centroFilter: centroFilter,
            isRefreshing: isRefreshing,
          ),
        );
      },
    );
  }

  Future<void> _onDesasignarConductorRequested(
    Emitter<TraficoDiarioState> emit, {
    required String idTraslado,
  }) async {
    debugPrint('🚫 TraficoDiarioBloc: Desasignando conductor del traslado $idTraslado');

    try {
      // Usar el nuevo método desasignarRecursos que pone null en todos los campos
      // y cambia el estado a 'pendiente' automáticamente
      final TrasladoEntity trasladoActualizado = await _trasladoRepository.desasignarRecursos(
        id: idTraslado,
      );

      debugPrint('✅ TraficoDiarioBloc: Conductor desasignado exitosamente del traslado $idTraslado');

      // Actualizar la lista de traslados en el estado
      state.whenOrNull(
        loaded: (
          List<TrasladoEntity> traslados,
          String searchQuery,
          String? estadoFilter,
          String? centroFilter,
          bool isRefreshing,
          bool isGenerating,
        DateTime? trasladosGeneradosHasta,
        ) {
          // Actualizar el traslado en la lista con la entidad actualizada
          final List<TrasladoEntity> trasladosActualizados = traslados.map((TrasladoEntity t) {
            if (t.id == idTraslado) {
              return trasladoActualizado;
            }
            return t;
          }).toList();

          emit(
            TraficoDiarioState.loaded(
              traslados: trasladosActualizados,
              searchQuery: searchQuery,
              estadoFilter: estadoFilter,
              centroFilter: centroFilter,
              isGenerating: isGenerating,
            trasladosGeneradosHasta: trasladosGeneradosHasta,
            ),
          );
        },
      );
    } catch (e) {
      debugPrint('❌ TraficoDiarioBloc: Error al desasignar conductor: $e');
      emit(TraficoDiarioState.error(message: 'Error al desasignar conductor: $e'));
    }
  }

  Future<void> _onDesasignarConductorMasivoRequested(
    Emitter<TraficoDiarioState> emit, {
    required List<String> idTraslados,
  }) async {
    debugPrint('🚫🚫 TraficoDiarioBloc: Desasignando conductor de ${idTraslados.length} traslados');
    debugPrint('   - IDs: $idTraslados');

    // CRÍTICO: Capturar el estado ANTES del loop async
    // Si no, el state puede cambiar durante las iteraciones
    final List<TrasladoEntity> trasladosOriginales = state.maybeWhen(
      loaded: (
        List<TrasladoEntity> traslados,
        String searchQuery,
        String? estadoFilter,
        String? centroFilter,
        bool isRefreshing,
        bool isGenerating,
        DateTime? trasladosGeneradosHasta,
      ) =>
          List<TrasladoEntity>.from(traslados),
      orElse: () => <TrasladoEntity>[],
    );

    final String searchQueryCapturado = state.maybeWhen(
      loaded: (List<TrasladoEntity> traslados, String searchQuery, String? estadoFilter, String? centroFilter, bool isRefreshing, bool isGenerating, DateTime? trasladosGeneradosHasta) => searchQuery,
      orElse: () => '',
    );

    final String? estadoFilterCapturado = state.maybeWhen(
      loaded: (List<TrasladoEntity> traslados, String searchQuery, String? estadoFilter, String? centroFilter, bool isRefreshing, bool isGenerating, DateTime? trasladosGeneradosHasta) => estadoFilter,
      orElse: () => null,
    );

    final String? centroFilterCapturado = state.maybeWhen(
      loaded: (List<TrasladoEntity> traslados, String searchQuery, String? estadoFilter, String? centroFilter, bool isRefreshing, bool isGenerating, DateTime? trasladosGeneradosHasta) => centroFilter,
      orElse: () => null,
    );

    if (trasladosOriginales.isEmpty) {
      debugPrint('⚠️ TraficoDiarioBloc: No hay traslados en el estado para desasignar');
      return;
    }

    try {
      // Crear copia mutable de la lista
      List<TrasladoEntity> trasladosActualizados = List<TrasladoEntity>.from(trasladosOriginales);

      // Desasignar cada traslado
      for (final String idTraslado in idTraslados) {
        debugPrint('🚫 Desasignando traslado $idTraslado...');

        final TrasladoEntity trasladoActualizado = await _trasladoRepository.desasignarRecursos(
          id: idTraslado,
        );

        debugPrint('✅ Traslado $idTraslado desasignado');

        // Actualizar en la lista
        trasladosActualizados = trasladosActualizados.map((TrasladoEntity t) {
          if (t.id == idTraslado) {
            return trasladoActualizado;
          }
          return t;
        }).toList();
      }

      debugPrint('✅ TraficoDiarioBloc: ${idTraslados.length} traslados desasignados exitosamente');

      // Emitir estado actualizado
      emit(
        TraficoDiarioState.loaded(
          traslados: trasladosActualizados,
          searchQuery: searchQueryCapturado,
          estadoFilter: estadoFilterCapturado,
          centroFilter: centroFilterCapturado,
        ),
      );
    } catch (e) {
      debugPrint('❌ TraficoDiarioBloc: Error al desasignar conductores masivamente: $e');
      emit(TraficoDiarioState.error(message: 'Error al desasignar conductores: $e'));
    }
  }

  Future<void> _onModificarHoraRequested(
    Emitter<TraficoDiarioState> emit, {
    required String idTraslado,
    required DateTime nuevaHora,
  }) async {
    debugPrint('🕐 TraficoDiarioBloc: Modificando hora del traslado $idTraslado');
    debugPrint('   - Nueva hora: ${nuevaHora.hour.toString().padLeft(2, '0')}:${nuevaHora.minute.toString().padLeft(2, '0')}');

    try {
      // Obtener el traslado actual
      final TrasladoEntity trasladoActual = await _trasladoRepository.getById(idTraslado);

      // Crear entidad actualizada con la nueva hora programada
      final DateTime fecha = trasladoActual.fecha ?? DateTime.now();
      final DateTime nuevaHoraProgramada = DateTime(
        fecha.year,
        fecha.month,
        fecha.day,
        nuevaHora.hour,
        nuevaHora.minute,
      );
      final TrasladoEntity trasladoConNuevaHora = trasladoActual.copyWith(
        horaProgramada: nuevaHoraProgramada,
        updatedAt: DateTime.now(),
      );

      // Actualizar en el repositorio
      final TrasladoEntity trasladoActualizado = await _trasladoRepository.update(trasladoConNuevaHora);

      debugPrint('✅ TraficoDiarioBloc: Hora modificada exitosamente');

      // Actualizar la lista de traslados en el estado
      state.whenOrNull(
        loaded: (
          List<TrasladoEntity> traslados,
          String searchQuery,
          String? estadoFilter,
          String? centroFilter,
          bool isRefreshing,
          bool isGenerating,
        DateTime? trasladosGeneradosHasta,
        ) {
          final List<TrasladoEntity> trasladosActualizados = traslados.map((TrasladoEntity t) {
            if (t.id == idTraslado) {
              return trasladoActualizado;
            }
            return t;
          }).toList();

          emit(
            TraficoDiarioState.loaded(
              traslados: trasladosActualizados,
              searchQuery: searchQuery,
              estadoFilter: estadoFilter,
              centroFilter: centroFilter,
              isGenerating: isGenerating,
            trasladosGeneradosHasta: trasladosGeneradosHasta,
            ),
          );
        },
      );
    } catch (e) {
      debugPrint('❌ TraficoDiarioBloc: Error al modificar hora: $e');
      emit(TraficoDiarioState.error(message: 'Error al modificar hora: $e'));
    }
  }

  Future<void> _onCancelarTrasladoRequested(
    Emitter<TraficoDiarioState> emit, {
    required String idTraslado,
    String? motivoCancelacion,
  }) async {
    debugPrint('❌ TraficoDiarioBloc: Cancelando traslado $idTraslado');
    if (motivoCancelacion != null) {
      debugPrint('   - Motivo: $motivoCancelacion');
    }

    try {
      // Usar el método updateEstado del repositorio para cambiar a 'cancelado'
      final TrasladoEntity trasladoActualizado = await _trasladoRepository.updateEstado(
        id: idTraslado,
        nuevoEstado: 'cancelado',
      );

      debugPrint('✅ TraficoDiarioBloc: Traslado cancelado exitosamente');

      // Actualizar la lista de traslados en el estado
      state.whenOrNull(
        loaded: (
          List<TrasladoEntity> traslados,
          String searchQuery,
          String? estadoFilter,
          String? centroFilter,
          bool isRefreshing,
          bool isGenerating,
        DateTime? trasladosGeneradosHasta,
        ) {
          final List<TrasladoEntity> trasladosActualizados = traslados.map((TrasladoEntity t) {
            if (t.id == idTraslado) {
              return trasladoActualizado;
            }
            return t;
          }).toList();

          emit(
            TraficoDiarioState.loaded(
              traslados: trasladosActualizados,
              searchQuery: searchQuery,
              estadoFilter: estadoFilter,
              centroFilter: centroFilter,
              isGenerating: isGenerating,
            trasladosGeneradosHasta: trasladosGeneradosHasta,
            ),
          );
        },
      );
    } catch (e) {
      debugPrint('❌ TraficoDiarioBloc: Error al cancelar traslado: $e');
      emit(TraficoDiarioState.error(message: 'Error al cancelar traslado: $e'));
    }
  }

  /// Maneja actualizaciones de traslados desde el stream Realtime
  /// Actualiza solo el traslado que cambió en el estado
  Future<void> _onTrasladoActualizadoFromRealtime(
    Emitter<TraficoDiarioState> emit, {
    required TrasladoEntity traslado,
  }) async {
    debugPrint('📡 TraficoDiarioBloc: Actualización Realtime recibida para traslado ${traslado.id}');
    final String estadoLabel = EstadoTraslado.fromValue(traslado.estado)?.label ?? traslado.estado ?? 'Desconocido';
    debugPrint('   - Estado: $estadoLabel');
    debugPrint('   - fechaEnviado: ${traslado.fechaEnviado}');
    debugPrint('   - fechaEnOrigen: ${traslado.fechaEnOrigen}');
    debugPrint('   - fechaSaliendoOrigen: ${traslado.fechaSaliendoOrigen}');
    debugPrint('   - fechaEnDestino: ${traslado.fechaEnDestino}');
    debugPrint('   - fechaFinalizado: ${traslado.fechaFinalizado}');

    state.whenOrNull(
      loaded: (
        List<TrasladoEntity> traslados,
        String searchQuery,
        String? estadoFilter,
        String? centroFilter,
        bool isRefreshing,
        bool isGenerating,
        DateTime? trasladosGeneradosHasta,
      ) {
        // Verificar si el traslado existe en la lista actual
        final int index = traslados.indexWhere((TrasladoEntity t) => t.id == traslado.id);

        if (index == -1) {
          debugPrint('⚠️ TraficoDiarioBloc: Traslado ${traslado.id} no encontrado en la lista actual');
          return;
        }

        // Crear lista actualizada con el traslado modificado
        final List<TrasladoEntity> trasladosActualizados = List<TrasladoEntity>.from(traslados);
        trasladosActualizados[index] = traslado;

        debugPrint('✅ TraficoDiarioBloc: Traslado ${traslado.id} actualizado en posición $index');

        emit(
          TraficoDiarioState.loaded(
            traslados: trasladosActualizados,
            searchQuery: searchQuery,
            estadoFilter: estadoFilter,
            centroFilter: centroFilter,
          ),
        );
      },
    );
  }

  /// Inicia la suscripción Realtime para los traslados cargados
  void _iniciarSuscripcionRealtime(List<TrasladoEntity> traslados) {
    // Cancelar suscripción anterior si existe
    _realtimeSubscription?.cancel();

    if (traslados.isEmpty) {
      debugPrint('📡 TraficoDiarioBloc: No hay traslados para suscribirse a Realtime');
      return;
    }

    // Obtener IDs de los traslados cargados
    final List<String> ids = traslados.map((TrasladoEntity t) => t.id).toList();

    debugPrint('📡 TraficoDiarioBloc: Iniciando suscripción Realtime para ${ids.length} traslados');

    // Suscribirse al stream
    _realtimeSubscription = _trasladoRepository.watchByIds(ids).listen(
      (List<TrasladoEntity> trasladosActualizados) {
        // Emitir evento para cada traslado actualizado
        for (final TrasladoEntity trasladoActualizado in trasladosActualizados) {
          add(TraficoDiarioEvent.trasladoActualizadoFromRealtime(traslado: trasladoActualizado));
        }
      },
      onError: (Object error) {
        debugPrint('❌ TraficoDiarioBloc: Error en stream Realtime: $error');
      },
    );
  }
}
