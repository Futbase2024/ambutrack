import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion_frame/gestion_frame.dart';
import 'package:ambutrack_web/features/trafico_diario/presentation/bloc/trafico_diario_bloc.dart';
import 'package:ambutrack_web/features/trafico_diario/presentation/bloc/trafico_diario_event.dart';
import 'package:ambutrack_web/features/trafico_diario/presentation/widgets/generate_traslados_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

/// Barra de herramientas compacta de la planificación de servicios
///
/// Incluye:
/// - Generar traslados (14 días) con confirmación
/// - Mostrar/ocultar vista de 14 días
/// - Ir a HOY
/// - Navegación de día (anterior/siguiente) y DatePicker al pulsar la fecha
class ServiciosHeader extends StatelessWidget {
  const ServiciosHeader({
    required this.selectedDay,
    required this.onDayChanged,
    this.show14DaysView = false,
    this.onToggle14DaysView,
    super.key,
  });

  final DateTime selectedDay;
  final ValueChanged<DateTime> onDayChanged;
  final bool show14DaysView;
  final VoidCallback? onToggle14DaysView;

  @override
  Widget build(BuildContext context) {
    final bool isGenerating = context.select<TraficoDiarioBloc, bool>(
      (TraficoDiarioBloc bloc) => bloc.state.maybeWhen(
        loaded: (
          List<TrasladoEntity> traslados,
          String searchQuery,
          String? estadoFilter,
          String? centroFilter,
          bool isRefreshing,
          bool isGenerating,
          DateTime? trasladosGeneradosHasta,
        ) =>
            isGenerating,
        orElse: () => false,
      ),
    );

    return GestionToolbar(
      title: 'Asignación de Servicios',
      icon: Icons.calendar_month,
      groups: <List<GestionToolbarAction>>[
        <GestionToolbarAction>[
          GestionToolbarAction(
            icon: Icons.event_repeat_rounded,
            label: isGenerating ? 'Generando...' : 'Generar traslados (14 días)',
            primary: true,
            onPressed: isGenerating ? null : () => _generar(context),
          ),
        ],
        <GestionToolbarAction>[
          if (onToggle14DaysView != null)
            GestionToolbarAction(
              icon: show14DaysView ? Icons.calendar_view_month : Icons.calendar_view_week,
              label: show14DaysView ? 'Ocultar 14 días' : 'Ver 14 días',
              onPressed: onToggle14DaysView,
            ),
          GestionToolbarAction(
            icon: Icons.today,
            label: 'Hoy',
            onPressed: () => onDayChanged(DateTime.now()),
          ),
        ],
      ],
      trailing: GestionPeriodNavigator(
        label: DateFormat('EEEE, dd MMMM yyyy', 'es_ES').format(selectedDay),
        previousTooltip: 'Día anterior',
        nextTooltip: 'Día siguiente',
        onPrevious: () => onDayChanged(selectedDay.subtract(const Duration(days: 1))),
        onNext: () => onDayChanged(selectedDay.add(const Duration(days: 1))),
        onLabelTap: () => _mostrarSelectorFecha(context),
      ),
    );
  }

  Future<void> _generar(BuildContext context) async {
    final bool confirmado = await confirmarGeneracionTraslados(context);
    if (confirmado && context.mounted) {
      context.read<TraficoDiarioBloc>().add(
            const TraficoDiarioEvent.generarTrasladosRequested(),
          );
    }
  }

  /// Muestra un diálogo DatePicker para seleccionar fecha
  Future<void> _mostrarSelectorFecha(BuildContext context) async {
    final DateTime? fecha = await showDatePicker(
      context: context,
      initialDate: selectedDay,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      locale: const Locale('es', 'ES'),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onSurface: AppColors.textPrimaryLight,
            ),
          ),
          child: child!,
        );
      },
    );

    if (fecha != null) {
      onDayChanged(fecha);
    }
  }
}

/// Barra de estado de la planificación: traslados del día y estado de la
/// generación (sustituye al banner `TrasladosGenerationIndicator`)
class PlanificarServiciosStatusBar extends StatelessWidget {
  const PlanificarServiciosStatusBar({
    required this.trasladosDelDia,
    required this.seleccionados,
    this.trasladosGeneradosHasta,
    super.key,
  });

  final int trasladosDelDia;
  final int seleccionados;
  final DateTime? trasladosGeneradosHasta;

  @override
  Widget build(BuildContext context) {
    return GestionStatusBar(
      items: <String>[
        'Traslados del día: $trasladosDelDia',
        if (seleccionados > 0) 'Seleccionados: $seleccionados',
        if (trasladosGeneradosHasta != null) _estadoGeneracion(trasladosGeneradosHasta!),
      ],
    );
  }

  String _estadoGeneracion(DateTime hasta) {
    final int dias = hasta.difference(DateTime.now()).inDays;
    final String fecha = DateFormat('dd/MM/yyyy').format(hasta);
    if (dias < 3) {
      return '⚠ Traslados desactualizados: generados hasta el $fecha '
          '(quedan ${dias < 0 ? 0 : dias} días, se recomienda regenerar)';
    }
    return 'Traslados generados hasta el $fecha ($dias días restantes)';
  }
}
