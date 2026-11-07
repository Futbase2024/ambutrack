import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/features/cuadrante/bases/presentation/bloc/bloc.dart';
import 'package:ambutrack_web/features/cuadrante/bases/presentation/widgets/gestion/bases_gestion_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Página de gestión de Bases/Centros (layout tipo programa de gestión)
class BasesPage extends StatelessWidget {
  const BasesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocProvider<BasesBloc>.value(
        value: getIt<BasesBloc>(),
        child: const Scaffold(
          backgroundColor: AppColors.backgroundLight,
          body: BasesGestionView(),
        ),
      ),
    );
  }
}
