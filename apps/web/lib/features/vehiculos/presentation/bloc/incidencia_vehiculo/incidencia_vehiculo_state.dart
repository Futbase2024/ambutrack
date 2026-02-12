import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'incidencia_vehiculo_state.freezed.dart';

/// Estados del BLoC de incidencias de vehículos
@freezed
class IncidenciaVehiculoState with _$IncidenciaVehiculoState {
  /// Estado inicial - Antes de cargar datos
  const factory IncidenciaVehiculoState.initial() = _Initial;

  /// Estado de carga - Mostrando loading indicator
  const factory IncidenciaVehiculoState.loading() = _Loading;

  /// Estado con datos cargados
  const factory IncidenciaVehiculoState.loaded({
    required List<IncidenciaVehiculoEntity> incidencias,
    required int currentPage,
    required int totalPages,
    @Default(null) EstadoIncidencia? filtroEstado,
    @Default(null) PrioridadIncidencia? filtroPrioridad,
    @Default(null) TipoIncidencia? filtroTipo,
  }) = _Loaded;

  /// Estado de error
  const factory IncidenciaVehiculoState.error(String message) = _Error;
}
