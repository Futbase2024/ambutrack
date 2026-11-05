import 'package:ambutrack_core_datasource/incidencias.dart';
import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/core/widgets/headers/page_header.dart';
import 'package:ambutrack_web/features/incidencias/presentation/bloc/incidencia/incidencia_bloc.dart';
import 'package:ambutrack_web/features/incidencias/presentation/bloc/incidencia/incidencia_event.dart';
import 'package:ambutrack_web/features/incidencias/presentation/bloc/incidencia/incidencia_state.dart';
import 'package:ambutrack_web/features/incidencias/presentation/widgets/incidencia_form_dialog.dart';
import 'package:ambutrack_web/features/incidencias/presentation/widgets/incidencias_filters.dart';
import 'package:ambutrack_web/features/incidencias/presentation/widgets/incidencias_table.dart';
import 'package:ambutrack_web/features/vehiculos/presentation/bloc/vehiculos_bloc.dart';
import 'package:ambutrack_web/features/vehiculos/presentation/bloc/vehiculos_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nested/nested.dart';

/// Página principal de gestión de incidencias
class IncidenciasPage extends StatelessWidget {
  const IncidenciasPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: MultiBlocProvider(
        providers: <SingleChildWidget>[
          BlocProvider<IncidenciaBloc>(
            create: (_) =>
                getIt<IncidenciaBloc>()..add(const IncidenciaLoadAllRequested()),
          ),
          BlocProvider<VehiculosBloc>(
            create: (_) =>
                getIt<VehiculosBloc>()..add(const VehiculosLoadRequested()),
          ),
        ],
        child: const _IncidenciasView(),
      ),
    );
  }
}

class _IncidenciasView extends StatelessWidget {
  const _IncidenciasView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSizes.paddingXl,
          AppSizes.paddingXl,
          AppSizes.paddingXl,
          AppSizes.paddingLarge,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            BlocBuilder<IncidenciaBloc, IncidenciaState>(
              builder: (BuildContext context, IncidenciaState state) {
                return PageHeader(
                  config: PageHeaderConfig(
                    icon: Icons.report_problem_outlined,
                    title: 'Gestión de Incidencias',
                    subtitle: 'Registro y seguimiento de incidencias del servicio',
                    addButtonLabel: 'Nueva Incidencia',
                    stats: _buildHeaderStats(state),
                    onAdd: () => _showCreateDialog(context),
                    extra: const IncidenciasFilters(),
                  ),
                );
              },
            ),
            const SizedBox(height: AppSizes.spacing),
            const Expanded(child: IncidenciasTable()),
          ],
        ),
      ),
    );
  }

  List<HeaderStat> _buildHeaderStats(IncidenciaState state) {
    String total = '-';
    String criticas = '-';
    String enProceso = '-';
    String resueltas = '-';

    if (state is IncidenciaLoaded) {
      final List<IncidenciaEntity> all = state.allIncidencias;
      total = all.length.toString();
      criticas = all
          .where((IncidenciaEntity i) =>
              i.prioridad == PrioridadIncidencia.critica)
          .length
          .toString();
      enProceso = all
          .where((IncidenciaEntity i) =>
              i.estado == EstadoIncidencia.enProceso)
          .length
          .toString();
      resueltas = all
          .where((IncidenciaEntity i) =>
              i.estado == EstadoIncidencia.resuelta)
          .length
          .toString();
    }

    return <HeaderStat>[
      HeaderStat(value: total, icon: Icons.list_alt),
      HeaderStat(value: criticas, icon: Icons.error, color: AppColors.error),
      HeaderStat(
        value: enProceso,
        icon: Icons.pending_actions,
        color: AppColors.warning,
      ),
      HeaderStat(
        value: resueltas,
        icon: Icons.check_circle,
        color: AppColors.success,
      ),
    ];
  }

  Future<void> _showCreateDialog(BuildContext context) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) => MultiBlocProvider(
        providers: <SingleChildWidget>[
          BlocProvider<IncidenciaBloc>.value(
            value: context.read<IncidenciaBloc>(),
          ),
          BlocProvider<VehiculosBloc>.value(
            value: context.read<VehiculosBloc>(),
          ),
        ],
        child: IncidenciaFormDialog(
          onSave: (IncidenciaEntity incidencia) async {
            context
                .read<IncidenciaBloc>()
                .add(IncidenciaCreateRequested(incidencia));
            return;
          },
        ),
      ),
    );
  }
}
