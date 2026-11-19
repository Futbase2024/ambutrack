import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

export 'gestion_column_filter_chips.dart';
export 'gestion_deep_link.dart';
export 'gestion_detail_panel.dart';
export 'gestion_dot_label.dart';
export 'gestion_feedback.dart';
export 'gestion_filter_bar.dart';
export 'gestion_formatters.dart';
export 'gestion_grid.dart';
export 'gestion_inline_text_cell.dart';
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
///
/// La ficha se puede ocultar y volver a mostrar; la preferencia se guarda y
/// se aplica a todas las pantallas de gestión.
class GestionLayout extends StatefulWidget {
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

  @override
  State<GestionLayout> createState() => _GestionLayoutState();
}

class _GestionLayoutState extends State<GestionLayout> {
  static const String _prefKey = 'gestion_ficha_visible';

  /// Preferencia en memoria (evita parpadeos al cambiar de pantalla)
  static bool? _visibleCache;

  bool _visible = _visibleCache ?? true;

  @override
  void initState() {
    super.initState();
    if (_visibleCache == null) {
      _cargarPreferencia();
    }
  }

  Future<void> _cargarPreferencia() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final bool visible = prefs.getBool(_prefKey) ?? true;
    _visibleCache = visible;
    if (mounted && visible != _visible) {
      setState(() => _visible = visible);
    }
  }

  Future<void> _toggle() async {
    final bool visible = !_visible;
    _visibleCache = visible;
    setState(() => _visible = visible);
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefKey, visible);
  }

  /// Ancho de la ficha para el espacio disponible (null = no cabe)
  double? _detailWidthFor(double available) {
    final double width = (available - widget.minContentWidth).clamp(0, widget.detailWidth).toDouble();
    return width >= widget.minDetailWidth ? width : null;
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
          widget.toolbar,
          if (widget.filterBar != null) widget.filterBar!,
          Expanded(
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                final double? panelWidth =
                    widget.detailPanel == null ? null : _detailWidthFor(constraints.maxWidth);
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Expanded(child: widget.content),
                    if (panelWidth != null && _visible)
                      _DetailSide(width: panelWidth, onHide: _toggle, child: widget.detailPanel!),
                    if (panelWidth != null && !_visible) _CollapsedDetail(onShow: _toggle),
                  ],
                );
              },
            ),
          ),
          widget.statusBar,
        ],
      ),
    );
  }
}

/// Ficha lateral visible, con botón para ocultarla
class _DetailSide extends StatelessWidget {
  const _DetailSide({required this.width, required this.onHide, required this.child});

  final double width;
  final VoidCallback onHide;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      decoration: const BoxDecoration(
        border: Border(left: BorderSide(color: AppColors.gray300)),
      ),
      child: Stack(
        children: <Widget>[
          Positioned.fill(child: child),
          Positioned(
            top: 6,
            right: 6,
            child: IconButton(
              onPressed: onHide,
              tooltip: 'Ocultar ficha',
              icon: const Icon(Icons.keyboard_double_arrow_right, size: 18),
              color: AppColors.gray500,
              visualDensity: VisualDensity.compact,
              style: IconButton.styleFrom(hoverColor: AppColors.gray100),
            ),
          ),
        ],
      ),
    );
  }
}

/// Franja estrecha que sustituye a la ficha oculta; al pulsarla se vuelve a mostrar
class _CollapsedDetail extends StatelessWidget {
  const _CollapsedDetail({required this.onShow});

  final VoidCallback onShow;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Mostrar ficha',
      child: Material(
        color: AppColors.gray50,
        child: InkWell(
          onTap: onShow,
          hoverColor: AppColors.gray100,
          child: Container(
            width: 28,
            decoration: const BoxDecoration(
              border: Border(left: BorderSide(color: AppColors.gray300)),
            ),
            child: const Column(
              children: <Widget>[
                SizedBox(height: 10),
                Icon(Icons.keyboard_double_arrow_left, size: 18, color: AppColors.gray500),
                SizedBox(height: 10),
                RotatedBox(
                  quarterTurns: 1,
                  child: Text(
                    'FICHA',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                      color: AppColors.gray500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
