import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';

part 'notificaciones_state.freezed.dart';

/// Estados del BLoC de notificaciones
@freezed
class NotificacionesState with _$NotificacionesState {
  /// Estado inicial
  const factory NotificacionesState.initial() = _Initial;

  /// Cargando notificaciones
  const factory NotificacionesState.loading() = _Loading;

  /// Notificaciones cargadas correctamente
  const factory NotificacionesState.loaded({
    required List<NotificacionEntity> notificaciones,
    required int conteoNoLeidas,
    @Default(false) bool isRefreshing,
  }) = _Loaded;

  /// Error al cargar notificaciones
  const factory NotificacionesState.error({
    required String message,
    List<NotificacionEntity>? notificacionesPrevias,
    int? conteoNoLeidasPrevio,
  }) = _Error;
}
