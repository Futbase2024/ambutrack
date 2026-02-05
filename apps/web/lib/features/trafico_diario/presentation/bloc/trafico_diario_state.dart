import 'package:ambutrack_core/ambutrack_core.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'trafico_diario_state.freezed.dart';

/// Estados del BLoC de Tráfico Diario (Planificación de Traslados)
@freezed
class TraficoDiarioState with _$TraficoDiarioState {
  /// Estado inicial
  const factory TraficoDiarioState.initial() = _Initial;

  /// Cargando traslados
  const factory TraficoDiarioState.loading() = _Loading;

  /// Traslados cargados exitosamente
  const factory TraficoDiarioState.loaded({
    required List<TrasladoEntity> traslados,
    @Default('') String searchQuery,
    String? estadoFilter,
    String? centroFilter,
    @Default(false) bool isRefreshing,
  }) = _Loaded;

  /// Error al cargar traslados
  const factory TraficoDiarioState.error({
    required String message,
  }) = _Error;
}
