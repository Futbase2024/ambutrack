import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/features/vehiculos/equipamiento/presentation/bloc/equipamiento_vehiculo_bloc.dart';
import 'package:ambutrack_web/features/vehiculos/equipamiento/presentation/bloc/equipamiento_vehiculo_event.dart';
import 'package:ambutrack_web/features/vehiculos/equipamiento/presentation/widgets/equipamiento_vehiculo_view.dart';
import 'package:ambutrack_web/features/vehiculos/presentation/bloc/vehiculos_bloc.dart';
import 'package:ambutrack_web/features/vehiculos/presentation/bloc/vehiculos_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Página de equipamiento de un vehículo concreto (layout tipo programa de gestión).
///
/// Muestra la dotación de su plantilla (según el tipo de vehículo) más los extras.
/// El BLoC de vehículos se usa para mostrar la matrícula y el tipo en el título.
class VehiculoStockPage extends StatelessWidget {
  const VehiculoStockPage({required this.vehiculoId, super.key});

  final String vehiculoId;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: MultiBlocProvider(
        providers: <BlocProvider<dynamic>>[
          BlocProvider<VehiculosBloc>(
            create: (BuildContext _) => getIt<VehiculosBloc>()..add(const VehiculosLoadRequested()),
          ),
          BlocProvider<EquipamientoVehiculoBloc>(
            create: (BuildContext _) =>
                getIt<EquipamientoVehiculoBloc>()..add(EquipamientoVehiculoLoadRequested(vehiculoId)),
          ),
        ],
        child: Scaffold(
          backgroundColor: AppColors.backgroundLight,
          body: EquipamientoVehiculoView(vehiculoId: vehiculoId),
        ),
      ),
    );
  }
}
