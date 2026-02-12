import 'dart:async';

// Imports del core datasource (sistema nuevo de almacén - importación directa)
import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart' hide MovimientoStockEntity, StockDataSource, StockDataSourceFactory;
import 'package:ambutrack_web/features/almacen/domain/repositories/producto_repository.dart';
import 'package:ambutrack_web/features/almacen/domain/repositories/stock_repository.dart';
import 'package:ambutrack_web/features/almacen/presentation/bloc/stock/stock_event.dart';
import 'package:ambutrack_web/features/almacen/presentation/bloc/stock/stock_state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

/// BLoC para gestionar el estado de Stock (sistema simplificado)
@injectable
class StockBloc extends Bloc<StockEvent, StockState> {
  StockBloc(
    this._repository,
    this._productoRepository,
  ) : super(const StockInitial()) {
    on<StockLoadAllRequested>(_onLoadAllRequested);
    on<StockLoadByProductoRequested>(_onLoadByProductoRequested);
    on<StockLoadByAlmacenRequested>(_onLoadByAlmacenRequested);
    on<StockLoadByVehiculoRequested>(_onLoadByVehiculoRequested);
    on<StockLoadBajoRequested>(_onLoadBajoRequested);
    on<StockLoadByTipoProductoRequested>(_onLoadByTipoProductoRequested);
    on<StockCreateRequested>(_onCreateRequested);
    on<StockUpdateRequested>(_onUpdateRequested);
    on<StockDeleteRequested>(_onDeleteRequested);
    on<StockAjustarCantidadRequested>(_onAjustarCantidadRequested);
    on<StockTransferirAVehiculoRequested>(_onTransferirAVehiculoRequested);
    on<StockTransferirEntreAlmacenesRequested>(_onTransferirEntreAlmacenesRequested);
    on<StockWatchAllRequested>(_onWatchAllRequested);
    on<StockWatchByAlmacenRequested>(_onWatchByAlmacenRequested);
    on<StockWatchByVehiculoRequested>(_onWatchByVehiculoRequested);
    on<StockProximoACaducarLoadRequested>(_onProximoACaducarRequested);
  }

  final StockRepository _repository;
  final ProductoRepository _productoRepository;
  StreamSubscription<List<StockEntity>>? _stockSubscription;

  @override
  Future<void> close() {
    _stockSubscription?.cancel();
    return super.close();
  }

  /// Maneja la carga de todo el stock
  Future<void> _onLoadAllRequested(
    StockLoadAllRequested event,
    Emitter<StockState> emit,
  ) async {
    debugPrint('🔄 StockBloc: Cargando todo el stock...');
    emit(const StockLoading());

    try {
      final List<StockEntity> stocks = await _repository.getAll();
      debugPrint('✅ StockBloc: ${stocks.length} registros de stock cargados');
      emit(StockLoaded(stocks));
    } catch (e, stackTrace) {
      debugPrint('❌ StockBloc: Error al cargar stock: $e');
      debugPrint('Stack trace: $stackTrace');
      emit(StockError('Error al cargar stock: $e'));
    }
  }

  /// Maneja la carga de stock por producto
  Future<void> _onLoadByProductoRequested(
    StockLoadByProductoRequested event,
    Emitter<StockState> emit,
  ) async {
    debugPrint('🔄 StockBloc: Cargando stock del producto ${event.productoId}...');
    emit(const StockLoading());

    try {
      final List<StockEntity> stocks = await _repository.getByProducto(event.productoId);
      debugPrint('✅ StockBloc: ${stocks.length} registros de stock del producto cargados');
      emit(StockLoaded(stocks));
    } catch (e, stackTrace) {
      debugPrint('❌ StockBloc: Error al cargar stock por producto: $e');
      debugPrint('Stack trace: $stackTrace');
      emit(StockError('Error al cargar stock por producto: $e'));
    }
  }

  /// Maneja la carga de stock por almacén
  Future<void> _onLoadByAlmacenRequested(
    StockLoadByAlmacenRequested event,
    Emitter<StockState> emit,
  ) async {
    debugPrint('🔄 StockBloc: Cargando stock del almacén ${event.almacenId}...');
    emit(const StockLoading());

    try {
      final List<StockEntity> stocks = await _repository.getByAlmacen(event.almacenId);
      debugPrint('✅ StockBloc: ${stocks.length} registros de stock del almacén cargados');
      emit(StockLoaded(stocks));
    } catch (e, stackTrace) {
      debugPrint('❌ StockBloc: Error al cargar stock por almacén: $e');
      debugPrint('Stack trace: $stackTrace');
      emit(StockError('Error al cargar stock por almacén: $e'));
    }
  }

