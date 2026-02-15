import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'alertas_caducidad_event.dart';

part 'alertas_caducidad_state.freezed.dart';

/// Estados para el BLoC de Alertas de Caducidad
@freezed
class AlertasCaducidadState with _$AlertasCaducidadState {
  /// Estado inicial
  const factory AlertasCaducidadState.initial() = _Initial;

  /// Estado de carga
  const factory AlertasCaducidadState.loading() = _Loading;

  /// Estado con datos cargados
  const factory AlertasCaducidadState.loaded({
    required List<AlertaCaducidadEntity> alertas,
    required AlertasResumenEntity resumen,
    @Default(AlertaTipoFilter.all) AlertaTipoFilter filtroTipo,
    @Default(AlertaSeveridadFilter.all) AlertaSeveridadFilter filtroSeveridad,
    @Default(false) bool isRefreshing,
  }) = _Loaded;

  /// Estado de error
  const factory AlertasCaducidadState.error({
    required String message,
    List<AlertaCaducidadEntity>? alertasPrevias,
    AlertasResumenEntity? resumenPrevio,
  }) = _Error;
}
