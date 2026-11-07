import 'dart:async';

// Imports del core datasource (sistema nuevo de almacén - importación directa)
import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart' hide MovimientoStockEntity, StockDataSource, StockDataSourceFactory;
import 'package:ambutrack_web/features/almacen/domain/repositories/mantenimiento_electromedicina_repository.dart';
import 'package:ambutrack_web/features/almacen/presentation/bloc/mantenimiento_electromedicina/mantenimiento_electromedicina_event.dart';
import 'package:ambutrack_web/features/almacen/presentation/bloc/mantenimiento_electromedicina/mantenimiento_electromedicina_state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

/// BLoC para gestionar el estado de Mantenimiento de Electromedicina
@injectable
class MantenimientoElectromedicinaBloc extends Bloc<MantenimientoElectromedicinaEvent, MantenimientoElectromedicinaState> {
  MantenimientoElectromedicinaBloc(this._repository) : super(const MantenimientoElectromedicinaInitial()) {
    on<MantenimientoElectromedicinaLoadAllRequested>(_onLoadAllRequested);
    on<MantenimientoElectromedicinaLoadByProductoRequested>(_onLoadByProductoRequested);
    on<MantenimientoElectromedicinaLoadByTipoRequested>(_onLoadByTipoRequested);
    on<MantenimientoElectromedicinaLoadProximosAVencerRequested>(_onLoadProximosAVencerRequested);
    on<MantenimientoElectromedicinaLoadVencidosRequested>(_onLoadVencidosRequested);
    on<MantenimientoElectromedicinaCreateRequested>(_onCreateRequested);
    on<MantenimientoElectromedicinaUpdateRequested>(_onUpdateRequested);
    on<MantenimientoElectromedicinaDeleteRequested>(_onDeleteRequested);
    on<MantenimientoElectromedicinaWatchAllRequested>(_onWatchAllRequested);
    on<MantenimientoElectromedicinaWatchByProductoRequested>(_onWatchByProductoRequested);
    on<MantenimientoElectromedicinaWatchProximosAVencerRequested>(_onWatchProximosAVencerRequested);
  }

  final MantenimientoElectromedicinaRepository _repository;
  StreamSubscription<List<MantenimientoElectromedicinaEntity>>? _mantenimientosSubscription;

  @override
  Future<void> close() {
    _mantenimientosSubscription?.cancel();
    return super.close();
  }

  Future<void> _onLoadAllRequested(
    MantenimientoElectromedicinaLoadAllRequested event,
    Emitter<MantenimientoElectromedicinaState> emit,
  ) async {
    debugPrint('= MantenimientoElectromedicinaBloc: Cargando todos los mantenimientos...');
    emit(const MantenimientoElectromedicinaLoading());

    try {
      final List<MantenimientoElectromedicinaEntity> mantenimientos = await _repository.getAll();
      debugPrint(' MantenimientoElectromedicinaBloc: ${mantenimientos.length} mantenimientos cargados');
      emit(MantenimientoElectromedicinaLoaded(mantenimientos));
    } catch (e, stackTrace) {
      debugPrint('L MantenimientoElectromedicinaBloc: Error al cargar mantenimientos: $e');
      debugPrint('Stack trace: $stackTrace');
      emit(MantenimientoElectromedicinaError('Error al cargar mantenimientos: $e'));
    }
  }

  Future<void> _onLoadByProductoRequested(
    MantenimientoElectromedicinaLoadByProductoRequested event,
    Emitter<MantenimientoElectromedicinaState> emit,
  ) async {
    debugPrint('= MantenimientoElectromedicinaBloc: Cargando mantenimientos del producto ${event.productoId}...');
    emit(const MantenimientoElectromedicinaLoading());

    try {
      final List<MantenimientoElectromedicinaEntity> mantenimientos = await _repository.getByProducto(event.productoId);
      debugPrint(' MantenimientoElectromedicinaBloc: ${mantenimientos.length} mantenimientos del producto cargados');
      emit(MantenimientoElectromedicinaLoaded(mantenimientos));
    } catch (e, stackTrace) {
      debugPrint('L MantenimientoElectromedicinaBloc: Error al cargar mantenimientos por producto: $e');
      debugPrint('Stack trace: $stackTrace');
      emit(MantenimientoElectromedicinaError('Error al cargar mantenimientos por producto: $e'));
    }
  }

  Future<void> _onLoadByTipoRequested(
    MantenimientoElectromedicinaLoadByTipoRequested event,
    Emitter<MantenimientoElectromedicinaState> emit,
  ) async {
    debugPrint('= MantenimientoElectromedicinaBloc: Cargando mantenimientos de tipo ${event.tipo}...');
    emit(const MantenimientoElectromedicinaLoading());

    try {
      final List<MantenimientoElectromedicinaEntity> mantenimientos = await _repository.getByTipo(event.tipo);
      debugPrint(' MantenimientoElectromedicinaBloc: ${mantenimientos.length} mantenimientos de tipo ${event.tipo} cargados');
      emit(MantenimientoElectromedicinaLoaded(mantenimientos));
    } catch (e, stackTrace) {
      debugPrint('L MantenimientoElectromedicinaBloc: Error al cargar mantenimientos por tipo: $e');
      debugPrint('Stack trace: $stackTrace');
      emit(MantenimientoElectromedicinaError('Error al cargar mantenimientos por tipo: $e'));
    }
  }

