import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Preferencias del shell (menú lateral) persistidas en el navegador
class ShellPreferences extends ChangeNotifier {
  ShellPreferences._();

  static final ShellPreferences instance = ShellPreferences._();

  static const String _kCollapsed = 'shell.collapsed';
  static const String _kFavoritos = 'shell.favoritos';
  static const String _kExpanded = 'shell.expanded';

  bool _loaded = false;
  bool _collapsed = false;
  List<String> _favoritos = <String>[];
  Set<String> _expanded = <String>{};

  bool get collapsed => _collapsed;

  /// Rutas marcadas como favoritas (orden de inserción)
  List<String> get favoritos => List<String>.unmodifiable(_favoritos);
  bool isFavorito(String route) => _favoritos.contains(route);
  bool isExpanded(String key) => _expanded.contains(key);

  Future<void> load() async {
    if (_loaded) {
      return;
    }
    _loaded = true;
    try {
      final SharedPreferences p = await SharedPreferences.getInstance();
      _collapsed = p.getBool(_kCollapsed) ?? false;
      _favoritos = p.getStringList(_kFavoritos) ?? <String>[];
      _expanded = (p.getStringList(_kExpanded) ?? <String>[]).toSet();
      notifyListeners();
    } catch (e) {
      debugPrint('⚠️ ShellPreferences: no se pudieron cargar: $e');
    }
  }

  Future<void> toggleCollapsed() async {
    _collapsed = !_collapsed;
    notifyListeners();
    await _save((SharedPreferences p) => p.setBool(_kCollapsed, _collapsed));
  }

  Future<void> toggleFavorito(String route) async {
    if (_favoritos.contains(route)) {
      _favoritos.remove(route);
    } else {
      _favoritos.add(route);
    }
    notifyListeners();
    await _save((SharedPreferences p) => p.setStringList(_kFavoritos, _favoritos));
  }

  Future<void> setExpanded(String key, {required bool expanded}) async {
    expanded ? _expanded.add(key) : _expanded.remove(key);
    notifyListeners();
    await _save((SharedPreferences p) => p.setStringList(_kExpanded, _expanded.toList()));
  }

  Future<void> _save(Future<bool> Function(SharedPreferences) write) async {
    try {
      await write(await SharedPreferences.getInstance());
    } catch (e) {
      debugPrint('⚠️ ShellPreferences: no se pudo guardar: $e');
    }
  }
}
