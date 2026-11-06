import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Acción de la barra de herramientas
class GestionToolbarAction {
  const GestionToolbarAction({
    required this.icon,
    required this.label,
    this.onPressed,
    this.primary = false,
    this.destructive = false,
    this.tooltip,
  });

  final IconData icon;
  final String label;

  /// Si es null, el botón aparece deshabilitado
  final VoidCallback? onPressed;

  /// Botón relleno con color primario (acción principal)
  final bool primary;

  /// Acción destructiva (icono en rojo)
  final bool destructive;
  final String? tooltip;
}

/// Barra de herramientas compacta estilo programa de gestión.
///
/// Las acciones se agrupan y cada grupo se separa con un divisor vertical.
class GestionToolbar extends StatelessWidget {
  const GestionToolbar({
    required this.title,
    required this.groups,
    this.icon,
    this.trailing,
    super.key,
  });

  final String title;
  final IconData? icon;
  final List<List<GestionToolbarAction>> groups;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final List<Widget> children = <Widget>[
      _ToolbarTitle(title: title, icon: icon),
    ];
    for (final List<GestionToolbarAction> group in groups) {
      children.add(const _ToolbarDivider());
      for (final GestionToolbarAction action in group) {
        children.add(_ToolbarButton(action: action));
      }
    }
    children.add(const Spacer());
    if (trailing != null) {
      children.add(trailing!);
    }

    return Container(
      height: 46,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.gray200)),
      ),
      // Ocupa todo el ancho (el Spacer empuja `trailing` a la derecha) y,
      // si no cabe, se desplaza en horizontal en lugar de desbordarse
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) => SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: constraints.maxWidth),
            child: IntrinsicWidth(child: Row(children: children)),
          ),
        ),
      ),
    );
  }
}

class _ToolbarTitle extends StatelessWidget {
  const _ToolbarTitle({required this.title, this.icon});

  final String title;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (icon != null) ...<Widget>[
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 8),
        ],
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.gray900,
          ),
        ),
      ],
    );
  }
}

class _ToolbarDivider extends StatelessWidget {
  const _ToolbarDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 22,
      margin: const EdgeInsets.symmetric(horizontal: 10),
      color: AppColors.gray200,
    );
  }
}

class _ToolbarButton extends StatelessWidget {
  const _ToolbarButton({required this.action});

  final GestionToolbarAction action;

  @override
  Widget build(BuildContext context) {
    final bool enabled = action.onPressed != null;
    final Color fg = !enabled
        ? AppColors.gray400
        : action.primary
            ? Colors.white
            : action.destructive
                ? AppColors.error
                : AppColors.gray700;
    final Color bg =
        action.primary && enabled ? AppColors.primary : Colors.transparent;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Tooltip(
        message: action.tooltip ?? action.label,
        waitDuration: const Duration(milliseconds: 500),
        child: Material(
          color: bg,
          borderRadius: BorderRadius.circular(6),
          child: InkWell(
            onTap: action.onPressed,
            borderRadius: BorderRadius.circular(6),
            hoverColor: action.primary ? null : AppColors.gray100,
            child: Container(
              height: 32,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              alignment: Alignment.center,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(action.icon, size: 16, color: fg),
                  const SizedBox(width: 6),
                  Text(
                    action.label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: fg,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
