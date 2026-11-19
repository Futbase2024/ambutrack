import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion/form/gestion_form.dart';
import 'package:ambutrack_web/features/personal/domain/entities/personal_entity.dart';
import 'package:flutter/material.dart';

/// Lista compacta de personal con casillas y "Seleccionar todos"
class GeneracionPersonalSelector extends StatelessWidget {
  const GeneracionPersonalSelector({
    required this.personal,
    required this.seleccionados,
    required this.onTodos,
    required this.onPersona,
    super.key,
  });

  final List<PersonalEntity> personal;
  final List<String> seleccionados;
  final ValueChanged<bool> onTodos;
  final void Function(String id, {required bool seleccionar}) onPersona;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.gray300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: const BoxDecoration(
              color: AppColors.gray50,
              border: Border(bottom: BorderSide(color: AppColors.gray200)),
            ),
            child: GestionCheckField(
              value: seleccionados.length == personal.length,
              text: 'Seleccionar todos (${seleccionados.length}/${personal.length})',
              onChanged: onTodos,
            ),
          ),
          SizedBox(
            height: 200,
            child: personal.isEmpty
                ? const Center(
                    child: Text(
                      'No hay personal activo',
                      style: TextStyle(fontSize: 12.5, color: AppColors.gray500),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                    itemCount: personal.length,
                    itemBuilder: (BuildContext context, int index) {
                      final PersonalEntity p = personal[index];
                      return _PersonaFila(
                        persona: p,
                        seleccionado: seleccionados.contains(p.id),
                        onChanged: (bool value) => onPersona(p.id, seleccionar: value),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _PersonaFila extends StatelessWidget {
  const _PersonaFila({required this.persona, required this.seleccionado, required this.onChanged});

  final PersonalEntity persona;
  final bool seleccionado;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: GestionCheckField(
            value: seleccionado,
            text: '${persona.nombre} ${persona.apellidos}',
            onChanged: onChanged,
          ),
        ),
        Text(
          persona.categoria ?? 'Sin categoría',
          style: const TextStyle(fontSize: 11.5, color: AppColors.gray500),
        ),
      ],
    );
  }
}

/// Deslizador compacto con el valor actual a la derecha
class GeneracionSliderField extends StatelessWidget {
  const GeneracionSliderField({
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    super.key,
  });

  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: Row(
        children: <Widget>[
          Expanded(
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 3,
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
              ),
              child: Slider(
                value: value,
                min: min,
                max: max,
                divisions: ((max - min) / (max > 50 ? 5 : 1)).toInt(),
                onChanged: onChanged,
                activeColor: AppColors.primary,
                inactiveColor: AppColors.gray200,
              ),
            ),
          ),
          Container(
            width: 48,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.gray50,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppColors.gray200),
            ),
            child: Text(
              value.toStringAsFixed(value % 1 == 0 ? 0 : 1),
              style: GestionFormStyle.text.copyWith(fontWeight: FontWeight.w600, color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}
