import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/auth/enums/app_module.dart';
import 'package:ambutrack_web/core/auth/enums/user_role.dart';
import 'package:ambutrack_web/core/auth/permissions/crud_permissions.dart';
import 'package:ambutrack_web/core/auth/permissions/gestion_usuarios_permissions.dart';
import 'package:ambutrack_web/core/auth/services/role_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/repositories/usuarios_repository.dart';
import 'usuarios_event.dart';
import 'usuarios_state.dart';

/// BLoC para gestionar usuarios
///
/// Maneja todas las operaciones CRUD de usuarios:
/// - Carga de lista completa
/// - Creación (con password en auth.users)
/// - Actualización
/// - Eliminación (auth.users + tabla usuarios)
/// - Reset de contraseña
/// - Cambio de estado activo/inactivo
///
/// ⚠️ PERMISOS: Admin (todo) y Jefe de Personal (personal operativo, sin eliminar).
/// La Edge Function `admin-users` vuelve a validarlo en servidor.
@injectable
class UsuariosBloc extends Bloc<UsuariosEvent, UsuariosState> {
  UsuariosBloc(this._repository, this._roleService) : super(const UsuariosInitial()) {
    on<UsuariosLoadAllRequested>(_onLoadAllRequested);
    on<UsuariosCreateRequested>(_onCreateRequested);
    on<UsuariosUpdateRequested>(_onUpdateRequested);
    on<UsuariosDeleteRequested>(_onDeleteRequested);
    on<UsuariosResetPasswordRequested>(_onResetPasswordRequested);
    on<UsuariosCambiarEstadoRequested>(_onCambiarEstadoRequested);
  }

  final UsuariosRepository _repository;
  final RoleService _roleService;

  /// Handler: Cargar todos los usuarios
  Future<void> _onLoadAllRequested(
    UsuariosLoadAllRequested event,
    Emitter<UsuariosState> emit,
  ) async {
    try {
      debugPrint('📋 UsuariosBloc: Cargando lista de usuarios');
      emit(const UsuariosLoading());

      final List<UserEntity> usuarios = await _repository.getAll();
      final UserRole rolActual = await _roleService.getCurrentUserRole();

      debugPrint('✅ UsuariosBloc: ${usuarios.length} usuarios cargados');
      emit(UsuariosLoaded(usuarios, rolActual: rolActual));
    } catch (e) {
      debugPrint('❌ UsuariosBloc: Error al cargar usuarios - $e');
      emit(UsuariosError(e.toString()));
    }
  }

  /// Handler: Crear nuevo usuario
  Future<void> _onCreateRequested(
    UsuariosCreateRequested event,
    Emitter<UsuariosState> emit,
  ) async {
    try {
      // ✅ VALIDAR PERMISOS: Admin o Jefe de Personal
      final UserRole role = await _roleService.getCurrentUserRole();
      if (!GestionUsuariosPermissions.puedeCrear(role)) {
        debugPrint('🚫 UsuariosBloc: Usuario sin permisos para crear usuarios');
        emit(const UsuariosError(
          'No tienes permisos para crear usuarios.\n'
          'Solo el Administrador y el Jefe de Personal pueden gestionar usuarios.',
        ));
        return;
      }

      debugPrint('🚀 UsuariosBloc: Creando usuario ${event.usuario.email}');
      emit(const UsuariosCreating());

      final UserEntity usuario = await _repository.create(event.usuario, event.password);

      debugPrint('✅ UsuariosBloc: Usuario creado con ID: ${usuario.uid}');
      emit(UsuariosCreated(usuario));

      // Recargar lista
      add(const UsuariosLoadAllRequested());
    } catch (e) {
      debugPrint('❌ UsuariosBloc: Error al crear usuario - $e');
      emit(UsuariosError(e.toString()));

      // Recargar lista incluso si hubo error
      add(const UsuariosLoadAllRequested());
    }
  }

  /// Handler: Actualizar usuario
  Future<void> _onUpdateRequested(
    UsuariosUpdateRequested event,
    Emitter<UsuariosState> emit,
  ) async {
    try {
      // ✅ VALIDAR PERMISOS: Admin o Jefe de Personal
      final UserRole role = await _roleService.getCurrentUserRole();
      if (!CrudPermissions.canUpdate(role, AppModule.usuariosRoles)) {
        debugPrint('🚫 UsuariosBloc: Usuario sin permisos para actualizar usuarios');
        emit(const UsuariosError(
          'No tienes permisos para actualizar usuarios.\n'
          'Solo el Administrador y el Jefe de Personal pueden gestionar usuarios.',
        ));
        return;
      }

      debugPrint('📝 UsuariosBloc: Actualizando usuario ${event.usuario.uid}');
      emit(const UsuariosUpdating());

      final UserEntity usuario = await _repository.update(event.usuario);

      debugPrint('✅ UsuariosBloc: Usuario actualizado');
      emit(UsuariosUpdated(usuario));

      // Recargar lista
      add(const UsuariosLoadAllRequested());
    } catch (e) {
      debugPrint('❌ UsuariosBloc: Error al actualizar usuario - $e');
      emit(UsuariosError(e.toString()));

      // Recargar lista incluso si hubo error
      add(const UsuariosLoadAllRequested());
    }
  }

