import 'package:ambutrack_core/ambutrack_core.dart';
import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/core/widgets/headers/page_header.dart';
import 'package:ambutrack_web/features/cuadrante/dotaciones/presentation/bloc/dotaciones_bloc_exports.dart';
import 'package:ambutrack_web/features/cuadrante/dotaciones/presentation/widgets/dotacion_form_dialog.dart';
import 'package:ambutrack_web/features/cuadrante/dotaciones/presentation/widgets/dotaciones_table.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Página principal de gestión de Dotaciones
class DotacionesPage extends StatelessWidget {
  const DotacionesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocProvider<DotacionesBloc>(
        create: (BuildContext context) => getIt<DotacionesBloc>()..add(const DotacionesLoadRequested()),
        child: const _DotacionesView(),
      ),
    );
  }
}

class _DotacionesView extends StatelessWidget {
  const _DotacionesView();

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
            BlocBuilder<DotacionesBloc, DotacionesState>(
              builder: (BuildContext context, DotacionesState state) {
                return PageHeader(
                  config: PageHeaderConfig(
                    icon: Icons.assignment,
                    title: 'Gestión de Dotaciones',
                    subtitle: 'Administra las dotaciones del sistema',
                    addButtonLabel: 'Nueva Dotación',
                    stats: _buildHeaderStats(state),
                    onAdd: () => _showCreateDialog(context),
                  ),
                );
              },
            ),
            const SizedBox(height: AppSizes.spacingXl),

            // Tabla ocupa el espacio restante
            const Expanded(child: DotacionesTable()),
          ],
        ),
      ),
    );
  }

  /// Construye las estadísticas del header
  List<HeaderStat> _buildHeaderStats(DotacionesState state) {
    String total = '-';
    String activas = '-';
    String inactivas = '-';

    if (state is DotacionesLoaded) {
      total = state.dotaciones.length.toString();
      activas = state.dotaciones.where((DotacionEntity d) => d.activo).length.toString();
      inactivas = state.dotaciones.where((DotacionEntity d) => !d.activo).length.toString();
    } else if (state is DotacionOperationSuccess) {
      total = state.dotaciones.length.toString();
      activas = state.dotaciones.where((DotacionEntity d) => d.activo).length.toString();
      inactivas = state.dotaciones.where((DotacionEntity d) => !d.activo).length.toString();
    }

    return <HeaderStat>[
      HeaderStat(
        value: total,
        icon: Icons.assignment,
      ),
      HeaderStat(
        value: activas,
        icon: Icons.check_circle,
      ),
      HeaderStat(
        value: inactivas,
        icon: Icons.cancel,
      ),
    ];
  }

  Future<void> _showCreateDialog(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) => BlocProvider<DotacionesBloc>.value(
        value: context.read<DotacionesBloc>(),
        child: const DotacionFormDialog(),
      ),
    );
  }
}
