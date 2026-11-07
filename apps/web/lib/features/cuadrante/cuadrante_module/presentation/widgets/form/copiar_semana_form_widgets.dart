import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion/form/gestion_form.dart';
import 'package:ambutrack_web/features/cuadrante/cuadrante_module/domain/entities/personal_con_turnos_entity.dart';
import 'package:flutter/material.dart';

/// Qué trabajadores se copian
enum CopiarSemanaModo { todos, uno, varios }

/// Selector compacto del modo de copia (Todos / Uno / Varios)
class CopiarSemanaModoSelector extends StatelessWidget {
  const CopiarSemanaModoSelector({required this.modo, required this.onChanged, super.key});

  final CopiarSemanaModo modo;
  final ValueChanged<CopiarSemanaModo> onChanged;

  static const Map<CopiarSemanaModo, (String, IconData)> _opciones = <CopiarSemanaModo, (String, IconData)>{
    CopiarSemanaModo.todos: ('Todos', Icons.groups_outlined),
    CopiarSemanaModo.uno: ('Uno', Icons.person_outline),
    CopiarSemanaModo.varios: ('Varios', Icons.people_outline),
  };

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        for (final CopiarSemanaModo m in CopiarSemanaModo.values) ...<Widget>[
          if (m != CopiarSemanaModo.todos) const SizedBox(width: 6),
          Expanded(
            child: _ModoChip(
              label: _opciones[m]!.$1,
              icon: _opciones[m]!.$2,
              selected: m == modo,
              onTap: () => onChanged(m),
            ),
          ),
        ],
      ],
    );
  }
}

class _ModoChip extends StatelessWidget {
  const _ModoChip({required this.label, required this.icon, required this.selected, required this.onTap});

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color fg = selected ? AppColors.primary : AppColors.gray600;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        height: 36,
        decoration: BoxDecoration(
          color: selected ? AppColors.primarySurface : Colors.white,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: selected ? AppColors.primary : AppColors.gray300),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(icon, size: 16, color: fg),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                color: fg,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Lista de casillas para seleccionar varios trabajadores (con validación)
class CopiarSemanaPersonalChecklist extends FormField<Set<String>> {
  CopiarSemanaPersonalChecklist({
    required List<PersonalConTurnosEntity> personal,
    required Set<String> seleccionados,
    required VoidCallback onChanged,
    super.key,
  }) : super(
          initialValue: seleccionados,
          validator: (_) => seleccionados.isEmpty ? 'Selecciona al menos un trabajador' : null,
          builder: (FormFieldState<Set<String>> state) => _ChecklistBody(
            state: state,
            personal: personal,
            seleccionados: seleccionados,
            onChanged: onChanged,
          ),
        );
}

class _ChecklistBody extends StatelessWidget {
  const _ChecklistBody({
    required this.state,
    required this.personal,
    required this.seleccionados,
    required this.onChanged,
  });

  final FormFieldState<Set<String>> state;
  final List<PersonalConTurnosEntity> personal;
  final Set<String> seleccionados;
  final VoidCallback onChanged;

  void _toggle(String id, bool value) {
    if (value) {
      seleccionados.add(id);
    } else {
      seleccionados.remove(id);
    }
    state.didChange(seleccionados);
    onChanged();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          constraints: const BoxConstraints(maxHeight: 200),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: state.hasError ? AppColors.error : AppColors.gray300),
          ),
          child: ListView(
            shrinkWrap: true,
            children: personal
                .map(
                  (PersonalConTurnosEntity p) => GestionCheckField(
                    value: seleccionados.contains(p.personal.id),
                    text: p.personal.nombreCompleto,
                    onChanged: (bool v) => _toggle(p.personal.id, v),
                  ),
                )
                .toList(),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 4, left: 2),
          child: Text(
            state.errorText ?? '${seleccionados.length} seleccionado(s)',
            style: TextStyle(
              fontSize: 11,
              color: state.hasError ? AppColors.error : AppColors.gray500,
            ),
          ),
        ),
      ],
    );
  }
}

/// Aviso compacto: los turnos existentes no se eliminan
class CopiarSemanaAviso extends StatelessWidget {
  const CopiarSemanaAviso({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 4),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
      ),
      child: const Row(
        children: <Widget>[
          Icon(Icons.warning_amber, color: AppColors.warning, size: 16),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Los turnos existentes en la semana destino no se eliminarán.',
              style: TextStyle(fontSize: 12, color: AppColors.gray700),
            ),
          ),
        ],
      ),
    );
  }
}
