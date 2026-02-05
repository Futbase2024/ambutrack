import 'package:ambutrack_core/ambutrack_core.dart';
import 'package:ambutrack_web/features/servicios/servicios/domain/repositories/traslado_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import 'trafico_diario_event.dart';
import 'trafico_diario_state.dart';

/// BLoC para gestión de tráfico diario (planificación de traslados)
@injectable
class TraficoDiarioBloc extends Bloc<TraficoDiarioEvent, TraficoDiarioState> {
  TraficoDiarioBloc(this._trasladoRepository) : super(const TraficoDiarioState.initial()) {
    on<TraficoDiarioEvent>(_onEvent);
  }

  Future<void> _onEvent(TraficoDiarioEvent event, Emitter<TraficoDiarioState> emit) async {
    await event.map(
      // ignore: always_specify_types
      started: (_) => _onStarted(emit),
      // ignore: always_specify_types
      loadTrasladosRequested: (e) => _onLoadTrasladosRequested(emit, idsServiciosRecurrentes: e.idsServiciosRecurrentes, fecha: e.fecha),
      // ignore: always_specify_types
      refreshRequested: (_) => _onRefreshRequested(emit),
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
    );
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

      emit(TraficoDiarioState.loaded(traslados: trasladosCargados));
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
      ) {
        // Marcar como refrescando
        emit(
          TraficoDiarioState.loaded(
            traslados: traslados,
            searchQuery: searchQuery,
            estadoFilter: estadoFilter,
            centroFilter: centroFilter,
            isRefreshing: true,
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
          ),
        );
      },
    );
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
      debugPrint('   - Conductor asignado: ${trasladoActualizado.idPersonalConductor}');

      // Actualizar la lista de traslados en el estado con la entidad actualizada
      state.whenOrNull(
        loaded: (
          List<TrasladoEntity> traslados,
          String searchQuery,
          String? estadoFilter,
          String? centroFilter,
          bool isRefreshing,
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
      ) =>
          List<TrasladoEntity>.from(traslados),
      orElse: () => <TrasladoEntity>[],
    );

    final String searchQueryCapturado = state.maybeWhen(
      loaded: (List<TrasladoEntity> traslados, String searchQuery, String? estadoFilter, String? centroFilter, bool isRefreshing) => searchQuery,
      orElse: () => '',
    );

    final String? estadoFilterCapturado = state.maybeWhen(
      loaded: (List<TrasladoEntity> traslados, String searchQuery, String? estadoFilter, String? centroFilter, bool isRefreshing) => estadoFilter,
      orElse: () => null,
    );

    final String? centroFilterCapturado = state.maybeWhen(
      loaded: (List<TrasladoEntity> traslados, String searchQuery, String? estadoFilter, String? centroFilter, bool isRefreshing) => centroFilter,
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
      final TrasladoEntity trasladoConNuevaHora = trasladoActual.copyWith(
        horaProgramada: nuevaHora,
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
            ),
          );
        },
      );
    } catch (e) {
      debugPrint('❌ TraficoDiarioBloc: Error al cancelar traslado: $e');
      emit(TraficoDiarioState.error(message: 'Error al cancelar traslado: $e'));
    }
  }
}
