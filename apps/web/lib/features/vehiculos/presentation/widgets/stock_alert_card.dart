import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Widget para mostrar una alerta de stock de equipamiento en el panel de notificaciones
class StockAlertCard extends StatelessWidget {
  const StockAlertCard({
    required this.vehiculo,
    this.onTap,
    super.key,
  });

  final VehiculoStockResumenEntity vehiculo;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final (Color severidadColor, IconData severidadIcon) = _getSeveridadData();

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: severidadColor.withValues(alpha: 0.05),
          border: Border(
            left: BorderSide(
              color: severidadColor,
              width: 4,
            ),
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Icono según severidad
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: severidadColor.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                severidadIcon,
                color: severidadColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),

            // Contenido
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // Título con matrícula
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          vehiculo.matricula,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimaryLight,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: severidadColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'STOCK',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: severidadColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // Marca y modelo
                  Text(
                    '${vehiculo.marca} ${vehiculo.modelo}'.trim(),
                    style: const TextStyle(
                      color: AppColors.textSecondaryLight,
                      fontSize: 13,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  // Mensaje de items faltantes
                  const SizedBox(height: 6),
                  _buildMissingItemsMessage(),

                  // Badge de severidad
                  const SizedBox(height: 6),
                  Row(
                    children: <Widget>[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: severidadColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          _getSeveridadLabel(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _getFaltantesLabel(),
                        style: TextStyle(
                          color: severidadColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Widget con el mensaje de items problemáticos
  Widget _buildMissingItemsMessage() {
    final List<String> problems = <String>[];

    if (vehiculo.itemsSinStock > 0) {
      problems.add('${vehiculo.itemsSinStock} sin stock');
    }
    if (vehiculo.itemsCaducados > 0) {
      problems.add('${vehiculo.itemsCaducados} caducados');
    }
    if (vehiculo.itemsStockBajo > 0) {
      problems.add('${vehiculo.itemsStockBajo} stock bajo');
    }
    if (vehiculo.itemsProximosCaducar > 0) {
      problems.add('${vehiculo.itemsProximosCaducar} próximos a caducar');
    }

    if (problems.isEmpty) {
      return const SizedBox.shrink();
    }

    return Text(
      problems.join(' • '),
      style: const TextStyle(
        color: AppColors.textSecondaryLight,
        fontSize: 13,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  /// Retorna el color y icono según la severidad
  (Color color, IconData icon) _getSeveridadData() {
    switch (vehiculo.estadoGeneral) {
      case EstadoStockGeneral.critico:
        return (AppColors.emergency, Icons.error_outline);
      case EstadoStockGeneral.atencion:
        return (AppColors.warning, Icons.warning_amber_outlined);
      case EstadoStockGeneral.ok:
        return (AppColors.success, Icons.check_circle_outline);
    }
  }

  /// Etiqueta de severidad
  String _getSeveridadLabel() {
    switch (vehiculo.estadoGeneral) {
      case EstadoStockGeneral.critico:
        return 'CRÍTICO';
      case EstadoStockGeneral.atencion:
        return 'ATENCIÓN';
      case EstadoStockGeneral.ok:
        return 'OK';
    }
  }

  /// Etiqueta de items con alerta
  String _getFaltantesLabel() {
    final int conAlerta = vehiculo.itemsConAlerta;
    if (conAlerta == 1) {
      return '1 item con alerta';
    } else {
      return '$conAlerta items con alerta';
    }
  }
}
