import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/features/servicios/operativa/presentation/bloc/programacion_recurrente_bloc.dart';
import 'package:ambutrack_web/features/servicios/operativa/presentation/bloc/programacion_recurrente_event.dart';
import 'package:ambutrack_web/features/servicios/operativa/presentation/widgets/recurrente/recurrente_gestion_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Página "Programación Recurrente" (servicios con recurrencia activa)
class ProgramacionRecurrentePage extends StatelessWidget {
  const ProgramacionRecurrentePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocProvider<ProgramacionRecurrenteBloc>(
        create: (BuildContext _) =>
            getIt<ProgramacionRecurrenteBloc>()..add(const ProgramacionLoadRequested()),
        child: const Scaffold(
          backgroundColor: AppColors.backgroundLight,
          body: RecurrenteGestionView(),
        ),
      ),
    );
  }
}
