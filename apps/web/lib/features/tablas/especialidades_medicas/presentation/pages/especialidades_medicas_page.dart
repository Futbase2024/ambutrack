import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/core/widgets/headers/page_header.dart';
import 'package:ambutrack_web/features/tablas/especialidades_medicas/presentation/bloc/especialidad_bloc.dart';
import 'package:ambutrack_web/features/tablas/especialidades_medicas/presentation/bloc/especialidad_event.dart';
import 'package:ambutrack_web/features/tablas/especialidades_medicas/presentation/bloc/especialidad_state.dart';
import 'package:ambutrack_web/features/tablas/especialidades_medicas/presentation/widgets/especialidad_form_dialog.dart';
import 'package:ambutrack_web/features/tablas/especialidades_medicas/presentation/widgets/especialidad_table.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Página de gestión de especialidades médicas
class EspecialidadesMedicasPage extends StatelessWidget {
  const EspecialidadesMedicasPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocProvider<EspecialidadBloc>(
        create: (BuildContext context) => getIt<EspecialidadBloc>()..add(const EspecialidadLoadAllRequested()),
        child: const _EspecialidadesMedicasView(),
      ),
    );
  }
}

/// Vista principal de especialidades médicas
class _EspecialidadesMedicasView extends StatelessWidget {
  const _EspecialidadesMedicasView();

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
            BlocBuilder<EspecialidadBloc, EspecialidadState>(
              builder: (BuildContext context, EspecialidadState state) {
                return PageHeader(
                  config: PageHeaderConfig(
                    icon: Icons.medical_services,
                    title: 'Gestión de Especialidades Médicas',
                    subtitle: 'Administra las especialidades médicas y certificaciones profesionales',
                    addButtonLabel: 'Nueva Especialidad',
                    stats: _buildHeaderStats(state),
                    onAdd: () => _showCreateDialog(context),
                  ),
                );
              },
            ),
            const SizedBox(height: AppSizes.spacingXl),

            // Tabla ocupa el espacio restante
            const Expanded(child: EspecialidadTable()),
          ],
        ),
      ),
    );
  }

  /// Construye las estadísticas del header
  List<HeaderStat> _buildHeaderStats(EspecialidadState state) {
    String total = '-';

    if (state is EspecialidadLoaded) {
      total = state.especialidades.length.toString();
    }

    return <HeaderStat>[
      HeaderStat(
        value: total,
        icon: Icons.medical_services,
      ),
    ];
  }

  Future<void> _showCreateDialog(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) => BlocProvider<EspecialidadBloc>.value(
        value: context.read<EspecialidadBloc>(),
        child: const EspecialidadFormDialog(),
      ),
    );
  }
}
