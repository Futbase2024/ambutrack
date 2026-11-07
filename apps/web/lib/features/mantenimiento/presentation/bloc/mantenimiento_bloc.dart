import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/features/mantenimiento/domain/repositories/mantenimiento_repository.dart';
import 'package:ambutrack_web/features/mantenimiento/presentation/bloc/mantenimiento_event.dart';
import 'package:ambutrack_web/features/mantenimiento/presentation/bloc/mantenimiento_state.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

/// BLoC para gestión de mantenimientos
@injectable
class MantenimientoBloc extends Bloc<MantenimientoEvent, MantenimientoState> {
  MantenimientoBloc(this._repository) : super(const MantenimientoInitial()) {
    on<MantenimientoLoadRequested>(_onLoadRequested);
    on<MantenimientoLoadByVehiculoRequested>(_onLoadByVehiculoRequested);
    on<MantenimientoCreateRequested>(_onCreateRequested);
    on<MantenimientoUpdateRequested>(_onUpdateRequested);
    on<MantenimientoDeleteRequested>(_onDeleteRequested);
    on<MantenimientoLoadProximosRequested>(_onLoadProximosRequested);
    on<MantenimientoLoadVencidosRequested>(_onLoadVencidosRequested);
  }

  final MantenimientoRepository _repository;

  /// Cargar todos los mantenimientos
  Future<void> _onLoadRequested(
    MantenimientoLoadRequested event,
    Emitter<MantenimientoState> emit,
  ) async {
    debugPrint('🔧 MantenimientoBloc: Cargando mantenimientos');
    emit(const MantenimientoLoading());

    final Either<Exception, List<MantenimientoEntity>> result = await _repository.getAll();

    result.fold(
      (Exception exception) {
        debugPrint('❌ MantenimientoBloc Error: $exception');
        emit(MantenimientoError(message: exception.toString()));
      },
      (List<MantenimientoEntity> mantenimientos) {
        debugPrint('✅ MantenimientoBloc: ${mantenimientos.length} mantenimientos cargados');
        emit(MantenimientoLoaded(mantenimientos: mantenimientos));
      },
    );
  }

  /// Cargar mantenimientos por vehículo
  Future<void> _onLoadByVehiculoRequested(
    MantenimientoLoadByVehiculoRequested event,
    Emitter<MantenimientoState> emit,
  ) async {
    debugPrint('🔧 MantenimientoBloc: Cargando mantenimientos del vehículo ${event.vehiculoId}');
    emit(const MantenimientoLoading());

    final Either<Exception, List<MantenimientoEntity>> result = await _repository.getByVehiculo(event.vehiculoId);

    result.fold(
      (Exception exception) {
        debugPrint('❌ MantenimientoBloc Error: $exception');
        emit(MantenimientoError(message: exception.toString()));
      },
      (List<MantenimientoEntity> mantenimientos) {
        debugPrint('✅ MantenimientoBloc: ${mantenimientos.length} mantenimientos del vehículo cargados');
        emit(MantenimientoLoaded(mantenimientos: mantenimientos));
      },
    );
  }

  /// Crear mantenimiento
  Future<void> _onCreateRequested(
    MantenimientoCreateRequested event,
    Emitter<MantenimientoState> emit,
  ) async {
    debugPrint('🔧 MantenimientoBloc: Creando mantenimiento');
    emit(const MantenimientoLoading());

    final Either<Exception, MantenimientoEntity> result = await _repository.create(event.mantenimiento);

    result.fold(
      (Exception exception) {
        debugPrint('❌ MantenimientoBloc Error: $exception');
        emit(MantenimientoError(message: exception.toString()));
      },
      (MantenimientoEntity mantenimiento) {
        debugPrint('✅ MantenimientoBloc: Mantenimiento creado con ID ${mantenimiento.id}');
        if (!isClosed) {
          add(const MantenimientoLoadRequested());
        }
      },
    );
  }

  /// Actualizar mantenimiento
  Future<void> _onUpdateRequested(
    MantenimientoUpdateRequested event,
    Emitter<MantenimientoState> emit,
  ) async {
    debugPrint('🔧 MantenimientoBloc: Actualizando mantenimiento ${event.mantenimiento.id}');
    emit(const MantenimientoLoading());

    final Either<Exception, MantenimientoEntity> result = await _repository.update(event.mantenimiento);

    result.fold(
      (Exception exception) {
        debugPrint('❌ MantenimientoBloc Error: $exception');
        emit(MantenimientoError(message: exception.toString()));
      },
      (MantenimientoEntity mantenimiento) {
        debugPrint('✅ MantenimientoBloc: Mantenimiento actualizado');
        if (!isClosed) {
          add(const MantenimientoLoadRequested());
        }
      },
    );
  }

  /// Eliminar mantenimiento
  Future<void> _onDeleteRequested(
    MantenimientoDeleteRequested event,
    Emitter<MantenimientoState> emit,
  ) async {
    debugPrint('🔧 MantenimientoBloc: Eliminando mantenimiento ${event.id}');
    emit(const MantenimientoLoading());

    final Either<Exception, void> result = await _repository.delete(event.id);

    result.fold(
      (Exception exception) {
        debugPrint('❌ MantenimientoBloc Error: $exception');
        emit(MantenimientoError(message: exception.toString()));
      },
      (_) {
        debugPrint('✅ MantenimientoBloc: Mantenimiento eliminado');
        if (!isClosed) {
          add(const MantenimientoLoadRequested());
        }
      },
    );
  }

  /// Cargar mantenimientos próximos
  Future<void> _onLoadProximosRequested(
    MantenimientoLoadProximosRequested event,
    Emitter<MantenimientoState> emit,
  ) async {
    debugPrint('🔧 MantenimientoBloc: Cargando mantenimientos próximos (${event.dias} días)');
    emit(const MantenimientoLoading());

    final Either<Exception, List<MantenimientoEntity>> result = await _repository.getProximos(event.dias);

    result.fold(
      (Exception exception) {
        debugPrint('❌ MantenimientoBloc Error: $exception');
        emit(MantenimientoError(message: exception.toString()));
      },
      (List<MantenimientoEntity> mantenimientos) {
        debugPrint('✅ MantenimientoBloc: ${mantenimientos.length} mantenimientos próximos cargados');
        emit(MantenimientoLoaded(mantenimientos: mantenimientos));
      },
    );
  }

  /// Cargar mantenimientos vencidos
  Future<void> _onLoadVencidosRequested(
    MantenimientoLoadVencidosRequested event,
    Emitter<MantenimientoState> emit,
  ) async {
    debugPrint('🔧 MantenimientoBloc: Cargando mantenimientos vencidos');
    emit(const MantenimientoLoading());

    final Either<Exception, List<MantenimientoEntity>> result = await _repository.getVencidos();

    result.fold(
      (Exception exception) {
        debugPrint('❌ MantenimientoBloc Error: $exception');
        emit(MantenimientoError(message: exception.toString()));
      },
      (List<MantenimientoEntity> mantenimientos) {
        debugPrint('✅ MantenimientoBloc: ${mantenimientos.length} mantenimientos vencidos cargados');
        emit(MantenimientoLoaded(mantenimientos: mantenimientos));
      },
    );
  }
}
