import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/core/widgets/headers/page_header.dart';
import 'package:ambutrack_web/features/cuadrante/excepciones_festivos/presentation/bloc/excepciones_festivos_bloc_exports.dart';
import 'package:ambutrack_web/features/cuadrante/excepciones_festivos/presentation/widgets/excepcion_festivo_form_dialog.dart';
import 'package:ambutrack_web/features/cuadrante/excepciones_festivos/presentation/widgets/excepciones_festivos_table.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Página principal de Excepciones y Festivos del Cuadrante
class ExcepcionesFestivosPage extends StatelessWidget {
  const ExcepcionesFestivosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocProvider<ExcepcionesFestivosBloc>(
        create: (BuildContext context) => getIt<ExcepcionesFestivosBloc>()
          ..add(const ExcepcionesFestivosLoadRequested()),
        child: const _ExcepcionesFestivosView(),
      ),
    );
  }
}

class _ExcepcionesFestivosView extends StatelessWidget {
  const _ExcepcionesFestivosView();

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
            // PageHeader con estadísticas
            BlocBuilder<ExcepcionesFestivosBloc, ExcepcionesFestivosState>(
              builder: (BuildContext context, ExcepcionesFestivosState state) {
                return PageHeader(
                  config: PageHeaderConfig(
                    icon: Icons.event_busy,
                    title: 'Excepciones y Festivos',
                    subtitle: 'Gestión de días festivos y excepciones del cuadrante',
                    addButtonLabel: 'Nueva Excepción/Festivo',
                    stats: _buildHeaderStats(state),
                    onAdd: () => _showCreateDialog(context),
                  ),
                );
              },
            ),
            const SizedBox(height: AppSizes.spacingXl),

            // Tabla ocupa el espacio restante
            const Expanded(child: ExcepcionesFestivosTable()),
          ],
        ),
      ),
    );
  }

  /// Construye las estadísticas del header
  List<HeaderStat> _buildHeaderStats(ExcepcionesFestivosState state) {
    String total = '-';
    String activos = '-';
    String anuales = '-';

    if (state is ExcepcionesFestivosLoaded) {
      total = state.items.length.toString();
      activos = state.items.where((ExcepcionFestivoEntity e) => e.activo).length.toString();
      anuales = state.items.where((ExcepcionFestivoEntity e) => e.repetirAnualmente).length.toString();
    } else if (state is ExcepcionFestivoOperationSuccess) {
      total = state.items.length.toString();
      activos = state.items.where((ExcepcionFestivoEntity e) => e.activo).length.toString();
      anuales = state.items.where((ExcepcionFestivoEntity e) => e.repetirAnualmente).length.toString();
    }

    return <HeaderStat>[
      HeaderStat(
        value: total,
        icon: Icons.event_busy,
      ),
      HeaderStat(
        value: activos,
        icon: Icons.check_circle,
      ),
      HeaderStat(
        value: anuales,
        icon: Icons.autorenew,
      ),
    ];
  }

  Future<void> _showCreateDialog(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) => BlocProvider<ExcepcionesFestivosBloc>.value(
        value: context.read<ExcepcionesFestivosBloc>(),
        child: const ExcepcionFestivoFormDialog(),
      ),
    );
  }
}
