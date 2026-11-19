import 'package:ambutrack_web/core/auth/enums/app_module.dart';
import 'package:ambutrack_web/core/auth/enums/user_role.dart';
import 'package:ambutrack_web/core/auth/permissions/role_permissions.dart';
import 'package:ambutrack_web/features/auth/domain/repositories/auth_repository.dart';
import 'package:ambutrack_web/features/personal/domain/entities/personal_entity.dart';
import 'package:ambutrack_web/features/personal/domain/repositories/personal_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

/// Servicio para gestionar roles y permisos de usuarios
@lazySingleton
class RoleService {
  RoleService(this._authRepository, this._personalRepository);

  final AuthRepository _authRepository;
  final PersonalRepository _personalRepository;

  PersonalEntity? _cachedPersonal;
  DateTime? _cacheTime;
  static const Duration _cacheDuration = Duration(minutes: 5);

  /// Obtiene el Personal del usuario autenticado actual
  Future<PersonalEntity?> getCurrentPersonal() async {
    // Verificar cache
    if (_cachedPersonal != null &&
        _cacheTime != null &&
        DateTime.now().difference(_cacheTime!) < _cacheDuration) {
      return _cachedPersonal;
    }

    try {
      // 1. Obtener UUID del usuario autenticado
      final String? userId = _authRepository.currentUser?.uid;

      if (userId == null) {
        debugPrint('🔐 RoleService: No hay usuario autenticado');
        return null;
      }

      // 2. Buscar PersonalEntity por usuarioId
      final List<PersonalEntity> todosPersonal =
          await _personalRepository.getAll();

      final PersonalEntity? personal = todosPersonal.cast<PersonalEntity?>().firstWhere(
        (PersonalEntity? p) => p?.usuarioId == userId,
        orElse: () => null,
      );

      if (personal == null) {
        debugPrint('🔐 RoleService: No se encontró Personal para usuario $userId');
        return null;
      }

      // Cachear resultado
      _cachedPersonal = personal;
      _cacheTime = DateTime.now();

      debugPrint('🔐 RoleService: Personal encontrado: ${personal.nombreCompleto} (${personal.id})');

      return personal;
    } catch (e) {
      debugPrint('🔐 RoleService: ❌ Error al obtener Personal: $e');
      return null;
    }
  }

  /// Obtiene el rol del usuario autenticado actual
  Future<UserRole> getCurrentUserRole() async {
    // ✅ CORREGIDO: Obtener rol desde tabla usuarios (AuthService)
    // NO desde tabla personal (que es solo para empleados)
    final String? rolString = _authRepository.currentUser?.rol;

    if (rolString == null || rolString.isEmpty) {
      debugPrint('🔐 RoleService: ⚠️ Usuario sin rol asignado → Rol por defecto: operador');
      return UserRole.operador;
    }

    final UserRole role = UserRole.fromString(rolString);

    debugPrint('🔐 RoleService: Rol del usuario: ${role.label} (${role.value})');

    return role;
  }

  /// Obtiene el rol del usuario actual de forma síncrona
  /// Usa el usuario en cache del AuthRepository
  UserRole getCurrentUserRoleSync() {
    final String? rolString = _authRepository.currentUser?.rol;
    if (rolString == null || rolString.isEmpty) {
      return UserRole.operador;
    }
    return UserRole.fromString(rolString);
  }

  /// Verifica si el usuario actual tiene acceso a un módulo
  Future<bool> hasAccessToModule(AppModule module) async {
    final UserRole role = await getCurrentUserRole();
    final bool hasAccess = RolePermissions.hasAccessToModule(role, module);

    debugPrint(
      '🔐 RoleService: ¿Acceso a ${module.label}? $hasAccess (Rol: ${role.label})',
    );

    return hasAccess;
  }

  /// Verifica si el usuario actual tiene acceso a una ruta
  Future<bool> hasAccessToRoute(String route) async {
    final UserRole role = await getCurrentUserRole();
    final bool hasAccess = RolePermissions.hasAccessToRoute(role, route);

    debugPrint(
      '🔐 RoleService: ¿Acceso a ruta $route? $hasAccess (Rol: ${role.label})',
    );

    return hasAccess;
  }

  /// Obtiene los módulos permitidos para el usuario actual
  Future<List<AppModule>> getAllowedModules() async {
    final UserRole role = await getCurrentUserRole();
    final List<AppModule> modules = RolePermissions.getModulesForRole(role);

    debugPrint(
      '🔐 RoleService: Módulos permitidos para ${role.label}: ${modules.length}',
    );

    return modules;
  }

  /// Verifica si el usuario actual es administrador
  Future<bool> isAdmin() async {
    final UserRole role = await getCurrentUserRole();
    return role.isAdmin;
  }

  /// Verifica si el usuario actual es gestor (admin, jefe_personal, jefe_trafico)
  Future<bool> isManager() async {
    final UserRole role = await getCurrentUserRole();
    return role.isManager;
  }

  /// Verifica si el usuario actual es operativo (conductor, sanitario)
  Future<bool> isOperative() async {
    final UserRole role = await getCurrentUserRole();
    return role.isOperative;
  }

  /// Limpia el cache
  void clearCache() {
    _cachedPersonal = null;
    _cacheTime = null;
    debugPrint('🔐 RoleService: Cache limpiado');
  }

  /// Refresca el cache del usuario actual
  Future<PersonalEntity?> refreshCurrentPersonal() async {
    clearCache();
    return getCurrentPersonal();
  }
}
