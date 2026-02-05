import 'package:flutter/material.dart';

import '../../../../core/datasources/traslados/traslados_datasource.dart';

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

    return Align(
      alignment: Alignment.centerLeft,
      child: IntrinsicWidth(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (showIcon) ...[
                Icon(
                  _getIcon(),
                  size: 14,
                  color: color,
                ),
                const SizedBox(width: 4),
              ],
              Text(
                estado.label,
                style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
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
      case EstadoTraslado.recibido:
        return Icons.check_circle_outline;
      case EstadoTraslado.enOrigen:
        return Icons.location_on;
      case EstadoTraslado.saliendoOrigen:
        return Icons.drive_eta;
      case EstadoTraslado.enDestino:
        return Icons.place;
      case EstadoTraslado.finalizado:
        return Icons.check_circle;
      case EstadoTraslado.cancelado:
        return Icons.cancel;
      case EstadoTraslado.noRealizado:
        return Icons.block;
      case EstadoTraslado.suspendido:
        return Icons.pause_circle;
    }
  }
}
