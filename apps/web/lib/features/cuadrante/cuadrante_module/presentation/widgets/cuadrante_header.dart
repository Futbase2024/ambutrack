import 'package:ambutrack_web/core/widgets/gestion_frame/gestion_frame.dart';
import 'package:ambutrack_web/features/cuadrante/cuadrante_module/domain/entities/cuadrante_view_mode.dart';
import 'package:ambutrack_web/features/cuadrante/cuadrante_module/presentation/bloc/cuadrante_bloc.dart';
import 'package:ambutrack_web/features/cuadrante/cuadrante_module/presentation/bloc/cuadrante_event.dart';
import 'package:ambutrack_web/features/cuadrante/cuadrante_module/presentation/bloc/cuadrante_state.dart';
import 'package:ambutrack_web/features/cuadrante/cuadrante_module/presentation/widgets/copiar_semana_dialog.dart';
import 'package:ambutrack_web/features/turnos/presentation/widgets/generacion_automatica_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

/// Barra de herramientas compacta del cuadrante:
/// acciones (Auto, Copiar, Refrescar) + selector de vista + navegación semanal
class CuadranteHeader extends StatelessWidget {
  const CuadranteHeader({required this.state, super.key});

  final CuadranteLoaded state;

  @override
  Widget build(BuildContext context) {
    return GestionToolbar(
      title: 'Cuadrante',
      icon: Icons.calendar_view_week,
      groups: <List<GestionToolbarAction>>[
        <GestionToolbarAction>[
          GestionToolbarAction(
            icon: Icons.auto_awesome,
            label: 'Auto',
            tooltip: 'Generación automática del cuadrante',
            primary: true,
            onPressed: () => _mostrarDialogoGeneracionAutomatica(context),
          ),
          GestionToolbarAction(
            icon: Icons.content_copy,
            label: 'Copiar semana',
            onPressed: () => _mostrarDialogoCopiarSemana(context),
          ),
        ],
        <GestionToolbarAction>[
          GestionToolbarAction(
            icon: Icons.refresh,
            label: 'Refrescar',
            onPressed: () => context.read<CuadranteBloc>().add(const CuadranteRefreshRequested()),
          ),
        ],
      ],
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          GestionSegmentedSelector<CuadranteViewMode>(
            selected: state.viewMode,
            options: <GestionSegmentOption<CuadranteViewMode>>[
              for (final CuadranteViewMode mode in CuadranteViewMode.values)
                GestionSegmentOption<CuadranteViewMode>(value: mode, label: mode.displayText),
            ],
            onChanged: (CuadranteViewMode mode) =>
                context.read<CuadranteBloc>().add(CuadranteViewModeChanged(mode)),
          ),
          const SizedBox(width: 10),
          GestionPeriodNavigator(
            label: cuadranteSemanaTexto(state),
            previousTooltip: 'Semana anterior',
            nextTooltip: 'Semana siguiente',
            onPrevious: () => context.read<CuadranteBloc>().add(const CuadranteSemanaChanged(-1)),
            onNext: () => context.read<CuadranteBloc>().add(const CuadranteSemanaChanged(1)),
          ),
        ],
      ),
    );
  }

  /// Muestra el diálogo para copiar la semana actual a otra fecha
  Future<void> _mostrarDialogoCopiarSemana(BuildContext context) async {
    final CopiarSemanaResult? resultado = await showDialog<CopiarSemanaResult>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return CopiarSemanaDialog(
          semanaActual: state.primerDiaSemana,
          personalConTurnos: state.personalConTurnos,
        );
      },
    );

    if (resultado != null && context.mounted) {
      final DateTime semanaDestino = DateTime.parse(resultado.semanaDestino);

      // Disparar evento para copiar la semana
      context.read<CuadranteBloc>().add(
            CuadranteCopiarSemanaRequested(
              semanaOrigen: state.primerDiaSemana,
              semanaDestino: semanaDestino,
              idPersonal: resultado.idPersonal,
            ),
          );
    }
  }

  /// Muestra el diálogo para generar cuadrante automáticamente
  Future<void> _mostrarDialogoGeneracionAutomatica(BuildContext context) async {
    final bool? result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return GeneracionAutomaticaDialog(
          fechaInicioSugerida: state.primerDiaSemana,
          fechaFinSugerida: state.ultimoDiaSemana,
        );
      },
    );

    // Si se confirmó la generación, refrescar cuadrante
    if (result == true && context.mounted) {
      context.read<CuadranteBloc>().add(const CuadranteRefreshRequested());
    }
  }
}

/// Texto del rango de la semana visible ("13 oct - 19 oct")
String cuadranteSemanaTexto(CuadranteLoaded state) {
  final DateFormat formatter = DateFormat('d MMM', 'es_ES');
  return '${formatter.format(state.primerDiaSemana)} - ${formatter.format(state.ultimoDiaSemana)}';
}

/// Barra de estado del cuadrante con el resumen (antes chips de la cabecera)
class CuadranteStatusBar extends StatelessWidget {
  const CuadranteStatusBar({required this.state, super.key});

  final CuadranteLoaded state;

  @override
  Widget build(BuildContext context) {
    return GestionStatusBar(
      items: <String>[
        'Personal: ${state.totalPersonal}',
        'Turnos: ${state.totalTurnos}',
        'Semana: ${cuadranteSemanaTexto(state)}',
        'Vista: ${state.viewMode.nombre}',
      ],
    );
  }
}
