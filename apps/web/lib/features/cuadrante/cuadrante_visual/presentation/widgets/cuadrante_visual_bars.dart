import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion_frame/gestion_frame.dart';
import 'package:ambutrack_web/features/cuadrante/cuadrante_visual/domain/entities/cuadrante_slot_entity.dart';
import 'package:ambutrack_web/features/cuadrante/cuadrante_visual/presentation/bloc/cuadrante_visual_bloc.dart';
import 'package:ambutrack_web/features/cuadrante/cuadrante_visual/presentation/bloc/cuadrante_visual_event.dart';
import 'package:ambutrack_web/features/cuadrante/cuadrante_visual/presentation/bloc/cuadrante_visual_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Barra de herramientas del cuadrante visual: fecha, guardar y limpiar
class CuadranteVisualToolbar extends StatelessWidget {
  const CuadranteVisualToolbar({
    required this.state,
    required this.selectedDate,
    required this.onDatePicked,
    super.key,
  });

  final CuadranteVisualLoaded state;
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDatePicked;

  @override
  Widget build(BuildContext context) {
    return GestionToolbar(
      title: 'Cuadrante Visual',
      icon: Icons.dashboard_customize_outlined,
      groups: <List<GestionToolbarAction>>[
        <GestionToolbarAction>[
          GestionToolbarAction(
            icon: Icons.calendar_today,
            label: '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
            tooltip: 'Cambiar fecha',
            onPressed: () => _pickDate(context),
          ),
        ],
        <GestionToolbarAction>[
          GestionToolbarAction(
            icon: Icons.save,
            label: 'Guardar',
            primary: true,
            onPressed: state.hasUnsavedChanges
                ? () => context.read<CuadranteVisualBloc>().add(const CuadranteSaveRequested())
                : null,
          ),
          GestionToolbarAction(
            icon: Icons.clear_all,
            label: 'Limpiar',
            destructive: true,
            onPressed: () => context.read<CuadranteVisualBloc>().add(const CuadranteClearRequested()),
          ),
        ],
      ],
      trailing: state.hasUnsavedChanges
          ? const GestionToolbarBadge(
              label: 'Cambios sin guardar',
              icon: Icons.warning_outlined,
              color: AppColors.warning,
            )
          : null,
    );
  }

  Future<void> _pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != selectedDate && context.mounted) {
      onDatePicked(picked);
    }
  }
}

/// Barra de estado con el resumen del cuadrante visual
class CuadranteVisualStatusBar extends StatelessWidget {
  const CuadranteVisualStatusBar({required this.state, super.key});

  final CuadranteVisualLoaded state;

  @override
  Widget build(BuildContext context) {
    final int completos = state.slots.where((CuadranteSlotEntity s) => s.estaCompleto).length;
    final int parciales = state.slots.where((CuadranteSlotEntity s) => s.estaParcial).length;
    return GestionStatusBar(
      items: <String>[
        'Dotaciones: ${state.dotaciones.length}',
        'Unidades: ${state.slots.length}',
        'Completas: $completos',
        'Parciales: $parciales',
        'Personal activo: ${state.personalList.length}',
        'Vehículos activos: ${state.vehiculosList.length}',
      ],
    );
  }
}
