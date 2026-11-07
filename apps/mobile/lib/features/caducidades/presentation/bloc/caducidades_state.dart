import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';

part 'caducidades_state.freezed.dart';

/// Estados del CaducidadesBloc
@freezed
class CaducidadesState with _$CaducidadesState {
  /// Estado inicial
  const factory CaducidadesState.initial() = _Initial;

  /// Cargando datos
  const factory CaducidadesState.loading() = _Loading;

  /// Caducidades cargadas
  const factory CaducidadesState.loaded({
    required List<StockVehiculoEntity> items,
    required List<AlertaStockEntity> alertas,
    required String vehiculoId,
    String? filtroActual, // null, 'ok', 'proximo', 'critico', 'caducado'
    @Default(0) int totalItems,
    @Default(0) int itemsOk,
    @Default(0) int itemsProximos,
    @Default(0) int itemsCriticos,
    @Default(0) int itemsCaducados,
    @Default(false) bool isRefreshing,
  }) = _Loaded;

  /// Procesando acción (solicitar reposición, registrar incidencia)
  const factory CaducidadesState.procesando({
    required String mensaje,
  }) = _Procesando;

  /// Acción completada exitosamente
  const factory CaducidadesState.accionExitosa({
    required String mensaje,
    String? vehiculoId, // Para recargar después
  }) = _AccionExitosa;

  /// Error al realizar operación
  const factory CaducidadesState.error({
    required String mensaje,
    String? vehiculoId,
  }) = _Error;
}
