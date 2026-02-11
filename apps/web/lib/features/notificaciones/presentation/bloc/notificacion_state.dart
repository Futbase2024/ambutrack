import 'package:ambutrack_core/ambutrack_core.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'notificacion_state.freezed.dart';

/// Estados del BLoC de notificaciones
@freezed
class NotificacionState with _$NotificacionState {
  const factory NotificacionState.initial() = _Initial;

  const factory NotificacionState.loading() = _Loading;

  const factory NotificacionState.loaded({
    required List<NotificacionEntity> notificaciones,
    required int conteoNoLeidas,
  }) = _Loaded;

  const factory NotificacionState.error(String message) = _Error;
}
