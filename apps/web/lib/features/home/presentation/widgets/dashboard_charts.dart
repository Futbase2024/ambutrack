import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/features/home/presentation/config/dashboard_card_config.dart';
import 'package:ambutrack_web/features/home/presentation/widgets/inicio/inicio_panel.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Sección de gráficas profesionales del Dashboard
///
/// Incluye:
/// - Gráfica de barras: Vehículos por estado
/// - Gráfica circular: Distribución de servicios
/// - Gráfica de resumen: Estadísticas del día
class DashboardCharts extends StatelessWidget {
  const DashboardCharts({
    super.key,
    required this.totalVehiculos,
    required this.vehiculosEnServicio,
    required this.vehiculosMantenimiento,
    required this.vehiculosDisponibles,
    required this.serviciosProgramadosActivos,
    required this.serviciosProgramadosCompletados,
    required this.serviciosUrgenciasActivos,
    required this.serviciosUrgenciasCompletados,
    required this.serviciosTotalesDia,
    required this.serviciosCompletadosDia,
    required this.serviciosEnProceso,
    this.visibleCharts,
  });

  final int totalVehiculos;
  final int vehiculosEnServicio;
  final int vehiculosMantenimiento;
  final int vehiculosDisponibles;
  final int serviciosProgramadosActivos;
  final int serviciosProgramadosCompletados;
  final int serviciosUrgenciasActivos;
  final int serviciosUrgenciasCompletados;
  final int serviciosTotalesDia;
  final int serviciosCompletadosDia;
  final int serviciosEnProceso;

  /// Charts a mostrar. Si es null, se muestran todos (backward compatible).
  final Set<DashboardChartType>? visibleCharts;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        // Responsive: 3 columnas en desktop, 2 en tablet, 1 en móvil
        final int crossAxisCount = constraints.maxWidth > 1200
            ? 3
            : constraints.maxWidth > 800
            ? 2
            : 1;

        // Calcular aspect ratio dinámico para llenar el espacio disponible
        const double mainSpacing = 14;
        const double crossSpacing = 14;
        final double cellWidth = (constraints.maxWidth - (crossAxisCount - 1) * crossSpacing) / crossAxisCount;

        // Usar la altura disponible para calcular el ratio
        // Con 3 charts en 1 fila: cellHeight = availableHeight
        final double cellHeight = constraints.maxHeight;
        final double aspectRatio = cellHeight.isFinite ? (cellWidth / cellHeight) : 1.4;

        // Construir charts según filtro de visibilidad
        final bool showAll = visibleCharts == null;
        final List<Widget> chartWidgets = <Widget>[
          if (showAll || visibleCharts!.contains(DashboardChartType.flota))
            _VehiculosChartCard(
              disponibles: vehiculosDisponibles,
              enServicio: vehiculosEnServicio,
              mantenimiento: vehiculosMantenimiento,
              inactivos: totalVehiculos - vehiculosDisponibles - vehiculosEnServicio - vehiculosMantenimiento,
            ),
          if (showAll || visibleCharts!.contains(DashboardChartType.servicios))
            _ServiciosDistributionCard(
              urgencias: serviciosUrgenciasActivos + serviciosUrgenciasCompletados,
              programados: serviciosProgramadosActivos + serviciosProgramadosCompletados,
              enProceso: serviciosEnProceso,
              completados: serviciosCompletadosDia,
            ),
          if (showAll || visibleCharts!.contains(DashboardChartType.resumenDia))
            _ResumenDiaCard(
              totalDia: serviciosTotalesDia,
              completados: serviciosCompletadosDia,
              enProceso: serviciosEnProceso,
              pendientes: serviciosTotalesDia - serviciosCompletadosDia - serviciosEnProceso,
            ),
        ];

        // Ajustar columnas al número real de charts visibles
        final int effectiveColumns = crossAxisCount > chartWidgets.length ? chartWidgets.length : crossAxisCount;

        return GridView.count(
          crossAxisCount: effectiveColumns,
          mainAxisSpacing: mainSpacing,
          crossAxisSpacing: crossSpacing,
          childAspectRatio: aspectRatio.clamp(0.8, 3.0),
          children: chartWidgets,
        );
      },
    );
  }
}

