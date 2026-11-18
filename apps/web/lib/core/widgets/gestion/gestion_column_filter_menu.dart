import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Resultado del menú de filtro de columna.
/// [accepted] null = quitar el filtro (se muestran todos los valores).
class GestionColumnFilterResult {
  const GestionColumnFilterResult(this.accepted);

  final Set<String>? accepted;
}

const double _kMenuWidth = 270;
const double _kMenuMaxHeight = 420;

/// Abre el filtro estilo Excel de una columna debajo de [anchor].
/// Devuelve null si se cancela.
Future<GestionColumnFilterResult?> showGestionColumnFilterMenu({
  required BuildContext context,
  required Rect anchor,
  required String title,
  required List<String> options,
  required Set<String>? selected,
}) {
  return showDialog<GestionColumnFilterResult>(
    context: context,
    barrierColor: Colors.transparent,
    builder: (BuildContext dialogContext) {
      final Size screen = MediaQuery.sizeOf(dialogContext);
      final double left = anchor.left.clamp(8, screen.width - _kMenuWidth - 8);
      final double top = anchor.bottom.clamp(8, screen.height - _kMenuMaxHeight - 8);
      return SafeArea(
        child: Stack(
          children: <Widget>[
            Positioned(
              left: left,
              top: top,
              width: _kMenuWidth,
              child: _ColumnFilterPanel(title: title, options: options, selected: selected),
            ),
          ],
        ),
      );
    },
  );
}

class _ColumnFilterPanel extends StatefulWidget {
  const _ColumnFilterPanel({required this.title, required this.options, required this.selected});

  final String title;
  final List<String> options;
  final Set<String>? selected;

  @override
  State<_ColumnFilterPanel> createState() => _ColumnFilterPanelState();
}

class _ColumnFilterPanelState extends State<_ColumnFilterPanel> {
  late final Set<String> _checked = widget.selected == null
      ? Set<String>.of(widget.options)
      : widget.selected!.intersection(widget.options.toSet());
  String _query = '';

  List<String> get _visibles => _query.isEmpty
      ? widget.options
      : widget.options.where((String o) => o.toLowerCase().contains(_query.toLowerCase())).toList();

  bool? get _allState {
    final List<String> visibles = _visibles;
    final int marcados = visibles.where(_checked.contains).length;
    if (marcados == 0) {
      return false;
    }
    return marcados == visibles.length ? true : null;
  }

  void _toggleAll() => setState(() {
        final List<String> visibles = _visibles;
        if (_allState ?? false) {
          _checked.removeAll(visibles);
        } else {
          _checked.addAll(visibles);
        }
      });

  void _toggle(String value) => setState(() {
        if (!_checked.remove(value)) {
          _checked.add(value);
        }
      });

  void _apply() {
    final bool todos = _checked.length == widget.options.length;
    Navigator.of(context).pop(GestionColumnFilterResult(todos ? null : Set<String>.of(_checked)));
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 8,
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: _kMenuMaxHeight),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
              child: Text(
                'Filtrar ${widget.title}',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.gray900),
              ),
            ),
            if (widget.options.length > 6) _FilterSearchField(onChanged: (String v) => setState(() => _query = v)),
            _FilterOption(label: '(Seleccionar todo)', value: _allState, bold: true, onTap: _toggleAll),
            const Divider(height: 1, color: AppColors.gray200),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                children: <Widget>[
                  for (final String o in _visibles)
                    _FilterOption(label: o, value: _checked.contains(o), onTap: () => _toggle(o)),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.gray200),
            _FilterFooter(
              onClear: () => Navigator.of(context).pop(const GestionColumnFilterResult(null)),
              onApply: _checked.isEmpty ? null : _apply,
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterSearchField extends StatelessWidget {
  const _FilterSearchField({required this.onChanged});

  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 6),
      child: SizedBox(
        height: 32,
        child: TextField(
          autofocus: true,
          onChanged: onChanged,
          style: const TextStyle(fontSize: 13),
          decoration: InputDecoration(
            isDense: true,
            hintText: 'Buscar...',
            prefixIcon: const Icon(Icons.search, size: 16, color: AppColors.gray500),
            prefixIconConstraints: const BoxConstraints(minWidth: 30),
            contentPadding: const EdgeInsets.symmetric(vertical: 8),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
          ),
        ),
      ),
    );
  }
}

class _FilterOption extends StatelessWidget {
  const _FilterOption({required this.label, required this.value, required this.onTap, this.bold = false});

  final String label;
  final bool? value;
  final VoidCallback onTap;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        height: 32,
        child: Row(
          children: <Widget>[
            const SizedBox(width: 4),
            Checkbox(
              value: value,
              tristate: true,
              visualDensity: VisualDensity.compact,
              activeColor: AppColors.primary,
              onChanged: (_) => onTap(),
            ),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: bold ? FontWeight.w600 : FontWeight.w400,
                  color: AppColors.gray800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterFooter extends StatelessWidget {
  const _FilterFooter({required this.onClear, required this.onApply});

  final VoidCallback onClear;
  final VoidCallback? onApply;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: <Widget>[
          TextButton.icon(
            onPressed: onClear,
            icon: const Icon(Icons.filter_alt_off_outlined, size: 16),
            label: const Text('Quitar filtro'),
            style: TextButton.styleFrom(foregroundColor: AppColors.gray600),
          ),
          const Spacer(),
          FilledButton(
            onPressed: onApply,
            style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Aplicar'),
          ),
        ],
      ),
    );
  }
}
