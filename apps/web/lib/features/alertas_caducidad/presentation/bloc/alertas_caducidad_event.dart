import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'alertas_caducidad_event.freezed.dart';

/// Eventos para el BLoC de Alertas de Caducidad
@freezed
class AlertasCaducidadEvent with _$AlertasCaducidadEvent {
  /// Evento inicial al cargar el BLoC
  const factory AlertasCaducidadEvent.started() = _Started;

  /// Cargar todas las alertas activas
  const factory AlertasCaducidadEvent.loadAlertas({
    String? usuarioId,
    int? umbralSeguro,
    int? umbralItv,
    int? umbralHomologacion,
    int? umbralMantenimiento,
  }) = _LoadAlertas;

  /// Cargar solo las alertas críticas
  const factory AlertasCaducidadEvent.loadAlertasCriticas({
    String? usuarioId,
  }) = _LoadAlertasCriticas;

  /// Cargar el resumen de alertas
  const factory AlertasCaducidadEvent.loadResumen() = _LoadResumen;

  /// Refrescar todas las alertas
  const factory AlertasCaducidadEvent.refresh() = _Refresh;

  /// Filtrar alertas por tipo
  const factory AlertasCaducidadEvent.filterByTipo(AlertaTipoFilter tipo) =
      _FilterByTipo;

  /// Filtrar alertas por severidad
  const factory AlertasCaducidadEvent.filterBySeveridad(
    AlertaSeveridadFilter severidad,
  ) = _FilterBySeveridad;

  /// Marcar una alerta como vista
  const factory AlertasCaducidadEvent.markAsViewed({
    required String alertaId,
    required AlertaTipo tipo,
    required String entidadId,
  }) = _MarkAsViewed;

  /// Limpiar todos los filtros
  const factory AlertasCaducidadEvent.clearFilters() = _ClearFilters;
}

/// Filtro de tipo de alerta para UI
enum AlertaTipoFilter {
  all,
  seguro,
  itv,
  homologacion,
  revisionTecnica,
  revision,
  mantenimiento,
}

/// Filtro de severidad para UI
enum AlertaSeveridadFilter {
  all,
  critica,
  alta,
  media,
  baja,
}
