import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/features/servicios/pacientes/presentation/bloc/pacientes_bloc.dart';
import 'package:ambutrack_web/features/servicios/pacientes/presentation/widgets/gestion/paciente_gestion_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Página de gestión de pacientes (layout tipo programa de gestión)
class PacientesPage extends StatelessWidget {
  const PacientesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocProvider<PacientesBloc>.value(
        value: getIt<PacientesBloc>(),
        child: const Scaffold(
          backgroundColor: AppColors.backgroundLight,
          body: PacienteGestionView(),
        ),
      ),
    );
  }
}
