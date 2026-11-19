import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/features/informes/domain/informe_models.dart';
import 'package:ambutrack_web/features/informes/presentation/widgets/informe_panel.dart';
import 'package:flutter/material.dart';

/// Gráfico de barras horizontales hecho con widgets (sin dependencias)
class InformeBarChart extends StatelessWidget {
  const InformeBarChart({
    required this.title,
    required this.items,
    this.color = AppColors.primary,
    this.emptyMessage = 'Sin datos en el periodo',
    super.key,
  });

  final String title;
  final List<InformeBarItem> items;
  final Color color;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    final double maximo = items.fold<double>(
      0,
      (double m, InformeBarItem i) => i.valor > m ? i.valor : m,
    );
    return InformePanel(
      title: title,
      child: items.isEmpty || maximo <= 0
          ? Center(
              child: Text(
                emptyMessage,
                style: const TextStyle(fontSize: 12, color: AppColors.gray400),
              ),
            )
          : ListView.builder(
              itemCount: items.length,
              itemExtent: 24,
              itemBuilder: (BuildContext context, int i) => _BarRow(
                item: items[i],
                factor: items[i].valor / maximo,
                color: color,
              ),
            ),
    );
  }
}

class _BarRow extends StatelessWidget {
  const _BarRow({required this.item, required this.factor, required this.color});

  final InformeBarItem item;
  final double factor;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        SizedBox(
          width: 140,
          child: Tooltip(
            message: item.label,
            waitDuration: const Duration(milliseconds: 400),
            child: Text(
              item.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12, color: AppColors.gray700),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Align(
            alignment: Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: factor.clamp(0.01, 1.0),
              child: Container(
                height: 12,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.75),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
        ),
        SizedBox(
          width: 92,
          child: Text(
            item.texto,
            textAlign: TextAlign.right,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.gray800,
            ),
          ),
        ),
      ],
    );
  }
}
