import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';

/// Chips para elegir el tipo de turno (plantilla) en el caso C
class SelectorPlantillaTurno extends StatelessWidget {
  const SelectorPlantillaTurno({
    required this.plantillas,
    required this.seleccionada,
    required this.onSeleccionar,
    super.key,
  });

  final List<PlantillaTurnoEntity> plantillas;
  final PlantillaTurnoEntity? seleccionada;
  final ValueChanged<PlantillaTurnoEntity> onSeleccionar;

  @override
  Widget build(BuildContext context) {
    if (plantillas.isEmpty) {
      return const Text(
        'No hay tipos de turno configurados. Contacta con coordinación.',
        style: TextStyle(fontSize: 13, color: AppColors.error),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: plantillas.map((PlantillaTurnoEntity p) {
        final bool activa = p.id == seleccionada?.id;
        return ChoiceChip(
          selected: activa,
          onSelected: (_) => onSeleccionar(p),
          showCheckmark: false,
          selectedColor: AppColors.primary,
          backgroundColor: Colors.white,
          side: BorderSide(color: activa ? AppColors.primary : AppColors.gray300),
          label: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                p.nombre.replaceFirst('Turno ', ''),
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: activa ? Colors.white : AppColors.gray900,
                ),
              ),
              Text(
                '${p.horaInicio} - ${p.horaFin}',
                style: TextStyle(fontSize: 11, color: activa ? Colors.white : AppColors.gray600),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
