import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import '../../../../core/theme/app_colors.dart';

/// Card de checklist en la lista de historial
///
/// Muestra resumen del checklist:
/// - Tipo y fecha
/// - Usuario que lo realizó
/// - Porcentaje completado
/// - Badge de estado (OK/NOK)
class ChecklistCard extends StatelessWidget {
  const ChecklistCard({
    super.key,
    required this.checklist,
    this.onTap,
  });

  final ChecklistVehiculoEntity checklist;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final porcentaje = checklist.porcentajeCompleto;
    final color = _getColorPorcentaje(porcentaje);

    return Card(
      margin: EdgeInsets.zero,
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.gray200, width: 1),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cabecera: Tipo + Fecha + Badge
              Row(
                children: [
                  // Icono tipo
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primarySurface,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getIconoTipo(checklist.tipo),
                      size: 20,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Tipo y fecha
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          checklist.tipo.nombre,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.gray900,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _formatFecha(checklist.fechaRealizacion),
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.gray600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Badge estado
                  _EstadoBadge(completo: checklist.checklistCompleto),
                ],
              ),
              const SizedBox(height: 16),

              // Progress bar
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: porcentaje / 100,
                        backgroundColor: AppColors.gray200,
                        valueColor: AlwaysStoppedAnimation<Color>(color),
                        minHeight: 6,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${porcentaje.toInt()}%',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Footer: Usuario + Stats
              Row(
                children: [
                  // Usuario
                  Expanded(
                    child: Row(
                      children: [
                        const Icon(
                          Icons.person_outline,
                          size: 16,
                          color: AppColors.gray500,
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            checklist.realizadoPorNombre,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.gray600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Stats
                  Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        size: 14,
                        color: AppColors.success,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${checklist.itemsPresentes}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.gray700,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.cancel,
                        size: 14,
                        color: AppColors.error,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${checklist.itemsAusentes}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.gray700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Formatea la fecha de realización
  String _formatFecha(DateTime fecha) {
    final ahora = DateTime.now();
    final diferencia = ahora.difference(fecha);

    if (diferencia.inDays == 0) {
      return 'Hoy ${DateFormat('HH:mm').format(fecha)}';
    } else if (diferencia.inDays == 1) {
      return 'Ayer ${DateFormat('HH:mm').format(fecha)}';
    } else if (diferencia.inDays < 7) {
      return '${diferencia.inDays} días atrás';
    } else {
      return DateFormat('dd/MM/yyyy HH:mm').format(fecha);
    }
  }

  /// Obtiene el icono según el tipo de checklist
  IconData _getIconoTipo(TipoChecklist tipo) {
    switch (tipo) {
      case TipoChecklist.preServicio:
        return Icons.play_circle_outline;
      case TipoChecklist.postServicio:
        return Icons.stop_circle_outlined;
      case TipoChecklist.mensual:
        return Icons.calendar_month;
    }
  }

  /// Determina el color según el porcentaje
  Color _getColorPorcentaje(double porcentaje) {
    if (porcentaje == 100) {
      return AppColors.success;
    } else if (porcentaje >= 80) {
      return AppColors.warning;
    } else {
      return AppColors.error;
    }
  }
}

/// Badge de estado del checklist
class _EstadoBadge extends StatelessWidget {
  const _EstadoBadge({required this.completo});

  final bool completo;

  @override
  Widget build(BuildContext context) {
    final color = completo ? AppColors.success : AppColors.error;
    final label = completo ? 'OK' : 'NOK';

    return Align(
      alignment: Alignment.centerLeft,
      child: IntrinsicWidth(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color, width: 1),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ),
      ),
    );
  }
}
