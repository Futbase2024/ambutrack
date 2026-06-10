import 'package:ambutrack_web/core/auth/enums/user_role.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:ambutrack_web/features/auth/presentation/bloc/auth_state.dart';
import 'package:ambutrack_web/features/menu/domain/entities/menu_item.dart';
import 'package:ambutrack_web/features/menu/domain/repositories/menu_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

/// Menú superior de navegación de AmbuTrack
///
/// Obtiene el rol reactivamente del [AuthBloc] para que el menú
/// se reconstruya automáticamente cuando cambie el estado de auth,
/// evitando que los items desaparezcan tras un hot restart.
class AppMenu extends StatefulWidget {
  const AppMenu({super.key});

  @override
  State<AppMenu> createState() => _AppMenuState();
}

class _AppMenuState extends State<AppMenu> with TickerProviderStateMixin {
  String? _hoveredItem;
  String? _openDropdown;
  late final MenuRepository _menuRepository;
  late AnimationController _hoverController;
  late Animation<double> _hoverAnimation;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _menuRepository = GetIt.instance<MenuRepository>();
    _scrollController = ScrollController();
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _hoverAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _hoverController,
      curve: Curves.easeInOut,
    ));
  }

  /// Obtiene el rol actual del [AuthBloc] de forma reactiva.
  UserRole _getCurrentRole() {
    final AuthState authState = context.watch<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      return UserRole.fromString(authState.user.rol);
    }
    return UserRole.operador;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _hoverController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final bool isWideScreen = MediaQuery.of(context).size.width > 800;

    if (isWideScreen) {
      return _buildDesktopMenu();
    } else {
      return _buildMobileMenu();
    }
  }

  /// Menú para pantallas grandes (desktop/tablet)
  Widget _buildDesktopMenu() {
    final List<MenuItem> mainItems = _menuRepository.getMainMenuItemsForRole(_getCurrentRole());

    // Separar items de navegación de los especiales (configuración, usuario)
    final List<MenuItem> navItems = mainItems
        .where((MenuItem item) => item.key != 'configuracion' && item.key != 'usuario')
        .toList();

    final List<Widget> menuWidgets = <Widget>[];

    for (int i = 0; i < navItems.length; i++) {
      final MenuItem item = navItems[i];

      if (item.hasChildren) {
        menuWidgets.add(_buildDropdownMenuItem(item));
      } else {
        menuWidgets.add(_buildMenuItem(item));
      }

      // Agregar separador entre items (excepto después del último)
      if (i < navItems.length - 1) {
        menuWidgets.add(const SizedBox(width: 4));
      }
    }

    return Scrollbar(
      controller: _scrollController,
      thumbVisibility: true,
      trackVisibility: true,
      thickness: 6.0,
      radius: const Radius.circular(3.0),
      child: SingleChildScrollView(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: menuWidgets,
        ),
      ),
    );
  }

  /// Menú para dispositivos móviles
  Widget _buildMobileMenu() {
    final List<MenuItem> mobileItems = _menuRepository.getMobileMenuItemsForRole(_getCurrentRole());

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.gray900.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: PopupMenuButton<String>(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.gray100,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: AppColors.gray200,
            ),
          ),
          child: const Icon(
            Icons.menu_rounded,
            color: AppColors.primary,
            size: 24,
          ),
        ),
        elevation: 12,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        color: AppColors.backgroundLight,
        onSelected: context.go,
        itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
          ...mobileItems.map((MenuItem item) => PopupMenuItem<String>(
                value: item.route ?? '/',
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: <Widget>[
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.gray100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          item.icon,
                          size: 18,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          item.label,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.gray900,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )),
        ],
      ),
    );
  }

  /// Construye un item de menú simple
  Widget _buildMenuItem(MenuItem item) {
    final bool isHovered = _hoveredItem == item.key;
    final bool isActive = GoRouterState.of(context).uri.path == item.route;

    return MouseRegion(
      onEnter: (_) {
        setState(() => _hoveredItem = item.key);
        _hoverController.forward();
      },
      onExit: (_) {
        setState(() => _hoveredItem = null);
        _hoverController.reverse();
      },
      child: AnimatedBuilder(
        animation: _hoverAnimation,
        builder: (BuildContext context, Widget? child) {
          return GestureDetector(
            onTap: () => item.route != null ? context.go(item.route!) : null,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: isActive
                    ? AppColors.primary
                    : isHovered
                        ? AppColors.gray200
                        : null,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(
                    item.icon,
                    size: 16,
                    color: isActive
                        ? AppColors.backgroundLight
                        : AppColors.gray700,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    item.label,
                    style: GoogleFonts.inter(
                      color: isActive
                          ? AppColors.backgroundLight
                          : AppColors.gray700,
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                      fontSize: 13,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// Construye un item de menú con dropdown
  Widget _buildDropdownMenuItem(MenuItem item) {
    final bool isHovered = _hoveredItem == item.key;
    final bool isOpen = _openDropdown == item.key;

    return MouseRegion(
      onEnter: (_) {
        setState(() => _hoveredItem = item.key);
        _hoverController.forward();
      },
      onExit: (_) {
        setState(() => _hoveredItem = null);
        _hoverController.reverse();
      },
      child: AnimatedBuilder(
        animation: _hoverAnimation,
        builder: (BuildContext context, Widget? child) {
          return PopupMenuButton<String>(
            elevation: 16,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            color: AppColors.backgroundLight,
            onOpened: () => setState(() => _openDropdown = item.key),
            onCanceled: () => setState(() => _openDropdown = null),
            onSelected: (String route) {
              setState(() => _openDropdown = null);
              context.go(route);
            },
            itemBuilder: (BuildContext context) => _buildDropdownItems(item.children),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: isOpen
                    ? AppColors.primary
                    : isHovered
                        ? AppColors.gray200
                        : null,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(
                    item.icon,
                    size: 16,
                    color: isOpen
                        ? AppColors.backgroundLight
                        : AppColors.gray700,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    item.label,
                    style: GoogleFonts.inter(
                      color: isOpen
                          ? AppColors.backgroundLight
                          : AppColors.gray700,
                      fontWeight: isOpen ? FontWeight.w600 : FontWeight.w500,
                      fontSize: 13,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(width: 6),
                  AnimatedRotation(
                    turns: isOpen ? 0.5 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 18,
                      color: isOpen
                          ? AppColors.backgroundLight
                          : AppColors.gray700,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// Construye los items del dropdown
  List<PopupMenuEntry<String>> _buildDropdownItems(List<MenuItem> items) {
    final List<PopupMenuEntry<String>> dropdownItems = <PopupMenuEntry<String>>[];

    for (int i = 0; i < items.length; i++) {
      final MenuItem item = items[i];

      dropdownItems.add(
        PopupMenuItem<String>(
          value: item.route ?? '/',
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: SizedBox(
            width: double.infinity,
            child: Row(
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: (item.color ?? AppColors.primary).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    item.icon,
                    color: item.color ?? AppColors.primary,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    item.label,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.gray900,
                      letterSpacing: 0.1,
                    ),
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 12,
                  color: AppColors.gray500,
                ),
              ],
            ),
          ),
        ),
      );

      if (_shouldAddDivider(items, i)) {
        dropdownItems.add(
          const PopupMenuDivider(
            height: 1,
          ),
        );
      }
    }

    return dropdownItems;
  }

  /// Determina si se debe agregar un separador después del item
  bool _shouldAddDivider(List<MenuItem> items, int index) {
    // Agregar separador después del tercer item en servicios
    if (items.length > 3 && index == 2) {
      return true;
    }
    // Agregar separador después del tercer item en ambulancias
    if (items.length > 3 && index == 2) {
      return true;
    }
    // Agregar separador después del tercer item en tablas
    if (items.length > 3 && index == 2) {
      return true;
    }
    // Agregar separador después del tercer item en reportes
    if (items.length > 3 && index == 2) {
      return true;
    }
    // Agregar separador antes del último item en usuario
    if (items.length > 2 && index == items.length - 2) {
      return true;
    }

    return false;
  }
}