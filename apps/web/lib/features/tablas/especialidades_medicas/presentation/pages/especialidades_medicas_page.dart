import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/features/tablas/especialidades_medicas/presentation/bloc/especialidad_bloc.dart';
import 'package:ambutrack_web/features/tablas/especialidades_medicas/presentation/bloc/especialidad_event.dart';
import 'package:ambutrack_web/features/tablas/especialidades_medicas/presentation/widgets/gestion/especialidad_gestion_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Página de gestión de especialidades médicas (layout tipo programa de gestión)
class EspecialidadesMedicasPage extends StatelessWidget {
  const EspecialidadesMedicasPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocProvider<EspecialidadBloc>(
        create: (BuildContext _) =>
            getIt<EspecialidadBloc>()..add(const EspecialidadLoadAllRequested()),
        child: const Scaffold(
          backgroundColor: AppColors.backgroundLight,
          body: EspecialidadGestionView(),
        ),
      ),
    );
  }
}
