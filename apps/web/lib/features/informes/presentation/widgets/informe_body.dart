import 'package:ambutrack_web/features/informes/domain/informe_models.dart';
import 'package:ambutrack_web/features/informes/presentation/widgets/informe_kpi_row.dart';
import 'package:ambutrack_web/features/informes/presentation/widgets/informe_panel.dart';
import 'package:flutter/material.dart';

const double _kChartsHeight = 200;
const double _kMinTableHeight = 320;
const double _kGap = 8;

/// Disposición estándar de un informe:
///
/// ```
/// [KPI] [KPI] [KPI] [KPI] [KPI]
/// [ gráfico 1 ] [ gráfico 2 ]
/// [ tabla de desglose (ocupa el resto) ]
/// ```
///
/// En pantallas bajas el contenido pasa a ser desplazable.
class InformeBody extends StatelessWidget {
  const InformeBody({
    required this.kpis,
    required this.charts,
    required this.tablaTitulo,
    required this.tabla,
    this.tablaTrailing,
    super.key,
  });

  final List<InformeKpi> kpis;
  final List<Widget> charts;
  final String tablaTitulo;
  final String? tablaTrailing;
  final Widget tabla;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double fixed = 76 + _kGap + (charts.isEmpty ? 0 : _kChartsHeight + _kGap);
        final bool scroll = constraints.maxHeight - fixed < _kMinTableHeight;
        final Widget panel = InformePanel(
          title: tablaTitulo,
          trailing: tablaTrailing,
          padding: EdgeInsets.zero,
          child: tabla,
        );
        final List<Widget> children = <Widget>[
          InformeKpiRow(kpis: kpis),
          const SizedBox(height: _kGap),
          if (charts.isNotEmpty) ...<Widget>[
            SizedBox(height: _kChartsHeight, child: _ChartsRow(charts: charts)),
            const SizedBox(height: _kGap),
          ],
          if (scroll) SizedBox(height: _kMinTableHeight, child: panel) else Expanded(child: panel),
        ];
        if (scroll) {
          return SingleChildScrollView(
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: children),
          );
        }
        return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: children);
      },
    );
  }
}

class _ChartsRow extends StatelessWidget {
  const _ChartsRow({required this.charts});

  final List<Widget> charts;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        for (int i = 0; i < charts.length; i++) ...<Widget>[
          if (i > 0) const SizedBox(width: _kGap),
          Expanded(child: charts[i]),
        ],
      ],
    );
  }
}
