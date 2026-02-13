import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';

import '../../domain/repositories/caducidades_repository.dart';
import 'caducidades_event.dart';
import 'caducidades_state.dart';

/// BLoC para gestión de caducidades de equipamiento médico
///
/// Maneja la visualización, filtrado y acciones sobre items con caducidad
@injectable
class CaducidadesBloc extends Bloc<CaducidadesEvent, CaducidadesState> {
  CaducidadesBloc({
    required CaducidadesRepository repository,
  })  : _repository = repository,
        super(const CaducidadesState.initial()) {
    on<CaducidadesEvent>(_onEvent);
  }

  final CaducidadesRepository _repository;

  /// Manejador principal de eventos
  Future<void> _onEvent(
    CaducidadesEvent event,
    Emitter<CaducidadesState> emit,
  ) async {
    await event.when(
      started: (vehiculoId) => _onStarted(emit, vehiculoId),
      cargarCaducidades: (vehiculoId) => _onCargarCaducidades(emit, vehiculoId),
      filtrarPorEstado: (filtro) => _onFiltrarPorEstado(emit, filtro),
      cargarAlertas: (vehiculoId) => _onCargarAlertas(emit, vehiculoId),
      solicitarReposicion: (
        vehiculoId,
        productoId,
        productoNombre,
        cantidad,
        motivo,
        usuarioId,
      ) =>
          _onSolicitarReposicion(
        emit,
        vehiculoId,
        productoId,
        productoNombre,
        cantidad,
        motivo,
        usuarioId,
      ),
      registrarIncidencia: (
        vehiculoId,
        titulo,
        descripcion,
        reportadoPor,
        reportadoPorNombre,
        empresaId,
      ) =>
          _onRegistrarIncidencia(
        emit,
        vehiculoId,
        titulo,
        descripcion,
        reportadoPor,
        reportadoPorNombre,
        empresaId,
      ),
      resolverAlerta: (alertaId, usuarioId) =>
          _onResolverAlerta(emit, alertaId, usuarioId),
      actualizarItem: (
        itemId,
        cantidadActual,
        fechaCaducidad,
        lote,
        ubicacion,
        observaciones,
      ) =>
          _onActualizarItem(
        emit,
        itemId,
        cantidadActual,
        fechaCaducidad,
        lote,
        ubicacion,
        observaciones,
      ),
      eliminarItem: (itemId, vehiculoId, productoNombre, usuarioId) =>
          _onEliminarItem(emit, itemId, vehiculoId, productoNombre, usuarioId),
      refrescar: () => _onRefrescar(emit),
    );
  }

  // ===== Implementaciones de eventos =====

  Future<void> _onStarted(
    Emitter<CaducidadesState> emit,
    String vehiculoId,
  ) async {
    debugPrint('📋 CaducidadesBloc: Iniciado para vehículo $vehiculoId');
    await _cargarDatos(emit, vehiculoId, null);
  }

  Future<void> _onCargarCaducidades(
    Emitter<CaducidadesState> emit,
    String vehiculoId,
  ) async {
    debugPrint('📋 CaducidadesBloc: Cargando caducidades...');
    emit(const CaducidadesState.loading());
    await _cargarDatos(emit, vehiculoId, null);
  }

  Future<void> _onFiltrarPorEstado(
    Emitter<CaducidadesState> emit,
    String? filtro,
  ) async {
    state.maybeWhen(
      loaded: (
        items,
        alertas,
        vehiculoId,
        filtroActual,
        total,
        ok,
        proximos,
        criticos,
        caducados,
        isRefreshing,
      ) {
        debugPrint('📋 CaducidadesBloc: Aplicando filtro: ${filtro ?? 'todas'}');
        _cargarDatos(emit, vehiculoId, filtro);
      },
      orElse: () {},
    );
  }

  Future<void> _onCargarAlertas(
    Emitter<CaducidadesState> emit,
    String vehiculoId,
  ) async {
    debugPrint('⚠️ CaducidadesBloc: Cargando alertas...');
    // Las alertas se cargan automáticamente en _cargarDatos
    await _cargarDatos(emit, vehiculoId, null);
  }

