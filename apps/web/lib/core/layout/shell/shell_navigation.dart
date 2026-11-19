import 'package:ambutrack_web/core/auth/enums/user_role.dart';
import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/features/menu/domain/entities/menu_item.dart';
import 'package:ambutrack_web/features/menu/domain/repositories/menu_repository.dart';

/// Grupo de módulos del menú lateral
class ShellNavGroup {
  const ShellNavGroup({required this.title, required this.items});

  /// null = sin título (p.ej. Dashboard)
  final String? title;
  final List<MenuItem> items;
}

/// Pantalla navegable con su módulo padre (para breadcrumb y buscador)
class ShellDestino {
  const ShellDestino({required this.item, this.parent});

  final MenuItem item;
  final MenuItem? parent;

  String get route => item.route!;
  String get label => item.label;
  String get ruta => parent == null ? item.label : '${parent!.label} › ${item.label}';
}

/// Construye la navegación del shell a partir del MenuRepository (respeta permisos por rol)
class ShellNavigation {
  ShellNavigation(UserRole role)
      : _items = getIt<MenuRepository>()
            .getMainMenuItemsForRole(role)
            .where((MenuItem i) => i.key != 'configuracion' && i.key != 'usuario')
            .toList();

  final List<MenuItem> _items;

  static const Map<String, List<String>> _grupos = <String, List<String>>{
    'Operación': <String>['trafico', 'servicios', 'cuadrante'],
    'Recursos': <String>['personal', 'vehiculos', 'taller', 'almacen'],
    'Gestión': <String>['informes', 'administracion', 'tablas', 'otros'],
  };

  /// Grupos en orden: inicio (dashboard), Operación, Recursos, Gestión y resto
  List<ShellNavGroup> get grupos {
    final Set<String> usados = <String>{};
    MenuItem? byKey(String k) {
      for (final MenuItem i in _items) {
        if (i.key == k) {
          return i;
        }
      }
      return null;
    }

    final List<ShellNavGroup> result = <ShellNavGroup>[];
    final MenuItem? dashboard = byKey('dashboard');
    if (dashboard != null) {
      usados.add('dashboard');
      result.add(ShellNavGroup(title: null, items: <MenuItem>[dashboard]));
    }
    _grupos.forEach((String titulo, List<String> keys) {
      final List<MenuItem> items = keys.map(byKey).whereType<MenuItem>().toList();
      usados.addAll(keys);
      if (items.isNotEmpty) {
        result.add(ShellNavGroup(title: titulo, items: items));
      }
    });
    final List<MenuItem> resto = _items.where((MenuItem i) => !usados.contains(i.key)).toList();
    if (resto.isNotEmpty) {
      result.add(ShellNavGroup(title: 'Otros', items: resto));
    }
    return result;
  }

  /// Todas las pantallas navegables (sin duplicados de ruta)
  List<ShellDestino> get destinos {
    final List<ShellDestino> out = <ShellDestino>[];
    final Set<String> rutas = <String>{};
    for (final MenuItem i in _items) {
      if (i.isNavigable && rutas.add(i.route!)) {
        out.add(ShellDestino(item: i));
      }
      for (final MenuItem c in i.children) {
        if (c.route != null && rutas.add(c.route!)) {
          out.add(ShellDestino(item: c, parent: i));
        }
      }
    }
    return out;
  }

  /// Destino que corresponde a [path] (coincidencia exacta o el prefijo más largo)
  ShellDestino? destinoDe(String path) {
    ShellDestino? best;
    for (final ShellDestino d in destinos) {
      final String r = d.route;
      final bool match = path == r || (r != '/' && path.startsWith('$r/'));
      if (match && (best == null || r.length > best.route.length)) {
        best = d;
      }
    }
    return best;
  }

  /// ¿El módulo [item] contiene la ruta activa?
  static bool contiene(MenuItem item, String path) {
    if (item.route != null && (item.route == path || (item.route != '/' && path.startsWith('${item.route}/')))) {
      return true;
    }
    return item.children.any((MenuItem c) => contiene(c, path));
  }
}
