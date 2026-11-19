import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Celda de texto editable en la propia rejilla (modo edición).
///
/// - Intro o salir del campo: guarda (solo si el valor ha cambiado)
/// - Esc: descarta el cambio y restaura el valor original
class GestionInlineTextCell extends StatefulWidget {
  const GestionInlineTextCell({
    required this.value,
    required this.onSubmitted,
    this.numeric = false,
    this.textAlign = TextAlign.start,
    this.hint,
    super.key,
  });

  /// Valor actual (texto que se muestra al empezar a editar)
  final String value;

  /// Se llama con el texto nuevo (ya recortado) cuando cambia
  final ValueChanged<String> onSubmitted;

  /// Solo admite dígitos
  final bool numeric;
  final TextAlign textAlign;
  final String? hint;

  @override
  State<GestionInlineTextCell> createState() => _GestionInlineTextCellState();
}

class _GestionInlineTextCellState extends State<GestionInlineTextCell> {
  late final TextEditingController _controller = TextEditingController(text: widget.value);
  final FocusNode _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _focus.addListener(_onFocusChange);
  }

  @override
  void didUpdateWidget(GestionInlineTextCell oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Refresca el texto si el dato cambia desde fuera (tiempo real) y no se está editando
    if (oldWidget.value != widget.value && !_focus.hasFocus) {
      _controller.text = widget.value;
    }
  }

  @override
  void dispose() {
    _focus
      ..removeListener(_onFocusChange)
      ..dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (!_focus.hasFocus) {
      _commit();
    }
  }

  void _commit() {
    final String texto = _controller.text.trim();
    if (texto != widget.value.trim()) {
      widget.onSubmitted(texto);
    }
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.escape) {
      _controller.text = widget.value;
      _focus.unfocus();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      onKeyEvent: _onKey,
      skipTraversal: true,
      child: TextField(
        controller: _controller,
        focusNode: _focus,
        textAlign: widget.textAlign,
        textInputAction: TextInputAction.done,
        keyboardType: widget.numeric ? TextInputType.number : TextInputType.text,
        inputFormatters: widget.numeric ? <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly] : null,
        onSubmitted: (_) => _focus.unfocus(),
        style: const TextStyle(fontSize: 13, color: AppColors.gray900),
        decoration: InputDecoration(
          isDense: true,
          filled: true,
          fillColor: Colors.white,
          hintText: widget.hint,
          hintStyle: const TextStyle(fontSize: 13, color: AppColors.gray300),
          contentPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
          enabledBorder: _border(AppColors.gray300),
          focusedBorder: _border(AppColors.primary),
        ),
      ),
    );
  }

  static OutlineInputBorder _border(Color color) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: BorderSide(color: color),
      );
}
