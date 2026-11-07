import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/features/vehiculos/presentation/bloc/incidencia_vehiculo/incidencia_vehiculo_bloc.dart';
import 'package:ambutrack_web/features/vehiculos/presentation/bloc/incidencia_vehiculo/incidencia_vehiculo_event.dart';
import 'package:ambutrack_web/features/vehiculos/presentation/bloc/vehiculos_bloc.dart';
import 'package:ambutrack_web/features/vehiculos/presentation/bloc/vehiculos_event.dart';
import 'package:ambutrack_web/features/vehiculos/widgets/gestion/averia_gestion_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Página de Historial de Averías (layout tipo programa de gestión).
///
/// El BLoC de vehículos se usa solo para mostrar la matrícula de cada avería.
class HistorialAveriasPage extends StatelessWidget {
  const HistorialAveriasPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: MultiBlocProvider(
        providers: <BlocProvider<dynamic>>[
          BlocProvider<IncidenciaVehiculoBloc>(
            create: (BuildContext _) =>
                getIt<IncidenciaVehiculoBloc>()..add(const IncidenciaVehiculoEvent.started()),
          ),
          BlocProvider<VehiculosBloc>(
            create: (BuildContext _) => getIt<VehiculosBloc>()..add(const VehiculosLoadRequested()),
          ),
        ],
        child: const Scaffold(
          backgroundColor: AppColors.backgroundLight,
          body: AveriaGestionView(),
        ),
      ),
    );
  }
}