  /// Maneja la carga de stock por vehículo
  Future<void> _onLoadByVehiculoRequested(
    StockLoadByVehiculoRequested event,
    Emitter<StockState> emit,
  ) async {
    debugPrint('🔄 StockBloc: Cargando stock del vehículo ${event.vehiculoId}...');
    emit(const StockLoading());

    try {
      final List<StockEntity> stocks = await _repository.getByVehiculo(event.vehiculoId);
      debugPrint('✅ StockBloc: ${stocks.length} registros de stock del vehículo cargados');
      emit(StockLoaded(stocks));
    } catch (e, stackTrace) {
      debugPrint('❌ StockBloc: Error al cargar stock por vehículo: $e');
      debugPrint('Stack trace: $stackTrace');
      emit(StockError('Error al cargar stock por vehículo: $e'));
    }
  }

  /// Maneja la carga de stock bajo
  Future<void> _onLoadBajoRequested(
    StockLoadBajoRequested event,
    Emitter<StockState> emit,
  ) async {
    debugPrint('⚠️ StockBloc: Cargando stock bajo del almacén: ${event.almacenId}');
    emit(const StockLoading());

    try {
      final List<StockEntity> stocks = await _repository.getStockBajo(event.almacenId);
      debugPrint('✅ StockBloc: ${stocks.length} productos con stock bajo cargados');
      emit(StockLoaded(stocks));
    } catch (e, stackTrace) {
      debugPrint('❌ StockBloc: Error al cargar stock bajo: $e');
      debugPrint('Stack trace: $stackTrace');
      emit(StockError('Error al cargar stock bajo: $e'));
    }
  }

  /// Maneja la creación de stock
  Future<void> _onCreateRequested(
    StockCreateRequested event,
    Emitter<StockState> emit,
  ) async {
    debugPrint('➕ StockBloc: Creando nuevo registro de stock...');
    emit(const StockOperationInProgress());

    try {
      await _repository.create(event.stock);
      debugPrint('✅ StockBloc: Stock creado exitosamente');
      emit(const StockOperationSuccess('Stock creado exitosamente'));

      // Recargar lista después de crear
      add(const StockLoadAllRequested());
    } catch (e, stackTrace) {
      debugPrint('❌ StockBloc: Error al crear stock: $e');
      debugPrint('Stack trace: $stackTrace');
      emit(StockError('Error al crear stock: $e'));
    }
  }

  /// Maneja la actualización de stock
  Future<void> _onUpdateRequested(
    StockUpdateRequested event,
    Emitter<StockState> emit,
  ) async {
    debugPrint('✏️ StockBloc: Actualizando stock...');
    emit(const StockOperationInProgress());

    try {
      await _repository.update(event.stock);
      debugPrint('✅ StockBloc: Stock actualizado exitosamente');
      emit(const StockOperationSuccess('Stock actualizado exitosamente'));

      // Recargar lista después de actualizar
      add(const StockLoadAllRequested());
    } catch (e, stackTrace) {
      debugPrint('❌ StockBloc: Error al actualizar stock: $e');
      debugPrint('Stack trace: $stackTrace');
      emit(StockError('Error al actualizar stock: $e'));
    }
  }

  /// Maneja la eliminación de stock
  Future<void> _onDeleteRequested(
    StockDeleteRequested event,
    Emitter<StockState> emit,
  ) async {
    debugPrint('🗑️ StockBloc: Eliminando stock con id ${event.id}...');
    emit(const StockOperationInProgress());

    try {
      await _repository.delete(event.id);
      debugPrint('✅ StockBloc: Stock eliminado exitosamente');
      emit(const StockOperationSuccess('Stock eliminado exitosamente'));

      // Recargar lista después de eliminar
      add(const StockLoadAllRequested());
    } catch (e, stackTrace) {
      debugPrint('❌ StockBloc: Error al eliminar stock: $e');
      debugPrint('Stack trace: $stackTrace');
      emit(StockError('Error al eliminar stock: $e'));
    }
  }

  /// Maneja el ajuste de cantidad de stock
  Future<void> _onAjustarCantidadRequested(
    StockAjustarCantidadRequested event,
    Emitter<StockState> emit,
  ) async {
    debugPrint('🔧 StockBloc: Ajustando cantidad de stock ${event.stockId}: ${event.cantidad}...');
    emit(const StockOperationInProgress());

    try {
      await _repository.ajustarCantidad(
        stockId: event.stockId,
        nuevaCantidad: event.cantidad,
        motivo: event.motivo,
      );
      debugPrint('✅ StockBloc: Cantidad ajustada exitosamente');
      emit(const StockOperationSuccess('Cantidad de stock ajustada exitosamente'));

      // Recargar lista después de ajustar
      add(const StockLoadAllRequested());
    } catch (e, stackTrace) {
      debugPrint('❌ StockBloc: Error al ajustar cantidad: $e');
      debugPrint('Stack trace: $stackTrace');
      emit(StockError('Error al ajustar cantidad: $e'));
    }
  }

