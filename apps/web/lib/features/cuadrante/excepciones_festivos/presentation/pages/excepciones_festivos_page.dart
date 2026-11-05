import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/features/cuadrante/excepciones_festivos/presentation/bloc/excepciones_festivos_bloc_exports.dart';
import 'package:ambutrack_web/features/cuadrante/excepciones_festivos/presentation/widgets/gestion/excepciones_gestion_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Página de Excepciones y Festivos del Cuadrante (layout tipo programa de gestión)
class ExcepcionesFestivosPage extends StatelessWidget {
  const ExcepcionesFestivosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocProvider<ExcepcionesFestivosBloc>.value(
        value: getIt<ExcepcionesFestivosBloc>(),
        child: const Scaffold(
          backgroundColor: AppColors.backgroundLight,
          body: ExcepcionesGestionView(),
        ),
      ),
    );
  }
}
