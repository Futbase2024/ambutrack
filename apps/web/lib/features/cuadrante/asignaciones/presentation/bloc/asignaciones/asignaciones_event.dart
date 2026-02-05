import 'package:ambutrack_core/ambutrack_core.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'asignaciones_event.freezed.dart';

@freezed
class AsignacionesEvent with _$AsignacionesEvent {
  const factory AsignacionesEvent.loadAll() = AsignacionesLoadAllRequested;

  const factory AsignacionesEvent.loadByFecha(DateTime fecha) =
      AsignacionesLoadByFechaRequested;

  const factory AsignacionesEvent.loadByRango(
    DateTime inicio,
    DateTime fin,
  ) = AsignacionesLoadByRangoRequested;

  const factory AsignacionesEvent.loadByVehiculo(
    String vehiculoId,
    DateTime fecha,
  ) = AsignacionesLoadByVehiculoRequested;

  const factory AsignacionesEvent.loadByEstado(String estado) =
      AsignacionesLoadByEstadoRequested;

  const factory AsignacionesEvent.create(AsignacionVehiculoTurnoEntity asignacion) =
      AsignacionCreateRequested;

  const factory AsignacionesEvent.update(AsignacionVehiculoTurnoEntity asignacion) =
      AsignacionUpdateRequested;

  const factory AsignacionesEvent.delete(String id) = AsignacionDeleteRequested;
}
