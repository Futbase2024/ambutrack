import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/features/tablas/tipos_vehiculo/domain/repositories/tipo_vehiculo_repository.dart';
import 'package:ambutrack_web/features/tablas/tipos_vehiculo/presentation/bloc/tipo_vehiculo_event.dart';
import 'package:ambutrack_web/features/tablas/tipos_vehiculo/presentation/bloc/tipo_vehiculo_state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

/// BLoC para gestión de tipos de vehículo
@injectable
class TipoVehiculoBloc extends Bloc<TipoVehiculoEvent, TipoVehiculoState> {
  TipoVehiculoBloc(this._repository) : super(const TipoVehiculoInitial()) {
    on<TipoVehiculoLoadAllRequested>(_onLoadAllRequested);
    on<TipoVehiculoCreateRequested>(_onCreateRequested);
    on<TipoVehiculoUpdateRequested>(_onUpdateRequested);
    on<TipoVehiculoDeleteRequested>(_onDeleteRequested);
  }

  final TipoVehiculoRepository _repository;

  /// Maneja la carga de todos los tipos de vehículo
  Future<void> _onLoadAllRequested(
    TipoVehiculoLoadAllRequested event,
    Emitter<TipoVehiculoState> emit,
  ) async {
    try {
      debugPrint('🚀 TipoVehiculoBloc: Cargando todos los tipos de vehículo...');
      emit(const TipoVehiculoLoading());

      final List<TipoVehiculoEntity> tiposVehiculo = await _repository.getAll();

      debugPrint('✅ TipoVehiculoBloc: ${tiposVehiculo.length} tipos de vehículo cargados');
      emit(TipoVehiculoLoaded(tiposVehiculo));
    } catch (e) {
      debugPrint('❌ TipoVehiculoBloc: Error al cargar tipos de vehículo: $e');
      emit(TipoVehiculoError(e.toString()));
    }
  }

  /// Maneja la creación de un tipo de vehículo
  Future<void> _onCreateRequested(
    TipoVehiculoCreateRequested event,
    Emitter<TipoVehiculoState> emit,
  ) async {
    try {
      debugPrint('🚀 TipoVehiculoBloc: Creando tipo de vehículo: ${event.tipoVehiculo.nombre}');
      emit(const TipoVehiculoCreating());

      final TipoVehiculoEntity tipoVehiculo = await _repository.create(event.tipoVehiculo);

      debugPrint('✅ TipoVehiculoBloc: Tipo de vehículo creado con ID: ${tipoVehiculo.id}');
      emit(TipoVehiculoCreated(tipoVehiculo));
      // Recargar la lista después de crear
      add(const TipoVehiculoLoadAllRequested());
    } catch (e) {
      debugPrint('❌ TipoVehiculoBloc: Error al crear tipo de vehículo: $e');
      emit(TipoVehiculoError(e.toString()));
    }
  }

  /// Maneja la actualización de un tipo de vehículo
  Future<void> _onUpdateRequested(
    TipoVehiculoUpdateRequested event,
    Emitter<TipoVehiculoState> emit,
  ) async {
    try {
      debugPrint('🚀 TipoVehiculoBloc: Actualizando tipo de vehículo: ${event.tipoVehiculo.id}');
      emit(const TipoVehiculoUpdating());

      final TipoVehiculoEntity tipoVehiculo = await _repository.update(event.tipoVehiculo);

      debugPrint('✅ TipoVehiculoBloc: Tipo de vehículo actualizado');
      emit(TipoVehiculoUpdated(tipoVehiculo));
      // Recargar la lista después de actualizar
      add(const TipoVehiculoLoadAllRequested());
    } catch (e) {
      debugPrint('❌ TipoVehiculoBloc: Error al actualizar tipo de vehículo: $e');
      emit(TipoVehiculoError(e.toString()));
    }
  }

  /// Maneja la eliminación de un tipo de vehículo
  Future<void> _onDeleteRequested(
    TipoVehiculoDeleteRequested event,
    Emitter<TipoVehiculoState> emit,
  ) async {
    try {
      debugPrint('🚀 TipoVehiculoBloc: Eliminando tipo de vehículo: ${event.id}');
      emit(const TipoVehiculoDeleting());

      await _repository.delete(event.id);

      debugPrint('✅ TipoVehiculoBloc: Tipo de vehículo eliminado');
      emit(const TipoVehiculoDeleted());
      // Recargar la lista después de eliminar
      add(const TipoVehiculoLoadAllRequested());
    } catch (e) {
      debugPrint('❌ TipoVehiculoBloc: Error al eliminar tipo de vehículo: $e');
      emit(TipoVehiculoError(e.toString()));
    }
  }
}
