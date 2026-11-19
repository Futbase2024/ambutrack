import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/features/vehiculos/presentation/bloc/stock_equipamiento/stock_equipamiento_bloc.dart';
import 'package:ambutrack_web/features/vehiculos/presentation/bloc/stock_equipamiento/stock_equipamiento_event.dart';
import 'package:ambutrack_web/features/vehiculos/presentation/widgets/gestion/stock_equipamiento_gestion_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Página de Stock de Equipamiento de Vehículos (layout tipo programa de gestión)
class StockEquipamientoPage extends StatelessWidget {
  const StockEquipamientoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocProvider<StockEquipamientoBloc>(
        create: (BuildContext _) =>
            getIt<StockEquipamientoBloc>()..add(const StockEquipamientoLoadRequested()),
        child: const Scaffold(
          backgroundColor: AppColors.backgroundLight,
          body: StockEquipamientoGestionView(),
        ),
      ),
    );
  }
}
