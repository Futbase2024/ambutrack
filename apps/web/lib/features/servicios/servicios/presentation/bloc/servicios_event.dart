import 'package:freezed_annotation/freezed_annotation.dart';

part 'servicios_event.freezed.dart';

/// Eventos del BLoC de Servicios
@freezed
class ServiciosEvent with _$ServiciosEvent {
  /// Evento inicial - carga todos los servicios
  const factory ServiciosEvent.started() = _Started;

  /// Solicita carga de servicios
  const factory ServiciosEvent.loadRequested() = _LoadRequested;

  /// Solicita refresco de servicios
  const factory ServiciosEvent.refreshRequested() = _RefreshRequested;

  /// Busca servicios por query
  const factory ServiciosEvent.searchChanged({required String query}) = _SearchChanged;

  /// Filtra por año
  const factory ServiciosEvent.yearFilterChanged({required int? year}) = _YearFilterChanged;

  /// Filtra por estado
  const factory ServiciosEvent.estadoFilterChanged({required String? estado}) = _EstadoFilterChanged;

  /// Actualiza el estado de un servicio
  const factory ServiciosEvent.updateEstadoRequested({
    required String id,
    required String estado,
  }) = _UpdateEstadoRequested;

  /// Reanuda un servicio suspendido
  const factory ServiciosEvent.reanudarRequested({required String id}) = _ReanudarRequested;

  /// Elimina un servicio
  const factory ServiciosEvent.deleteRequested({required String id}) = _DeleteRequested;

  /// Carga detalles de un servicio específico
  const factory ServiciosEvent.loadServicioDetailsRequested({required String id}) = _LoadServicioDetailsRequested;
}
