import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/turnos/presentation/widgets/gestion/plantilla_gestion_columns.dart';
import 'package:flutter/material.dart';

/// Ficha lateral de la plantilla de turno seleccionada
class PlantillaDetailPanel extends StatelessWidget {
  const PlantillaDetailPanel({
    required this.plantilla,
    required this.onEdit,
    required this.onDelete,
    super.key,
  });

  final PlantillaTurnoEntity? plantilla;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final PlantillaTurnoEntity? p = plantilla;
    if (p == null) {
      return const GestionDetailEmpty(message: 'Selecciona una plantilla para ver su ficha');
    }
    return GestionDetailPanel(
      key: ValueKey<String>(p.id),
      title: p.nombre,
      badges: <Widget>[
        GestionDotLabel(label: p.tipoTurno.nombre, color: plantillaHexColor(p.tipoTurno.colorHex)),
        PlantillaEstadoDot(activo: p.activo),
      ],
      tabs: <GestionDetailTab>[
        GestionDetailTab(label: 'General', child: _PlantillaGeneralTab(plantilla: p)),
      ],
      actions: <Widget>[
        OutlinedButton.icon(
          onPressed: onEdit,
          icon: const Icon(Icons.edit_outlined, size: 16),
          label: const Text('Editar'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            minimumSize: const Size(0, 34),
            textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ),
        OutlinedButton.icon(
          onPressed: onDelete,
          icon: const Icon(Icons.delete_outline, size: 16),
          label: const Text('Eliminar'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.error,
            side: BorderSide(color: AppColors.error.withValues(alpha: 0.4)),
            minimumSize: const Size(0, 34),
            textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}

class _PlantillaGeneralTab extends StatelessWidget {
  const _PlantillaGeneralTab({required this.plantilla});

  final PlantillaTurnoEntity plantilla;

  @override
  Widget build(BuildContext context) {
    final PlantillaTurnoEntity p = plantilla;
    final bool colorPropio = p.color?.trim().isNotEmpty ?? false;
    return GestionDetailBody(
      children: <Widget>[
        const GestionDetailSection(title: 'Plantilla'),
        GestionDetailField(label: 'Nombre', value: p.nombre),
        GestionDetailField(label: 'Descripción', value: p.descripcion),
        GestionDetailField(label: 'Estado', child: PlantillaEstadoDot(activo: p.activo)),
        const GestionDetailSection(title: 'Horario'),
        GestionDetailField(label: 'Tipo de turno', value: p.tipoTurno.nombre),
        GestionDetailField(label: 'Hora inicio', value: p.horaInicio),
        GestionDetailField(label: 'Hora fin', value: p.horaFin),
        GestionDetailField(label: 'Duración', value: plantillaDuracion(p)),
        const GestionDetailSection(title: 'Visualización'),
        GestionDetailField(
          label: 'Color',
          child: Align(
            alignment: Alignment.centerLeft,
            child: PlantillaColorSwatch(hex: p.getColorHex()),
          ),
        ),
        GestionDetailField(label: 'Origen color', value: colorPropio ? 'Personalizado' : 'Del tipo de turno'),
        const GestionDetailSection(title: 'Observaciones'),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Text(
            GestionFormatters.texto(p.observaciones),
            style: TextStyle(
              fontSize: 12.5,
              height: 1.4,
              color: p.observaciones?.trim().isNotEmpty ?? false ? AppColors.gray800 : AppColors.gray300,
            ),
          ),
        ),
      ],
    );
  }
}