  Future<void> _onSolicitarReposicion(
    Emitter<CaducidadesState> emit,
    String vehiculoId,
    String productoId,
    String productoNombre,
    int cantidad,
    String motivo,
    String usuarioId,
  ) async {
    debugPrint(
      '📝 CaducidadesBloc: Solicitando reposición de $productoNombre...',
    );
    emit(
      CaducidadesState.procesando(
        mensaje: 'Solicitando reposición de $productoNombre...',
      ),
    );

    try {
      await _repository.solicitarReposicion(
        vehiculoId: vehiculoId,
        productoId: productoId,
        cantidadSolicitada: cantidad,
        motivo: motivo,
        usuarioId: usuarioId,
      );

      debugPrint('✅ CaducidadesBloc: Reposición solicitada exitosamente');
      emit(
        CaducidadesState.accionExitosa(
          mensaje: 'Solicitud de reposición registrada correctamente',
          vehiculoId: vehiculoId,
        ),
      );
    } catch (e) {
      debugPrint('❌ CaducidadesBloc: Error al solicitar reposición - $e');
      emit(
        CaducidadesState.error(
          mensaje: 'Error al solicitar reposición: ${e.toString()}',
          vehiculoId: vehiculoId,
        ),
      );
    }
  }

  Future<void> _onRegistrarIncidencia(
    Emitter<CaducidadesState> emit,
    String vehiculoId,
    String titulo,
    String descripcion,
    String reportadoPor,
    String reportadoPorNombre,
    String empresaId,
  ) async {
    debugPrint('🚨 CaducidadesBloc: Registrando incidencia...');
    emit(const CaducidadesState.procesando(mensaje: 'Registrando incidencia...'));

    try {
      await _repository.registrarIncidencia(
        vehiculoId: vehiculoId,
        titulo: titulo,
        descripcion: descripcion,
        reportadoPor: reportadoPor,
        reportadoPorNombre: reportadoPorNombre,
        empresaId: empresaId,
      );

      debugPrint('✅ CaducidadesBloc: Incidencia registrada exitosamente');
      emit(
        CaducidadesState.accionExitosa(
          mensaje: 'Incidencia registrada correctamente',
          vehiculoId: vehiculoId,
        ),
      );
    } catch (e) {
      debugPrint('❌ CaducidadesBloc: Error al registrar incidencia - $e');
      emit(
        CaducidadesState.error(
          mensaje: 'Error al registrar incidencia: ${e.toString()}',
          vehiculoId: vehiculoId,
        ),
      );
    }
  }

  Future<void> _onResolverAlerta(
    Emitter<CaducidadesState> emit,
    String alertaId,
    String usuarioId,
  ) async {
    debugPrint('✅ CaducidadesBloc: Resolviendo alerta $alertaId...');

    try {
      await _repository.resolverAlerta(alertaId: alertaId, usuarioId: usuarioId);

      // Recargar datos después de resolver
      state.maybeWhen(
        loaded: (
          items,
          alertas,
          vehiculoId,
          filtroActual,
          total,
          ok,
          proximos,
          criticos,
          caducados,
          isRefreshing,
        ) {
          _cargarDatos(emit, vehiculoId, filtroActual);
        },
        orElse: () {},
      );
    } catch (e) {
      debugPrint('❌ CaducidadesBloc: Error al resolver alerta - $e');
    }
  }

