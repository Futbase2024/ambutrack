import 'package:ambutrack_web/app/flavors.dart';
import 'package:ambutrack_web/core/layout/shell/shell_navigation.dart';
import 'package:ambutrack_web/core/layout/shell/shell_preferences.dart';
import 'package:ambutrack_web/core/layout/shell/sidebar_tiles.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/features/menu/domain/entities/menu_item.dart';
import 'package:flutter/material.dart';

const double kSidebarWidth = 224;
const double kSidebarCollapsedWidth = 58;

/// Menú lateral de la aplicación (estilo programa de gestión)
class AppSidebar extends StatelessWidget {
  const AppSidebar({
    required this.navigation,
    required this.path,
    required this.onNavigate,
    this.forceExpanded = false,
    super.key,
  });

  final ShellNavigation navigation;
  final String path;
  final ValueChanged<String> onNavigate;

  /// En modo cajón (pantallas estrechas) siempre se muestra desplegado
  final bool forceExpanded;

  @override
  Widget build(BuildContext context) {
    final ShellPreferences prefs = ShellPreferences.instance;
    return ListenableBuilder(
      listenable: prefs,
      builder: (BuildContext context, Widget? _) {
        final bool collapsed = prefs.collapsed && !forceExpanded;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          width: collapsed ? kSidebarCollapsedWidth : kSidebarWidth,
          decoration: const BoxDecoration(
            color: AppColors.gray50,
            border: Border(right: BorderSide(color: AppColors.gray200)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              _SidebarHeader(collapsed: collapsed),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.only(bottom: 8),
                  children: <Widget>[
                    _Favoritos(navigation: navigation, path: path, collapsed: collapsed, onNavigate: onNavigate),
                    for (final ShellNavGroup g in navigation.grupos) ...<Widget>[
                      if (g.title != null) SidebarGroupTitle(title: g.title!, collapsed: collapsed),
                      for (final MenuItem item in g.items)
                        SidebarModule(item: item, path: path, collapsed: collapsed, onNavigate: onNavigate),
                    ],
                  ],
                ),
              ),
              if (!forceExpanded) _CollapseButton(collapsed: collapsed, onTap: prefs.toggleCollapsed),
            ],
          ),
        );
      },
    );
  }
}

class _SidebarHeader extends StatelessWidget {
  const _SidebarHeader({required this.collapsed});

  final bool collapsed;

  @override
  Widget build(BuildContext context) {
    final bool isDev = F.appFlavor == Flavor.dev;
    final Widget logo = Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(7)),
      child: const Icon(Icons.local_hospital, size: 18, color: Colors.white),
    );
    return Container(
      height: 52,
      padding: EdgeInsets.symmetric(horizontal: collapsed ? 0 : 14),
      alignment: collapsed ? Alignment.center : Alignment.centerLeft,
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.gray200))),
      child: collapsed
          ? logo
          : Row(
              children: <Widget>[
                logo,
                const SizedBox(width: 10),
                const Text(
                  'AmbuTrack',
                  style: TextStyle(fontSize: 15.5, fontWeight: FontWeight.w800, color: AppColors.gray900),
                ),
                if (isDev) ...<Widget>[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'DEV',
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.warning),
                    ),
                  ),
                ],
              ],
            ),
    );
  }
}

class _Favoritos extends StatelessWidget {
  const _Favoritos({
    required this.navigation,
    required this.path,
    required this.collapsed,
    required this.onNavigate,
  });

  final ShellNavigation navigation;
  final String path;
  final bool collapsed;
  final ValueChanged<String> onNavigate;

  @override
  Widget build(BuildContext context) {
    final List<ShellDestino> favs = ShellPreferences.instance.favoritos
        .map((String r) => navigation.destinos.where((ShellDestino d) => d.route == r).firstOrNull)
        .whereType<ShellDestino>()
        .toList();
    if (favs.isEmpty) {
      return const SizedBox(height: 6);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        SidebarGroupTitle(title: 'Favoritos', collapsed: collapsed),
        for (final ShellDestino d in favs)
          SidebarTile(
            icon: collapsed ? d.item.icon : Icons.star_rounded,
            label: d.label,
            collapsed: collapsed,
            selected: d.route == path,
            onTap: () => onNavigate(d.route),
          ),
      ],
    );
  }
}

class _CollapseButton extends StatelessWidget {
  const _CollapseButton({required this.collapsed, required this.onTap});

  final bool collapsed;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppColors.gray200))),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: SidebarTile(
          icon: collapsed ? Icons.keyboard_double_arrow_right : Icons.keyboard_double_arrow_left,
          label: collapsed ? 'Expandir menú' : 'Contraer menú',
          selected: false,
          collapsed: collapsed,
          onTap: onTap,
        ),
      ),
    );
  }
}
