import 'package:ambutrack_web/core/auth/enums/user_role.dart';

/// Reglas de gestión de cuentas de usuario (alta, edición, claves, estado)
///
/// Son las mismas que aplica en servidor la Edge Function `admin-users`;
/// aquí solo sirven para que la interfaz no ofrezca acciones no permitidas.
///
/// - Administrador: todo, cualquier rol
/// - Jefe de Personal: usuarios con rol operativo (no elimina)
/// - Jefe de Tráfico / Coordinador: solo consulta
class GestionUsuariosPermissions {
  const GestionUsuariosPermissions._();

  /// Roles que el jefe de personal puede asignar y gestionar
  static const List<String> rolesOperativos = <String>[
    'administrativo',
    'conductor',
    'operador',
    'sanitario',
    'tecnico',
  ];

  /// Puede dar de alta usuarios
  static bool puedeCrear(UserRole rol) => rol == UserRole.admin || rol == UserRole.jefePersonal;

  /// Puede eliminar usuarios (solo admin; el resto desactiva)
  static bool puedeEliminar(UserRole rol) => rol == UserRole.admin;

  /// Puede editar, restablecer la clave o activar/desactivar a un usuario con [rolObjetivo]
  static bool puedeGestionar(UserRole rol, String? rolObjetivo) {
    if (rol == UserRole.admin) {
      return true;
    }
    return rol == UserRole.jefePersonal && rolesOperativos.contains(rolObjetivo);
  }

  /// Filtra los roles que [rol] puede asignar
  static List<String> rolesAsignables(UserRole rol, Iterable<String> todos) {
    if (rol == UserRole.admin) {
      return todos.toList();
    }
    if (rol == UserRole.jefePersonal) {
      return todos.where(rolesOperativos.contains).toList();
    }
    return const <String>[];
  }
}
