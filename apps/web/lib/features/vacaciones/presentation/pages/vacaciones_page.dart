import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/features/vacaciones/presentation/bloc/vacaciones_bloc.dart';
import 'package:ambutrack_web/features/vacaciones/presentation/widgets/gestion/vacacion_gestion_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Página principal de gestión de Vacaciones (layout tipo programa de gestión)
class VacacionesPage extends StatelessWidget {
  const VacacionesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocProvider<VacacionesBloc>.value(
        value: getIt<VacacionesBloc>(),
        child: const Scaffold(
          backgroundColor: AppColors.backgroundLight,
          body: VacacionGestionView(),
        ),
      ),
    );
  }
}
