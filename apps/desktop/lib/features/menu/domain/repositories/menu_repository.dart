import 'package:ambutrack_desktop/features/menu/domain/entities/menu_item.dart';

/// Repositorio abstracto para gestión del menú de navegación
abstract class MenuRepository {
  /// Obtiene todos los items del menú principal
  List<MenuItem> getMainMenuItems();

  /// Obtiene los items del menú móvil
  List<MenuItem> getMobileMenuItems();

  /// Obtiene un item específico por su key
  MenuItem? getMenuItemByKey(String key);

  /// Obtiene todos los items de navegación planos (sin estructura jerárquica)
  List<MenuItem> getFlatMenuItems();
}