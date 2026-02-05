import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/core/widgets/headers/page_header.dart';
import 'package:ambutrack_web/features/tablas/tipos_vehiculo/presentation/bloc/tipo_vehiculo_bloc.dart';
import 'package:ambutrack_web/features/tablas/tipos_vehiculo/presentation/bloc/tipo_vehiculo_event.dart';
import 'package:ambutrack_web/features/tablas/tipos_vehiculo/presentation/bloc/tipo_vehiculo_state.dart';
import 'package:ambutrack_web/features/tablas/tipos_vehiculo/presentation/widgets/tipo_vehiculo_form_dialog.dart';
import 'package:ambutrack_web/features/tablas/tipos_vehiculo/presentation/widgets/tipo_vehiculo_table.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Página de gestión de tipos de vehículo
class TiposVehiculoPage extends StatelessWidget {
  const TiposVehiculoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocProvider<TipoVehiculoBloc>(
        create: (BuildContext context) => getIt<TipoVehiculoBloc>()..add(const TipoVehiculoLoadAllRequested()),
        child: const _TiposVehiculoView(),
      ),
    );
  }
}

/// Vista principal de tipos de vehículo
class _TiposVehiculoView extends StatelessWidget {
  const _TiposVehiculoView();

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
            BlocBuilder<TipoVehiculoBloc, TipoVehiculoState>(
              builder: (BuildContext context, TipoVehiculoState state) {
                return PageHeader(
                  config: PageHeaderConfig(
                    icon: Icons.directions_car,
                    title: 'Gestión de Tipos de Vehículo',
                    subtitle: 'Administra los tipos de vehículo disponibles en el sistema',
                    addButtonLabel: 'Nuevo Tipo',
                    stats: _buildHeaderStats(state),
                    onAdd: () => _showCreateDialog(context),
                  ),
                );
              },
            ),
            const SizedBox(height: AppSizes.spacingXl),

            // Tabla ocupa el espacio restante
            const Expanded(child: TipoVehiculoTable()),
          ],
        ),
      ),
    );
  }

  /// Construye las estadísticas del header
  List<HeaderStat> _buildHeaderStats(TipoVehiculoState state) {
    String total = '-';

    if (state is TipoVehiculoLoaded) {
      total = state.tiposVehiculo.length.toString();
    }

    return <HeaderStat>[
      HeaderStat(
        value: total,
        icon: Icons.directions_car,
      ),
    ];
  }

  Future<void> _showCreateDialog(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) => BlocProvider<TipoVehiculoBloc>.value(
        value: context.read<TipoVehiculoBloc>(),
        child: const TipoVehiculoFormDialog(),
      ),
    );
  }
}
