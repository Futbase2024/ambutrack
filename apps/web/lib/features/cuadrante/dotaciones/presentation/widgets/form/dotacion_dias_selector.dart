import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Selector compacto de días de la semana (L M X J V S D) con validación
class DotacionDiasSelector extends FormField<List<bool>> {
  DotacionDiasSelector({
    required List<bool> dias,
    required VoidCallback onChanged,
    super.key,
  }) : super(
          initialValue: dias,
          validator: (_) => dias.any((bool d) => d) ? null : 'Selecciona al menos un día de aplicación',
          builder: (FormFieldState<List<bool>> state) => _DiasBody(state: state, dias: dias, onChanged: onChanged),
        );
}

class _DiasBody extends StatelessWidget {
  const _DiasBody({required this.state, required this.dias, required this.onChanged});

  final FormFieldState<List<bool>> state;
  final List<bool> dias;
  final VoidCallback onChanged;

  static const List<String> _letras = <String>['L', 'M', 'X', 'J', 'V', 'S', 'D'];

  void _toggle(int i) {
    dias[i] = !dias[i];
    state.didChange(dias);
    onChanged();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(
          height: 36,
          child: Row(
            children: <Widget>[
              for (int i = 0; i < _letras.length; i++) ...<Widget>[
                if (i > 0) const SizedBox(width: 6),
                _DiaBox(letra: _letras[i], selected: dias[i], onTap: () => _toggle(i)),
              ],
            ],
          ),
        ),
        if (state.hasError)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 2),
            child: Text(state.errorText!, style: const TextStyle(fontSize: 11, color: AppColors.error)),
          ),
      ],
    );
  }
}

class _DiaBox extends StatelessWidget {
  const _DiaBox({required this.letra, required this.selected, required this.onTap});

  final String letra;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        width: 34,
        height: 34,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: selected ? AppColors.primary : AppColors.gray300),
        ),
        child: Text(
          letra,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : AppColors.gray700,
          ),
        ),
      ),
    );
  }
}
