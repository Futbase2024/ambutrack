import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/features/vehiculos/presentation/bloc/stock_equipamiento/stock_equipamiento_bloc.dart';
import 'package:ambutrack_web/features/vehiculos/presentation/bloc/stock_equipamiento/stock_equipamiento_event.dart';
import 'package:ambutrack_web/features/vehiculos/presentation/widgets/stock_equipamiento_header.dart';
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
      child: BlocProvider<StockEquipamientoBloc>(
        create: (BuildContext context) =>
            getIt<StockEquipamientoBloc>()..add(const StockEquipamientoLoadRequested()),
        child: const _StockEquipamientoView(),
      ),
    );
  }
}

/// Vista principal de Stock de Equipamiento
class _StockEquipamientoView extends StatelessWidget {
  const _StockEquipamientoView();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: Padding(
        padding: EdgeInsets.fromLTRB(
          AppSizes.paddingXl,
          AppSizes.paddingXl,
          AppSizes.paddingXl,
          AppSizes.paddingLarge,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // Header con estadísticas
            StockEquipamientoHeader(),
            SizedBox(height: AppSizes.spacingXl),

            // Tabla de vehículos
            Expanded(
              child: StockEquipamientoTable(),
            ),
          ],
        ),
      ),
    );
  }
}
