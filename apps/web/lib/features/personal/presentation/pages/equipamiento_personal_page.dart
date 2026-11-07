import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/features/personal/presentation/bloc/equipamiento_personal_bloc.dart';
import 'package:ambutrack_web/features/personal/presentation/bloc/equipamiento_personal_event.dart';
import 'package:ambutrack_web/features/personal/presentation/widgets/gestion/equipamiento/equipamiento_gestion_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Página de Equipamiento del Personal (layout tipo programa de gestión)
class EquipamientoPersonalPage extends StatelessWidget {
  const EquipamientoPersonalPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocProvider<EquipamientoPersonalBloc>(
        create: (BuildContext _) =>
            getIt<EquipamientoPersonalBloc>()..add(const EquipamientoPersonalLoadRequested()),
        child: const Scaffold(
          backgroundColor: AppColors.backgroundLight,
          body: EquipamientoGestionView(),
        ),
      ),
    );
  }
}
