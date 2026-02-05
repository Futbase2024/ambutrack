import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/core/widgets/headers/page_header.dart';
import 'package:ambutrack_web/features/tablas/localidades/presentation/bloc/localidad_bloc.dart';
import 'package:ambutrack_web/features/tablas/localidades/presentation/bloc/localidad_event.dart';
import 'package:ambutrack_web/features/tablas/localidades/presentation/bloc/localidad_state.dart';
import 'package:ambutrack_web/features/tablas/localidades/presentation/widgets/localidad_form_dialog.dart';
import 'package:ambutrack_web/features/tablas/localidades/presentation/widgets/localidad_table.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Página de gestión de localidades
class LocalidadesPage extends StatelessWidget {
  const LocalidadesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocProvider<LocalidadBloc>(
        create: (BuildContext context) => getIt<LocalidadBloc>()..add(const LocalidadLoadAllRequested()),
        child: const _LocalidadesView(),
      ),
    );
  }
}

/// Vista principal de localidades
class _LocalidadesView extends StatelessWidget {
  const _LocalidadesView();

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
            BlocBuilder<LocalidadBloc, LocalidadState>(
              builder: (BuildContext context, LocalidadState state) {
                return PageHeader(
                  config: PageHeaderConfig(
                    icon: Icons.location_city,
                    title: 'Gestión de Localidades',
                    subtitle: 'Administra las localidades y poblaciones del sistema',
                    addButtonLabel: 'Nueva Localidad',
                    stats: _buildHeaderStats(state),
                    onAdd: () => _showCreateDialog(context),
                  ),
                );
              },
            ),
            const SizedBox(height: AppSizes.spacingXl),

            // Tabla ocupa el espacio restante
            const Expanded(child: LocalidadTable()),
          ],
        ),
      ),
    );
  }

  /// Construye las estadísticas del header
  List<HeaderStat> _buildHeaderStats(LocalidadState state) {
    String total = '-';

    if (state is LocalidadLoaded) {
      total = state.localidades.length.toString();
    }

    return <HeaderStat>[
      HeaderStat(
        value: total,
        icon: Icons.location_city,
      ),
    ];
  }

  Future<void> _showCreateDialog(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) => BlocProvider<LocalidadBloc>.value(
        value: context.read<LocalidadBloc>(),
        child: const LocalidadFormDialog(),
      ),
    );
  }
}
