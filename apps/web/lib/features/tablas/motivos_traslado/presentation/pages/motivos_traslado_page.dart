import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/core/widgets/headers/page_header.dart';
import 'package:ambutrack_web/features/tablas/motivos_traslado/presentation/bloc/motivo_traslado_bloc.dart';
import 'package:ambutrack_web/features/tablas/motivos_traslado/presentation/bloc/motivo_traslado_event.dart';
import 'package:ambutrack_web/features/tablas/motivos_traslado/presentation/bloc/motivo_traslado_state.dart';
import 'package:ambutrack_web/features/tablas/motivos_traslado/presentation/widgets/motivo_traslado_form_dialog.dart';
import 'package:ambutrack_web/features/tablas/motivos_traslado/presentation/widgets/motivo_traslado_table.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Página de gestión de motivos de traslado
class MotivosTrasladoPage extends StatelessWidget {
  const MotivosTrasladoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocProvider<MotivoTrasladoBloc>(
        create: (BuildContext context) => getIt<MotivoTrasladoBloc>()..add(const MotivoTrasladoLoadAllRequested()),
        child: const _MotivosTrasladoView(),
      ),
    );
  }
}

/// Vista principal de motivos de traslado
class _MotivosTrasladoView extends StatelessWidget {
  const _MotivosTrasladoView();

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
            BlocBuilder<MotivoTrasladoBloc, MotivoTrasladoState>(
              builder: (BuildContext context, MotivoTrasladoState state) {
                return PageHeader(
                  config: PageHeaderConfig(
                    icon: Icons.transfer_within_a_station,
                    title: 'Gestión de Motivos de Traslado',
                    subtitle: 'Administra los motivos de traslado disponibles en el sistema',
                    addButtonLabel: 'Nuevo Motivo',
                    stats: _buildHeaderStats(state),
                    onAdd: () => _showCreateDialog(context),
                  ),
                );
              },
            ),
            const SizedBox(height: AppSizes.spacingXl),

            // Tabla ocupa el espacio restante
            const Expanded(child: MotivoTrasladoTable()),
          ],
        ),
      ),
    );
  }

  /// Construye las estadísticas del header
  List<HeaderStat> _buildHeaderStats(MotivoTrasladoState state) {
    String total = '-';

    if (state is MotivoTrasladoLoaded) {
      total = state.motivos.length.toString();
    }

    return <HeaderStat>[
      HeaderStat(
        value: total,
        icon: Icons.transfer_within_a_station,
      ),
    ];
  }

  Future<void> _showCreateDialog(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) => BlocProvider<MotivoTrasladoBloc>.value(
        value: context.read<MotivoTrasladoBloc>(),
        child: const MotivoTrasladoFormDialog(),
      ),
    );
  }
}
