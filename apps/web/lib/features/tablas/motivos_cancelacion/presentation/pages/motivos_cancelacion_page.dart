import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/core/widgets/headers/page_header.dart';
import 'package:ambutrack_web/features/tablas/motivos_cancelacion/presentation/bloc/motivo_cancelacion_bloc.dart';
import 'package:ambutrack_web/features/tablas/motivos_cancelacion/presentation/bloc/motivo_cancelacion_event.dart';
import 'package:ambutrack_web/features/tablas/motivos_cancelacion/presentation/bloc/motivo_cancelacion_state.dart';
import 'package:ambutrack_web/features/tablas/motivos_cancelacion/presentation/widgets/motivo_cancelacion_form_dialog.dart';
import 'package:ambutrack_web/features/tablas/motivos_cancelacion/presentation/widgets/motivo_cancelacion_table.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Página de gestión de motivos de cancelación
class MotivosCancelacionPage extends StatelessWidget {
  const MotivosCancelacionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocProvider<MotivoCancelacionBloc>(
        create: (BuildContext context) => getIt<MotivoCancelacionBloc>()..add(const MotivoCancelacionLoadRequested()),
        child: const _MotivosCancelacionView(),
      ),
    );
  }
}

/// Vista principal de motivos de cancelación
class _MotivosCancelacionView extends StatelessWidget {
  const _MotivosCancelacionView();

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
            BlocBuilder<MotivoCancelacionBloc, MotivoCancelacionState>(
              builder: (BuildContext context, MotivoCancelacionState state) {
                return PageHeader(
                  config: PageHeaderConfig(
                    icon: Icons.cancel,
                    title: 'Gestión de Motivos de Cancelación',
                    subtitle: 'Administra los motivos de cancelación de servicios y traslados',
                    addButtonLabel: 'Nuevo Motivo',
                    stats: _buildHeaderStats(state),
                    onAdd: () => _showCreateDialog(context),
                  ),
                );
              },
            ),
            const SizedBox(height: AppSizes.spacingXl),

            // Tabla ocupa el espacio restante
            const Expanded(child: MotivoCancelacionTable()),
          ],
        ),
      ),
    );
  }

  /// Construye las estadísticas del header
  List<HeaderStat> _buildHeaderStats(MotivoCancelacionState state) {
    String total = '-';

    if (state is MotivoCancelacionLoaded) {
      total = state.motivos.length.toString();
    }

    return <HeaderStat>[
      HeaderStat(
        value: total,
        icon: Icons.cancel,
      ),
    ];
  }

  Future<void> _showCreateDialog(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) => BlocProvider<MotivoCancelacionBloc>.value(
        value: context.read<MotivoCancelacionBloc>(),
        child: const MotivoCancelacionFormDialog(),
      ),
    );
  }
}
