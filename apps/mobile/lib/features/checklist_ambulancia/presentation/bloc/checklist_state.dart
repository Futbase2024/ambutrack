import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';

part 'checklist_state.freezed.dart';

/// Estados del ChecklistBloc
@freezed
class ChecklistState with _$ChecklistState {
  /// Estado inicial
  const factory ChecklistState.initial() = _Initial;

  /// Cargando datos
  const factory ChecklistState.loading() = _Loading;

  /// Historial de checklists cargado
  ///
  /// Muestra lista de checklists realizados para un vehículo
  const factory ChecklistState.historialCargado({
    required List<ChecklistVehiculoEntity> checklists,
    required String vehiculoId,
  }) = _HistorialCargado;

  /// Creando nuevo checklist
  ///
  /// Estado durante la creación de un checklist (formulario)
  /// Mantiene el progreso temporal hasta guardar
  const factory ChecklistState.creandoChecklist({
    required String vehiculoId,
    required TipoChecklist tipo,
    required List<ItemChecklistEntity> items,
    required Map<int, ResultadoItem> resultados,
    required Map<int, String> observaciones,
  }) = _CreandoChecklist;

  /// Guardando checklist en Supabase
  const factory ChecklistState.guardando() = _Guardando;

  /// Checklist guardado exitosamente
  ///
  /// Muestra el checklist recién creado antes de volver al historial
  const factory ChecklistState.checklistGuardado({
    required ChecklistVehiculoEntity checklist,
  }) = _ChecklistGuardado;

  /// Viendo detalle de checklist guardado
  ///
  /// Estado read-only para ver un checklist pasado
  const factory ChecklistState.viendoDetalle({
    required ChecklistVehiculoEntity checklist,
  }) = _ViendoDetalle;

  /// Error al realizar operación
  const factory ChecklistState.error({
    required String mensaje,
    String? vehiculoId,
  }) = _Error;
}
