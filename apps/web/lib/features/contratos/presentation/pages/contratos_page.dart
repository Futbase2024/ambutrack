import 'package:ambutrack_core/ambutrack_core.dart';
import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/core/widgets/headers/page_header.dart';
import 'package:ambutrack_web/features/contratos/presentation/bloc/bloc.dart';
import 'package:ambutrack_web/features/contratos/presentation/widgets/contrato_form_dialog.dart';
import 'package:ambutrack_web/features/contratos/presentation/widgets/contrato_table.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Página principal de gestión de contratos
class ContratosPage extends StatelessWidget {
  const ContratosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocProvider<ContratoBloc>(
        create: (BuildContext context) =>
            getIt<ContratoBloc>()..add(const ContratoLoadRequested()),
        child: const _ContratosView(),
      ),
    );
  }
}

class _ContratosView extends StatelessWidget {
  const _ContratosView();

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
            BlocBuilder<ContratoBloc, ContratoState>(
              builder: (BuildContext context, ContratoState state) {
                return PageHeader(
                  config: PageHeaderConfig(
                    icon: Icons.description,
                    title: 'Gestión de Contratos',
                    subtitle: 'Gestiona los contratos con centros hospitalarios y servicios',
                    addButtonLabel: 'Nuevo Contrato',
                    stats: _buildHeaderStats(state),
                    onAdd: () => _showCreateDialog(context),
                  ),
                );
              },
            ),
            const SizedBox(height: AppSizes.spacingXl),

            // Tabla ocupa el espacio restante
            const Expanded(child: ContratoTable()),
          ],
        ),
      ),
    );
  }

  /// Construye las estadísticas del header
  List<HeaderStat> _buildHeaderStats(ContratoState state) {
    String total = '-';
    String activos = '-';
    String vigentes = '-';

    if (state is ContratoLoaded) {
      total = state.contratos.length.toString();
      activos = state.contratos.where((ContratoEntity c) => c.activo).length.toString();
      vigentes = state.contratos.where((ContratoEntity c) => c.esVigente).length.toString();
    } else if (state is ContratoOperationSuccess) {
      total = state.contratos.length.toString();
      activos = state.contratos.where((ContratoEntity c) => c.activo).length.toString();
      vigentes = state.contratos.where((ContratoEntity c) => c.esVigente).length.toString();
    }

    return <HeaderStat>[
      HeaderStat(
        value: total,
        icon: Icons.description,
      ),
      HeaderStat(
        value: activos,
        icon: Icons.check_circle,
      ),
      HeaderStat(
        value: vigentes,
        icon: Icons.event_available,
      ),
    ];
  }

  Future<void> _showCreateDialog(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) => BlocProvider<ContratoBloc>.value(
        value: context.read<ContratoBloc>(),
        child: const ContratoFormDialog(),
      ),
    );
  }
}
