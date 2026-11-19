import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/features/tablas/plantillas_equipamiento/presentation/bloc/plantillas_equipamiento_bloc.dart';
import 'package:ambutrack_web/features/tablas/plantillas_equipamiento/presentation/bloc/plantillas_equipamiento_event.dart';
import 'package:ambutrack_web/features/tablas/plantillas_equipamiento/presentation/widgets/plantillas_equipamiento_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Página de plantillas de equipamiento por tipo de vehículo (tabla maestra)
class PlantillasEquipamientoPage extends StatelessWidget {
  const PlantillasEquipamientoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocProvider<PlantillasEquipamientoBloc>(
        create: (BuildContext _) => getIt<PlantillasEquipamientoBloc>()..add(const PlantillasLoadRequested()),
        child: const Scaffold(
          backgroundColor: AppColors.backgroundLight,
          body: PlantillasEquipamientoView(),
        ),
      ),
    );
  }
}
