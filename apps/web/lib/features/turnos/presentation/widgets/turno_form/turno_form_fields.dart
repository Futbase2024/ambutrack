import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion/form/gestion_form.dart';
import 'package:ambutrack_web/features/turnos/presentation/widgets/turno_form/turno_form_utils.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Campo "cargando…" con el mismo alto que un campo de gestión
class TurnoFormLoadingField extends StatelessWidget {
  const TurnoFormLoadingField({this.text = 'Cargando…', super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: GestionFormStyle.decoration(enabled: false),
      child: Row(
        children: <Widget>[
          const SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
          ),
          const SizedBox(width: 8),
          Text(text, style: GestionFormStyle.hint),
        ],
      ),
    );
  }
}

/// Fecha dd/mm/aaaa de solo visualización que abre el selector al pulsar.
///
/// A diferencia de `GestionDateField`, refleja siempre [value] (la fecha fin
/// se recalcula desde el estado al cruzar medianoche).
class TurnoFormDateField extends StatelessWidget {
  const TurnoFormDateField({required this.value, required this.onTap, super.key});

  final DateTime value;
  final VoidCallback onTap;

  static final DateFormat _fmt = DateFormat('dd/MM/yyyy');

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: InputDecorator(
        decoration: GestionFormStyle.decoration(
          suffix: const Icon(Icons.calendar_today_outlined, size: 16, color: AppColors.gray500),
        ),
        child: Text(_fmt.format(value), style: GestionFormStyle.text),
      ),
    );
  }
}

/// Hora HH:mm editable a mano (admite "8", "830", "1430"…)
class TurnoHoraField extends StatelessWidget {
  const TurnoHoraField({
    required this.controller,
    required this.focusNode,
    required this.onEditingComplete,
    super.key,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onEditingComplete;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      textInputAction: TextInputAction.next,
      style: GestionFormStyle.text,
      decoration: GestionFormStyle.decoration(
        hint: 'HH:mm',
        suffix: const Icon(Icons.schedule, size: 16, color: AppColors.gray500),
      ),
      onEditingComplete: onEditingComplete,
      validator: TurnoFormUtils.validarHora,
    );
  }
}

/// Selector compacto de tipo de turno (Mañana, Tarde, Noche, Personalizado)
class TurnoTipoSelector extends StatelessWidget {
  const TurnoTipoSelector({
    required this.value,
    required this.enabled,
    required this.onSelected,
    super.key,
  });

  final TipoTurno value;

  /// Deshabilitado cuando hay una plantilla seleccionada
  final bool enabled;
  final ValueChanged<TipoTurno> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: TipoTurno.values
              .map(
                (TipoTurno tipo) => _TipoChip(
                  tipo: tipo,
                  selected: value == tipo,
                  enabled: enabled,
                  onTap: () => onSelected(tipo),
                ),
              )
              .toList(),
        ),
        if (!enabled)
          const Padding(
            padding: EdgeInsets.only(top: 4),
            child: Text(
              'Plantilla seleccionada. Los tipos de turno están deshabilitados.',
              style: TextStyle(fontSize: 11.5, color: AppColors.gray500, fontStyle: FontStyle.italic),
            ),
          ),
      ],
    );
  }
}

class _TipoChip extends StatelessWidget {
  const _TipoChip({
    required this.tipo,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  final TipoTurno tipo;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color color = TurnoFormUtils.tipoColor(tipo);
    final Color background = enabled ? (selected ? color : Colors.white) : AppColors.gray100;
    final Color foreground = enabled ? (selected ? Colors.white : color) : AppColors.gray400;
    final Color border = enabled ? color : AppColors.gray300;

    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        height: 34,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: background,
          border: Border.all(color: border),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          tipo.nombre,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            color: foreground,
          ),
        ),
      ),
    );
  }
}