/// Card con gráfica de barras para vehículos por estado
class _VehiculosChartCard extends StatelessWidget {
  const _VehiculosChartCard({
    required this.disponibles,
    required this.enServicio,
    required this.mantenimiento,
    required this.inactivos,
  });

  final int disponibles;
  final int enServicio;
  final int mantenimiento;
  final int inactivos;

  @override
  Widget build(BuildContext context) {
    return _ChartCard(
      title: 'Flota de Vehículos',
      subtitle: 'Por estado actual',
      icon: Icons.directions_bus_outlined,
      iconColor: AppColors.success,
      child: _BarChart(
        data: <_BarData>[
          _BarData('Disponibles', disponibles, AppColors.success),
          _BarData('En Servicio', enServicio, AppColors.primary),
          _BarData('Mantenimiento', mantenimiento, AppColors.warning),
          _BarData('Inactivos', inactivos.clamp(0, 999), AppColors.error),
        ],
      ),
    );
  }
}

/// Card con gráfica circular de distribución de servicios
class _ServiciosDistributionCard extends StatelessWidget {
  const _ServiciosDistributionCard({
    required this.urgencias,
    required this.programados,
    required this.enProceso,
    required this.completados,
  });

  final int urgencias;
  final int programados;
  final int enProceso;
  final int completados;

  @override
  Widget build(BuildContext context) {
    final int total = urgencias + programados + enProceso;
    return _ChartCard(
      title: 'Tipos de Servicios',
      subtitle: 'Distribución actual',
      icon: Icons.pie_chart_outline,
      iconColor: AppColors.info,
      child: total > 0
          ? _PieChart(
              data: <_PieData>[
                _PieData('Urgencias', urgencias, AppColors.emergency),
                _PieData('Programados', programados, AppColors.primary),
                _PieData('En Proceso', enProceso, AppColors.info),
              ],
            )
          : const _EmptyChart(message: 'Sin servicios activos'),
    );
  }
}

/// Card con resumen estadístico del día
class _ResumenDiaCard extends StatelessWidget {
  const _ResumenDiaCard({
    required this.totalDia,
    required this.completados,
    required this.enProceso,
    required this.pendientes,
  });

  final int totalDia;
  final int completados;
  final int enProceso;
  final int pendientes;

  @override
  Widget build(BuildContext context) {
    return _ChartCard(
      title: 'Resumen del Día',
      subtitle: 'Servicios de hoy',
      icon: Icons.analytics_outlined,
      iconColor: AppColors.primary,
      child: _DaySummaryChart(
        total: totalDia,
        completados: completados,
        enProceso: enProceso,
        pendientes: pendientes.clamp(0, 999),
      ),
    );
  }
}

/// Card contenedor para las gráficas
class _ChartCard extends StatelessWidget {
  const _ChartCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.child,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    // Mismo estilo que los paneles del dashboard (borde fino + cabecera)
    return InicioPanel(
      title: title,
      icon: icon,
      trailing: Text(
        subtitle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontSize: 11.5, color: AppColors.gray500),
      ),
      child: Padding(padding: const EdgeInsets.all(12), child: child),
    );
  }
}

/// Widget para mostrar cuando no hay datos
class _EmptyChart extends StatelessWidget {
  const _EmptyChart({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Icon(Icons.info_outline, size: 48, color: AppColors.gray300),
          const SizedBox(height: 12),
          Text(
            message,
            style: GoogleFonts.inter(fontSize: 14, color: AppColors.gray500),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Gráfica de barras personalizada
class _BarChart extends StatelessWidget {
  const _BarChart({required this.data});

  final List<_BarData> data;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return CustomPaint(
          size: Size(constraints.maxWidth, constraints.maxHeight),
          painter: _BarChartPainter(data: data),
        );
      },
    );
  }
}

/// Painter para la gráfica de barras
class _BarChartPainter extends CustomPainter {
  _BarChartPainter({required this.data});

  final List<_BarData> data;

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) {
      return;
    }

    const double padding = 40;
    final double chartWidth = size.width - padding * 2;
    final double chartHeight = size.height - padding * 2;