  Future<void> _onLoadProximosAVencerRequested(
    MantenimientoElectromedicinaLoadProximosAVencerRequested event,
    Emitter<MantenimientoElectromedicinaState> emit,
  ) async {
    debugPrint('  MantenimientoElectromedicinaBloc: Cargando mantenimientos próximos a vencer (${event.dias} días)...');
    emit(const MantenimientoElectromedicinaLoading());

    try {
      final List<MantenimientoElectromedicinaEntity> mantenimientos = await _repository.getProximosAVencer(dias: event.dias);
      debugPrint(' MantenimientoElectromedicinaBloc: ${mantenimientos.length} mantenimientos próximos a vencer cargados');
      emit(MantenimientoElectromedicinaLoaded(mantenimientos));
    } catch (e, stackTrace) {
      debugPrint('L MantenimientoElectromedicinaBloc: Error al cargar mantenimientos próximos a vencer: $e');
      debugPrint('Stack trace: $stackTrace');
      emit(MantenimientoElectromedicinaError('Error al cargar mantenimientos próximos a vencer: $e'));
    }
  }

  Future<void> _onLoadVencidosRequested(
    MantenimientoElectromedicinaLoadVencidosRequested event,
    Emitter<MantenimientoElectromedicinaState> emit,
  ) async {
    debugPrint('=¨ MantenimientoElectromedicinaBloc: Cargando mantenimientos vencidos...');
    emit(const MantenimientoElectromedicinaLoading());

    try {
      final List<MantenimientoElectromedicinaEntity> mantenimientos = await _repository.getVencidos();
      debugPrint(' MantenimientoElectromedicinaBloc: ${mantenimientos.length} mantenimientos vencidos cargados');
      emit(MantenimientoElectromedicinaLoaded(mantenimientos));
    } catch (e, stackTrace) {
      debugPrint('L MantenimientoElectromedicinaBloc: Error al cargar mantenimientos vencidos: $e');
      debugPrint('Stack trace: $stackTrace');
      emit(MantenimientoElectromedicinaError('Error al cargar mantenimientos vencidos: $e'));
    }
  }

  Future<void> _onCreateRequested(
    MantenimientoElectromedicinaCreateRequested event,
    Emitter<MantenimientoElectromedicinaState> emit,
  ) async {
    debugPrint(' MantenimientoElectromedicinaBloc: Creando mantenimiento...');
    emit(const MantenimientoElectromedicinaOperationInProgress());

    try {
      await _repository.create(event.mantenimiento);
      debugPrint(' MantenimientoElectromedicinaBloc: Mantenimiento creado exitosamente');
      emit(const MantenimientoElectromedicinaOperationSuccess('Mantenimiento registrado exitosamente'));

      add(const MantenimientoElectromedicinaLoadAllRequested());
    } catch (e, stackTrace) {
      debugPrint('L MantenimientoElectromedicinaBloc: Error al crear mantenimiento: $e');
      debugPrint('Stack trace: $stackTrace');
      emit(MantenimientoElectromedicinaError('Error al registrar mantenimiento: $e'));
    }
  }

  Future<void> _onUpdateRequested(
    MantenimientoElectromedicinaUpdateRequested event,
    Emitter<MantenimientoElectromedicinaState> emit,
  ) async {
    debugPrint(' MantenimientoElectromedicinaBloc: Actualizando mantenimiento...');
    emit(const MantenimientoElectromedicinaOperationInProgress());

    try {
      await _repository.update(event.mantenimiento);
      debugPrint(' MantenimientoElectromedicinaBloc: Mantenimiento actualizado exitosamente');
      emit(const MantenimientoElectromedicinaOperationSuccess('Mantenimiento actualizado exitosamente'));

      add(const MantenimientoElectromedicinaLoadAllRequested());
    } catch (e, stackTrace) {
      debugPrint('L MantenimientoElectromedicinaBloc: Error al actualizar mantenimiento: $e');
      debugPrint('Stack trace: $stackTrace');
      emit(MantenimientoElectromedicinaError('Error al actualizar mantenimiento: $e'));
    }
  }

