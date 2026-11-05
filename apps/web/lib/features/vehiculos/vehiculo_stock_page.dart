import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/features/vehiculos/presentation/bloc/vehiculos_bloc.dart';
import 'package:ambutrack_web/features/vehiculos/presentation/bloc/vehiculos_event.dart';
import 'package:ambutrack_web/features/vehiculos/widgets/gestion/vehiculo_stock_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Página de stock de un vehículo concreto (layout tipo programa de gestión).
///
/// El BLoC de vehículos se usa para mostrar la matrícula/marca/modelo en el título.
class VehiculoStockPage extends StatelessWidget {
  const VehiculoStockPage({required this.vehiculoId, super.key});

  final String vehiculoId;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocProvider<VehiculosBloc>(
        create: (BuildContext _) => getIt<VehiculosBloc>()..add(const VehiculosLoadRequested()),
        child: Scaffold(
          backgroundColor: AppColors.backgroundLight,
          body: VehiculoStockView(vehiculoId: vehiculoId),
        ),
      ),
    );
  }
}