  Future<void> _onActualizarItem(
    Emitter<CaducidadesState> emit,
    String itemId,
    int cantidadActual,
    DateTime? fechaCaducidad,
    String? lote,
    String? ubicacion,
    String? observaciones,
  ) async {
    debugPrint('📝 CaducidadesBloc: Actualizando item $itemId...');

    try {
      // Capturar datos ANTES de cambiar el estado
      String? vehiculoIdCapturado;
      StockVehiculoEntity? currentItem;

      state.maybeWhen(
        loaded: (items, alertas, vehiculoId, filtroActual, total, ok, proximos, criticos, caducados, isRefreshing) {
          vehiculoIdCapturado = vehiculoId;
          try {
            currentItem = items.firstWhere((item) => item.id == itemId);
          } catch (e) {
            debugPrint('⚠️ Item $itemId no encontrado en la lista');
          }
        },
        orElse: () {},
      );

      if (currentItem == null || vehiculoIdCapturado == null) {
        debugPrint('❌ CaducidadesBloc: Item o vehículoId no disponible');
        emit(
          CaducidadesState.error(
            mensaje: 'No se pudo obtener la información del item',
            vehiculoId: vehiculoIdCapturado ?? '',
          ),
        );
        return;
      }

      // Ahora sí, emitir estado de procesando
      emit(const CaducidadesState.procesando(mensaje: 'Actualizando item...'));

      // Crear item actualizado
      final itemActualizado = StockVehiculoEntity(
        id: currentItem!.id,
        vehiculoId: currentItem!.vehiculoId,
        productoId: currentItem!.productoId,
        cantidadActual: cantidadActual,
        cantidadMinima: currentItem!.cantidadMinima,
        fechaCaducidad: fechaCaducidad,
        lote: lote,
        ubicacion: ubicacion,
        observaciones: observaciones,
        updatedAt: DateTime.now(),
        updatedBy: null,
        matricula: currentItem!.matricula,
        tipoVehiculo: currentItem!.tipoVehiculo,
        productoNombre: currentItem!.productoNombre,
        nombreComercial: currentItem!.nombreComercial,
        categoriaCodigo: currentItem!.categoriaCodigo,
        categoriaNombre: currentItem!.categoriaNombre,
        estadoStock: currentItem!.estadoStock,
        estadoCaducidad: currentItem!.estadoCaducidad,
      );

      await _repository.actualizarItem(stock: itemActualizado);

      debugPrint('✅ CaducidadesBloc: Item actualizado exitosamente');

      emit(
        CaducidadesState.accionExitosa(
          mensaje: 'Item actualizado correctamente',
          vehiculoId: vehiculoIdCapturado!,
        ),
      );
    } catch (e) {
      debugPrint('❌ CaducidadesBloc: Error al actualizar item - $e');

      // Intentar obtener vehiculoId del estado actual para el mensaje de error
      String? vehiculoIdError;
      state.maybeWhen(
        loaded: (items, alertas, vehiculoId, filtroActual, total, ok, proximos, criticos, caducados, isRefreshing) {
          vehiculoIdError = vehiculoId;
        },
        orElse: () {},
      );

      emit(
        CaducidadesState.error(
          mensaje: 'Error al actualizar item: ${e.toString()}',
          vehiculoId: vehiculoIdError ?? '',
        ),
      );
    }
  }

  Future<void> _onEliminarItem(
    Emitter<CaducidadesState> emit,
    String itemId,
    String vehiculoId,
    String productoNombre,
    String usuarioId,
  ) async {
    debugPrint('🗑️ CaducidadesBloc: Eliminando item $productoNombre...');

    try {
      // Capturar productoId ANTES de cambiar el estado
      StockVehiculoEntity? currentItem;

      state.maybeWhen(
        loaded: (items, alertas, vehiculoId, filtroActual, total, ok, proximos, criticos, caducados, isRefreshing) {
          try {
            currentItem = items.firstWhere((item) => item.id == itemId);
          } catch (e) {
            debugPrint('⚠️ Item $itemId no encontrado en la lista');
          }
        },
        orElse: () {},
      );

      if (currentItem == null) {
        debugPrint('❌ CaducidadesBloc: Item no disponible');
        emit(
          CaducidadesState.error(
            mensaje: 'No se pudo obtener la información del item',
            vehiculoId: vehiculoId,
          ),
        );
        return;
      }

      // Ahora sí, emitir estado de procesando
      emit(CaducidadesState.procesando(mensaje: 'Eliminando $productoNombre...'));

      await _repository.eliminarItem(
        vehiculoId: vehiculoId,
        productoId: currentItem!.productoId,
        usuarioId: usuarioId,
        motivo: 'Eliminación manual de $productoNombre',
      );

      debugPrint('✅ CaducidadesBloc: Item eliminado exitosamente');
      emit(
        CaducidadesState.accionExitosa(
          mensaje: '$productoNombre eliminado correctamente',
          vehiculoId: vehiculoId,
        ),
      );
    } catch (e) {
      debugPrint('❌ CaducidadesBloc: Error al eliminar item - $e');
      emit(
        CaducidadesState.error(
          mensaje: 'Error al eliminar item: ${e.toString()}',
          vehiculoId: vehiculoId,
        ),
      );
    }
  }

