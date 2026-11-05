import 'package:ambutrack_web/core/widgets/gestion/form/gestion_form.dart';
import 'package:flutter/material.dart';

/// Widget campo de observaciones
class ObservacionesFieldWidget extends StatelessWidget {
  const ObservacionesFieldWidget({
    super.key,
    required this.label,
    required this.hint,
    required this.value,
    required this.onChanged,
    this.maxLines = 1,
  });

  final String label;
  final String hint;
  final String? value;
  final ValueChanged<String?> onChanged;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return GestionFormRow(
      label: label,
      multiline: maxLines > 1,
      child: TextFormField(
        initialValue: value,
        maxLines: maxLines,
        minLines: maxLines > 1 ? maxLines : null,
        keyboardType: maxLines > 1 ? TextInputType.multiline : null,
        textInputAction: maxLines > 1 ? TextInputAction.newline : TextInputAction.next,
        style: GestionFormStyle.text,
        decoration: GestionFormStyle.decoration(hint: hint),
        onChanged: onChanged,
      ),
    );
  }
}
