import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/features/personal/presentation/bloc/historial_medico_bloc.dart';
import 'package:ambutrack_web/features/personal/presentation/bloc/historial_medico_event.dart';
import 'package:ambutrack_web/features/personal/presentation/widgets/gestion/historial_medico/historial_medico_gestion_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Página de Historial Médico del Personal (layout tipo programa de gestión)
class HistorialMedicoPage extends StatelessWidget {
  const HistorialMedicoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocProvider<HistorialMedicoBloc>(
        create: (BuildContext _) =>
            getIt<HistorialMedicoBloc>()..add(const HistorialMedicoLoadRequested()),
        child: const Scaffold(
          backgroundColor: AppColors.backgroundLight,
          body: HistorialMedicoGestionView(),
        ),
      ),
    );
  }
}
