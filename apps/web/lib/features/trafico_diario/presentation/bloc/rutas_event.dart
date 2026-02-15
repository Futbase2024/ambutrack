import 'package:freezed_annotation/freezed_annotation.dart';

part 'rutas_event.freezed.dart';

/// Eventos del RutasBloc
@freezed
class RutasEvent with _$RutasEvent {
  /// Evento de inicialización
  const factory RutasEvent.started() = _Started;

  /// Evento para cargar la ruta de un técnico
  const factory RutasEvent.cargarRutaRequested({
    required String tecnicoId,
    required DateTime fecha,
    String? turno,
  }) = _CargarRutaRequested;

  /// Evento para optimizar la ruta automáticamente
  const factory RutasEvent.optimizarRutaRequested() = _OptimizarRutaRequested;

  /// Evento para reordenar traslados manualmente
  const factory RutasEvent.reordenarTrasladosRequested({
    required List<String> nuevoOrdenIds,
  }) = _ReordenarTrasladosRequested;

  /// Evento para refrescar los datos
  const factory RutasEvent.refreshRequested() = _RefreshRequested;

  /// Evento para limpiar la ruta actual
  const factory RutasEvent.limpiarRuta() = _LimpiarRuta;
}
