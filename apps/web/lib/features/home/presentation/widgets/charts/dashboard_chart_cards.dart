import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/features/home/presentation/widgets/charts/dashboard_bar_chart.dart';
import 'package:ambutrack_web/features/home/presentation/widgets/charts/dashboard_day_summary.dart';
import 'package:ambutrack_web/features/home/presentation/widgets/charts/dashboard_donut_chart.dart';
import 'package:ambutrack_web/features/home/presentation/widgets/inicio/inicio_panel.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Card con gráfica de barras para vehículos por estado
class VehiculosChartCard extends StatelessWidget {
  const VehiculosChartCard({
    required this.disponibles,
    required this.enServicio,
    required this.mantenimiento,
    required this.inactivos,
    super.key,
  });

  final int disponibles;
  final int enServicio;
  final int mantenimiento;
  final int inactivos;

  @override
  Widget build(BuildContext context) {
    return DashboardChartCard(
      title: 'Flota de Vehículos',
      subtitle: 'Por estado actual',
      icon: Icons.directions_bus_outlined,
      child: DashboardBarChart(
        data: <DashboardBarData>[
          DashboardBarData('Disponibles', disponibles, AppColors.success),
          DashboardBarData('En Servicio', enServicio, AppColors.primary),
          DashboardBarData('Mantenimiento', mantenimiento, AppColors.warning),
          DashboardBarData('Inactivos', inactivos < 0 ? 0 : inactivos, AppColors.error),
        ],
      ),
    );
  }
}

/// Card con gráfica circular de distribución de servicios
class ServiciosDistributionCard extends StatelessWidget {
  const ServiciosDistributionCard({
    required this.urgencias,
    required this.programados,
    required this.enProceso,
    super.key,
  });

  final int urgencias;
  final int programados;
  final int enProceso;

  @override
  Widget build(BuildContext context) {
    final int total = urgencias + programados + enProceso;
    return DashboardChartCard(
      title: 'Tipos de Servicios',
      subtitle: 'Distribución actual',
      icon: Icons.pie_chart_outline,
      child: total > 0
          ? DashboardDonutChart(
              data: <DashboardDonutData>[
                DashboardDonutData('Urgencias', urgencias, AppColors.emergency),
                DashboardDonutData('Programados', programados, AppColors.primary),
                DashboardDonutData('En Proceso', enProceso, AppColors.info),
              ],
            )
          : const DashboardEmptyChart(message: 'Sin servicios activos'),
    );
  }
}

/// Card con resumen estadístico del día
class ResumenDiaCard extends StatelessWidget {
  const ResumenDiaCard({
    required this.totalDia,
    required this.completados,
    required this.enProceso,
    required this.pendientes,
    super.key,
  });

  final int totalDia;
  final int completados;
  final int enProceso;
  final int pendientes;

  @override
  Widget build(BuildContext context) {
    return DashboardChartCard(
      title: 'Resumen del Día',
      subtitle: 'Servicios de hoy',
      icon: Icons.analytics_outlined,
      child: totalDia == 0
          ? const DashboardEmptyChart(message: 'Sin servicios programados')
          : DashboardDaySummary(
              total: totalDia,
              completados: completados,
              enProceso: enProceso,
              pendientes: pendientes < 0 ? 0 : pendientes,
            ),
    );
  }
}

/// Card contenedor de las gráficas (mismo estilo que los paneles del dashboard)
class DashboardChartCard extends StatelessWidget {
  const DashboardChartCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.child,
    super.key,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return InicioPanel(
      title: title,
      icon: icon,
      trailing: Text(
        subtitle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontSize: 11.5, color: AppColors.gray500),
      ),
      child: ClipRect(
        child: Padding(padding: const EdgeInsets.all(12), child: child),
      ),
    );
  }
}

/// Estado vacío de una gráfica (se reduce si el espacio es pequeño)
class DashboardEmptyChart extends StatelessWidget {
  const DashboardEmptyChart({required this.message, super.key});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(Icons.info_outline, size: 40, color: AppColors.gray300),
            const SizedBox(height: 10),
            Text(
              message,
              style: GoogleFonts.inter(fontSize: 14, color: AppColors.gray500),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
