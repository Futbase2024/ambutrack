import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

export 'gestion_deep_link.dart';
export 'gestion_detail_panel.dart';
export 'gestion_dot_label.dart';
export 'gestion_feedback.dart';
export 'gestion_filter_bar.dart';
export 'gestion_formatters.dart';
export 'gestion_grid.dart';
export 'gestion_print.dart';
export 'gestion_status_bar.dart';
export 'gestion_toolbar.dart';

/// Layout estándar de pantalla tipo programa de gestión:
///
/// ```
/// ┌──────────── barra de herramientas ────────────┐
/// ├──────────── barra de filtros ─────────────────┤
/// │ rejilla                       │ ficha lateral │
/// ├──────────── barra de estado ──────────────────┤
/// ```
///
/// La ficha lateral se estrecha en pantallas medianas (hasta [minDetailWidth])
/// y solo se oculta si la rejilla se quedaría con menos de [minContentWidth]
/// (la rejilla se desplaza en horizontal si sus columnas no caben).
class GestionLayout extends StatelessWidget {
  const GestionLayout({
    required this.toolbar,
    required this.content,
    required this.statusBar,
    this.filterBar,
    this.detailPanel,
    this.detailWidth = 380,
    this.minDetailWidth = 300,
    this.minContentWidth = 420,
    super.key,
  });

  final Widget toolbar;
  final Widget? filterBar;

  /// Normalmente un `GestionGrid`
  final Widget content;
  final Widget? detailPanel;
  final Widget statusBar;

  /// Ancho preferido de la ficha lateral
  final double detailWidth;

  /// Ancho mínimo de la ficha lateral en pantallas medianas
  final double minDetailWidth;

  /// Ancho mínimo que debe quedar para la rejilla al mostrar la ficha
  final double minContentWidth;

  /// Ancho de la ficha para el espacio disponible (null = no cabe)
  double? _detailWidthFor(double available) {
    final double width = (available - minContentWidth).clamp(0, detailWidth).toDouble();
    return width >= minDetailWidth ? width : null;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(10),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          toolbar,
          if (filterBar != null) filterBar!,
          Expanded(
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                final double? panelWidth =
                    detailPanel == null ? null : _detailWidthFor(constraints.maxWidth);
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Expanded(child: content),
                    if (panelWidth != null)
                      Container(
                        width: panelWidth,
                        decoration: const BoxDecoration(
                          border: Border(left: BorderSide(color: AppColors.gray300)),
                        ),
                        child: detailPanel,
                      ),
                  ],
                );
              },
            ),
          ),
          statusBar,
        ],
      ),
    );
  }
}
