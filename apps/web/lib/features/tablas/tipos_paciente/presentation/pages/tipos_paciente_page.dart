import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/core/widgets/headers/page_header.dart';
import 'package:ambutrack_web/features/tablas/tipos_paciente/presentation/bloc/tipo_paciente_bloc.dart';
import 'package:ambutrack_web/features/tablas/tipos_paciente/presentation/bloc/tipo_paciente_event.dart';
import 'package:ambutrack_web/features/tablas/tipos_paciente/presentation/bloc/tipo_paciente_state.dart';
import 'package:ambutrack_web/features/tablas/tipos_paciente/presentation/widgets/tipo_paciente_form_dialog.dart';
import 'package:ambutrack_web/features/tablas/tipos_paciente/presentation/widgets/tipo_paciente_table.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Página de gestión de tipos de paciente
class TiposPacientePage extends StatelessWidget {
  const TiposPacientePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocProvider<TipoPacienteBloc>(
        create: (BuildContext context) => getIt<TipoPacienteBloc>()..add(const TipoPacienteLoadRequested()),
        child: const _TiposPacienteView(),
      ),
    );
  }
}

/// Vista principal de tipos de paciente
class _TiposPacienteView extends StatelessWidget {
  const _TiposPacienteView();

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
            BlocBuilder<TipoPacienteBloc, TipoPacienteState>(
              builder: (BuildContext context, TipoPacienteState state) {
                return PageHeader(
                  config: PageHeaderConfig(
                    icon: Icons.personal_injury,
                    title: 'Gestión de Tipos de Paciente',
                    subtitle: 'Administra los tipos de paciente disponibles en el sistema',
                    addButtonLabel: 'Nuevo Tipo',
                    stats: _buildHeaderStats(state),
                    onAdd: () => _showCreateDialog(context),
                  ),
                );
              },
            ),
            const SizedBox(height: AppSizes.spacingXl),

            // Tabla ocupa el espacio restante
            const Expanded(child: TipoPacienteTable()),
          ],
        ),
      ),
    );
  }

  /// Construye las estadísticas del header
  List<HeaderStat> _buildHeaderStats(TipoPacienteState state) {
    String total = '-';

    if (state is TipoPacienteLoaded) {
      total = state.tiposPaciente.length.toString();
    }

    return <HeaderStat>[
      HeaderStat(
        value: total,
        icon: Icons.personal_injury,
      ),
    ];
  }

  Future<void> _showCreateDialog(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) => BlocProvider<TipoPacienteBloc>.value(
        value: context.read<TipoPacienteBloc>(),
        child: const TipoPacienteFormDialog(),
      ),
    );
  }
}
