import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'consumo_combustible_state.freezed.dart';

/// Estados del BLoC de consumo de combustible
@freezed
class ConsumoCombustibleState with _$ConsumoCombustibleState {
  /// Estado inicial - Antes de cargar datos
  const factory ConsumoCombustibleState.initial() = _Initial;

  /// Estado de carga - Mostrando loading indicator
  const factory ConsumoCombustibleState.loading() = _Loading;

  /// Estado con datos cargados
  const factory ConsumoCombustibleState.loaded({
    required List<ConsumoCombustibleEntity> registros,
    required List<VehiculoEntity> vehiculos,
    required int currentPage,
    required int totalPages,
    required Map<String, double> estadisticas,
    @Default(null) String? filtroVehiculoId,
    @Default(null) DateTime? filtroFechaInicio,
    @Default(null) DateTime? filtroFechaFin,
  }) = _Loaded;

  /// Estado de error
  const factory ConsumoCombustibleState.error(String message) = _Error;
}