  /// Handler: Eliminar usuario
  Future<void> _onDeleteRequested(
    UsuariosDeleteRequested event,
    Emitter<UsuariosState> emit,
  ) async {
    try {
      // ✅ VALIDAR PERMISOS: Solo Admin elimina
      final UserRole role = await _roleService.getCurrentUserRole();
      if (!GestionUsuariosPermissions.puedeEliminar(role)) {
        debugPrint('🚫 UsuariosBloc: Usuario sin permisos para eliminar usuarios');
        emit(const UsuariosError(
          'No tienes permisos para eliminar usuarios.\n'
          'Solo el Administrador puede eliminar usuarios; desactívalo en su lugar.',
        ));
        return;
      }

      debugPrint('🗑️ UsuariosBloc: Eliminando usuario ${event.id}');
      emit(const UsuariosDeleting());

      await _repository.delete(event.id);

      debugPrint('✅ UsuariosBloc: Usuario eliminado');
      emit(const UsuariosDeleted());

      // Recargar lista
      add(const UsuariosLoadAllRequested());
    } catch (e) {
      debugPrint('❌ UsuariosBloc: Error al eliminar usuario - $e');
      emit(UsuariosError(e.toString()));

      // Recargar lista incluso si hubo error
      add(const UsuariosLoadAllRequested());
    }
  }

  /// Handler: Resetear contraseña
  Future<void> _onResetPasswordRequested(
    UsuariosResetPasswordRequested event,
    Emitter<UsuariosState> emit,
  ) async {
    try {
      // ✅ VALIDAR PERMISOS: Admin o Jefe de Personal
      final UserRole role = await _roleService.getCurrentUserRole();
      if (!CrudPermissions.canUpdate(role, AppModule.usuariosRoles)) {
        debugPrint('🚫 UsuariosBloc: Usuario sin permisos para resetear contraseñas');
        emit(const UsuariosError(
          'No tienes permisos para resetear contraseñas.\n'
          'Solo el Administrador y el Jefe de Personal pueden gestionar usuarios.',
        ));
        return;
      }

      debugPrint('🔒 UsuariosBloc: Reseteando contraseña de usuario ${event.userId}');
      emit(const UsuariosResettingPassword());

      await _repository.resetearPassword(event.userId, event.newPassword);

      debugPrint('✅ UsuariosBloc: Contraseña reseteada');
      emit(const UsuariosPasswordReset());

      // Recargar lista
      add(const UsuariosLoadAllRequested());
    } catch (e) {
      debugPrint('❌ UsuariosBloc: Error al resetear contraseña - $e');
      emit(UsuariosError(e.toString()));

      // Recargar lista incluso si hubo error
      add(const UsuariosLoadAllRequested());
    }
  }

  /// Handler: Cambiar estado activo/inactivo
  Future<void> _onCambiarEstadoRequested(
    UsuariosCambiarEstadoRequested event,
    Emitter<UsuariosState> emit,
  ) async {
    try {
      // ✅ VALIDAR PERMISOS: Admin o Jefe de Personal
      final UserRole role = await _roleService.getCurrentUserRole();
      if (!CrudPermissions.canUpdate(role, AppModule.usuariosRoles)) {
        debugPrint('🚫 UsuariosBloc: Usuario sin permisos para cambiar estado de usuarios');
        emit(const UsuariosError(
          'No tienes permisos para cambiar el estado de usuarios.\n'
          'Solo el Administrador y el Jefe de Personal pueden gestionar usuarios.',
        ));
        return;
      }

      debugPrint('🔄 UsuariosBloc: Cambiando estado de usuario ${event.id} a ${event.activo ? 'activo' : 'inactivo'}');
      emit(const UsuariosUpdating());

      await _repository.cambiarEstado(event.id, activo: event.activo);

      debugPrint('✅ UsuariosBloc: Estado cambiado');

      // Recargar lista
      add(const UsuariosLoadAllRequested());
    } catch (e) {
      debugPrint('❌ UsuariosBloc: Error al cambiar estado - $e');
      emit(UsuariosError(e.toString()));

      // Recargar lista incluso si hubo error
      add(const UsuariosLoadAllRequested());
    }
  }
}
