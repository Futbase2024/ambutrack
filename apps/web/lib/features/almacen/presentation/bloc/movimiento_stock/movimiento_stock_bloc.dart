import 'dart:async';

// Imports del core datasource (sistema nuevo de almacén - importación directa)
import 'package:ambutrack_core/ambutrack_core.dart';
import 'package:ambutrack_web/features/almacen/domain/repositories/movimiento_stock_repository.dart';
import 'package:ambutrack_web/features/almacen/presentation/bloc/movimiento_stock/movimiento_stock_event.dart';
import 'package:ambutrack_web/features/almacen/presentation/bloc/movimiento_stock/movimiento_stock_state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

/// BLoC para gestionar el estado de Movimientos de Stock
@injectable
class MovimientoStockBloc extends Bloc<MovimientoStockEvent, MovimientoStockState> {
  MovimientoStockBloc(this._repository) : super(const MovimientoStockInitial()) {
    on<MovimientoStockLoadAllRequested>(_onLoadAllRequested);
    on<MovimientoStockLoadByProductoRequested>(_onLoadByProductoRequested);
    on<MovimientoStockLoadByAlmacenRequested>(_onLoadByAlmacenRequested);
    on<MovimientoStockLoadByTipoRequested>(_onLoadByTipoRequested);
    on<MovimientoStockLoadByFechasRequested>(_onLoadByFechasRequested);
    on<MovimientoStockCreateRequested>(_onCreateRequested);
    on<MovimientoStockDeleteRequested>(_onDeleteRequested);
    on<MovimientoStockWatchAllRequested>(_onWatchAllRequested);
    on<MovimientoStockWatchByAlmacenRequested>(_onWatchByAlmacenRequested);
  }

  final MovimientoStockRepository _repository;
  StreamSubscription<List<MovimientoStockEntity>>? _movimientosSubscription;

  @override
  Future<void> close() {
    _movimientosSubscription?.cancel();
    return super.close();
  }

  Future<void> _onLoadAllRequested(
    MovimientoStockLoadAllRequested event,
    Emitter<MovimientoStockState> emit,
  ) async {
    debugPrint('= MovimientoStockBloc: Cargando movimientos (limit: ${event.limit})...');
    emit(const MovimientoStockLoading());

    try {
      final List<MovimientoStockEntity> movimientos = await _repository.getAll(limit: event.limit);
      debugPrint(' MovimientoStockBloc: ${movimientos.length} movimientos cargados');
      emit(MovimientoStockLoaded(movimientos));
    } catch (e, stackTrace) {
      debugPrint('L MovimientoStockBloc: Error al cargar movimientos: $e');
      debugPrint('Stack trace: $stackTrace');
      emit(MovimientoStockError('Error al cargar movimientos: $e'));
    }
  }

  Future<void> _onLoadByProductoRequested(
    MovimientoStockLoadByProductoRequested event,
    Emitter<MovimientoStockState> emit,
  ) async {
    debugPrint('= MovimientoStockBloc: Cargando movimientos del producto ${event.productoId}...');
    emit(const MovimientoStockLoading());

    try {
      final List<MovimientoStockEntity> movimientos = await _repository.getByProducto(event.productoId);
      debugPrint(' MovimientoStockBloc: ${movimientos.length} movimientos del producto cargados');
      emit(MovimientoStockLoaded(movimientos));
    } catch (e, stackTrace) {
      debugPrint('L MovimientoStockBloc: Error al cargar movimientos por producto: $e');
      debugPrint('Stack trace: $stackTrace');
      emit(MovimientoStockError('Error al cargar movimientos por producto: $e'));
    }
  }

  Future<void> _onLoadByAlmacenRequested(
    MovimientoStockLoadByAlmacenRequested event,
    Emitter<MovimientoStockState> emit,
  ) async {
    debugPrint('= MovimientoStockBloc: Cargando movimientos del almacén ${event.almacenId}...');
    emit(const MovimientoStockLoading());

    try {
      final List<MovimientoStockEntity> movimientos = await _repository.getByAlmacen(event.almacenId);
      debugPrint(' MovimientoStockBloc: ${movimientos.length} movimientos del almacén cargados');
      emit(MovimientoStockLoaded(movimientos));
    } catch (e, stackTrace) {
      debugPrint('L MovimientoStockBloc: Error al cargar movimientos por almacén: $e');
      debugPrint('Stack trace: $stackTrace');
      emit(MovimientoStockError('Error al cargar movimientos por almacén: $e'));
    }
  }

  Future<void> _onLoadByTipoRequested(
    MovimientoStockLoadByTipoRequested event,
    Emitter<MovimientoStockState> emit,
  ) async {
    debugPrint('= MovimientoStockBloc: Cargando movimientos de tipo ${event.tipo}...');
    emit(const MovimientoStockLoading());

    try {
      final List<MovimientoStockEntity> movimientos = await _repository.getByTipo(event.tipo);
      debugPrint(' MovimientoStockBloc: ${movimientos.length} movimientos de tipo ${event.tipo} cargados');
      emit(MovimientoStockLoaded(movimientos));
    } catch (e, stackTrace) {
      debugPrint('L MovimientoStockBloc: Error al cargar movimientos por tipo: $e');
      debugPrint('Stack trace: $stackTrace');
      emit(MovimientoStockError('Error al cargar movimientos por tipo: $e'));
    }
  }

