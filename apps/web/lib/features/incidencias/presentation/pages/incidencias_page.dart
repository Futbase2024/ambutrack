import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/features/incidencias/presentation/bloc/incidencia/incidencia_bloc.dart';
import 'package:ambutrack_web/features/incidencias/presentation/bloc/incidencia/incidencia_event.dart';
import 'package:ambutrack_web/features/incidencias/presentation/widgets/gestion/incidencia_gestion_view.dart';
import 'package:ambutrack_web/features/vehiculos/presentation/bloc/vehiculos_bloc.dart';
import 'package:ambutrack_web/features/vehiculos/presentation/bloc/vehiculos_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nested/nested.dart';

/// Página de gestión de incidencias (layout tipo programa de gestión)
class IncidenciasPage extends StatelessWidget {
  const IncidenciasPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: MultiBlocProvider(
        providers: <SingleChildWidget>[
          BlocProvider<IncidenciaBloc>(
            create: (BuildContext _) => getIt<IncidenciaBloc>()..add(const IncidenciaLoadAllRequested()),
          ),
          BlocProvider<VehiculosBloc>(
            create: (BuildContext _) => getIt<VehiculosBloc>()..add(const VehiculosLoadRequested()),
          ),
        ],
        child: const Scaffold(
          backgroundColor: AppColors.backgroundLight,
          body: IncidenciaGestionView(),
        ),
      ),
    );
  }
}
