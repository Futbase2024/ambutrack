import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion/form/gestion_form.dart';
import 'package:flutter/material.dart';

/// Acción extra en el sufijo del campo de contraseña (copiar, generar…)
class PasswordFieldAction {
  const PasswordFieldAction({required this.icon, required this.tooltip, required this.onPressed});

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;
}

/// Campo de contraseña compacto con estilo de gestión y botón mostrar/ocultar.
///
/// Si [visible] no es null, la visibilidad se controla desde fuera
/// (p.ej. para mostrar una contraseña recién generada).
class PasswordFormField extends StatefulWidget {
  const PasswordFormField({
    required this.controller,
    this.hint,
    this.validator,
    this.readOnly = false,
    this.visible,
    this.onVisibleChanged,
    this.actions = const <PasswordFieldAction>[],
    super.key,
  });

  final TextEditingController controller;
  final String? hint;
  final FormFieldValidator<String>? validator;
  final bool readOnly;
  final bool? visible;
  final ValueChanged<bool>? onVisibleChanged;
  final List<PasswordFieldAction> actions;

  @override
  State<PasswordFormField> createState() => _PasswordFormFieldState();
}

class _PasswordFormFieldState extends State<PasswordFormField> {
  bool _visible = false;

  bool get _isVisible => widget.visible ?? _visible;

  void _toggle() {
    final bool next = !_isVisible;
    if (widget.onVisibleChanged != null) {
      widget.onVisibleChanged!(next);
    }
    if (widget.visible == null) {
      setState(() => _visible = next);
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: !_isVisible,
      readOnly: widget.readOnly,
      textInputAction: TextInputAction.next,
      style: GestionFormStyle.text,
      validator: widget.validator,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: GestionFormStyle.decoration(
        hint: widget.hint,
        enabled: !widget.readOnly,
        suffix: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            _SuffixButton(
              icon: _isVisible ? Icons.visibility_off_outlined : Icons.visibility_outlined,
              tooltip: _isVisible ? 'Ocultar contraseña' : 'Mostrar contraseña',
              onPressed: _toggle,
            ),
            for (final PasswordFieldAction a in widget.actions)
              _SuffixButton(icon: a.icon, tooltip: a.tooltip, onPressed: a.onPressed),
          ],
        ),
      ),
    );
  }
}

class _SuffixButton extends StatelessWidget {
  const _SuffixButton({required this.icon, required this.tooltip, required this.onPressed});

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon, size: 16),
      color: AppColors.gray600,
      tooltip: tooltip,
      visualDensity: VisualDensity.compact,
      onPressed: onPressed,
    );
  }
}

/// Nota informativa compacta dentro de un formulario de gestión
class GestionFormNote extends StatelessWidget {
  const GestionFormNote({required this.text, this.icon = Icons.info_outline, this.color = AppColors.info, super.key});

  final String text;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, style: const TextStyle(fontSize: 12, color: AppColors.gray700, height: 1.35)),
          ),
        ],
      ),
    );
  }
}
