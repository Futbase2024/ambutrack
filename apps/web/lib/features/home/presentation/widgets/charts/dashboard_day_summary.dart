import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Resumen del día: barra de progreso segmentada + filas de estadísticas.
///
/// Reparte el espacio vertical disponible y, si no cabe, se reduce
/// proporcionalmente en lugar de desbordar.
class DashboardDaySummary extends StatelessWidget {
  const DashboardDaySummary({
    required this.total,
    required this.completados,
    required this.enProceso,
    required this.pendientes,
    super.key,
  });

  final int total;
  final int completados;
  final int enProceso;
  final int pendientes;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.topCenter,
          child: SizedBox(
            width: constraints.maxWidth,
            height: constraints.maxHeight < 150 ? 150 : constraints.maxHeight,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                _SegmentedProgress(
                  total: total,
                  completados: completados,
                  enProceso: enProceso,
                  pendientes: pendientes,
                ),
                _StatRow(
                  icon: Icons.check_circle_outline,
                  label: 'Completados',
                  value: completados,
                  color: AppColors.success,
                ),
                _StatRow(icon: Icons.pending_outlined, label: 'En Proceso', value: enProceso, color: AppColors.info),
                _StatRow(
                  icon: Icons.schedule_outlined,
                  label: 'Pendientes',
                  value: pendientes,
                  color: AppColors.warning,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Barra de progreso con segmentos completados / en proceso / pendientes
class _SegmentedProgress extends StatelessWidget {
  const _SegmentedProgress({
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
    final int porcentaje = total > 0 ? (completados / total * 100).round() : 0;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Container(
            height: 18,
            color: AppColors.gray100,
            child: Row(
              children: <Widget>[
                if (completados > 0) Expanded(flex: completados, child: Container(color: AppColors.success)),
                if (enProceso > 0) Expanded(flex: enProceso, child: Container(color: AppColors.info)),
                if (pendientes > 0) Expanded(flex: pendientes, child: Container(color: AppColors.warning)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text('$porcentaje% completado', style: GoogleFonts.inter(fontSize: 12, color: AppColors.gray600)),
      ],
    );
  }
}

/// Fila de estadística (icono, etiqueta y valor)
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
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(fontSize: 14, color: AppColors.gray700),
          ),
        ),
        Text(
          value.toString(),
          style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: color),
        ),
      ],
    );
  }
}
