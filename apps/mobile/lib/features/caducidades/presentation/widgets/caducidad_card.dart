import 'package:flutter/material.dart';
import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';

/// Card de item con caducidad
///
/// Muestra:
/// - Producto (nombre + nombre comercial)
/// - Cantidad actual
/// - Fecha de caducidad
/// - Badge de estado (ok/proximo/critico/caducado)
/// - Días restantes
/// - Botones de acción rápida (si crítico/caducado)
class CaducidadCard extends StatelessWidget {
  const CaducidadCard({
    super.key,
    required this.item,
    this.onTap,
    this.onSolicitarReposicion,
    this.onRegistrarIncidencia,
  });

  final StockVehiculoEntity item;
  final VoidCallback? onTap;
  final VoidCallback? onSolicitarReposicion;
  final VoidCallback? onRegistrarIncidencia;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Producto + Badge estado
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.productoNombre ?? 'Sin nombre',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.gray900,
                          ),
                        ),
                        if (item.nombreComercial != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            item.nombreComercial!,
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.gray600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Badge de estado (con IntrinsicWidth)
                  Align(
                    alignment: Alignment.centerRight,
                    child: IntrinsicWidth(
                      child: _EstadoBadge(estadoCaducidad: item.estadoCaducidad),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),

              // Info: Cantidad, Fecha, Días restantes
              Row(
                children: [
                  // Cantidad
                  Expanded(
                    child: _InfoItem(
                      icon: Icons.inventory_2_outlined,
                      label: 'Cantidad',
                      value: '${item.cantidadActual} uds',
                    ),
                  ),
                  // Fecha caducidad
                  Expanded(
                    child: _InfoItem(
                      icon: Icons.calendar_today_outlined,
                      label: 'Caducidad',
                      value: _formatFechaCaducidad(),
                    ),
                  ),
                  // Días restantes
                  Expanded(
                    child: _InfoItem(
                      icon: Icons.timelapse_outlined,
                      label: 'Días',
                      value: _calcularDiasRestantes(),
                      valueColor: _getColorDiasRestantes(),
                    ),
                  ),
                ],
              ),

              // Botones de acción (solo si crítico/caducado)
              if (_mostrarBotonesAccion()) ...[
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onSolicitarReposicion,
                        icon: const Icon(Icons.refresh, size: 18),
                        label: const Text('Reponer'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onRegistrarIncidencia,
                        icon: const Icon(Icons.report_problem_outlined, size: 18),
                        label: const Text('Incidencia'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.error,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatFechaCaducidad() {
    if (item.fechaCaducidad == null) return 'N/A';
    final fecha = item.fechaCaducidad!;
    return '${fecha.day.toString().padLeft(2, '0')}/${fecha.month.toString().padLeft(2, '0')}/${fecha.year}';
  }

  String _calcularDiasRestantes() {
    if (item.fechaCaducidad == null) return 'N/A';
    final dias = item.fechaCaducidad!.difference(DateTime.now()).inDays;
    if (dias < 0) return 'Caducado';
    return '$dias días';
  }

  Color _getColorDiasRestantes() {
    if (item.fechaCaducidad == null) return AppColors.gray700;
    final dias = item.fechaCaducidad!.difference(DateTime.now()).inDays;
    if (dias < 0) return AppColors.emergency;
    if (dias <= 7) return AppColors.error;
    if (dias <= 30) return AppColors.warning;
    return AppColors.success;
  }

  bool _mostrarBotonesAccion() {
    return item.estadoCaducidad == 'critico' ||
        item.estadoCaducidad == 'caducado';
  }
}

/// Widget para badge de estado de caducidad
class _EstadoBadge extends StatelessWidget {
  const _EstadoBadge({required this.estadoCaducidad});

  final String? estadoCaducidad;

  @override
  Widget build(BuildContext context) {
    final estado = estadoCaducidad ?? 'sin_caducidad';
    Color color;
    IconData icon;
    String label;

    switch (estado) {
      case 'ok':
        color = AppColors.success;
        icon = Icons.check_circle;
        label = 'OK';
        break;
      case 'proximo':
        color = AppColors.warning;
        icon = Icons.warning_amber;
        label = 'Próximo';
        break;
      case 'critico':
        color = AppColors.error;
        icon = Icons.error;
        label = 'Crítico';
        break;
      case 'caducado':
        color = AppColors.emergency;
        icon = Icons.cancel;
        label = 'Caducado';
        break;
      default:
        color = AppColors.gray500;
        icon = Icons.info;
        label = 'N/A';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        border: Border.all(color: color, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget para mostrar información de un campo
class _InfoItem extends StatelessWidget {
  const _InfoItem({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: AppColors.gray600),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.gray600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: valueColor ?? AppColors.gray900,
          ),
        ),
      ],
    );
  }
}
