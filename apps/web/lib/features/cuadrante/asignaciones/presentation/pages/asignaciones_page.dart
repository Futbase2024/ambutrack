import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/features/cuadrante/asignaciones/presentation/bloc/asignaciones/asignaciones_bloc.dart';
import 'package:ambutrack_web/features/cuadrante/asignaciones/presentation/widgets/gestion/asignaciones_gestion_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Página de gestión de Asignaciones de vehículos a turnos (layout tipo programa de gestión)
class AsignacionesPage extends StatelessWidget {
  const AsignacionesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocProvider<AsignacionesBloc>.value(
        value: getIt<AsignacionesBloc>(),
        child: const Scaffold(
          backgroundColor: AppColors.backgroundLight,
          body: AsignacionesGestionView(),
        ),
      ),
    );
  }
}
