import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../auth/domain/entities/user_entity.dart';
import '../../domain/repositories/perfil_repository.dart';
import 'perfil_event.dart';
import 'perfil_state.dart';

/// BLoC para gestionar el estado del perfil de usuario
@injectable
class PerfilBloc extends Bloc<PerfilEvent, PerfilState> {
  PerfilBloc(this._repository) : super(const PerfilState.initial()) {
    on<PerfilEvent>(_onEvent);
  }

  final PerfilRepository _repository;

  Future<void> _onEvent(PerfilEvent event, Emitter<PerfilState> emit) async {
    await event.when(
      loaded: () => _onLoaded(emit),
      updateProfileRequested: (String? displayName, String? phoneNumber, String? photoUrl) =>
          _onUpdateProfileRequested(
        emit,
        displayName: displayName,
        phoneNumber: phoneNumber,
        photoUrl: photoUrl,
      ),
      updatePasswordRequested: (String newPassword) =>
          _onUpdatePasswordRequested(emit, newPassword: newPassword),
    );
  }

  Future<void> _onLoaded(Emitter<PerfilState> emit) async {
    debugPrint('🔄 PerfilBloc: Cargando perfil del usuario...');
    emit(const PerfilState.loading());

    try {
      // Refrescar datos del usuario desde la base de datos
      final UserEntity? user = await _repository.refreshCurrentUser();

      if (user == null) {
        debugPrint('❌ PerfilBloc: No hay usuario autenticado');
        emit(const PerfilState.error(
          message: 'No se pudo cargar el perfil. Usuario no autenticado.',
        ));
        return;
      }

      debugPrint('✅ PerfilBloc: Perfil cargado - ${user.email}');
      debugPrint('   - Nombre: ${user.displayName}');
      debugPrint('   - DNI: ${user.dni}');
      debugPrint('   - Rol: ${user.rol}');
      emit(PerfilState.loaded(user: user));
    } catch (e) {
      debugPrint('❌ PerfilBloc: Error al cargar perfil - $e');
      emit(PerfilState.error(
        message: 'Error al cargar el perfil: ${e.toString()}',
      ));
    }
  }

  Future<void> _onUpdateProfileRequested(
    Emitter<PerfilState> emit, {
    String? displayName,
    String? phoneNumber,
    String? photoUrl,
  }) async {
    debugPrint('📝 PerfilBloc: Actualizando perfil...');
    debugPrint('  - displayName: $displayName');
    debugPrint('  - phoneNumber: $phoneNumber');
    debugPrint('  - photoUrl: $photoUrl');

    emit(const PerfilState.updating());

    try {
      // Actualizar perfil en el repositorio
      await _repository.updateProfile(
        displayName: displayName,
        phoneNumber: phoneNumber,
        photoUrl: photoUrl,
      );

      debugPrint('✅ PerfilBloc: Perfil actualizado correctamente');
      emit(const PerfilState.updateSuccess(
        message: 'Tu perfil ha sido actualizado correctamente.',
      ));

      // Recargar el perfil después de actualizar
      add(const PerfilEvent.loaded());
    } catch (e) {
      debugPrint('❌ PerfilBloc: Error al actualizar perfil - $e');
      emit(PerfilState.error(
        message: 'Error al actualizar el perfil: ${e.toString()}',
      ));

      // Intentar recargar el perfil incluso si hubo error
      add(const PerfilEvent.loaded());
    }
  }

  Future<void> _onUpdatePasswordRequested(
    Emitter<PerfilState> emit, {
    required String newPassword,
  }) async {
    debugPrint('🔒 PerfilBloc: Cambiando contraseña...');

    emit(const PerfilState.updating());

    try {
      // Validar longitud mínima
      if (newPassword.length < 6) {
        throw Exception('La contraseña debe tener al menos 6 caracteres');
      }

      // Actualizar contraseña en el repositorio
      await _repository.updatePassword(newPassword);

      debugPrint('✅ PerfilBloc: Contraseña cambiada correctamente');
      emit(const PerfilState.updateSuccess(
        message: 'Tu contraseña ha sido cambiada correctamente.',
      ));

      // Recargar el perfil después de cambiar contraseña
      add(const PerfilEvent.loaded());
    } catch (e) {
      debugPrint('❌ PerfilBloc: Error al cambiar contraseña - $e');
      emit(PerfilState.error(
        message: 'Error al cambiar la contraseña: ${e.toString()}',
      ));

      // Intentar recargar el perfil incluso si hubo error
      add(const PerfilEvent.loaded());
    }
  }
}
