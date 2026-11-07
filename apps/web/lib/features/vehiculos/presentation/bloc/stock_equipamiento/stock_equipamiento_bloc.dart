// ignore_for_file: implementation_imports
import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_core_datasource/src/datasources/stock/stock_contract.dart'
    as legacy_stock;
import 'package:ambutrack_core_datasource/src/datasources/stock/stock_factory.dart'
    as legacy_stock;
import 'package:ambutrack_web/features/vehiculos/domain/repositories/vehiculo_repository.dart';
import 'package:ambutrack_web/features/vehiculos/presentation/bloc/stock_equipamiento/stock_equipamiento_event.dart';
import 'package:ambutrack_web/features/vehiculos/presentation/bloc/stock_equipamiento/stock_equipamiento_state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

/// BLoC para gestionar el stock de equipamiento de todos los vehículos
@injectable
class StockEquipamientoBloc
    extends Bloc<StockEquipamientoEvent, StockEquipamientoState> {
  StockEquipamientoBloc(this._vehiculoRepository)
      : _stockDataSource = legacy_stock.StockDataSourceFactory.createSupabase(),
        super(const StockEquipamientoInitial()) {
    on<StockEquipamientoLoadRequested>(_onLoadRequested);
    on<StockEquipamientoRefreshRequested>(_onRefreshRequested);
    on<StockEquipamientoVehiculoUpdated>(_onVehiculoUpdated);
  }

  final VehiculoRepository _vehiculoRepository;
  final legacy_stock.StockDataSource _stockDataSource;

  /// Maneja la carga inicial de datos
  Future<void> _onLoadRequested(
    StockEquipamientoLoadRequested event,
    Emitter<StockEquipamientoState> emit,
  ) async {
    final DateTime startTime = DateTime.now();
    debugPrint('📦 StockEquipamientoBloc: Iniciando carga de stock...');
    emit(const StockEquipamientoLoading());

    try {
      final List<VehiculoStockResumenEntity> resumenes =
          await _cargarResumenesStock();

      final Duration elapsed = DateTime.now().difference(startTime);
      debugPrint(
          '⏱️ StockEquipamientoBloc: Carga completada en ${elapsed.inMilliseconds}ms');
      debugPrint(
          '📦 StockEquipamientoBloc: ${resumenes.length} vehículos con resumen de stock');

      emit(StockEquipamientoLoaded(vehiculos: resumenes));
    } catch (e, stackTrace) {
      debugPrint('❌ StockEquipamientoBloc: ERROR - $e');
      debugPrint('Stack trace: $stackTrace');
      emit(StockEquipamientoError(message: e.toString()));
    }
  }

  /// Maneja la recarga de datos
  Future<void> _onRefreshRequested(
    StockEquipamientoRefreshRequested event,
    Emitter<StockEquipamientoState> emit,
  ) async {
    debugPrint('🔄 StockEquipamientoBloc: Refrescando datos...');

    // Si ya tenemos datos, marcar como refrescando
    if (state is StockEquipamientoLoaded) {
      emit((state as StockEquipamientoLoaded).copyWith(isRefreshing: true));
    }

    try {
      final List<VehiculoStockResumenEntity> resumenes =
          await _cargarResumenesStock();
      emit(StockEquipamientoLoaded(vehiculos: resumenes));
    } catch (e) {
      debugPrint('❌ StockEquipamientoBloc: ERROR al refrescar - $e');
      // Mantener datos anteriores si los hay
      if (state is StockEquipamientoLoaded) {
        emit(StockEquipamientoError(
          message: e.toString(),
          previousVehiculos: (state as StockEquipamientoLoaded).vehiculos,
        ));
      } else {
        emit(StockEquipamientoError(message: e.toString()));
      }
    }
  }

  /// Maneja la actualización de un vehículo específico
  Future<void> _onVehiculoUpdated(
    StockEquipamientoVehiculoUpdated event,
    Emitter<StockEquipamientoState> emit,
  ) async {
    debugPrint(
        '🔄 StockEquipamientoBloc: Actualizando vehículo ${event.vehiculoId}...');

    if (state is! StockEquipamientoLoaded) {
      // Si no tenemos datos cargados, cargar todo
      add(const StockEquipamientoLoadRequested());
      return;
    }

    final StockEquipamientoLoaded currentState =
        state as StockEquipamientoLoaded;

    try {
      // Obtener el vehículo
      final List<VehiculoEntity> vehiculos = await _vehiculoRepository.getAll();
      final VehiculoEntity? vehiculo = vehiculos
          .cast<VehiculoEntity?>()
          .firstWhere(
            (VehiculoEntity? v) => v?.id == event.vehiculoId,
            orElse: () => null,
          );

      if (vehiculo == null) {
        debugPrint(
            '⚠️ StockEquipamientoBloc: Vehículo ${event.vehiculoId} no encontrado');
        return;
      }

      // Calcular nuevo resumen para este vehículo
      final VehiculoStockResumenEntity nuevoResumen =
          await _calcularResumenVehiculo(vehiculo);

      // Actualizar la lista
      final List<VehiculoStockResumenEntity> nuevosVehiculos =
          currentState.vehiculos.map((VehiculoStockResumenEntity v) {
        if (v.vehiculoId == event.vehiculoId) {
          return nuevoResumen;
        }
        return v;
      }).toList();

      emit(StockEquipamientoLoaded(vehiculos: nuevosVehiculos));
    } catch (e) {
      debugPrint('❌ StockEquipamientoBloc: ERROR al actualizar vehículo - $e');
    }
  }

  /// Carga los resúmenes de stock de todos los vehículos
  Future<List<VehiculoStockResumenEntity>> _cargarResumenesStock() async {
    // 1. Obtener todos los vehículos
    debugPrint('📦 Obteniendo lista de vehículos...');
    final List<VehiculoEntity> vehiculos = await _vehiculoRepository.getAll();
    debugPrint('📦 Encontrados ${vehiculos.length} vehículos');

    // 2. Cargar stock de cada vehículo en paralelo
    debugPrint('📦 Cargando stock de cada vehículo en paralelo...');
    final List<VehiculoStockResumenEntity> resumenes =
        await Future.wait<VehiculoStockResumenEntity>(
      vehiculos.map((VehiculoEntity vehiculo) async {
        return _calcularResumenVehiculo(vehiculo);
      }),
    );

    // 3. Ordenar por estado (críticos primero, luego atención, luego OK)
    resumenes.sort((VehiculoStockResumenEntity a, VehiculoStockResumenEntity b) {
      final int ordenA = _getOrdenEstado(a.estadoGeneral);
      final int ordenB = _getOrdenEstado(b.estadoGeneral);
      if (ordenA != ordenB) {
        return ordenA.compareTo(ordenB);
      }
      // Si tienen el mismo estado, ordenar por matrícula
      return a.matricula.compareTo(b.matricula);
    });

    return resumenes;
  }

  /// Calcula el resumen de stock de un vehículo
  Future<VehiculoStockResumenEntity> _calcularResumenVehiculo(
    VehiculoEntity vehiculo,
  ) async {
    try {
      final List<StockVehiculoEntity> stock =
          await _stockDataSource.getStockVehiculo(vehiculo.id);

      // Calcular estadísticas
      int itemsOk = 0;
      int itemsCaducados = 0;
      int itemsStockBajo = 0;
      int itemsSinStock = 0;
      int itemsProximosCaducar = 0;
      int itemsConAlerta = 0;

      for (final StockVehiculoEntity item in stock) {
        bool tieneProblemaStock = false;
        bool tieneProblemasCaducidad = false;

        // Estado de stock
        if (item.estadoStock == 'sin_stock') {
          itemsSinStock++;
          itemsConAlerta++;
          tieneProblemaStock = true;
        } else if (item.estadoStock == 'bajo') {
          itemsStockBajo++;
          itemsConAlerta++;
          tieneProblemaStock = true;
        }

        // Estado de caducidad
        if (item.estadoCaducidad == 'caducado') {
          itemsCaducados++;
          itemsConAlerta++;
          tieneProblemasCaducidad = true;
        } else if (item.estadoCaducidad == 'critico' ||
            item.estadoCaducidad == 'proximo') {
          itemsProximosCaducar++;
          itemsConAlerta++;
          tieneProblemasCaducidad = true;
        }

        // Contar OK: si no tiene ningún problema de stock ni de caducidad
        if (!tieneProblemaStock && !tieneProblemasCaducidad) {
          itemsOk++;
        }
      }

      return VehiculoStockResumenEntity(
        vehiculoId: vehiculo.id,
        matricula: vehiculo.matricula,
        tipoVehiculo: vehiculo.tipoVehiculo,
        marca: vehiculo.marca,
        modelo: vehiculo.modelo,
        estadoVehiculo: vehiculo.estado,
        totalItems: stock.length,
        itemsOk: itemsOk,
        itemsCaducados: itemsCaducados,
        itemsStockBajo: itemsStockBajo,
        itemsSinStock: itemsSinStock,
        itemsProximosCaducar: itemsProximosCaducar,
        itemsConAlerta: itemsConAlerta,
      );
    } catch (e) {
      debugPrint(
          '⚠️ Error al cargar stock del vehículo ${vehiculo.matricula}: $e');
      // Retornar resumen vacío en caso de error
      return VehiculoStockResumenEntity.empty(
        vehiculoId: vehiculo.id,
        matricula: vehiculo.matricula,
        tipoVehiculo: vehiculo.tipoVehiculo,
        marca: vehiculo.marca,
        modelo: vehiculo.modelo,
        estadoVehiculo: vehiculo.estado,
      );
    }
  }

  /// Obtiene el orden de prioridad de un estado (menor = más prioritario)
  int _getOrdenEstado(EstadoStockGeneral estado) {
    switch (estado) {
      case EstadoStockGeneral.critico:
        return 0;
      case EstadoStockGeneral.atencion:
        return 1;
      case EstadoStockGeneral.ok:
        return 2;
    }
  }
}
