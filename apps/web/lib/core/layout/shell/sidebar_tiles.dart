import 'package:ambutrack_web/core/layout/shell/shell_navigation.dart';
import 'package:ambutrack_web/core/layout/shell/shell_preferences.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/features/menu/domain/entities/menu_item.dart';
import 'package:flutter/material.dart';

/// Título de grupo del menú lateral ("OPERACIÓN")
class SidebarGroupTitle extends StatelessWidget {
  const SidebarGroupTitle({required this.title, required this.collapsed, super.key});

  final String title;
  final bool collapsed;

  @override
  Widget build(BuildContext context) {
    if (collapsed) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 14),
        child: Divider(height: 1, color: AppColors.gray200),
      );
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
          color: AppColors.gray400,
        ),
      ),
    );
  }
}

/// Fila navegable del menú lateral
class SidebarTile extends StatelessWidget {
  const SidebarTile({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    required this.collapsed,
    this.indent = false,
    this.trailing,
    super.key,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final bool collapsed;
  final bool indent;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final Color fg = selected ? AppColors.primary : AppColors.gray700;
    final Widget tile = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
      child: Material(
        color: selected ? AppColors.primarySurface : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(6),
          hoverColor: AppColors.gray100,
          child: Container(
            height: indent ? 30 : 34,
            padding: EdgeInsets.only(left: collapsed ? 0 : (indent ? 34 : 10), right: 6),
            alignment: collapsed ? Alignment.center : Alignment.centerLeft,
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(
                  color: selected && !collapsed ? AppColors.primary : Colors.transparent,
                  width: 3,
                ),
              ),
            ),
            child: collapsed
                ? Icon(icon, size: 19, color: fg)
                : Row(
                    children: <Widget>[
                      if (!indent) ...<Widget>[
                        Icon(icon, size: 17, color: fg),
                        const SizedBox(width: 10),
                      ],
                      Expanded(
                        child: Text(
                          label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: indent ? 12.5 : 13,
                            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                            color: fg,
                          ),
                        ),
                      ),
                      if (trailing != null) trailing!,
                    ],
                  ),
          ),
        ),
      ),
    );
    return collapsed ? Tooltip(message: label, waitDuration: const Duration(milliseconds: 300), child: tile) : tile;
  }
}

/// Módulo del menú (con o sin submenú)
class SidebarModule extends StatelessWidget {
  const SidebarModule({
    required this.item,
    required this.path,
    required this.collapsed,
    required this.onNavigate,
    super.key,
  });

  final MenuItem item;
  final String path;
  final bool collapsed;
  final ValueChanged<String> onNavigate;

  @override
  Widget build(BuildContext context) {
    final bool activo = ShellNavigation.contiene(item, path);
    if (!item.hasChildren) {
      return SidebarTile(
        icon: item.icon,
        label: item.label,
        selected: activo,
        collapsed: collapsed,
        onTap: () => onNavigate(item.route!),
      );
    }
    if (collapsed) {
      return _CollapsedModule(item: item, path: path, activo: activo, onNavigate: onNavigate);
    }
    final ShellPreferences prefs = ShellPreferences.instance;
    final bool expanded = prefs.isExpanded(item.key) || activo;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        SidebarTile(
          icon: item.icon,
          label: item.label,
          selected: activo && !expanded,
          collapsed: false,
          onTap: () => prefs.setExpanded(item.key, expanded: !prefs.isExpanded(item.key)),
          trailing: Icon(
            expanded ? Icons.expand_less : Icons.expand_more,
            size: 16,
            color: AppColors.gray400,
          ),
        ),
        if (expanded)
          for (final MenuItem c in item.children)
            if (c.route != null)
              SidebarTile(
                icon: c.icon,
                label: c.label,
                indent: true,
                collapsed: false,
                selected: ShellNavigation.contiene(c, path),
                onTap: () => onNavigate(c.route!),
              ),
      ],
    );
  }
}

/// Módulo en modo contraído: icono que abre un menú flotante con las pantallas
class _CollapsedModule extends StatelessWidget {
  const _CollapsedModule({
    required this.item,
    required this.path,
    required this.activo,
    required this.onNavigate,
  });

  final MenuItem item;
  final String path;
  final bool activo;
  final ValueChanged<String> onNavigate;

  @override
  Widget build(BuildContext context) {
    return MenuAnchor(
      alignmentOffset: const Offset(52, -34),
      style: const MenuStyle(
        backgroundColor: WidgetStatePropertyAll<Color>(Colors.white),
        padding: WidgetStatePropertyAll<EdgeInsets>(EdgeInsets.symmetric(vertical: 4)),
      ),
      menuChildren: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 6, 12, 4),
          child: Text(
            item.label.toUpperCase(),
            style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: AppColors.gray500),
          ),
        ),
        for (final MenuItem c in item.children)
          if (c.route != null)
            MenuItemButton(
              onPressed: () => onNavigate(c.route!),
              leadingIcon: Icon(c.icon, size: 16),
              style: ButtonStyle(
                foregroundColor: WidgetStatePropertyAll<Color>(
                  ShellNavigation.contiene(c, path) ? AppColors.primary : AppColors.gray800,
                ),
                textStyle: const WidgetStatePropertyAll<TextStyle>(TextStyle(fontSize: 13)),
              ),
              child: Text(c.label),
            ),
      ],
      builder: (BuildContext context, MenuController menu, Widget? _) => SidebarTile(
        icon: item.icon,
        label: item.label,
        selected: activo,
        collapsed: true,
        onTap: () => menu.isOpen ? menu.close() : menu.open(),
      ),
    );
  }
}
