import 'package:ambutrack_web/core/auth/enums/user_role.dart';
import 'package:ambutrack_web/core/auth/permissions/role_permissions.dart';
import 'package:ambutrack_web/features/menu/domain/entities/menu_item.dart';

/// Filtra items del menú según los permisos del rol del usuario
class MenuFilter {
  /// Filtra una lista de items del menú según el rol
  ///
  /// - Admin ve todo sin filtrar
  /// - Items con route: visibles si `hasAccessToRoute` es true
  /// - Items con children: se filtran los hijos; si no quedan, se oculta el padre
  /// - Items especiales (configuracion, usuario): siempre visibles
  static List<MenuItem> filterForRole(List<MenuItem> items, UserRole role) {
    if (role == UserRole.admin) {
      return items;
    }

    return items
        .map((MenuItem item) => _filterItem(item, role))
        .where((MenuItem item) => _hasVisibleContent(item, role))
        .toList();
  }

  /// Filtra un item individual y sus hijos
  static MenuItem _filterItem(MenuItem item, UserRole role) {
    // Items sin hijos: no necesitan filtrado interno
    if (!item.hasChildren) {
      return item;
    }

    // Filtrar hijos por permisos de ruta
    final List<MenuItem> filteredChildren = item.children
        .where((MenuItem child) =>
            child.route != null &&
            RolePermissions.hasAccessToRoute(role, child.route!))
        .toList();

    return item.copyWith(children: filteredChildren);
  }

  /// Determina si un item tiene contenido visible tras el filtrado
  static bool _hasVisibleContent(MenuItem item, UserRole role) {
    // Items especiales: siempre visibles (botones del AppBar)
    if (_isSpecialItem(item)) {
      return true;
    }

    // Items con ruta propia: visibles si tienen permiso
    if (item.route != null) {
      return RolePermissions.hasAccessToRoute(role, item.route!);
    }

    // Items padre: visibles si tienen hijos tras el filtrado
    if (item.hasChildren) {
      return item.children.isNotEmpty;
    }

    return false;
  }

  /// Items especiales que siempre se muestran (gestionados por el AppBar)
  static bool _isSpecialItem(MenuItem item) {
    return item.key == 'configuracion' || item.key == 'usuario';
  }
}
