import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../vehiculo/domain/repositories/incidencias_repository.dart';

enum IncidenciaDetalleStatus { cargando, listo, guardando, error }

class IncidenciaDetalleState extends Equatable {
  const IncidenciaDetalleState({
    this.status = IncidenciaDetalleStatus.cargando,
    this.incidencia,
    this.error,
  });

  final IncidenciaDetalleStatus status;
  final IncidenciaVehiculoEntity? incidencia;
  final String? error;

  IncidenciaDetalleState copyWith({
    IncidenciaDetalleStatus? status,
    IncidenciaVehiculoEntity? incidencia,
    String? error,
  }) {
    return IncidenciaDetalleState(
      status: status ?? this.status,
      incidencia: incidencia ?? this.incidencia,
      error: error,
    );
  }

  @override
  List<Object?> get props => <Object?>[status, incidencia, error];
}

/// Carga una incidencia de vehículo y permite cambiar su estado desde la notificación
class IncidenciaDetalleCubit extends Cubit<IncidenciaDetalleState> {
  IncidenciaDetalleCubit(this._repository) : super(const IncidenciaDetalleState());

  final IncidenciasRepository _repository;

  Future<void> cargar(String id) async {
    emit(const IncidenciaDetalleState());
    try {
      final IncidenciaVehiculoEntity incidencia = await _repository.getById(id);
      emit(IncidenciaDetalleState(status: IncidenciaDetalleStatus.listo, incidencia: incidencia));
    } catch (e) {
      debugPrint('❌ [IncidenciaDetalleCubit] Error al cargar incidencia $id: $e');
      emit(const IncidenciaDetalleState(
        status: IncidenciaDetalleStatus.error,
        error: 'No se ha podido cargar la incidencia.',
      ));
    }
  }

  /// Cambia el estado y guarda la nota como solución aplicada.
  /// Devuelve true si se ha guardado.
  Future<bool> actualizar(EstadoIncidencia estado, String nota) async {
    final IncidenciaVehiculoEntity? actual = state.incidencia;
    if (actual == null) {
      return false;
    }
    emit(state.copyWith(status: IncidenciaDetalleStatus.guardando));
    final DateTime ahora = DateTime.now();
    final bool cierra = estado == EstadoIncidencia.resuelta || estado == EstadoIncidencia.cerrada;
    final String texto = nota.trim();
    try {
      final IncidenciaVehiculoEntity guardada = await _repository.update(actual.copyWith(
        estado: estado,
        solucionAplicada: texto.isEmpty ? null : texto,
        fechaResolucion: cierra ? (actual.fechaResolucion ?? ahora) : null,
        updatedAt: ahora,
      ));
      emit(IncidenciaDetalleState(status: IncidenciaDetalleStatus.listo, incidencia: guardada));
      return true;
    } catch (e) {
      debugPrint('❌ [IncidenciaDetalleCubit] Error al actualizar incidencia: $e');
      emit(state.copyWith(
        status: IncidenciaDetalleStatus.listo,
        error: 'No se ha podido actualizar la incidencia.',
      ));
      return false;
    }
  }
}
