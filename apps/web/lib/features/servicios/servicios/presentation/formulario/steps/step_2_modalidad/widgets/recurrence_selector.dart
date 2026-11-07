import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion/form/gestion_form.dart';
import 'package:ambutrack_web/features/servicios/domain/entities/configuracion_modalidad.dart';
import 'package:flutter/material.dart';

/// Selector de tipo de recurrencia para servicios
/// Muestra 6 opciones en grid: Único, Diario, Semanal, Días Alternos, Fechas Específicas, Mensual
class RecurrenceSelector extends StatelessWidget {
  const RecurrenceSelector({
    required this.tipoSeleccionado,
    required this.onTipoChanged,
    super.key,
  });

  final TipoRecurrencia? tipoSeleccionado;
  final void Function(TipoRecurrencia) onTipoChanged;

  static const List<(TipoRecurrencia, IconData)> _opciones = <(TipoRecurrencia, IconData)>[
    (TipoRecurrencia.unico, Icons.calendar_today),
    (TipoRecurrencia.diario, Icons.calendar_view_day),
    (TipoRecurrencia.semanal, Icons.calendar_view_week),
    (TipoRecurrencia.diasAlternos, Icons.repeat),
    (TipoRecurrencia.fechasEspecificas, Icons.event_note),
    (TipoRecurrencia.mensual, Icons.calendar_month),
  ];

  @override
  Widget build(BuildContext context) {
    return GestionFormRow(
      label: 'Recurrencia',
      required: true,
      child: Wrap(
        spacing: 6,
        runSpacing: 6,
        children: <Widget>[
          for (final (TipoRecurrencia tipo, IconData icon) in _opciones)
            _RecurrenceCard(
              tipo: tipo,
              icon: icon,
              isSelected: tipoSeleccionado == tipo,
              onTap: () => onTipoChanged(tipo),
            ),
        ],
      ),
    );
  }
}

/// Opción compacta (alto de campo) para un tipo de recurrencia
class _RecurrenceCard extends StatelessWidget {
  const _RecurrenceCard({
    required this.tipo,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final TipoRecurrencia tipo;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tipo.description,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary.withValues(alpha: 0.08) : Colors.white,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.gray300,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(icon, size: 16, color: isSelected ? AppColors.primary : AppColors.gray500),
              const SizedBox(width: 6),
              Text(
                tipo.displayName,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? AppColors.primary : AppColors.gray800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
