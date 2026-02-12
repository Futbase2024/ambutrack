import 'package:ambutrack_desktop/core/theme/app_colors.dart';
import 'package:ambutrack_desktop/core/theme/app_sizes.dart';
import 'package:flutter/material.dart';

/// Opción del menú contextual personalizado
class ContextMenuOption {
  const ContextMenuOption({
    required this.label,
    this.icon,
    this.emoji,
    required this.onTap,
    this.enabled = true,
  });

  final String label;
  final IconData? icon;
  final String? emoji;
  final VoidCallback onTap;
  final bool enabled;
}

/// Widget que envuelve contenido y muestra menú contextual al hacer clic derecho
///
/// Bloquea el menú contextual del navegador y muestra un menú personalizado
class CustomContextMenu extends StatefulWidget {
  const CustomContextMenu({
    required this.child,
    required this.menuOptions,
    super.key,
  });

  final Widget child;
  final List<ContextMenuOption> menuOptions;

  @override
  State<CustomContextMenu> createState() => _CustomContextMenuState();
}

class _CustomContextMenuState extends State<CustomContextMenu> {
  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: Listener(
        // Usar translucent para permitir que los clics izquierdos se propaguen
        // al GestureDetector padre (selección de fila)
        behavior: HitTestBehavior.translucent,
        onPointerDown: (PointerDownEvent event) {
          // Detectar clic derecho (botón secundario = 2)
          if (event.buttons == 2) {
            _showContextMenu(event.localPosition);
          }
        },
        child: widget.child,
      ),
    );
  }

  void _showContextMenu(Offset localPosition) {
    // Cerrar menú anterior si existe
    _removeOverlay();

    debugPrint('🖱️ CustomContextMenu - Posición local del clic: $localPosition');

    // Crear nueva entrada de overlay usando CompositedTransformFollower
    _overlayEntry = _createOverlayEntry(localPosition);
    Overlay.of(context).insert(_overlayEntry!);
  }

  OverlayEntry _createOverlayEntry(Offset localPosition) {
    return OverlayEntry(
      builder: (BuildContext context) {
        return Stack(
          children: <Widget>[
            // Fondo transparente que cierra el menú al hacer clic
            Positioned.fill(
              child: GestureDetector(
                onTap: _removeOverlay,
                child: Container(color: Colors.transparent),
              ),
            ),

            // Menú contextual anclado al widget usando CompositedTransformFollower
            CompositedTransformFollower(
              link: _layerLink,
              showWhenUnlinked: false,
              offset: Offset(localPosition.dx, localPosition.dy + 5),
              child: Align(
                alignment: Alignment.topLeft,
                child: Material(
                  color: Colors.transparent,
                  child: _buildContextMenu(context),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildContextMenu(BuildContext context) {
    return Container(
      width: 220,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        border: Border.all(color: AppColors.gray300),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: widget.menuOptions.map(_buildMenuItem).toList(),
        ),
      ),
    );
  }

  Widget _buildMenuItem(ContextMenuOption option) {
    return InkWell(
      onTap: option.enabled
          ? () {
              _removeOverlay();
              option.onTap();
            }
          : null,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.paddingMedium,
          vertical: AppSizes.paddingSmall,
        ),
        child: Row(
          children: <Widget>[
            // Mostrar emoji si está presente, sino icono
            if (option.emoji != null)
              Text(
                option.emoji!,
                style: const TextStyle(fontSize: 20),
              )
            else if (option.icon != null)
              Icon(
                option.icon,
                size: 18,
                color: option.enabled ? AppColors.textPrimaryLight : AppColors.gray400,
              ),
            const SizedBox(width: AppSizes.spacing),
            Expanded(
              child: Text(
                option.label,
                style: TextStyle(
                  fontSize: 14,
                  color: option.enabled ? AppColors.textPrimaryLight : AppColors.gray400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }
}
