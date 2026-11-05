import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/features/cuadrante/dotaciones/presentation/bloc/dotaciones_bloc_exports.dart';
import 'package:ambutrack_web/features/cuadrante/dotaciones/presentation/widgets/gestion/dotaciones_gestion_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Página de gestión de Dotaciones (layout tipo programa de gestión)
class DotacionesPage extends StatelessWidget {
  const DotacionesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocProvider<DotacionesBloc>.value(
        value: getIt<DotacionesBloc>(),
        child: const Scaffold(
          backgroundColor: AppColors.backgroundLight,
          body: DotacionesGestionView(),
        ),
      ),
    );
  }
}
