import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/core/widgets/headers/page_header.dart';
import 'package:ambutrack_web/features/vehiculos/presentation/bloc/stock_equipamiento/stock_equipamiento_bloc.dart';
import 'package:ambutrack_web/features/vehiculos/presentation/bloc/stock_equipamiento/stock_equipamiento_event.dart';
import 'package:ambutrack_web/features/vehiculos/presentation/bloc/stock_equipamiento/stock_equipamiento_state.dart';
import 'package:ambutrack_web/features/vehiculos/presentation/widgets/stock_equipamiento_table.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Página de Stock de Equipamiento de Vehículos
///
/// Muestra una tabla con todos los vehículos y sus estadísticas de equipamiento:
/// - Total de items
/// - Items OK
/// - Items caducados
/// - Items con stock bajo
/// - Items próximos a caducar
///
/// Permite ver, editar y añadir stock a cada vehículo.
class StockEquipamientoPage extends StatelessWidget {
  const StockEquipamientoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.backgroundLight,
        body: BlocProvider<StockEquipamientoBloc>(
          create: (BuildContext context) =>
              getIt<StockEquipamientoBloc>()..add(const StockEquipamientoLoadRequested()),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSizes.paddingXl,
              AppSizes.paddingXl,
              AppSizes.paddingXl,
              AppSizes.paddingLarge,
            ),
            child: BlocBuilder<StockEquipamientoBloc, StockEquipamientoState>(
              builder: (BuildContext context, StockEquipamientoState state) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    _HeaderSection(state: state),
                    const SizedBox(height: AppSizes.spacingXl),
                    const Expanded(
                      child: StockEquipamientoTable(),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _HeaderSection extends StatelessWidget {
  const _HeaderSection({required this.state});

  final StockEquipamientoState state;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: PageHeader(
            config: PageHeaderConfig(
              icon: Icons.medical_services,
              title: 'Stock de Equipamiento',
              subtitle: 'Resumen de equipamiento por vehículo',
              stats: _buildHeaderStats(state),
              onAdd: () {}, // No hay acción de agregar en esta página
              addButtonLabel: 'Actualizar',
            ),
          ),
        ),
        const SizedBox(width: AppSizes.spacingMedium),
        _RefreshButton(state: state),
      ],
    );
  }

  List<HeaderStat> _buildHeaderStats(StockEquipamientoState state) {
    if (state is StockEquipamientoLoading || state is StockEquipamientoInitial) {
      return const <HeaderStat>[
        HeaderStat(
          value: '-',
          icon: Icons.directions_car,
          color: AppColors.primary,
        ),
        HeaderStat(
          value: '-',
          icon: Icons.check_circle,
          color: AppColors.primary,
        ),
        HeaderStat(
          value: '-',
          icon: Icons.warning,
          color: AppColors.primary,
        ),
        HeaderStat(
          value: '-',
          icon: Icons.error,
          color: AppColors.primary,
        ),
      ];
    }

    if (state is StockEquipamientoLoaded) {
      return <HeaderStat>[
        HeaderStat(
          value: state.totalVehiculos.toString(),
          icon: Icons.directions_car,
          color: AppColors.primary,
        ),
        HeaderStat(
          value: state.vehiculosOk.toString(),
          icon: Icons.check_circle,
          color: AppColors.primary,
        ),
        HeaderStat(
          value: state.vehiculosAtencion.toString(),
          icon: Icons.warning,
          color: AppColors.primary,
        ),
        HeaderStat(
          value: state.vehiculosCritico.toString(),
          icon: Icons.error,
          color: AppColors.primary,
        ),
      ];
    }

    return const <HeaderStat>[];
  }
}

class _RefreshButton extends StatelessWidget {
  const _RefreshButton({required this.state});

  final StockEquipamientoState state;

  @override
  Widget build(BuildContext context) {
    final bool isLoading = state is StockEquipamientoLoading ||
        (state is StockEquipamientoLoaded && (state as StockEquipamientoLoaded).isRefreshing);

    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingMedium),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
        border: Border.all(color: AppColors.gray200),
      ),
      child: IconButton(
        onPressed: isLoading
            ? null
            : () {
                context
                    .read<StockEquipamientoBloc>()
                    .add(const StockEquipamientoRefreshRequested());
              },
        icon: const Icon(Icons.refresh),
        tooltip: 'Actualizar',
        color: AppColors.primary,
      ),
    );
  }
}
