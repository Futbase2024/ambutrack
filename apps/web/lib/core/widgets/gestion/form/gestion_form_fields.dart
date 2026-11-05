import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion/form/gestion_form_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

/// Campo de texto compacto (una o varias líneas)
class GestionTextField extends StatelessWidget {
  const GestionTextField({
    required this.controller,
    this.hint,
    this.validator,
    this.maxLines = 1,
    this.maxLength,
    this.keyboardType,
    this.inputFormatters,
    this.enabled = true,
    this.suffixText,
    this.textAlign = TextAlign.start,
    this.onChanged,
    super.key,
  });

  final TextEditingController controller;
  final String? hint;
  final FormFieldValidator<String>? validator;
  final int maxLines;
  final int? maxLength;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final bool enabled;
  final String? suffixText;
  final TextAlign textAlign;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      maxLines: maxLines,
      minLines: maxLines > 1 ? maxLines : null,
      maxLength: maxLength,
      keyboardType: maxLines > 1 ? TextInputType.multiline : keyboardType,
      textInputAction: maxLines > 1 ? TextInputAction.newline : TextInputAction.next,
      inputFormatters: inputFormatters,
      textAlign: textAlign,
      style: GestionFormStyle.text,
      validator: validator,
      onChanged: onChanged,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: GestionFormStyle.decoration(hint: hint, suffixText: suffixText, enabled: enabled)
          .copyWith(counterText: ''),
    );
  }
}

/// Número entero (p.ej. kilometraje) alineado a la derecha con unidad opcional
class GestionIntField extends StatelessWidget {
  const GestionIntField({
    required this.controller,
    this.unit,
    this.required = false,
    this.enabled = true,
    super.key,
  });

  final TextEditingController controller;
  final String? unit;
  final bool required;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return GestionTextField(
      controller: controller,
      enabled: enabled,
      hint: '0',
      suffixText: unit,
      textAlign: TextAlign.end,
      keyboardType: TextInputType.number,
      inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
      validator: required ? GestionFormStyle.requerido : null,
    );
  }
}

/// Importe en euros con formato español ("1.234,50 €")
class GestionMoneyField extends StatelessWidget {
  const GestionMoneyField({
    required this.controller,
    this.required = false,
    this.enabled = true,
    super.key,
  });

  final TextEditingController controller;
  final bool required;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return GestionTextField(
      controller: controller,
      enabled: enabled,
      hint: '0,00',
      suffixText: '€',
      textAlign: TextAlign.end,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.allow(RegExp(r'[\d.,]'))],
      validator: (String? v) {
        if (v == null || v.trim().isEmpty) {
          return required ? 'Campo obligatorio' : null;
        }
        return GestionFormParse.decimal(v) == null ? 'Importe no válido' : null;
      },
    );
  }
}

/// Fecha dd/mm/aaaa con selector de calendario
class GestionDateField extends FormField<DateTime> {
  GestionDateField({
    required DateTime? value,
    required ValueChanged<DateTime?> onChanged,
    bool required = false,
    DateTime? firstDate,
    DateTime? lastDate,
    super.key,
  }) : super(
          initialValue: value,
          validator: (DateTime? v) => required && v == null ? 'Campo obligatorio' : null,
          builder: (FormFieldState<DateTime> state) {
            return _DateFieldBody(
              state: state,
              required: required,
              firstDate: firstDate ?? DateTime(2000),
              lastDate: lastDate ?? DateTime(2100),
              onChanged: onChanged,
            );
          },
        );
}

class _DateFieldBody extends StatelessWidget {
  const _DateFieldBody({
    required this.state,
    required this.required,
    required this.firstDate,
    required this.lastDate,
    required this.onChanged,
  });

  final FormFieldState<DateTime> state;
  final bool required;
  final DateTime firstDate;
  final DateTime lastDate;
  final ValueChanged<DateTime?> onChanged;

  static final DateFormat _fmt = DateFormat('dd/MM/yyyy');

  Future<void> _pick(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: state.value ?? DateTime.now(),
      firstDate: firstDate,
      lastDate: lastDate,
    );
    if (picked != null) {
      state.didChange(picked);
      onChanged(picked);
    }
  }

  void _clear() {
    state.didChange(null);
    onChanged(null);
  }

  @override
  Widget build(BuildContext context) {
    final DateTime? v = state.value;
    return InkWell(
      onTap: () => _pick(context),
      borderRadius: BorderRadius.circular(6),
      child: InputDecorator(
        isEmpty: v == null,
        decoration: GestionFormStyle.decoration(
          hint: 'dd/mm/aaaa',
          suffix: v != null && !required
              ? IconButton(
                  icon: const Icon(Icons.close, size: 15),
                  color: AppColors.gray500,
                  tooltip: 'Quitar fecha',
                  onPressed: _clear,
                )
              : const Icon(Icons.calendar_today_outlined, size: 16, color: AppColors.gray500),
        ).copyWith(errorText: state.errorText),
        child: Text(v == null ? '' : _fmt.format(v), style: GestionFormStyle.text),
      ),
    );
  }
}

/// Opción de desplegable con punto de color opcional
class GestionOption<T> {
  const GestionOption(this.value, this.label, {this.color});

  final T value;
  final String label;
  final Color? color;
}

/// Desplegable compacto para listas cortas (≤ 10 opciones)
class GestionDropdownField<T> extends StatelessWidget {
  const GestionDropdownField({
    required this.value,
    required this.options,
    required this.onChanged,
    this.hint = 'Seleccionar…',
    this.required = false,
    this.enabled = true,
    super.key,
  });

  final T? value;
  final List<GestionOption<T>> options;
  final ValueChanged<T?> onChanged;
  final String hint;
  final bool required;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      isExpanded: true,
      focusColor: Colors.transparent,
      icon: const Icon(Icons.expand_more, size: 18, color: AppColors.gray500),
      style: GestionFormStyle.text,
      decoration: GestionFormStyle.decoration(hint: hint, enabled: enabled),
      validator: (T? v) => required && v == null ? 'Campo obligatorio' : null,
      onChanged: enabled ? onChanged : null,
      items: options
          .map(
            (GestionOption<T> o) => DropdownMenuItem<T>(
              value: o.value,
              child: _OptionLabel<T>(option: o),
            ),
          )
          .toList(),
    );
  }
}

class _OptionLabel<T> extends StatelessWidget {
  const _OptionLabel({required this.option});

  final GestionOption<T> option;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        if (option.color != null) ...<Widget>[
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: option.color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
        ],
        Flexible(
          child: Text(option.label, maxLines: 1, overflow: TextOverflow.ellipsis, style: GestionFormStyle.text),
        ),
      ],
    );
  }
}