    // Encontrar valor máximo
    final int maxValue = data.map((_BarData d) => d.value).reduce((int a, int b) => a > b ? a : b);
    if (maxValue == 0) {
      // Si todos son 0, mostrar mensaje
      final TextPainter emptyPainter = TextPainter(
        text: TextSpan(
          text: 'Sin datos',
          style: GoogleFonts.inter(fontSize: 14, color: AppColors.gray400),
        ),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );
      emptyPainter
        ..layout()
        ..paint(canvas, Offset(size.width / 2 - emptyPainter.width / 2, size.height / 2));
      return;
    }

    final double yScale = chartHeight / (maxValue * 1.2);
    final double barWidth = chartWidth / data.length * 0.6;
    final double barSpacing = chartWidth / data.length;

    // Pintar grid horizontal
    final Paint gridPaint = Paint()
      ..color = AppColors.gray100
      ..strokeWidth = 1;

    for (int i = 0; i <= 4; i++) {
      final double y = padding + (chartHeight / 4) * i;
      canvas.drawLine(Offset(padding, y), Offset(size.width - padding, y), gridPaint);
    }

    // Pintar barras
    for (int i = 0; i < data.length; i++) {
      final double barHeight = data[i].value * yScale;
      final double x = padding + barSpacing * i + (barSpacing - barWidth) / 2;
      final double y = padding + chartHeight - barHeight;

      // Barra con redondeo superior
      final RRect barRect = RRect.fromRectAndCorners(
        Rect.fromLTWH(x, y, barWidth, barHeight),
        topLeft: const Radius.circular(6),
        topRight: const Radius.circular(6),
      );

      final Paint barPaint = Paint()
        ..color = data[i].color
        ..style = PaintingStyle.fill;

      canvas.drawRRect(barRect, barPaint);

      // Valor encima de la barra
      final TextPainter valuePainter = TextPainter(
        text: TextSpan(
          text: data[i].value.toString(),
          style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: data[i].color),
        ),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );
      valuePainter
        ..layout()
        ..paint(canvas, Offset(x + barWidth / 2 - valuePainter.width / 2, y - 18));

      // Etiqueta debajo de la barra
      final TextPainter labelPainter = TextPainter(
        text: TextSpan(
          text: data[i].label,
          style: GoogleFonts.inter(fontSize: 10, color: AppColors.gray600),
        ),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );
      labelPainter
        ..layout()
        ..paint(canvas, Offset(x + barWidth / 2 - labelPainter.width / 2, size.height - 15));
    }
  }

  @override
  bool shouldRepaint(covariant _BarChartPainter oldDelegate) {
    return oldDelegate.data != data;
  }
}

/// Gráfica circular personalizada
class _PieChart extends StatelessWidget {
  const _PieChart({required this.data});

  final List<_PieData> data;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return Row(
          children: <Widget>[
            // Gráfica circular
            Expanded(
              flex: 3,
              child: CustomPaint(
                size: Size(constraints.maxHeight, constraints.maxHeight),
                painter: _PieChartPainter(data: data),
              ),
            ),
            // Leyenda
            Expanded(flex: 2, child: _PieLegend(data: data)),
          ],
        );
      },
    );
  }
}

/// Painter para la gráfica circular
class _PieChartPainter extends CustomPainter {
  _PieChartPainter({required this.data});

  final List<_PieData> data;

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) {
      return;
    }

    final double centerX = size.width / 2;
    final double centerY = size.height / 2;
    final double radius = size.width / 2 - 20;
    final double innerRadius = radius * 0.6;

    // Calcular total
    final double total = data.map((_PieData d) => d.value).reduce((int a, int b) => a + b).toDouble();

    if (total == 0) {
      return;
    }

    double startAngle = -90 * (3.14159 / 180); // Empezar desde arriba

    for (final _PieData item in data) {
      if (item.value == 0) {
        continue;
      }

      final double sweepAngle = (item.value / total) * 360 * (3.14159 / 180);

      // Dibujar segmento
      final Paint segmentPaint = Paint()
        ..color = item.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = radius - innerRadius
        ..strokeCap = StrokeCap.butt;

      canvas.drawArc(
        Rect.fromCircle(center: Offset(centerX, centerY), radius: (radius + innerRadius) / 2),
        startAngle,
        sweepAngle,
        false,
        segmentPaint,
      );

      startAngle += sweepAngle;
    }

    // Círculo central (donut)
    final Paint centerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(centerX, centerY), innerRadius - 5, centerPaint);

    // Texto central
    final TextPainter totalPainter = TextPainter(
      text: TextSpan(
        children: <TextSpan>[
          TextSpan(
            text: total.toInt().toString(),
            style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.gray900),
          ),
          TextSpan(
            text: '\nTotal',
            style: GoogleFonts.inter(fontSize: 12, color: AppColors.gray500),
          ),
        ],
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    totalPainter
      ..layout()
      ..paint(canvas, Offset(centerX - totalPainter.width / 2, centerY - totalPainter.height / 2));
  }

  @override
  bool shouldRepaint(covariant _PieChartPainter oldDelegate) {
    return oldDelegate.data != data;
  }
}

