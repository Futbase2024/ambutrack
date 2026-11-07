import 'package:freezed_annotation/freezed_annotation.dart';

part 'perfil_event.freezed.dart';

/// Eventos del BLoC de Perfil
@freezed
class PerfilEvent with _$PerfilEvent {
  /// Evento para cargar el perfil del usuario actual
  const factory PerfilEvent.loaded() = _Loaded;

  /// Evento para solicitar actualización del perfil
  const factory PerfilEvent.updateProfileRequested({
    String? displayName,
    String? phoneNumber,
    String? photoUrl,
  }) = _UpdateProfileRequested;

  /// Evento para solicitar cambio de contraseña
  const factory PerfilEvent.updatePasswordRequested({
    required String newPassword,
  }) = _UpdatePasswordRequested;
}
