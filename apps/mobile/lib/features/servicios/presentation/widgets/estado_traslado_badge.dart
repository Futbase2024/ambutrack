import 'package:flutter/material.dart';

import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';

/// Badge para mostrar el estado de un traslado
/// Ajusta automáticamente su ancho al contenido (usando IntrinsicWidth)
class EstadoTrasladoBadge extends StatelessWidget {
  const EstadoTrasladoBadge({
    required this.estado,
    this.showIcon = false,
    super.key,
  });

  final EstadoTraslado estado;
  final bool showIcon;

  @override
  Widget build(BuildContext context) {
    final color = _getColorFromHex(estado.colorHex);
    final screenWidth = MediaQuery.of(context).size.width;
    final isNarrow = screenWidth < 600;

    return Align(
      alignment: Alignment.centerLeft,
      child: IntrinsicWidth(
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: isNarrow ? 8 : 12,
            vertical: isNarrow ? 4 : 6,
          ),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (showIcon) ...[
                Icon(
                  _getIcon(),
                  size: isNarrow ? 14 : 18,
                  color: color,
                ),
                SizedBox(width: isNarrow ? 4 : 6),
              ],
              Flexible(
                child: Text(
                  estado.label,
                  style: TextStyle(
                    color: color,
                    fontSize: isNarrow ? 11 : 14,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Convierte hex string a Color
  Color _getColorFromHex(String hexColor) {
    final hex = hexColor.replaceAll('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }

  /// Obtiene el icono según el estado
  IconData _getIcon() {
    switch (estado) {
      case EstadoTraslado.pendiente:
        return Icons.schedule;
      case EstadoTraslado.asignado:
        return Icons.assignment_ind;
      case EstadoTraslado.enviado:
        return Icons.send_outlined;
      case EstadoTraslado.recibido:
        return Icons.check_circle_outline;
      case EstadoTraslado.enOrigen:
        return Icons.location_on;
      case EstadoTraslado.saliendoOrigen:
        return Icons.drive_eta;
      case EstadoTraslado.enTransito:
        return Icons.local_shipping_outlined;
      case EstadoTraslado.enDestino:
        return Icons.place;
      case EstadoTraslado.finalizado:
        return Icons.check_circle;
      case EstadoTraslado.cancelado:
        return Icons.cancel;
      case EstadoTraslado.noRealizado:
        return Icons.block;
    }
  }
}
