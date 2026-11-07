import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'consumo_combustible_event.freezed.dart';

/// Eventos del BLoC de consumo de combustible
@freezed
class ConsumoCombustibleEvent with _$ConsumoCombustibleEvent {
  /// Evento inicial - Carga registros al iniciar
  const factory ConsumoCombustibleEvent.started() = _Started;

  /// Recargar registros desde el repositorio
  const factory ConsumoCombustibleEvent.loadRegistros() = _LoadRegistros;

  /// Cargar registros de un vehículo específico
  const factory ConsumoCombustibleEvent.loadByVehiculo(String vehiculoId) =
      _LoadByVehiculo;

  /// Cargar registros por rango de fechas
  const factory ConsumoCombustibleEvent.loadByRangoFechas(
    DateTime fechaInicio,
    DateTime fechaFin,
  ) = _LoadByRangoFechas;

  /// Crear nuevo registro de consumo
  const factory ConsumoCombustibleEvent.createRegistro(
    ConsumoCombustibleEntity consumo,
  ) = _CreateRegistro;

  /// Actualizar registro existente
  const factory ConsumoCombustibleEvent.updateRegistro(
    ConsumoCombustibleEntity consumo,
  ) = _UpdateRegistro;

  /// Eliminar registro por ID
  const factory ConsumoCombustibleEvent.deleteRegistro(String id) =
      _DeleteRegistro;

  /// Filtrar por vehículo
  const factory ConsumoCombustibleEvent.filterByVehiculo(
    String? vehiculoId,
  ) = _FilterByVehiculo;

  /// Filtrar por rango de fechas
  const factory ConsumoCombustibleEvent.filterByFecha(
    DateTime? fechaInicio,
    DateTime? fechaFin,
  ) = _FilterByFecha;

  /// Limpiar todos los filtros
  const factory ConsumoCombustibleEvent.clearFilters() = _ClearFilters;

  /// Cambiar página de la paginación
  const factory ConsumoCombustibleEvent.changePage(int page) = _ChangePage;

  /// Suscribirse al stream en tiempo real de un vehículo
  const factory ConsumoCombustibleEvent.subscribeToVehiculo(
    String vehiculoId,
  ) = _SubscribeToVehiculo;

  /// Cancelar suscripción al stream
  const factory ConsumoCombustibleEvent.unsubscribe() = _Unsubscribe;
}