/// Leyenda para la gráfica circular
class _PieLegend extends StatelessWidget {
  const _PieLegend({required this.data});

  final List<_PieData> data;

  @override
  Widget build(BuildContext context) {
    final int total = data.map((_PieData d) => d.value).reduce((int a, int b) => a + b);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: data.map((_PieData item) {
        final int percentage = total > 0 ? ((item.value / total) * 100).round() : 0;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: <Widget>[
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(color: item.color, borderRadius: BorderRadius.circular(3)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      item.label,
                      style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.gray700),
                    ),
                    Text(
                      '$percentage% (${item.value})',
                      style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.gray900),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

/// Gráfica de resumen del día (barra horizontal)
class _DaySummaryChart extends StatelessWidget {
  const _DaySummaryChart({
    required this.total,
    required this.completados,
    required this.enProceso,
    required this.pendientes,
  });

  final int total;
  final int completados;
  final int enProceso;
  final int pendientes;

  @override
  Widget build(BuildContext context) {
    if (total == 0) {
      return const _EmptyChart(message: 'Sin servicios programados');
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        // Barra de progreso
        _ProgressBar(completados: completados, enProceso: enProceso, pendientes: pendientes, total: total),
        const SizedBox(height: 24),
        // Estadísticas en filas
        _StatRow(icon: Icons.check_circle_outline, label: 'Completados', value: completados, color: AppColors.success),
        const SizedBox(height: 12),
        _StatRow(icon: Icons.pending_outlined, label: 'En Proceso', value: enProceso, color: AppColors.info),
        const SizedBox(height: 12),
        _StatRow(icon: Icons.schedule_outlined, label: 'Pendientes', value: pendientes, color: AppColors.warning),
      ],
    );
  }
}

/// Barra de progreso con segmentos
class _ProgressBar extends StatelessWidget {
  const _ProgressBar({
    required this.completados,
    required this.enProceso,
    required this.pendientes,
    required this.total,
  });

  final int completados;
  final int enProceso;
  final int pendientes;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        // Barra
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            height: 24,
            child: Row(
              children: <Widget>[
                if (completados > 0)
                  Expanded(
                    flex: completados,
                    child: Container(color: AppColors.success),
                  ),
                if (enProceso > 0)
                  Expanded(
                    flex: enProceso,
                    child: Container(color: AppColors.info),
                  ),
                if (pendientes > 0)
                  Expanded(
                    flex: pendientes,
                    child: Container(color: AppColors.warning),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        // Porcentaje
        Text(
          total > 0 ? '${((completados / total) * 100).round()}% completado' : '0% completado',
          style: GoogleFonts.inter(fontSize: 12, color: AppColors.gray600),
        ),
      ],
    );
  }
}

/// Fila de estadística
class _StatRow extends StatelessWidget {
  const _StatRow({required this.icon, required this.label, required this.value, required this.color});

  final IconData icon;
  final String label;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 12),
        Expanded(
          child: Text(label, style: GoogleFonts.inter(fontSize: 14, color: AppColors.gray700)),
        ),
        Text(
          value.toString(),
          style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: color),
        ),
      ],
    );
  }
}

/// Modelos de datos para las gráficas
class _BarData {
  const _BarData(this.label, this.value, this.color);

  final String label;
  final int value;
  final Color color;
}

class _PieData {
  const _PieData(this.label, this.value, this.color);

  final String label;
  final int value;
  final Color color;
}
