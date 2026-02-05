import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/core/widgets/headers/page_header.dart';
import 'package:ambutrack_web/features/tablas/facultativos/presentation/bloc/facultativo_bloc.dart';
import 'package:ambutrack_web/features/tablas/facultativos/presentation/bloc/facultativo_event.dart';
import 'package:ambutrack_web/features/tablas/facultativos/presentation/bloc/facultativo_state.dart';
import 'package:ambutrack_web/features/tablas/facultativos/presentation/widgets/facultativo_form_dialog.dart';
import 'package:ambutrack_web/features/tablas/facultativos/presentation/widgets/facultativo_table.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Página de gestión de facultativos
class FacultativoPage extends StatelessWidget {
  const FacultativoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocProvider<FacultativoBloc>(
        create: (BuildContext context) => getIt<FacultativoBloc>()..add(const FacultativoLoadAllRequested()),
        child: const _FacultativoView(),
      ),
    );
  }
}

/// Vista principal de facultativos
class _FacultativoView extends StatelessWidget {
  const _FacultativoView();

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
            BlocBuilder<FacultativoBloc, FacultativoState>(
              builder: (BuildContext context, FacultativoState state) {
                return PageHeader(
                  config: PageHeaderConfig(
                    icon: Icons.medical_services_outlined,
                    title: 'Gestión de Facultativos',
                    subtitle: 'Administra los médicos y personal facultativo del sistema',
                    addButtonLabel: 'Nuevo Facultativo',
                    stats: _buildHeaderStats(state),
                    onAdd: () => _showCreateDialog(context),
                  ),
                );
              },
            ),
            const SizedBox(height: AppSizes.spacingXl),

            // Tabla ocupa el espacio restante
            const Expanded(child: FacultativoTable()),
          ],
        ),
      ),
    );
  }

  /// Construye las estadísticas del header
  List<HeaderStat> _buildHeaderStats(FacultativoState state) {
    String total = '-';

    if (state is FacultativoLoaded) {
      total = state.facultativos.length.toString();
    }

    return <HeaderStat>[
      HeaderStat(
        value: total,
        icon: Icons.medical_services_outlined,
      ),
    ];
  }

  Future<void> _showCreateDialog(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) => BlocProvider<FacultativoBloc>.value(
        value: context.read<FacultativoBloc>(),
        child: const FacultativoFormDialog(),
      ),
    );
  }
}
