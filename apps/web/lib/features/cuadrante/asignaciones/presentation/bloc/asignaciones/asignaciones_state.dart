import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'asignaciones_state.freezed.dart';

@freezed
class AsignacionesState with _$AsignacionesState {
  const factory AsignacionesState.initial() = AsignacionesInitial;

  const factory AsignacionesState.loading() = AsignacionesLoading;

  const factory AsignacionesState.loaded(
    List<AsignacionVehiculoTurnoEntity> asignaciones,
  ) = AsignacionesLoaded;

  const factory AsignacionesState.operationSuccess({
    required String message,
    required List<AsignacionVehiculoTurnoEntity> asignaciones,
  }) = AsignacionOperationSuccess;

  const factory AsignacionesState.error(String message) = AsignacionesError;
}
