import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';

part 'checklist_event.freezed.dart';

/// Eventos del ChecklistBloc
@freezed
class ChecklistEvent with _$ChecklistEvent {
  /// Evento inicial - Carga historial del vehículo asignado
  const factory ChecklistEvent.started() = _Started;

  /// Cargar historial de checklists de un vehículo
  const factory ChecklistEvent.cargarHistorial({
    required String vehiculoId,
  }) = _CargarHistorial;

  /// Cargar plantilla de items para un tipo de checklist
  const factory ChecklistEvent.cargarPlantilla({
    required TipoChecklist tipo,
  }) = _CargarPlantilla;

  /// Iniciar nuevo checklist
  ///
  /// Carga la plantilla de ítems y prepara el estado para crear checklist
  const factory ChecklistEvent.iniciarNuevoChecklist({
    required String vehiculoId,
    required TipoChecklist tipo,
  }) = _IniciarNuevoChecklist;

  /// Actualizar resultado de un ítem individual
  ///
  /// [index] Índice del ítem en la lista
  /// [resultado] Nuevo resultado (presente/ausente/noAplica)
  /// [observaciones] Observaciones opcionales (obligatorias si ausente)
  const factory ChecklistEvent.actualizarItem({
    required int index,
    required ResultadoItem resultado,
    String? observaciones,
  }) = _ActualizarItem;

  /// Guardar checklist completo
  ///
  /// Valida que todos los ítems estén verificados y guarda en Supabase
  const factory ChecklistEvent.guardarChecklist({
    required double kilometraje,
    required String empresaId,
    required String realizadoPor,
    required String realizadoPorNombre,
    String? observacionesGenerales,
    String? firmaUrl,
  }) = _GuardarChecklist;

  /// Cancelar creación de checklist
  ///
  /// Vuelve al estado de historial sin guardar cambios
  const factory ChecklistEvent.cancelarChecklist() = _CancelarChecklist;

  /// Recargar historial (pull-to-refresh)
  const factory ChecklistEvent.refrescarHistorial() = _RefrescarHistorial;

  /// Ver detalle de un checklist guardado
  const factory ChecklistEvent.verDetalle({
    required String checklistId,
  }) = _VerDetalle;
}
