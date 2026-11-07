import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

export 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
export 'gestion_frame_controls.dart';
export 'gestion_frame_indicators.dart';

/// Marco estándar para pantallas "especiales" (calendarios, planificadores,
/// dashboards) que no usan rejilla pero deben verse coherentes con las
/// pantallas de `GestionLayout`:
///
/// ```
/// ┌──────────── barra de herramientas ────────────┐
/// ├──────────── barra de filtros (opcional) ──────┤
/// │ contenido libre                               │
/// ├──────────── barra de estado (opcional) ───────┤
/// ```
class GestionFrame extends StatelessWidget {
  const GestionFrame({
    required this.content,
    this.toolbar,
    this.filterBar,
    this.statusBar,
    this.contentPadding = const EdgeInsets.all(8),
    super.key,
  });

  /// Normalmente un `GestionToolbar`
  final Widget? toolbar;

  /// Normalmente un `GestionFilterBar`
  final Widget? filterBar;
  final Widget content;

  /// Normalmente un `GestionStatusBar`
  final Widget? statusBar;
  final EdgeInsetsGeometry contentPadding;

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
          if (toolbar != null) toolbar!,
          if (filterBar != null) filterBar!,
          Expanded(
            child: Padding(padding: contentPadding, child: content),
          ),
          if (statusBar != null) statusBar!,
        ],
      ),
    );
  }
}
