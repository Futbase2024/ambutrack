import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

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
/// La ficha lateral se oculta automáticamente en pantallas estrechas.
class GestionLayout extends StatelessWidget {
  const GestionLayout({
    required this.toolbar,
    required this.content,
    required this.statusBar,
    this.filterBar,
    this.detailPanel,
    this.detailWidth = 380,
    this.minWidthForDetail = 1100,
    super.key,
  });

  final Widget toolbar;
  final Widget? filterBar;

  /// Normalmente un `GestionGrid`
  final Widget content;
  final Widget? detailPanel;
  final Widget statusBar;
  final double detailWidth;
  final double minWidthForDetail;

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
                final bool showDetail = detailPanel != null &&
                    constraints.maxWidth >= minWidthForDetail;
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Expanded(child: content),
                    if (showDetail)
                      Container(
                        width: detailWidth,
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
