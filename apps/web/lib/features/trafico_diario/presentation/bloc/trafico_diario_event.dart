import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'trafico_diario_event.freezed.dart';

/// Eventos del BLoC de Tráfico Diario (Planificación de Traslados)
@freezed
class TraficoDiarioEvent with _$TraficoDiarioEvent {
  /// Evento inicial - prepara el estado
  const factory TraficoDiarioEvent.started() = _Started;

  /// Carga traslados de los servicios actuales para una fecha específica
  const factory TraficoDiarioEvent.loadTrasladosRequested({
    required List<String> idsServiciosRecurrentes,
    required DateTime fecha,
  }) = _LoadTrasladosRequested;

  /// Solicita refresco de traslados
  const factory TraficoDiarioEvent.refreshRequested() = _RefreshRequested;

  /// Asigna un conductor, vehículo y matrícula a un traslado individual
  const factory TraficoDiarioEvent.asignarConductorRequested({
    required String idTraslado,
    required String idConductor,
    required String idVehiculo,
    required String matriculaVehiculo,
  }) = _AsignarConductorRequested;

  /// Asigna un conductor, vehículo y matrícula a múltiples traslados
  const factory TraficoDiarioEvent.asignarConductorMasivoRequested({
    required List<String> idTraslados,
    required String idConductor,
    required String idVehiculo,
    required String matriculaVehiculo,
  }) = _AsignarConductorMasivoRequested;

  /// Filtra traslados por estado
  const factory TraficoDiarioEvent.filterByEstadoChanged({
    String? estado,
  }) = _FilterByEstadoChanged;

  /// Filtra traslados por centro hospitalario
  const factory TraficoDiarioEvent.filterByCentroChanged({
    String? idCentro,
  }) = _FilterByCentroChanged;

  /// Busca traslados por query (paciente, centro, etc.)
  const factory TraficoDiarioEvent.searchChanged({
    required String query,
  }) = _SearchChanged;

  /// Desasigna conductor y vehículo de un traslado
  /// Pone el estado del traslado de vuelta a 'pendiente'
  const factory TraficoDiarioEvent.desasignarConductorRequested({
    required String idTraslado,
  }) = _DesasignarConductorRequested;

  /// Desasigna conductor y vehículo de múltiples traslados
  /// Pone el estado de todos los traslados de vuelta a 'pendiente'
  const factory TraficoDiarioEvent.desasignarConductorMasivoRequested({
    required List<String> idTraslados,
  }) = _DesasignarConductorMasivoRequested;

  /// Modifica la hora programada de un traslado
  const factory TraficoDiarioEvent.modificarHoraRequested({
    required String idTraslado,
    required DateTime nuevaHora,
  }) = _ModificarHoraRequested;

  /// Cancela un traslado (cambia estado a 'cancelado')
  const factory TraficoDiarioEvent.cancelarTrasladoRequested({
    required String idTraslado,
    String? motivoCancelacion,
  }) = _CancelarTrasladoRequested;

  /// Actualiza un traslado específico desde el stream Realtime
  /// Usado cuando llega una actualización de estado/horas desde mobile
  const factory TraficoDiarioEvent.trasladoActualizadoFromRealtime({
    required TrasladoEntity traslado,
  }) = _TrasladoActualizadoFromRealtime;
}
