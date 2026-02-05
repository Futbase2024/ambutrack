import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/core/widgets/headers/page_header.dart';
import 'package:ambutrack_web/features/tablas/provincias/presentation/bloc/provincia_bloc.dart';
import 'package:ambutrack_web/features/tablas/provincias/presentation/bloc/provincia_event.dart';
import 'package:ambutrack_web/features/tablas/provincias/presentation/bloc/provincia_state.dart';
import 'package:ambutrack_web/features/tablas/provincias/presentation/widgets/provincia_form_dialog.dart';
import 'package:ambutrack_web/features/tablas/provincias/presentation/widgets/provincia_table.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Página de gestión de provincias
class ProvinciasPage extends StatelessWidget {
  const ProvinciasPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocProvider<ProvinciaBloc>(
        create: (BuildContext context) => getIt<ProvinciaBloc>()..add(const ProvinciaLoadAllRequested()),
        child: const _ProvinciasView(),
      ),
    );
  }
}

/// Vista principal de provincias
class _ProvinciasView extends StatelessWidget {
  const _ProvinciasView();

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
            BlocBuilder<ProvinciaBloc, ProvinciaState>(
              builder: (BuildContext context, ProvinciaState state) {
                return PageHeader(
                  config: PageHeaderConfig(
                    icon: Icons.map,
                    title: 'Gestión de Provincias',
                    subtitle: 'Administra las provincias y comunidades autónomas del sistema',
                    addButtonLabel: 'Nueva Provincia',
                    stats: _buildHeaderStats(state),
                    onAdd: () => _showCreateDialog(context),
                  ),
                );
              },
            ),
            const SizedBox(height: AppSizes.spacingXl),

            // Tabla ocupa el espacio restante
            const Expanded(child: ProvinciaTable()),
          ],
        ),
      ),
    );
  }

  /// Construye las estadísticas del header
  List<HeaderStat> _buildHeaderStats(ProvinciaState state) {
    String total = '-';

    if (state is ProvinciaLoaded) {
      total = state.provincias.length.toString();
    }

    return <HeaderStat>[
      HeaderStat(
        value: total,
        icon: Icons.map,
      ),
    ];
  }

  Future<void> _showCreateDialog(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) => BlocProvider<ProvinciaBloc>.value(
        value: context.read<ProvinciaBloc>(),
        child: const ProvinciaFormDialog(),
      ),
    );
  }
}
