import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/features/turnos/presentation/bloc/plantillas_turnos_bloc.dart';
import 'package:ambutrack_web/features/turnos/presentation/bloc/plantillas_turnos_event.dart';
import 'package:ambutrack_web/features/turnos/presentation/widgets/gestion/plantilla_gestion_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Página de gestión de plantillas de turnos (layout tipo programa de gestión)
class PlantillasTurnosPage extends StatelessWidget {
  const PlantillasTurnosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocProvider<PlantillasTurnosBloc>(
        create: (BuildContext _) => getIt<PlantillasTurnosBloc>()..add(const PlantillasTurnosLoadRequested()),
        child: const Scaffold(
          backgroundColor: AppColors.backgroundLight,
          body: PlantillaGestionView(),
        ),
      ),
    );
  }
}