  Future<void> _onDeleteRequested(
    MantenimientoElectromedicinaDeleteRequested event,
    Emitter<MantenimientoElectromedicinaState> emit,
  ) async {
    debugPrint('=Ñ MantenimientoElectromedicinaBloc: Eliminando mantenimiento ${event.id}...');
    emit(const MantenimientoElectromedicinaOperationInProgress());

    try {
      await _repository.delete(event.id);
      debugPrint(' MantenimientoElectromedicinaBloc: Mantenimiento eliminado exitosamente');
      emit(const MantenimientoElectromedicinaOperationSuccess('Mantenimiento eliminado exitosamente'));

      add(const MantenimientoElectromedicinaLoadAllRequested());
    } catch (e, stackTrace) {
      debugPrint('L MantenimientoElectromedicinaBloc: Error al eliminar mantenimiento: $e');
      debugPrint('Stack trace: $stackTrace');
      emit(MantenimientoElectromedicinaError('Error al eliminar mantenimiento: $e'));
    }
  }

  Future<void> _onWatchAllRequested(
    MantenimientoElectromedicinaWatchAllRequested event,
    Emitter<MantenimientoElectromedicinaState> emit,
  ) async {
    debugPrint('=A MantenimientoElectromedicinaBloc: Iniciando watch de mantenimientos...');
    emit(const MantenimientoElectromedicinaLoading());

    try {
      await _mantenimientosSubscription?.cancel();

      _mantenimientosSubscription = _repository.watchAll().listen(
        (List<MantenimientoElectromedicinaEntity> mantenimientos) {
          debugPrint('= MantenimientoElectromedicinaBloc: Recibidos ${mantenimientos.length} mantenimientos del stream');
          emit(MantenimientoElectromedicinaLoaded(mantenimientos));
        },
        onError: (Object error, StackTrace stackTrace) {
          debugPrint('L MantenimientoElectromedicinaBloc: Error en stream: $error');
          debugPrint('Stack trace: $stackTrace');
          emit(MantenimientoElectromedicinaError('Error en tiempo real: $error'));
        },
      );
    } catch (e, stackTrace) {
      debugPrint('L MantenimientoElectromedicinaBloc: Error al iniciar watch: $e');
      debugPrint('Stack trace: $stackTrace');
      emit(MantenimientoElectromedicinaError('Error al iniciar suscripción: $e'));
    }
  }

  Future<void> _onWatchByProductoRequested(
    MantenimientoElectromedicinaWatchByProductoRequested event,
    Emitter<MantenimientoElectromedicinaState> emit,
  ) async {
    debugPrint('=A MantenimientoElectromedicinaBloc: Iniciando watch de mantenimientos del producto ${event.productoId}...');
    emit(const MantenimientoElectromedicinaLoading());

    try {
      await _mantenimientosSubscription?.cancel();

      _mantenimientosSubscription = _repository.watchByProducto(event.productoId).listen(
        (List<MantenimientoElectromedicinaEntity> mantenimientos) {
          debugPrint('= MantenimientoElectromedicinaBloc: Recibidos ${mantenimientos.length} mantenimientos del producto ${event.productoId} del stream');
          emit(MantenimientoElectromedicinaLoaded(mantenimientos));
        },
        onError: (Object error, StackTrace stackTrace) {
          debugPrint('L MantenimientoElectromedicinaBloc: Error en stream por producto: $error');
          debugPrint('Stack trace: $stackTrace');
          emit(MantenimientoElectromedicinaError('Error en tiempo real: $error'));
        },
      );
    } catch (e, stackTrace) {
      debugPrint('L MantenimientoElectromedicinaBloc: Error al iniciar watch por producto: $e');
      debugPrint('Stack trace: $stackTrace');
      emit(MantenimientoElectromedicinaError('Error al iniciar suscripción: $e'));
    }
  }

  Future<void> _onWatchProximosAVencerRequested(
    MantenimientoElectromedicinaWatchProximosAVencerRequested event,
    Emitter<MantenimientoElectromedicinaState> emit,
  ) async {
    debugPrint('=A MantenimientoElectromedicinaBloc: Iniciando watch de mantenimientos próximos a vencer...');
    emit(const MantenimientoElectromedicinaLoading());

    try {
      await _mantenimientosSubscription?.cancel();

      _mantenimientosSubscription = _repository.watchProximosAVencer(dias: event.dias).listen(
        (List<MantenimientoElectromedicinaEntity> mantenimientos) {
          debugPrint('= MantenimientoElectromedicinaBloc: Recibidos ${mantenimientos.length} mantenimientos próximos a vencer del stream');
          emit(MantenimientoElectromedicinaLoaded(mantenimientos));
        },
        onError: (Object error, StackTrace stackTrace) {
          debugPrint('L MantenimientoElectromedicinaBloc: Error en stream próximos a vencer: $error');
          debugPrint('Stack trace: $stackTrace');
          emit(MantenimientoElectromedicinaError('Error en tiempo real: $error'));
        },
      );
    } catch (e, stackTrace) {
      debugPrint('L MantenimientoElectromedicinaBloc: Error al iniciar watch próximos a vencer: $e');
      debugPrint('Stack trace: $stackTrace');
      emit(MantenimientoElectromedicinaError('Error al iniciar suscripción: $e'));
    }
  }
}
