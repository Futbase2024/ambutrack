import 'dart:async';

import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/features/vehiculos/domain/repositories/consumo_combustible_repository.dart';
import 'package:ambutrack_web/features/vehiculos/domain/repositories/vehiculo_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import 'consumo_combustible_event.dart';
import 'consumo_combustible_state.dart';

/// BLoC para gestión de consumo de combustible
@injectable
class ConsumoCombustibleBloc
    extends Bloc<ConsumoCombustibleEvent, ConsumoCombustibleState> {
  ConsumoCombustibleBloc(
    this._consumoRepository,
    this._vehiculosRepository,
  ) : super(const ConsumoCombustibleState.initial()) {
    on<ConsumoCombustibleEvent>(_onEvent);
  }

  final ConsumoCombustibleRepository _consumoRepository;
  final VehiculoRepository _vehiculosRepository;

  List<ConsumoCombustibleEntity> _allRegistros = <ConsumoCombustibleEntity>[];
  List<VehiculoEntity> _vehiculos = <VehiculoEntity>[];
  StreamSubscription<List<ConsumoCombustibleEntity>>? _streamSubscription;

  String? _filtroVehiculoId;
  DateTime? _filtroFechaInicio;
  DateTime? _filtroFechaFin;

  Future<void> _onEvent(
    ConsumoCombustibleEvent event,
    Emitter<ConsumoCombustibleState> emit,
  ) async {
    await event.when<Future<void>>(
      started: () => _onStarted(emit),
      loadRegistros: () => _onLoadRegistros(emit),
      loadByVehiculo: (String vehiculoId) =>
          _onLoadByVehiculo(emit, vehiculoId: vehiculoId),
      loadByRangoFechas: (DateTime fechaInicio, DateTime fechaFin) =>
          _onLoadByRangoFechas(emit, fechaInicio: fechaInicio, fechaFin: fechaFin),
      createRegistro: (ConsumoCombustibleEntity consumo) =>
          _onCreateRegistro(emit, consumo: consumo),
      updateRegistro: (ConsumoCombustibleEntity consumo) =>
          _onUpdateRegistro(emit, consumo: consumo),
      deleteRegistro: (String id) => _onDeleteRegistro(emit, id: id),
      filterByVehiculo: (String? vehiculoId) =>
          _onFilterByVehiculo(emit, vehiculoId: vehiculoId),
      filterByFecha: (DateTime? fechaInicio, DateTime? fechaFin) =>
          _onFilterByFecha(emit, fechaInicio: fechaInicio, fechaFin: fechaFin),
      clearFilters: () => _onClearFilters(emit),
      changePage: (int page) => _onChangePage(emit, page: page),
      subscribeToVehiculo: (String vehiculoId) =>
          _onSubscribeToVehiculo(emit, vehiculoId: vehiculoId),
      unsubscribe: () => _onUnsubscribe(emit),
    );
  }

  Future<void> _onStarted(Emitter<ConsumoCombustibleState> emit) async {
    debugPrint('⛽ ConsumoCombustibleBloc: Iniciando...');
    emit(const ConsumoCombustibleState.loading());
    await _loadVehiculos(emit);
    await _loadAndEmit(emit);
  }

  Future<void> _onLoadRegistros(Emitter<ConsumoCombustibleState> emit) async {
    debugPrint('⛽ ConsumoCombustibleBloc: Recargando registros...');
    emit(const ConsumoCombustibleState.loading());
    await _loadAndEmit(emit);
  }

  Future<void> _onLoadByVehiculo(
    Emitter<ConsumoCombustibleState> emit, {
    required String vehiculoId,
  }) async {
    debugPrint('⛽ ConsumoCombustibleBloc: Cargando registros del vehículo: $vehiculoId');
    emit(const ConsumoCombustibleState.loading());

    try {
      final List<ConsumoCombustibleEntity> registros =
          await _consumoRepository.getByVehiculo(vehiculoId);
      _allRegistros = registros;
      _filtroVehiculoId = vehiculoId;

      _emitFiltered(emit);
    } catch (e) {
      debugPrint('⛽ ConsumoCombustibleBloc: ❌ Error: $e');
      emit(ConsumoCombustibleState.error(e.toString()));
    }
  }

  Future<void> _onLoadByRangoFechas(
    Emitter<ConsumoCombustibleState> emit, {
    required DateTime fechaInicio,
    required DateTime fechaFin,
  }) async {
    debugPrint(
        '⛽ ConsumoCombustibleBloc: Cargando registros por rango: $fechaInicio - $fechaFin');
    emit(const ConsumoCombustibleState.loading());

    try {
      final List<ConsumoCombustibleEntity> registros = await _consumoRepository.getByRangoFechas(
        fechaInicio,
        fechaFin,
      );
      _allRegistros = registros;
      _filtroFechaInicio = fechaInicio;
      _filtroFechaFin = fechaFin;

      _emitFiltered(emit);
    } catch (e) {
      debugPrint('⛽ ConsumoCombustibleBloc: ❌ Error: $e');
      emit(ConsumoCombustibleState.error(e.toString()));
    }
  }

  Future<void> _onCreateRegistro(
    Emitter<ConsumoCombustibleState> emit, {
    required ConsumoCombustibleEntity consumo,
  }) async {
    debugPrint(
        '⛽ ConsumoCombustibleBloc: Creando registro para vehículo: ${consumo.vehiculoId}');
    try {
      await _consumoRepository.create(consumo);
      debugPrint('⛽ ConsumoCombustibleBloc: ✅ Registro creado exitosamente');
      await _loadAndEmit(emit);
    } catch (e) {
      debugPrint('⛽ ConsumoCombustibleBloc: ❌ Error al crear: $e');
      emit(ConsumoCombustibleState.error(e.toString()));
    }
  }

  Future<void> _onUpdateRegistro(
    Emitter<ConsumoCombustibleState> emit, {
    required ConsumoCombustibleEntity consumo,
  }) async {
    debugPrint(
        '⛽ ConsumoCombustibleBloc: Actualizando registro ID: ${consumo.id}');
    try {
      await _consumoRepository.update(consumo);
      debugPrint('⛽ ConsumoCombustibleBloc: ✅ Registro actualizado exitosamente');
      await _loadAndEmit(emit);
    } catch (e) {
      debugPrint('⛽ ConsumoCombustibleBloc: ❌ Error al actualizar: $e');
      emit(ConsumoCombustibleState.error(e.toString()));
    }
  }

  Future<void> _onDeleteRegistro(
    Emitter<ConsumoCombustibleState> emit, {
    required String id,
  }) async {
    debugPrint('⛽ ConsumoCombustibleBloc: Eliminando registro ID: $id');
    try {
      await _consumoRepository.delete(id);
      debugPrint('⛽ ConsumoCombustibleBloc: ✅ Registro eliminado exitosamente');
      await _loadAndEmit(emit);
    } catch (e) {
      debugPrint('⛽ ConsumoCombustibleBloc: ❌ Error al eliminar: $e');
      emit(ConsumoCombustibleState.error(e.toString()));
    }
  }

  Future<void> _onFilterByVehiculo(
    Emitter<ConsumoCombustibleState> emit, {
    required String? vehiculoId,
  }) async {
    debugPrint('⛽ ConsumoCombustibleBloc: Filtrando por vehículo: $vehiculoId');
    _filtroVehiculoId = vehiculoId;
    emit(const ConsumoCombustibleState.loading());
    _emitFiltered(emit);
  }

  Future<void> _onFilterByFecha(
    Emitter<ConsumoCombustibleState> emit, {
    required DateTime? fechaInicio,
    required DateTime? fechaFin,
  }) async {
    debugPrint(
        '⛽ ConsumoCombustibleBloc: Filtrando por fechas: $fechaInicio - $fechaFin');
    _filtroFechaInicio = fechaInicio;
    _filtroFechaFin = fechaFin;
    emit(const ConsumoCombustibleState.loading());
    _emitFiltered(emit);
  }

  Future<void> _onClearFilters(Emitter<ConsumoCombustibleState> emit) async {
    debugPrint('⛽ ConsumoCombustibleBloc: Limpiando filtros');
    _filtroVehiculoId = null;
    _filtroFechaInicio = null;
    _filtroFechaFin = null;
    emit(const ConsumoCombustibleState.loading());
    await _loadAndEmit(emit);
  }

  /// La paginación se hace en la vista (client-side) sobre el listado completo:
  /// el evento se mantiene por compatibilidad y solo reemite el estado actual.
  Future<void> _onChangePage(
    Emitter<ConsumoCombustibleState> emit, {
    required int page,
  }) async {
    debugPrint('⛽ ConsumoCombustibleBloc: changePage($page) ignorado (paginación en la vista)');
    _emitFiltered(emit);
  }

  Future<void> _onSubscribeToVehiculo(
    Emitter<ConsumoCombustibleState> emit, {
    required String vehiculoId,
  }) async {
    debugPrint(
        '⛽ ConsumoCombustibleBloc: Suscribiendo al stream del vehículo: $vehiculoId');

    // Cancelar suscripción anterior si existe
    await _streamSubscription?.cancel();

    _streamSubscription =
        _consumoRepository.watchByVehiculo(vehiculoId).listen(
      (List<ConsumoCombustibleEntity> registros) {
        debugPrint(
            '⛽ ConsumoCombustibleBloc: 📢 Stream actualizado: ${registros.length} registros');
        _allRegistros = registros;
        // Emitir estado sin recargar desde el repositorio
        _emitFiltered(emit);
      },
      onError: (Object error) {
        debugPrint('⛽ ConsumoCombustibleBloc: ❌ Error en stream: $error');
        emit(ConsumoCombustibleState.error(error.toString()));
      },
    );
  }

  Future<void> _onUnsubscribe(Emitter<ConsumoCombustibleState> emit) async {
    debugPrint('⛽ ConsumoCombustibleBloc: Cancelando suscripción');
    await _streamSubscription?.cancel();
    _streamSubscription = null;
  }

  Future<void> _loadAndEmit(Emitter<ConsumoCombustibleState> emit) async {
    try {
      final List<ConsumoCombustibleEntity> registros = await _consumoRepository.getAll();
      _allRegistros = registros;
      _emitFiltered(emit);
    } catch (e) {
      debugPrint('⛽ ConsumoCombustibleBloc: ❌ Error al cargar: $e');
      emit(ConsumoCombustibleState.error(e.toString()));
    }
  }

  Future<void> _loadVehiculos(Emitter<ConsumoCombustibleState> emit) async {
    try {
      final List<VehiculoEntity> vehiculos = await _vehiculosRepository.getAll();
      _vehiculos = vehiculos;
      debugPrint('⛽ ConsumoCombustibleBloc: ✅ ${vehiculos.length} vehículos cargados');
    } catch (e) {
      debugPrint('⛽ ConsumoCombustibleBloc: ❌ Error al cargar vehículos: $e');
      // No emitir error, solo log
    }
  }

  /// Registros que cumplen los filtros de vehículo y rango de fechas
  List<ConsumoCombustibleEntity> _filtered() {
    final DateTime? inicio = _filtroFechaInicio;
    final DateTime? fin = _filtroFechaFin?.add(const Duration(days: 1));
    return _allRegistros
        .where(
          (ConsumoCombustibleEntity r) =>
              (_filtroVehiculoId == null || r.vehiculoId == _filtroVehiculoId) &&
              (inicio == null || !r.fecha.isBefore(inicio)) &&
              (fin == null || r.fecha.isBefore(fin)),
        )
        .toList();
  }

  /// Emite el listado COMPLETO filtrado con sus estadísticas.
  ///
  /// `currentPage`/`totalPages` se fijan a 1: la vista pagina en cliente.
  void _emitFiltered(Emitter<ConsumoCombustibleState> emit) {
    final List<ConsumoCombustibleEntity> filtered = _filtered();
    debugPrint(
      '⛽ ConsumoCombustibleBloc: ${filtered.length} de ${_allRegistros.length} registros tras filtros',
    );
    emit(
      ConsumoCombustibleState.loaded(
        registros: filtered,
        vehiculos: _vehiculos,
        currentPage: 1,
        totalPages: 1,
        estadisticas: _calculateEstadisticas(filtered),
        filtroVehiculoId: _filtroVehiculoId,
        filtroFechaInicio: _filtroFechaInicio,
        filtroFechaFin: _filtroFechaFin,
      ),
    );
  }

  Map<String, double> _calculateEstadisticas(
    List<ConsumoCombustibleEntity> registros,
  ) {
    if (registros.isEmpty) {
      return const <String, double>{
        'consumo_promedio': 0.0,
        'km_recorridos': 0.0,
        'litros_totales': 0.0,
        'costo_total': 0.0,
      };
    }

    double litrosTotales = 0.0;
    double costoTotal = 0.0;
    double kmRecorridos = 0.0;
    double sumaConsumos = 0.0;
    int countConsumos = 0;

    for (final ConsumoCombustibleEntity registro in registros) {
      litrosTotales += registro.litros;
      costoTotal += registro.costoTotal;

      if (registro.kmRecorridosDesdeUltimo != null) {
        kmRecorridos += registro.kmRecorridosDesdeUltimo!;
      }

      if (registro.consumoL100km != null) {
        sumaConsumos += registro.consumoL100km!;
        countConsumos++;
      }
    }

    final double consumoPromedio =
        countConsumos > 0 ? sumaConsumos / countConsumos : 0.0;

    return <String, double>{
      'consumo_promedio': consumoPromedio,
      'km_recorridos': kmRecorridos,
      'litros_totales': litrosTotales,
      'costo_total': costoTotal,
    };
  }

  @override
  Future<void> close() async {
    await _streamSubscription?.cancel();
    await super.close();
  }
}
