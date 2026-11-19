import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/features/personal/presentation/bloc/evaluacion_desempeno_bloc.dart';
import 'package:ambutrack_web/features/personal/presentation/bloc/evaluacion_desempeno_event.dart';
import 'package:ambutrack_web/features/personal/presentation/widgets/gestion/evaluaciones/evaluacion_gestion_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Página de Evaluaciones de Desempeño (layout tipo programa de gestión)
class EvaluacionesPage extends StatelessWidget {
  const EvaluacionesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocProvider<EvaluacionDesempenoBloc>(
        create: (BuildContext _) => getIt<EvaluacionDesempenoBloc>()..add(const EvaluacionDesempenoLoadRequested()),
        child: const Scaffold(
          backgroundColor: AppColors.backgroundLight,
          body: EvaluacionGestionView(),
        ),
      ),
    );
  }
}
