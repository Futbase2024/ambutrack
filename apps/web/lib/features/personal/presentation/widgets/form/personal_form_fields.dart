import 'package:ambutrack_web/core/widgets/gestion/form/gestion_form.dart';
import 'package:flutter/material.dart';

/// Selector opcional de tabla maestra (con buscador y botón para quitar el valor,
/// igual que el desplegable "clearable" anterior; robusto si el valor guardado
/// ya no está en la lista)
class PersonalFkField extends StatelessWidget {
  const PersonalFkField({
    required this.value,
    required this.options,
    required this.onChanged,
    this.hint = 'Seleccionar…',
    this.enabled = true,
    super.key,
  });

  final String? value;
  final List<GestionOption<String>> options;
  final ValueChanged<String?> onChanged;
  final String hint;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return GestionSearchField<String>(
      value: value,
      options: options,
      hint: hint,
      enabled: enabled,
      onChanged: onChanged,
    );
  }
}

/// Contraseña oculta con el estilo de los formularios de gestión
class PersonalPasswordField extends StatefulWidget {
  const PersonalPasswordField({required this.controller, super.key});

  final TextEditingController controller;

  @override
  State<PersonalPasswordField> createState() => _PersonalPasswordFieldState();
}

class _PersonalPasswordFieldState extends State<PersonalPasswordField> {
  bool _oculta = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: _oculta,
      textInputAction: TextInputAction.next,
      style: GestionFormStyle.text,
      decoration: GestionFormStyle.decoration(
        hint: '••••••••',
        suffix: IconButton(
          icon: Icon(_oculta ? Icons.visibility_outlined : Icons.visibility_off_outlined, size: 16),
          tooltip: _oculta ? 'Mostrar' : 'Ocultar',
          onPressed: () => setState(() => _oculta = !_oculta),
        ),
      ),
    );
  }
}
