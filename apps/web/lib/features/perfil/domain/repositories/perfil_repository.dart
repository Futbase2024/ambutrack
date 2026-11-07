import 'package:ambutrack_web/features/auth/domain/entities/user_entity.dart';

/// Repositorio para gestionar el perfil del usuario
abstract class PerfilRepository {
  /// Obtiene el usuario actual desde AuthRepository
  UserEntity? getCurrentUser();

  /// Refresca los datos del usuario actual desde la base de datos
  Future<UserEntity?> refreshCurrentUser();

  /// Actualiza el perfil del usuario
  ///
  /// Parámetros opcionales:
  /// - [displayName]: Nombre completo del usuario
  /// - [phoneNumber]: Número de teléfono
  /// - [photoUrl]: URL de la foto de perfil
  Future<void> updateProfile({
    String? displayName,
    String? phoneNumber,
    String? photoUrl,
  });

  /// Actualiza la contraseña del usuario
  ///
  /// [newPassword]: Nueva contraseña (mínimo 6 caracteres)
  Future<void> updatePassword(String newPassword);
}
