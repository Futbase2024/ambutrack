import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../auth/domain/entities/user_entity.dart';

part 'perfil_state.freezed.dart';

/// Estados del BLoC de Perfil
@freezed
class PerfilState with _$PerfilState {
  /// Estado inicial
  const factory PerfilState.initial() = _Initial;

  /// Estado de carga inicial
  const factory PerfilState.loading() = _Loading;

  /// Estado cuando el perfil ha sido cargado
  const factory PerfilState.loaded({
    required UserEntity user,
  }) = _Loaded;

  /// Estado mientras se actualiza el perfil
  const factory PerfilState.updating() = _Updating;

  /// Estado de éxito después de actualizar
  const factory PerfilState.updateSuccess({
    required String message,
  }) = _UpdateSuccess;

  /// Estado de error
  const factory PerfilState.error({
    required String message,
  }) = _Error;
}