  /// Maneja la suscripción a todo el stock en tiempo real
  Future<void> _onWatchAllRequested(
    StockWatchAllRequested event,
    Emitter<StockState> emit,
  ) async {
    debugPrint('👁️ StockBloc: Iniciando watch de todo el stock...');
    emit(const StockLoading());

    try {
      await _stockSubscription?.cancel();

      _stockSubscription = _repository.watchAll().listen(
        (List<StockEntity> stocks) {
          debugPrint('🔄 StockBloc: Recibidos ${stocks.length} registros del stream');
          emit(StockLoaded(stocks));
        },
        onError: (Object error, StackTrace stackTrace) {
          debugPrint('❌ StockBloc: Error en stream: $error');
          debugPrint('Stack trace: $stackTrace');
          emit(StockError('Error en tiempo real: $error'));
        },
      );
    } catch (e, stackTrace) {
      debugPrint('❌ StockBloc: Error al iniciar watch: $e');
      debugPrint('Stack trace: $stackTrace');
      emit(StockError('Error al iniciar suscripción: $e'));
    }
  }

  /// Maneja la suscripción a stock por almacén en tiempo real
  Future<void> _onWatchByAlmacenRequested(
    StockWatchByAlmacenRequested event,
    Emitter<StockState> emit,
  ) async {
    debugPrint('👁️ StockBloc: Iniciando watch del almacén ${event.almacenId}...');
    emit(const StockLoading());

    try {
      await _stockSubscription?.cancel();

      _stockSubscription = _repository.watchByAlmacen(event.almacenId).listen(
        (List<StockEntity> stocks) {
          debugPrint('🔄 StockBloc: Recibidos ${stocks.length} registros del almacén ${event.almacenId} del stream');
          emit(StockLoaded(stocks));
        },
        onError: (Object error, StackTrace stackTrace) {
          debugPrint('❌ StockBloc: Error en stream por almacén: $error');
          debugPrint('Stack trace: $stackTrace');
          emit(StockError('Error en tiempo real: $error'));
        },
      );
    } catch (e, stackTrace) {
      debugPrint('❌ StockBloc: Error al iniciar watch por almacén: $e');
      debugPrint('Stack trace: $stackTrace');
      emit(StockError('Error al iniciar suscripción: $e'));
    }
  }

  /// Maneja la suscripción a stock por vehículo en tiempo real
  Future<void> _onWatchByVehiculoRequested(
    StockWatchByVehiculoRequested event,
    Emitter<StockState> emit,
  ) async {
    debugPrint('👁️ StockBloc: Iniciando watch del vehículo ${event.vehiculoId}...');
    emit(const StockLoading());

    try {
      await _stockSubscription?.cancel();

      _stockSubscription = _repository.watchByVehiculo(event.vehiculoId).listen(
        (List<StockEntity> stocks) {
          debugPrint('🔄 StockBloc: Recibidos ${stocks.length} registros del vehículo ${event.vehiculoId} del stream');
          emit(StockLoaded(stocks));
        },
        onError: (Object error, StackTrace stackTrace) {
          debugPrint('❌ StockBloc: Error en stream por vehículo: $error');
          debugPrint('Stack trace: $stackTrace');
          emit(StockError('Error en tiempo real: $error'));
        },
      );
    } catch (e, stackTrace) {
      debugPrint('❌ StockBloc: Error al iniciar watch por vehículo: $e');
      debugPrint('Stack trace: $stackTrace');
      emit(StockError('Error al iniciar suscripción: $e'));
    }
  }

  /// Handler para cargar stock próximo a caducar
  Future<void> _onProximoACaducarRequested(
    StockProximoACaducarLoadRequested event,
    Emitter<StockState> emit,
  ) async {
    debugPrint('📦 StockBloc: Solicitando stock próximo a caducar (${event.diasAntes} días)...');
    emit(const StockLoading());

    try {
      final List<StockEntity> stocks = await _repository.getProximoACaducar(diasAntes: event.diasAntes);
      debugPrint('✅ StockBloc: ${stocks.length} registros próximos a caducar obtenidos');
      emit(StockLoaded(stocks));
    } catch (e, stackTrace) {
      debugPrint('❌ StockBloc: Error al obtener stock próximo a caducar: $e');
      debugPrint('Stack trace: $stackTrace');
      emit(StockError('Error al cargar stock próximo a caducar: $e'));
    }
  }

