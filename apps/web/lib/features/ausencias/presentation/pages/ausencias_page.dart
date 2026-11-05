import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/features/ausencias/presentation/bloc/ausencias_bloc.dart';
import 'package:ambutrack_web/features/ausencias/presentation/widgets/gestion/ausencia_gestion_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Página de gestión de Ausencias (layout tipo programa de gestión)
class AusenciasPage extends StatelessWidget {
  const AusenciasPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocProvider<AusenciasBloc>.value(
        value: getIt<AusenciasBloc>(),
        child: const Scaffold(
          backgroundColor: AppColors.backgroundLight,
          body: AusenciaGestionView(),
        ),
      ),
    );
  }
}
