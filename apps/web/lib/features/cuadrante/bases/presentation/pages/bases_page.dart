import 'package:ambutrack_core/ambutrack_core.dart';
import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/core/widgets/headers/page_header.dart';
import 'package:ambutrack_web/features/cuadrante/bases/presentation/bloc/bloc.dart';
import 'package:ambutrack_web/features/cuadrante/bases/presentation/widgets/base_form_dialog.dart';
import 'package:ambutrack_web/features/cuadrante/bases/presentation/widgets/bases_table.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Página principal de gestión de Bases/Centros de ambulancias
class BasesPage extends StatelessWidget {
  const BasesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocProvider<BasesBloc>(
        create: (BuildContext context) => getIt<BasesBloc>()..add(const BasesLoadRequested()),
        child: const _BasesView(),
      ),
    );
  }
}

class _BasesView extends StatelessWidget {
  const _BasesView();

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
            BlocBuilder<BasesBloc, BasesState>(
              builder: (BuildContext context, BasesState state) {
                return PageHeader(
                  config: PageHeaderConfig(
                    icon: Icons.location_city,
                    title: 'Gestión de Bases',
                    subtitle: 'Administra las bases y centros del sistema',
                    addButtonLabel: 'Nueva Base',
                    stats: _buildHeaderStats(state),
                    onAdd: () => _showCreateDialog(context),
                  ),
                );
              },
            ),
            const SizedBox(height: AppSizes.spacingXl),

            // Tabla ocupa el espacio restante
            const Expanded(child: BasesTable()),
          ],
        ),
      ),
    );
  }

  /// Construye las estadísticas del header
  List<HeaderStat> _buildHeaderStats(BasesState state) {
    String total = '-';
    String activas = '-';
    String inactivas = '-';

    if (state is BasesLoaded) {
      total = state.bases.length.toString();
      activas = state.bases.where((BaseCentroEntity b) => b.activo).length.toString();
      inactivas = state.bases.where((BaseCentroEntity b) => !b.activo).length.toString();
    } else if (state is BaseOperationSuccess) {
      total = state.bases.length.toString();
      activas = state.bases.where((BaseCentroEntity b) => b.activo).length.toString();
      inactivas = state.bases.where((BaseCentroEntity b) => !b.activo).length.toString();
    }

    return <HeaderStat>[
      HeaderStat(
        value: total,
        icon: Icons.location_city,
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
      builder: (BuildContext dialogContext) => BlocProvider<BasesBloc>.value(
        value: context.read<BasesBloc>(),
        child: const BaseFormDialog(),
      ),
    );
  }
}
