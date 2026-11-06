import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/features/vehiculos/equipamiento/domain/repositories/equipamiento_vehiculo_repository.dart';
import 'package:ambutrack_web/features/vehiculos/equipamiento/presentation/bloc/equipamiento_vehiculo_event.dart';
import 'package:ambutrack_web/features/vehiculos/equipamiento/presentation/bloc/equipamiento_vehiculo_state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

/// BLoC de la dotación (equipamiento + documentación) de un vehículo
@injectable
class EquipamientoVehiculoBloc extends Bloc<EquipamientoVehiculoEvent, EquipamientoVehiculoState> {
  EquipamientoVehiculoBloc(this._repository) : super(const EquipamientoVehiculoState()) {
    on<EquipamientoVehiculoLoadRequested>(_onLoad);
    on<EquipamientoLineaUpdateRequested>(_onUpdateLinea);
    on<EquipamientoExcluirRequested>(_onExcluir);
    on<EquipamientoExtraAddRequested>(_onAddExtra);
    on<EquipamientoExtraDeleteRequested>(_onDeleteExtra);
    on<EquipamientoAdjuntoUploadRequested>(_onUploadAdjunto);
    on<EquipamientoAdjuntoDeleteRequested>(_onDeleteAdjunto);
  }

  final EquipamientoVehiculoRepository _repository;

  Future<void> _onLoad(
    EquipamientoVehiculoLoadRequested event,
    Emitter<EquipamientoVehiculoState> emit,
  ) async {
    emit(state.copyWith(vehiculoId: event.vehiculoId, status: EquipamientoStatus.loading));
    try {
      final List<StockVehiculoEntity> lineas = await _repository.getDotacion(event.vehiculoId);
      debugPrint('✅ EquipamientoVehiculoBloc: ${lineas.length} líneas');
      emit(state.copyWith(status: EquipamientoStatus.loaded, lineas: lineas, clearError: true));
    } catch (e) {
      debugPrint('❌ EquipamientoVehiculoBloc: error al cargar: $e');
      emit(state.copyWith(status: EquipamientoStatus.failure, error: e.toString()));
    }
  }

  Future<void> _onUpdateLinea(
    EquipamientoLineaUpdateRequested event,
    Emitter<EquipamientoVehiculoState> emit,
  ) {
    return _guardar(
      emit,
      mensaje: 'Línea de equipamiento actualizada correctamente.',
      accion: () async => _reemplazar(
        await _repository.actualizarLinea(
          id: event.id,
          cantidadActual: event.cantidad,
          fechaCaducidad: event.fechaCaducidad,
          borrarCaducidad: event.borrarCaducidad,
          lote: event.lote,
          observaciones: event.observaciones,
        ),
      ),
    );
  }

  Future<void> _onExcluir(EquipamientoExcluirRequested event, Emitter<EquipamientoVehiculoState> emit) {
    return _guardar(
      emit,
      mensaje: event.excluido
          ? 'El item queda excluido de este vehículo.'
          : 'El item vuelve a formar parte de la dotación del vehículo.',
      accion: () async => _reemplazar(await _repository.setExcluido(event.id, excluido: event.excluido)),
    );
  }

  Future<void> _onAddExtra(EquipamientoExtraAddRequested event, Emitter<EquipamientoVehiculoState> emit) {
    return _guardar(
      emit,
      mensaje: 'Item extra añadido al vehículo.',
      accion: () async {
        await _repository.addExtra(
          vehiculoId: state.vehiculoId!,
          productoId: event.productoId,
          cantidad: event.cantidad,
          fechaCaducidad: event.fechaCaducidad,
          lote: event.lote,
          observaciones: event.observaciones,
        );
        return _repository.getDotacion(state.vehiculoId!);
      },
    );
  }

  Future<void> _onDeleteExtra(EquipamientoExtraDeleteRequested event, Emitter<EquipamientoVehiculoState> emit) {
    return _guardar(
      emit,
      mensaje: 'Item extra eliminado del vehículo.',
      accion: () async {
        await _repository.eliminarExtra(event.id);
        return state.lineas.where((StockVehiculoEntity l) => l.id != event.id).toList();
      },
    );
  }

  Future<void> _onUploadAdjunto(
    EquipamientoAdjuntoUploadRequested event,
    Emitter<EquipamientoVehiculoState> emit,
  ) {
    return _guardar(
      emit,
      mensaje: 'Documento "${event.fileName}" adjuntado correctamente.',
      accion: () async => _reemplazar(
        await _repository.subirAdjunto(
          id: event.id,
          vehiculoId: state.vehiculoId!,
          bytes: event.bytes,
          fileName: event.fileName,
          contentType: event.contentType,
        ),
      ),
    );
  }

  Future<void> _onDeleteAdjunto(
    EquipamientoAdjuntoDeleteRequested event,
    Emitter<EquipamientoVehiculoState> emit,
  ) {
    return _guardar(
      emit,
      mensaje: 'Documento adjunto eliminado.',
      accion: () async => _reemplazar(await _repository.eliminarAdjunto(event.id)),
    );
  }

  /// Ejecuta una escritura y publica el resultado una sola vez
  Future<void> _guardar(
    Emitter<EquipamientoVehiculoState> emit, {
    required String mensaje,
    required Future<List<StockVehiculoEntity>> Function() accion,
  }) async {
    emit(state.copyWith(saving: true));
    try {
      final List<StockVehiculoEntity> lineas = await accion();
      emit(state.copyWith(
        lineas: lineas,
        saving: false,
        operacion: state.operacion + 1,
        resultado: EquipamientoResultado.exito,
        mensaje: mensaje,
        clearError: true,
      ));
    } catch (e) {
      debugPrint('❌ EquipamientoVehiculoBloc: error en operación: $e');
      emit(state.copyWith(
        saving: false,
        operacion: state.operacion + 1,
        resultado: EquipamientoResultado.error,
        error: e.toString(),
      ));
    }
  }

  List<StockVehiculoEntity> _reemplazar(StockVehiculoEntity linea) => state.lineas
      .map((StockVehiculoEntity l) => l.id == linea.id ? linea : l)
      .toList();
}
