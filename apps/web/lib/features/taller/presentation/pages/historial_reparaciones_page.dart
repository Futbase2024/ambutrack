import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/features/taller/presentation/bloc/historial_reparaciones_bloc.dart';
import 'package:ambutrack_web/features/taller/presentation/bloc/historial_reparaciones_event.dart';
import 'package:ambutrack_web/features/taller/presentation/widgets/historial/historial_gestion_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Página de consulta del Historial de Reparaciones del taller
class HistorialReparacionesPage extends StatelessWidget {
  const HistorialReparacionesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocProvider<HistorialReparacionesBloc>(
        create: (BuildContext _) =>
            getIt<HistorialReparacionesBloc>()..add(const HistorialReparacionesLoadRequested()),
        child: const Scaffold(
          backgroundColor: AppColors.backgroundLight,
          body: HistorialGestionView(),
        ),
      ),
    );
  }
}
