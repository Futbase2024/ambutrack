import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/equipamiento_repository.dart';
import 'equipamiento_event.dart';
import 'equipamiento_state.dart';

/// BLoC de la dotación del vehículo asignado (pantalla del técnico)
class EquipamientoBloc extends Bloc<EquipamientoEvent, EquipamientoState> {
  EquipamientoBloc(this._repository) : super(const EquipamientoState()) {
    on<EquipamientoLoadRequested>(_onLoad);
    on<EquipamientoLineaGuardada>(_onGuardar);
  }

  final EquipamientoRepository _repository;

  Future<void> _onLoad(EquipamientoLoadRequested event, Emitter<EquipamientoState> emit) async {
    emit(state.copyWith(vehiculoId: event.vehiculoId, status: EquipamientoStatus.loading));
    try {
      final List<StockVehiculoEntity> lineas = await _repository.getDotacion(event.vehiculoId);
      debugPrint('✅ EquipamientoBloc: ${lineas.length} líneas');
      emit(state.copyWith(
        status: EquipamientoStatus.loaded,
        lineas: lineas.where((StockVehiculoEntity l) => !l.excluido).toList(),
        clearError: true,
      ));
    } catch (e) {
      debugPrint('❌ EquipamientoBloc: error al cargar: $e');
      emit(state.copyWith(status: EquipamientoStatus.failure, error: e.toString()));
    }
  }

  Future<void> _onGuardar(EquipamientoLineaGuardada event, Emitter<EquipamientoState> emit) async {
    emit(state.copyWith(saving: true));
    try {
      final StockVehiculoEntity linea = await _repository.actualizarLinea(
        id: event.id,
        cantidadActual: event.cantidad,
        fechaCaducidad: event.fechaCaducidad,
        borrarCaducidad: event.borrarCaducidad,
        lote: event.lote,
        observaciones: event.observaciones,
      );
      emit(state.copyWith(
        lineas: state.lineas.map((StockVehiculoEntity l) => l.id == linea.id ? linea : l).toList(),
        saving: false,
        operacion: state.operacion + 1,
        resultado: EquipamientoResultado.exito,
        clearError: true,
      ));
    } catch (e) {
      debugPrint('❌ EquipamientoBloc: error al guardar: $e');
      emit(state.copyWith(
        saving: false,
        operacion: state.operacion + 1,
        resultado: EquipamientoResultado.error,
        error: e.toString(),
      ));
    }
  }
}
