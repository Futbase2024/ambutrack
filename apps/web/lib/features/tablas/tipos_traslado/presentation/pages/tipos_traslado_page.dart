import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/core/widgets/headers/page_header.dart';
import 'package:ambutrack_web/features/tablas/tipos_traslado/presentation/bloc/tipo_traslado_bloc.dart';
import 'package:ambutrack_web/features/tablas/tipos_traslado/presentation/bloc/tipo_traslado_event.dart';
import 'package:ambutrack_web/features/tablas/tipos_traslado/presentation/bloc/tipo_traslado_state.dart';
import 'package:ambutrack_web/features/tablas/tipos_traslado/presentation/widgets/tipo_traslado_form_dialog.dart';
import 'package:ambutrack_web/features/tablas/tipos_traslado/presentation/widgets/tipo_traslado_table.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Página de gestión de tipos de traslado
class TiposTrasladoPage extends StatelessWidget {
  const TiposTrasladoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocProvider<TipoTrasladoBloc>(
        create: (BuildContext context) => getIt<TipoTrasladoBloc>()..add(const TipoTrasladoLoadRequested()),
        child: const _TiposTrasladoView(),
      ),
    );
  }
}

/// Vista principal de tipos de traslado
class _TiposTrasladoView extends StatelessWidget {
  const _TiposTrasladoView();

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
            BlocBuilder<TipoTrasladoBloc, TipoTrasladoState>(
              builder: (BuildContext context, TipoTrasladoState state) {
                return PageHeader(
                  config: PageHeaderConfig(
                    icon: Icons.swap_horiz,
                    title: 'Gestión de Tipos de Traslado',
                    subtitle: 'Administra los tipos de traslado disponibles en el sistema',
                    addButtonLabel: 'Nuevo Tipo',
                    stats: _buildHeaderStats(state),
                    onAdd: () => _showCreateDialog(context),
                  ),
                );
              },
            ),
            const SizedBox(height: AppSizes.spacingXl),

            // Tabla ocupa el espacio restante
            const Expanded(child: TipoTrasladoTable()),
          ],
        ),
      ),
    );
  }

  /// Construye las estadísticas del header
  List<HeaderStat> _buildHeaderStats(TipoTrasladoState state) {
    String total = '-';

    if (state is TipoTrasladoLoaded) {
      total = state.tipos.length.toString();
    }

    return <HeaderStat>[
      HeaderStat(
        value: total,
        icon: Icons.swap_horiz,
      ),
    ];
  }

  Future<void> _showCreateDialog(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) => BlocProvider<TipoTrasladoBloc>.value(
        value: context.read<TipoTrasladoBloc>(),
        child: const TipoTrasladoFormDialog(),
      ),
    );
  }
}
