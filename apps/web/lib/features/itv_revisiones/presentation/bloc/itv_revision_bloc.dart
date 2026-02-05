import 'package:ambutrack_core/ambutrack_core.dart';
import 'package:ambutrack_web/features/itv_revisiones/domain/repositories/itv_revision_repository.dart';
import 'package:ambutrack_web/features/itv_revisiones/presentation/bloc/itv_revision_event.dart';
import 'package:ambutrack_web/features/itv_revisiones/presentation/bloc/itv_revision_state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

/// BLoC para gestionar ITV y Revisiones
@injectable
class ItvRevisionBloc extends Bloc<ItvRevisionEvent, ItvRevisionState> {
  ItvRevisionBloc(this._repository) : super(const ItvRevisionInitial()) {
    on<ItvRevisionLoadRequested>(_onLoadRequested);
    on<ItvRevisionLoadByVehiculoRequested>(_onLoadByVehiculoRequested);
    on<ItvRevisionCreateRequested>(_onCreateRequested);
    on<ItvRevisionUpdateRequested>(_onUpdateRequested);
    on<ItvRevisionDeleteRequested>(_onDeleteRequested);
    on<ItvRevisionLoadProximasVencerRequested>(_onLoadProximasVencerRequested);
  }

  final ItvRevisionRepository _repository;

  /// Carga todas las ITV/Revisiones
  Future<void> _onLoadRequested(
    ItvRevisionLoadRequested event,
    Emitter<ItvRevisionState> emit,
  ) async {
    try {
      debugPrint('🚀 ItvRevisionBloc: Cargando ITV/Revisiones...');
      emit(const ItvRevisionLoading());

      final List<ItvRevisionEntity> itvRevisiones = await _repository.getAll();

      debugPrint('✅ ItvRevisionBloc: ${itvRevisiones.length} ITV/Revisiones cargadas');
      emit(ItvRevisionLoaded(itvRevisiones: itvRevisiones));
    } catch (e, stackTrace) {
      debugPrint('❌ ItvRevisionBloc: Error al cargar ITV/Revisiones: $e');
      debugPrint('Stack trace: $stackTrace');
      emit(ItvRevisionError(message: 'Error al cargar ITV/Revisiones: ${e.toString()}'));
    }
  }

  /// Carga ITV/Revisiones por vehículo
  Future<void> _onLoadByVehiculoRequested(
    ItvRevisionLoadByVehiculoRequested event,
    Emitter<ItvRevisionState> emit,
  ) async {
    try {
      debugPrint('🚀 ItvRevisionBloc: Cargando ITV/Revisiones del vehículo...');
      emit(const ItvRevisionLoading());

      final List<ItvRevisionEntity> itvRevisiones = await _repository.getByVehiculo(event.vehiculoId);

      debugPrint('✅ ItvRevisionBloc: ${itvRevisiones.length} ITV/Revisiones cargadas');
      emit(ItvRevisionLoaded(itvRevisiones: itvRevisiones));
    } catch (e, stackTrace) {
      debugPrint('❌ ItvRevisionBloc: Error al cargar ITV/Revisiones por vehículo: $e');
      debugPrint('Stack trace: $stackTrace');
      emit(ItvRevisionError(message: 'Error al cargar ITV/Revisiones: ${e.toString()}'));
    }
  }

  /// Crea una nueva ITV/Revisión
  Future<void> _onCreateRequested(
    ItvRevisionCreateRequested event,
    Emitter<ItvRevisionState> emit,
  ) async {
    try {
      debugPrint('🚀 ItvRevisionBloc: Creando ITV/Revisión...');

      await _repository.create(event.itvRevision);

      debugPrint('✅ ItvRevisionBloc: ITV/Revisión creada exitosamente');
      emit(const ItvRevisionOperationSuccess(message: 'ITV/Revisión programada correctamente'));

      // Recargar la lista
      add(const ItvRevisionLoadRequested());
    } catch (e, stackTrace) {
      debugPrint('❌ ItvRevisionBloc: Error al crear ITV/Revisión: $e');
      debugPrint('Stack trace: $stackTrace');
      emit(ItvRevisionError(message: 'Error al crear ITV/Revisión: ${e.toString()}'));
    }
  }

  /// Actualiza una ITV/Revisión existente
  Future<void> _onUpdateRequested(
    ItvRevisionUpdateRequested event,
    Emitter<ItvRevisionState> emit,
  ) async {
    try {
      debugPrint('🚀 ItvRevisionBloc: Actualizando ITV/Revisión...');

      await _repository.update(event.itvRevision);

      debugPrint('✅ ItvRevisionBloc: ITV/Revisión actualizada exitosamente');
      emit(const ItvRevisionOperationSuccess(message: 'ITV/Revisión actualizada correctamente'));

      // Recargar la lista
      add(const ItvRevisionLoadRequested());
    } catch (e, stackTrace) {
      debugPrint('❌ ItvRevisionBloc: Error al actualizar ITV/Revisión: $e');
      debugPrint('Stack trace: $stackTrace');
      emit(ItvRevisionError(message: 'Error al actualizar ITV/Revisión: ${e.toString()}'));
    }
  }

  /// Elimina una ITV/Revisión
  Future<void> _onDeleteRequested(
    ItvRevisionDeleteRequested event,
    Emitter<ItvRevisionState> emit,
  ) async {
    try {
      debugPrint('🚀 ItvRevisionBloc: Eliminando ITV/Revisión...');

      await _repository.delete(event.id);

      debugPrint('✅ ItvRevisionBloc: ITV/Revisión eliminada exitosamente');
      emit(const ItvRevisionOperationSuccess(message: 'ITV/Revisión eliminada correctamente'));

      // Recargar la lista
      add(const ItvRevisionLoadRequested());
    } catch (e, stackTrace) {
      debugPrint('❌ ItvRevisionBloc: Error al eliminar ITV/Revisión: $e');
      debugPrint('Stack trace: $stackTrace');
      emit(ItvRevisionError(message: 'Error al eliminar ITV/Revisión: ${e.toString()}'));
    }
  }

  /// Carga ITV/Revisiones próximas a vencer
  Future<void> _onLoadProximasVencerRequested(
    ItvRevisionLoadProximasVencerRequested event,
    Emitter<ItvRevisionState> emit,
  ) async {
    try {
      debugPrint('🚀 ItvRevisionBloc: Cargando ITV/Revisiones próximas a vencer...');
      emit(const ItvRevisionLoading());

      final List<ItvRevisionEntity> itvRevisiones = await _repository.getProximasVencer(event.dias);

      debugPrint('✅ ItvRevisionBloc: ${itvRevisiones.length} ITV/Revisiones próximas a vencer');
      emit(ItvRevisionLoaded(itvRevisiones: itvRevisiones));
    } catch (e, stackTrace) {
      debugPrint('❌ ItvRevisionBloc: Error al cargar ITV/Revisiones próximas a vencer: $e');
      debugPrint('Stack trace: $stackTrace');
      emit(ItvRevisionError(message: 'Error al cargar ITV/Revisiones: ${e.toString()}'));
    }
  }
}