  Future<void> _onLoadByFechasRequested(
    MovimientoStockLoadByFechasRequested event,
    Emitter<MovimientoStockState> emit,
  ) async {
    debugPrint('= MovimientoStockBloc: Cargando movimientos entre ${event.fechaInicio} y ${event.fechaFin}...');
    emit(const MovimientoStockLoading());

    try {
      final List<MovimientoStockEntity> movimientos = await _repository.getByFechas(
        fechaInicio: event.fechaInicio,
        fechaFin: event.fechaFin,
      );
      debugPrint(' MovimientoStockBloc: ${movimientos.length} movimientos en el rango de fechas cargados');
      emit(MovimientoStockLoaded(movimientos));
    } catch (e, stackTrace) {
      debugPrint('L MovimientoStockBloc: Error al cargar movimientos por fechas: $e');
      debugPrint('Stack trace: $stackTrace');
      emit(MovimientoStockError('Error al cargar movimientos por fechas: $e'));
    }
  }

  Future<void> _onCreateRequested(
    MovimientoStockCreateRequested event,
    Emitter<MovimientoStockState> emit,
  ) async {
    debugPrint(' MovimientoStockBloc: Creando movimiento de ${event.movimiento.tipo}...');
    emit(const MovimientoStockOperationInProgress());

    try {
      await _repository.create(event.movimiento);
      debugPrint(' MovimientoStockBloc: Movimiento creado exitosamente');
      emit(const MovimientoStockOperationSuccess('Movimiento registrado exitosamente'));

      add(const MovimientoStockLoadAllRequested());
    } catch (e, stackTrace) {
      debugPrint('L MovimientoStockBloc: Error al crear movimiento: $e');
      debugPrint('Stack trace: $stackTrace');
      emit(MovimientoStockError('Error al registrar movimiento: $e'));
    }
  }

  Future<void> _onDeleteRequested(
    MovimientoStockDeleteRequested event,
    Emitter<MovimientoStockState> emit,
  ) async {
    debugPrint('=Ñ MovimientoStockBloc: Eliminando movimiento ${event.id}...');
    emit(const MovimientoStockOperationInProgress());

    try {
      await _repository.delete(event.id);
      debugPrint(' MovimientoStockBloc: Movimiento eliminado exitosamente');
      emit(const MovimientoStockOperationSuccess('Movimiento eliminado exitosamente'));

      add(const MovimientoStockLoadAllRequested());
    } catch (e, stackTrace) {
      debugPrint('L MovimientoStockBloc: Error al eliminar movimiento: $e');
      debugPrint('Stack trace: $stackTrace');
      emit(MovimientoStockError('Error al eliminar movimiento: $e'));
    }
  }

  Future<void> _onWatchAllRequested(
    MovimientoStockWatchAllRequested event,
    Emitter<MovimientoStockState> emit,
  ) async {
    debugPrint('=A MovimientoStockBloc: Iniciando watch de movimientos...');
    emit(const MovimientoStockLoading());

    try {
      await _movimientosSubscription?.cancel();

      _movimientosSubscription = _repository.watchAll().listen(
        (List<MovimientoStockEntity> movimientos) {
          debugPrint('= MovimientoStockBloc: Recibidos ${movimientos.length} movimientos del stream');
          emit(MovimientoStockLoaded(movimientos));
        },
        onError: (Object error, StackTrace stackTrace) {
          debugPrint('L MovimientoStockBloc: Error en stream: $error');
          debugPrint('Stack trace: $stackTrace');
          emit(MovimientoStockError('Error en tiempo real: $error'));
        },
      );
    } catch (e, stackTrace) {
      debugPrint('L MovimientoStockBloc: Error al iniciar watch: $e');
      debugPrint('Stack trace: $stackTrace');
      emit(MovimientoStockError('Error al iniciar suscripción: $e'));
    }
  }

  Future<void> _onWatchByAlmacenRequested(
    MovimientoStockWatchByAlmacenRequested event,
    Emitter<MovimientoStockState> emit,
  ) async {
    debugPrint('=A MovimientoStockBloc: Iniciando watch de movimientos del almacén ${event.almacenId}...');
    emit(const MovimientoStockLoading());

    try {
      await _movimientosSubscription?.cancel();

      _movimientosSubscription = _repository.watchByAlmacen(event.almacenId).listen(
        (List<MovimientoStockEntity> movimientos) {
          debugPrint('= MovimientoStockBloc: Recibidos ${movimientos.length} movimientos del almacén ${event.almacenId} del stream');
          emit(MovimientoStockLoaded(movimientos));
        },
        onError: (Object error, StackTrace stackTrace) {
          debugPrint('L MovimientoStockBloc: Error en stream por almacén: $error');
          debugPrint('Stack trace: $stackTrace');
          emit(MovimientoStockError('Error en tiempo real: $error'));
        },
      );
    } catch (e, stackTrace) {
      debugPrint('L MovimientoStockBloc: Error al iniciar watch por almacén: $e');
      debugPrint('Stack trace: $stackTrace');
      emit(MovimientoStockError('Error al iniciar suscripción: $e'));
    }
  }
}
