import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/features/informes/domain/informe_models.dart';
import 'package:flutter/material.dart';

/// Fila compacta de indicadores clave
class InformeKpiRow extends StatelessWidget {
  const InformeKpiRow({required this.kpis, super.key});

  final List<InformeKpi> kpis;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 76,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          for (int i = 0; i < kpis.length; i++) ...<Widget>[
            if (i > 0) const SizedBox(width: 8),
            Expanded(child: _KpiTile(kpi: kpis[i])),
          ],
        ],
      ),
    );
  }
}

class _KpiTile extends StatelessWidget {
  const _KpiTile({required this.kpi});

  final InformeKpi kpi;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            kpi.label.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
              color: AppColors.gray500,
            ),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              kpi.valor,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.gray900,
              ),
            ),
          ),
          if (kpi.detalle != null)
            Text(
              kpi.detalle!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 11, color: AppColors.gray500),
            ),
        ],
      ),
    );
  }
}
