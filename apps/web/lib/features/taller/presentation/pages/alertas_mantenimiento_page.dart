import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/features/taller/presentation/bloc/alertas_mantenimiento_bloc.dart';
import 'package:ambutrack_web/features/taller/presentation/bloc/alertas_mantenimiento_event.dart';
import 'package:ambutrack_web/features/taller/presentation/widgets/alertas/alertas_gestion_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Página de Alertas de Mantenimiento del taller (calculadas a partir de datos existentes)
class AlertasMantenimientoPage extends StatelessWidget {
  const AlertasMantenimientoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocProvider<AlertasMantenimientoBloc>(
        create: (BuildContext _) =>
            getIt<AlertasMantenimientoBloc>()..add(const AlertasMantenimientoLoadRequested()),
        child: const Scaffold(
          backgroundColor: AppColors.backgroundLight,
          body: AlertasGestionView(),
        ),
      ),
    );
  }
}
