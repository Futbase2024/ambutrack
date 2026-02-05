import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/core/widgets/headers/page_header.dart';
import 'package:ambutrack_web/features/tablas/centros_hospitalarios/presentation/bloc/centro_hospitalario_bloc.dart';
import 'package:ambutrack_web/features/tablas/centros_hospitalarios/presentation/bloc/centro_hospitalario_event.dart';
import 'package:ambutrack_web/features/tablas/centros_hospitalarios/presentation/bloc/centro_hospitalario_state.dart';
import 'package:ambutrack_web/features/tablas/centros_hospitalarios/presentation/widgets/centro_hospitalario_form_dialog.dart';
import 'package:ambutrack_web/features/tablas/centros_hospitalarios/presentation/widgets/centro_hospitalario_table.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Página de gestión de centros hospitalarios
class CentrosHospitalariosPage extends StatelessWidget {
  const CentrosHospitalariosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocProvider<CentroHospitalarioBloc>(
        create: (BuildContext context) => getIt<CentroHospitalarioBloc>()..add(const CentroHospitalarioLoadAllRequested()),
        child: const _CentrosHospitalariosView(),
      ),
    );
  }
}

/// Vista principal de centros hospitalarios
class _CentrosHospitalariosView extends StatelessWidget {
  const _CentrosHospitalariosView();

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
            BlocBuilder<CentroHospitalarioBloc, CentroHospitalarioState>(
              builder: (BuildContext context, CentroHospitalarioState state) {
                return PageHeader(
                  config: PageHeaderConfig(
                    icon: Icons.local_hospital,
                    title: 'Gestión de Centros Hospitalarios',
                    subtitle: 'Administra hospitales, centros de salud y clínicas',
                    addButtonLabel: 'Nuevo Centro',
                    stats: _buildHeaderStats(state),
                    onAdd: () => _showCreateDialog(context),
                  ),
                );
              },
            ),
            const SizedBox(height: AppSizes.spacingXl),

            // Tabla ocupa el espacio restante
            const Expanded(child: CentroHospitalarioTable()),
          ],
        ),
      ),
    );
  }

  /// Construye las estadísticas del header
  List<HeaderStat> _buildHeaderStats(CentroHospitalarioState state) {
    String total = '-';

    if (state is CentroHospitalarioLoaded) {
      total = state.centros.length.toString();
    }

    return <HeaderStat>[
      HeaderStat(
        value: total,
        icon: Icons.local_hospital,
      ),
    ];
  }

  Future<void> _showCreateDialog(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) => BlocProvider<CentroHospitalarioBloc>.value(
        value: context.read<CentroHospitalarioBloc>(),
        child: const CentroHospitalarioFormDialog(),
      ),
    );
  }
}
