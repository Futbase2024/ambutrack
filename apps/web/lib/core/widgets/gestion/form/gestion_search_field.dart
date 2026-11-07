import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion/form/gestion_form_fields.dart';
import 'package:ambutrack_web/core/widgets/gestion/form/gestion_form_style.dart';
import 'package:flutter/material.dart';

/// Desplegable con búsqueda para listas largas (> 10 opciones).
///
/// Se abre bajo el campo con un buscador y la lista filtrada.
class GestionSearchField<T> extends FormField<T> {
  GestionSearchField({
    required T? value,
    required List<GestionOption<T>> options,
    required ValueChanged<T?> onChanged,
    String hint = 'Buscar…',
    bool required = false,
    bool enabled = true,
    bool loading = false,
    super.key,
  }) : super(
          initialValue: value,
          validator: (T? v) => required && v == null ? 'Campo obligatorio' : null,
          builder: (FormFieldState<T> state) => _SearchFieldBody<T>(
            state: state,
            value: value,
            options: options,
            hint: hint,
            required: required,
            enabled: enabled,
            loading: loading,
            onChanged: onChanged,
          ),
        );
}

class _SearchFieldBody<T> extends StatefulWidget {
  const _SearchFieldBody({
    required this.state,
    required this.value,
    required this.options,
    required this.hint,
    required this.required,
    required this.enabled,
    required this.loading,
    required this.onChanged,
  });

  final FormFieldState<T> state;

  /// Valor que marca el formulario padre (para sincronizar cambios externos)
  final T? value;
  final List<GestionOption<T>> options;
  final String hint;
  final bool required;
  final bool enabled;
  final bool loading;
  final ValueChanged<T?> onChanged;

  @override
  State<_SearchFieldBody<T>> createState() => _SearchFieldBodyState<T>();
}

class _SearchFieldBodyState<T> extends State<_SearchFieldBody<T>> {
  final MenuController _menu = MenuController();
  final TextEditingController _query = TextEditingController();

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  GestionOption<T>? get _selected {
    for (final GestionOption<T> o in widget.options) {
      if (o.value == widget.state.value) {
        return o;
      }
    }
    return null;
  }

  void _select(T? value) {
    widget.state.didChange(value);
    widget.onChanged(value);
    _menu.close();
  }

  void _open() {
    if (!widget.enabled || widget.loading) {
      return;
    }
    _query.clear();
    _menu.isOpen ? _menu.close() : _menu.open();
  }

  @override
  void didUpdateWidget(covariant _SearchFieldBody<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value && widget.value != widget.state.value) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          widget.state.didChange(widget.value);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final GestionOption<T>? sel = _selected;
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints c) => MenuAnchor(
        controller: _menu,
        crossAxisUnconstrained: false,
        style: MenuStyle(
          padding: const WidgetStatePropertyAll<EdgeInsets>(EdgeInsets.zero),
          backgroundColor: const WidgetStatePropertyAll<Color>(Colors.white),
          shape: WidgetStatePropertyAll<OutlinedBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
              side: const BorderSide(color: AppColors.gray300),
            ),
          ),
        ),
        menuChildren: <Widget>[
          _SearchMenu<T>(
            width: c.maxWidth,
            query: _query,
            options: widget.options,
            selected: widget.state.value,
            onSelect: _select,
          ),
        ],
        child: InkWell(
          onTap: _open,
          borderRadius: BorderRadius.circular(6),
          child: InputDecorator(
            isEmpty: sel == null,
            decoration: GestionFormStyle.decoration(
              hint: widget.loading ? 'Cargando…' : widget.hint,
              enabled: widget.enabled,
              suffix: sel != null && !widget.required && widget.enabled
                  ? IconButton(
                      icon: const Icon(Icons.close, size: 15),
                      color: AppColors.gray500,
                      tooltip: 'Quitar',
                      onPressed: () => _select(null),
                    )
                  : const Icon(Icons.unfold_more, size: 17, color: AppColors.gray500),
            ).copyWith(errorText: widget.state.errorText),
            child: Text(
              sel?.label ?? '',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GestionFormStyle.text,
            ),
          ),
        ),
      ),
    );
  }
}

class _SearchMenu<T> extends StatefulWidget {
  const _SearchMenu({
    required this.width,
    required this.query,
    required this.options,
    required this.selected,
    required this.onSelect,
  });

  final double width;
  final TextEditingController query;
  final List<GestionOption<T>> options;
  final T? selected;
  final ValueChanged<T?> onSelect;

  @override
  State<_SearchMenu<T>> createState() => _SearchMenuState<T>();
}

class _SearchMenuState<T> extends State<_SearchMenu<T>> {
  List<GestionOption<T>> get _filtered {
    final String q = widget.query.text.trim().toLowerCase();
    if (q.isEmpty) {
      return widget.options;
    }
    return widget.options.where((GestionOption<T> o) => o.label.toLowerCase().contains(q)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final List<GestionOption<T>> items = _filtered;
    return SizedBox(
      width: widget.width,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(6),
            child: TextField(
              controller: widget.query,
              autofocus: true,
              style: GestionFormStyle.text,
              onChanged: (_) => setState(() {}),
              onSubmitted: (_) {
                if (items.isNotEmpty) {
                  widget.onSelect(items.first.value);
                }
              },
              decoration: GestionFormStyle.decoration(hint: 'Escribe para buscar…').copyWith(
                prefixIcon: const Icon(Icons.search, size: 16, color: AppColors.gray500),
                prefixIconConstraints: const BoxConstraints(minWidth: 30),
              ),
            ),
          ),
          const Divider(height: 1, color: AppColors.gray200),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 260),
            child: items.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(14),
                    child: Text('Sin resultados', style: TextStyle(fontSize: 12.5, color: AppColors.gray500)),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: items.length,
                    itemExtent: 32,
                    itemBuilder: (BuildContext context, int i) => _SearchItem<T>(
                      option: items[i],
                      selected: items[i].value == widget.selected,
                      onTap: () => widget.onSelect(items[i].value),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _SearchItem<T> extends StatelessWidget {
  const _SearchItem({required this.option, required this.selected, required this.onTap});

  final GestionOption<T> option;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.primarySurface : Colors.white,
      child: InkWell(
        onTap: onTap,
        hoverColor: AppColors.gray100,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            children: <Widget>[
              if (option.color != null) ...<Widget>[
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(color: option.color, shape: BoxShape.circle),
                ),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: Text(
                  option.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                    color: AppColors.gray900,
                  ),
                ),
              ),
              if (selected) const Icon(Icons.check, size: 15, color: AppColors.primary),
            ],
          ),
        ),
      ),
    );
  }
}