  /// Maneja la carga de stock filtrado por categoría de producto
  Future<void> _onLoadByTipoProductoRequested(
    StockLoadByTipoProductoRequested event,
    Emitter<StockState> emit,
  ) async {
    debugPrint('🔄 StockBloc: Cargando stock del almacén ${event.almacenId} - Categoría: ${event.categoria.label}...');
    emit(const StockLoading());

    try {
      // 1. Obtener todo el stock del almacén
      final List<StockEntity> stockAlmacen = await _repository.getByAlmacen(event.almacenId);
      debugPrint('📦 StockBloc: ${stockAlmacen.length} registros de stock en almacén');

      // 2. Obtener productos de la categoría solicitada
      final List<ProductoEntity> productosCategoria = await _productoRepository.getByCategoria(event.categoria);
      debugPrint('📦 StockBloc: ${productosCategoria.length} productos en categoría ${event.categoria.label}');

      // 3. Crear Set de IDs de productos para filtrado eficiente
      final Set<String> productosIds = productosCategoria.map((ProductoEntity p) => p.id).toSet();

      // 4. Filtrar stock por productos de la categoría
      final List<StockEntity> stockFiltrado = stockAlmacen.where((StockEntity stock) => productosIds.contains(stock.idProducto)).toList();

      debugPrint('✅ StockBloc: ${stockFiltrado.length} registros de stock filtrados para categoría ${event.categoria.label}');
      emit(StockLoaded(stockFiltrado));
    } catch (e, stackTrace) {
      debugPrint('❌ StockBloc: Error al cargar stock por categoría: $e');
      debugPrint('Stack trace: $stackTrace');
      emit(StockError('Error al cargar stock por categoría: $e'));
    }
  }

  /// Maneja la transferencia de stock a un vehículo
  Future<void> _onTransferirAVehiculoRequested(
    StockTransferirAVehiculoRequested event,
    Emitter<StockState> emit,
  ) async {
    debugPrint('🔄 StockBloc: Transfiriendo stock a vehículo...');
    debugPrint('   - Stock ID: ${event.stockId}');
    debugPrint('   - Vehículo ID: ${event.vehiculoId}');
    debugPrint('   - Cantidad: ${event.cantidad}');

    // Emitir loading pero mantener los datos actuales
    if (state is StockLoaded) {
      emit(StockLoaded((state as StockLoaded).stocks, isLoading: true));
    } else {
      emit(const StockLoading());
    }

    try {
      await _repository.transferirAVehiculo(
        idStock: event.stockId,
        vehiculoId: event.vehiculoId,
        cantidad: event.cantidad,
        motivo: event.motivo,
        lote: event.lote,
        fechaCaducidad: event.fechaCaducidad,
      );

      debugPrint('✅ StockBloc: Transferencia a vehículo exitosa');

      // Recargar el stock para reflejar los cambios
      final List<StockEntity> stocks = await _repository.getAll();
      emit(StockLoaded(stocks));
    } catch (e, stackTrace) {
      debugPrint('❌ StockBloc: Error al transferir a vehículo: $e');
      debugPrint('Stack trace: $stackTrace');

      // Mantener el estado anterior si existe
      if (state is StockLoaded) {
        emit(StockLoaded((state as StockLoaded).stocks));
      }

      emit(StockError('Error al transferir stock: $e'));
    }
  }

  /// Maneja la transferencia de stock entre almacenes
  Future<void> _onTransferirEntreAlmacenesRequested(
    StockTransferirEntreAlmacenesRequested event,
    Emitter<StockState> emit,
  ) async {
    debugPrint('🔄 StockBloc: Transfiriendo stock entre almacenes...');
    debugPrint('   - Stock origen ID: ${event.stockOrigenId}');
    debugPrint('   - Almacén destino ID: ${event.almacenDestinoId}');
    debugPrint('   - Cantidad: ${event.cantidad}');

    // Emitir loading pero mantener los datos actuales
    if (state is StockLoaded) {
      emit(StockLoaded((state as StockLoaded).stocks, isLoading: true));
    } else {
      emit(const StockLoading());
    }

    try {
      await _repository.transferirEntreAlmacenes(
        idStockOrigen: event.stockOrigenId,
        almacenDestinoId: event.almacenDestinoId,
        cantidad: event.cantidad,
        motivo: event.motivo,
      );

      debugPrint('✅ StockBloc: Transferencia entre almacenes exitosa');

      // Recargar el stock para reflejar los cambios
      final List<StockEntity> stocks = await _repository.getAll();
      emit(StockLoaded(stocks));
    } catch (e, stackTrace) {
      debugPrint('❌ StockBloc: Error al transferir entre almacenes: $e');
      debugPrint('Stack trace: $stackTrace');

      // Mantener el estado anterior si existe
      if (state is StockLoaded) {
        emit(StockLoaded((state as StockLoaded).stocks));
      }

      emit(StockError('Error al transferir stock: $e'));
    }
  }
}
