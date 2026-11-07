import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion/form/gestion_form_style.dart';
import 'package:flutter/material.dart';

/// Interruptor Sí/No con texto descriptivo, alto de campo estándar
class GestionSwitchField extends StatelessWidget {
  const GestionSwitchField({
    required this.value,
    required this.onChanged,
    this.text,
    this.enabled = true,
    super.key,
  });

  final bool value;
  final ValueChanged<bool> onChanged;

  /// Texto a la derecha (p.ej. "Activo"); si es null muestra Sí/No
  final String? text;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: Row(
        children: <Widget>[
          Transform.scale(
            scale: 0.8,
            alignment: Alignment.centerLeft,
            child: Switch(
              value: value,
              onChanged: enabled ? onChanged : null,
              activeThumbColor: Colors.white,
              activeTrackColor: AppColors.success,
            ),
          ),
          const SizedBox(width: 2),
          Flexible(
            child: Text(
              text ?? (value ? 'Sí' : 'No'),
              style: TextStyle(
                fontSize: 13,
                color: enabled ? AppColors.gray800 : AppColors.gray400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Casilla de verificación con texto, alto de campo estándar
class GestionCheckField extends StatelessWidget {
  const GestionCheckField({
    required this.value,
    required this.onChanged,
    required this.text,
    this.enabled = true,
    super.key,
  });

  final bool value;
  final ValueChanged<bool> onChanged;
  final String text;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? () => onChanged(!value) : null,
      borderRadius: BorderRadius.circular(4),
      child: SizedBox(
        height: 36,
        child: Row(
          children: <Widget>[
            SizedBox(
              width: 22,
              child: Checkbox(
                value: value,
                onChanged: enabled ? (bool? v) => onChanged(v ?? false) : null,
                visualDensity: VisualDensity.compact,
                activeColor: AppColors.primary,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
            const SizedBox(width: 8),
            Flexible(child: Text(text, style: const TextStyle(fontSize: 13, color: AppColors.gray800))),
          ],
        ),
      ),
    );
  }
}

/// Hora HH:mm con selector
class GestionTimeField extends FormField<TimeOfDay> {
  GestionTimeField({
    required TimeOfDay? value,
    required ValueChanged<TimeOfDay?> onChanged,
    bool required = false,
    super.key,
  }) : super(
          initialValue: value,
          validator: (TimeOfDay? v) => required && v == null ? 'Campo obligatorio' : null,
          builder: (FormFieldState<TimeOfDay> state) => _TimeBody(
            state: state,
            required: required,
            onChanged: onChanged,
          ),
        );
}

class _TimeBody extends StatelessWidget {
  const _TimeBody({required this.state, required this.required, required this.onChanged});

  final FormFieldState<TimeOfDay> state;
  final bool required;
  final ValueChanged<TimeOfDay?> onChanged;

  static String _fmt(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  Future<void> _pick(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: state.value ?? TimeOfDay.now(),
      builder: (BuildContext ctx, Widget? child) => MediaQuery(
        data: MediaQuery.of(ctx).copyWith(alwaysUse24HourFormat: true),
        child: child!,
      ),
    );
    if (picked != null) {
      state.didChange(picked);
      onChanged(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final TimeOfDay? v = state.value;
    return InkWell(
      onTap: () => _pick(context),
      borderRadius: BorderRadius.circular(6),
      child: InputDecorator(
        isEmpty: v == null,
        decoration: GestionFormStyle.decoration(
          hint: 'hh:mm',
          suffix: v != null && !required
              ? IconButton(
                  icon: const Icon(Icons.close, size: 15),
                  color: AppColors.gray500,
                  tooltip: 'Quitar hora',
                  onPressed: () {
                    state.didChange(null);
                    onChanged(null);
                  },
                )
              : const Icon(Icons.schedule, size: 16, color: AppColors.gray500),
        ).copyWith(errorText: state.errorText),
        child: Text(v == null ? '' : _fmt(v), style: GestionFormStyle.text),
      ),
    );
  }
}
