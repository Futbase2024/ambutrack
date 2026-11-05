import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/features/vehiculos/presentation/bloc/consumo_combustible/consumo_combustible_bloc.dart';
import 'package:ambutrack_web/features/vehiculos/presentation/bloc/consumo_combustible/consumo_combustible_event.dart';
import 'package:ambutrack_web/features/vehiculos/widgets/gestion/consumo_gestion_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Página de Consumo y Kilometraje (layout tipo programa de gestión).
///
/// Gestiona los registros de consumo de combustible de la flota: filtrado por
/// vehículo y rango de fechas, estadísticas en la barra de estado y CRUD.
class ConsumoKmPage extends StatelessWidget {
  const ConsumoKmPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocProvider<ConsumoCombustibleBloc>(
        create: (BuildContext _) =>
            getIt<ConsumoCombustibleBloc>()..add(const ConsumoCombustibleEvent.started()),
        child: const Scaffold(
          backgroundColor: AppColors.backgroundLight,
          body: ConsumoGestionView(),
        ),
      ),
    );
  }
}
