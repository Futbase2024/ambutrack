import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/features/home/presentation/widgets/stat_card.dart';
import 'package:flutter/material.dart';

/// Tarjetas de estadísticas para el dashboard principal.
///
/// Todas las cards comparten el mismo diseño: fondo blanco con borde
/// de color temático, valor grande y botón añadir opcional.
class DashboardStatsCards extends StatelessWidget {
  const DashboardStatsCards({
    super.key,
    required this.serviciosActivos,
    required this.disponibles,
    required this.mantenimientosProgramados,
    required this.mantenimientosEnProceso,
    required this.mantenimientosCompletados,
    required this.personalActivo,
    required this.pendientesHoy,
    required this.incidenciasAbiertas,
    this.onAddPendiente,
    this.onAddIncidencia,
    this.onAddMantenimiento,
    this.onTapServicios,
    this.onTapVehiculos,
    this.onTapMantenimiento,
    this.onTapPersonal,
    this.onTapAgenda,
    this.onTapIncidencias,
  });

  final int serviciosActivos;
  final int disponibles;
  final int mantenimientosProgramados;
  final int mantenimientosEnProceso;
  final int mantenimientosCompletados;
  final int personalActivo;
  final int pendientesHoy;
  final int incidenciasAbiertas;

  final VoidCallback? onAddPendiente;
  final VoidCallback? onAddIncidencia;
  final VoidCallback? onAddMantenimiento;
  final VoidCallback? onTapServicios;
  final VoidCallback? onTapVehiculos;
  final VoidCallback? onTapMantenimiento;
  final VoidCallback? onTapPersonal;
  final VoidCallback? onTapAgenda;
  final VoidCallback? onTapIncidencias;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        // Responsive: 6 columnas en desktop, 3 en tablet, 2 en móvil
        int crossAxisCount = 6;
        if (constraints.maxWidth < 1200) {
          crossAxisCount = 3;
        }
        if (constraints.maxWidth < 600) {
          crossAxisCount = 2;
        }

        // Aspect ratio dinámico: llena el espacio del Flexible(flex: 4)
        const double crossSpacing = 16;
        const double mainSpacing = 16;
        final double cellWidth =
            (constraints.maxWidth - (crossAxisCount - 1) * crossSpacing) /
                crossAxisCount;
        // 6 cards en 1 fila → cellHeight = availableHeight
        final double cellHeight = constraints.maxHeight;
        final double aspectRatio =
            cellHeight.isFinite ? (cellWidth / cellHeight) : 1.55;

        return GridView.count(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: crossSpacing,
          mainAxisSpacing: mainSpacing,
          childAspectRatio: aspectRatio.clamp(0.8, 3.0),
          children: <Widget>[
            StatCard(
              title: 'Servicios',
              value: _formatNumber(serviciosActivos),
              icon: Icons.medical_services_outlined,
              accentColor: AppColors.primary,
              onTap: onTapServicios,
            ),
            StatCard(
              title: 'Vehículos',
              value: disponibles.toString(),
              icon: Icons.check_circle_outline,
              accentColor: AppColors.secondary,
              onTap: onTapVehiculos,
            ),
            StatCard(
              title: 'Mantenimiento',
              value: (mantenimientosProgramados + mantenimientosEnProceso)
                  .toString(),
              subtitle: 'activos',
              icon: Icons.build_outlined,
              accentColor: AppColors.warning,
              detalles: <StatCardDetalle>[
                StatCardDetalle(
                  label: 'Programados',
                  count: mantenimientosProgramados,
                  color: AppColors.info,
                ),
                StatCardDetalle(
                  label: 'En proceso',
                  count: mantenimientosEnProceso,
                  color: AppColors.warning,
                ),
                StatCardDetalle(
                  label: 'Completados',
                  count: mantenimientosCompletados,
                  color: AppColors.success,
                ),
              ],
              onTap: onTapMantenimiento,
              onAdd: onAddMantenimiento,
            ),
            StatCard(
              title: 'Personal',
              value: personalActivo.toString(),
              icon: Icons.badge_outlined,
              accentColor: const Color(0xFF7C3AED),
              onTap: onTapPersonal,
            ),
            StatCard(
              title: 'Agenda Pend.',
              value: pendientesHoy.toString(),
              icon: Icons.event_note,
              accentColor: AppColors.info,
              onTap: onTapAgenda,
              onAdd: onAddPendiente,
            ),
            StatCard(
              title: 'Incidencias',
              value: incidenciasAbiertas.toString(),
              subtitle: incidenciasAbiertas == 1 ? 'abierta' : 'abiertas',
              icon: Icons.report_problem_outlined,
              accentColor: AppColors.error,
              onTap: onTapIncidencias,
              onAdd: onAddIncidencia,
            ),
          ],
        );
      },
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}k'.replaceAll('.0', '');
    }
    return number.toString();
  }
}