  Future<void> _onRefrescar(Emitter<CaducidadesState> emit) async {
    state.maybeWhen(
      loaded: (
        items,
        alertas,
        vehiculoId,
        filtroActual,
        total,
        ok,
        proximos,
        criticos,
        caducados,
        isRefreshing,
      ) {
        debugPrint('🔄 CaducidadesBloc: Refrescando datos...');
        _cargarDatos(emit, vehiculoId, filtroActual, isRefreshing: true);
      },
      orElse: () {},
    );
  }

  // ===== Método auxiliar para cargar datos =====

  Future<void> _cargarDatos(
    Emitter<CaducidadesState> emit,
    String vehiculoId,
    String? filtro, {
    bool isRefreshing = false,
  }) async {
    try {
      if (!isRefreshing) {
        emit(const CaducidadesState.loading());
      }

      // Cargar stock con caducidades
      final items = await _repository.getStockConCaducidades(
        vehiculoId: vehiculoId,
        estadoCaducidad: filtro,
      );

      // Cargar alertas activas
      final alertas = await _repository.getAlertasCaducidad(
        vehiculoId: vehiculoId,
      );

      // Calcular estadísticas
      final stats = _calcularEstadisticas(items);

      debugPrint('✅ CaducidadesBloc: Datos cargados');
      debugPrint('   - Total items: ${stats['total']}');
      debugPrint('   - OK: ${stats['ok']}');
      debugPrint('   - Próximos: ${stats['proximos']}');
      debugPrint('   - Críticos: ${stats['criticos']}');
      debugPrint('   - Caducados: ${stats['caducados']}');
      debugPrint('   - Alertas activas: ${alertas.length}');

      // Debug: Mostrar estados de cada item
      if (items.isNotEmpty) {
        debugPrint('📊 Estados de items:');
        for (final item in items) {
          debugPrint('   - ${item.productoNombre}: estado="${item.estadoCaducidad}", fecha=${item.fechaCaducidad}');
        }
      }

      emit(
        CaducidadesState.loaded(
          items: items,
          alertas: alertas,
          vehiculoId: vehiculoId,
          filtroActual: filtro,
          totalItems: stats['total']!,
          itemsOk: stats['ok']!,
          itemsProximos: stats['proximos']!,
          itemsCriticos: stats['criticos']!,
          itemsCaducados: stats['caducados']!,
          isRefreshing: false,
        ),
      );
    } catch (e) {
      debugPrint('❌ CaducidadesBloc: Error al cargar datos - $e');
      emit(
        CaducidadesState.error(
          mensaje: 'Error al cargar caducidades: ${e.toString()}',
          vehiculoId: vehiculoId,
        ),
      );
    }
  }

  Map<String, int> _calcularEstadisticas(List<StockVehiculoEntity> items) {
    var total = 0;
    var ok = 0;
    var proximos = 0;
    var criticos = 0;
    var caducados = 0;

    for (final item in items) {
      total++;
      switch (item.estadoCaducidad) {
        case 'ok':
          ok++;
          break;
        case 'proximo':
          proximos++;
          break;
        case 'critico':
          criticos++;
          break;
        case 'caducado':
          caducados++;
          break;
      }
    }

    return {
      'total': total,
      'ok': ok,
      'proximos': proximos,
      'criticos': criticos,
      'caducados': caducados,
    };
  }
}
