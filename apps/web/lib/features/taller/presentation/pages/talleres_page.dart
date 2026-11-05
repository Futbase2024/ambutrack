import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/core/widgets/headers/page_header.dart';
import 'package:ambutrack_web/features/taller/presentation/bloc/taller_bloc.dart';
import 'package:ambutrack_web/features/taller/presentation/bloc/taller_event.dart';
import 'package:ambutrack_web/features/taller/presentation/bloc/taller_state.dart';
import 'package:ambutrack_web/features/taller/presentation/widgets/taller_form_dialog.dart';
import 'package:ambutrack_web/features/taller/presentation/widgets/taller_table.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Página de gestión del Catálogo de Talleres
class TalleresPage extends StatelessWidget {
  const TalleresPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocProvider<TallerBloc>(
        create: (BuildContext context) =>
            getIt<TallerBloc>()..add(const TallerLoadRequested()),
        child: const _TalleresView(),
      ),
    );
  }
}

class _TalleresView extends StatelessWidget {
  const _TalleresView();

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
            BlocBuilder<TallerBloc, TallerState>(
              builder: (BuildContext context, TallerState state) {
                final List<TallerEntity> talleres =
                    state is TallerLoaded ? state.talleres : <TallerEntity>[];
                return PageHeader(
                  config: PageHeaderConfig(
                    icon: Icons.construction,
                    title: 'Catálogo de Talleres',
                    subtitle: 'Gestión de talleres mecánicos y estaciones ITV',
                    addButtonLabel: 'Nuevo Taller',
                    stats: _buildStats(talleres),
                    onAdd: () => _showFormDialog(context),
                  ),
                );
              },
            ),
            const SizedBox(height: AppSizes.spacingXl),
            const Expanded(
              child: TallerTable(),
            ),
          ],
        ),
      ),
    );
  }

  List<HeaderStat> _buildStats(List<TallerEntity> talleres) {
    final int propios = talleres
        .where((TallerEntity t) => t.tipo == TipoTaller.propio)
        .length;
    final int externos = talleres
        .where((TallerEntity t) => t.tipo == TipoTaller.externo)
        .length;
    final int itv = talleres
        .where((TallerEntity t) => t.tipo == TipoTaller.itv)
        .length;

    return <HeaderStat>[
      HeaderStat(value: talleres.length.toString(), icon: Icons.construction),
      HeaderStat(
        value: propios.toString(),
        icon: Icons.home_repair_service,
        color: AppColors.success,
      ),
      HeaderStat(
        value: externos.toString(),
        icon: Icons.business,
        color: AppColors.info,
      ),
      HeaderStat(
        value: itv.toString(),
        icon: Icons.verified,
        color: AppColors.secondary,
      ),
    ];
  }

  Future<void> _showFormDialog(BuildContext context) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return BlocProvider<TallerBloc>.value(
          value: context.read<TallerBloc>(),
          child: const TallerFormDialog(),
        );
      },
    );
  }
}
