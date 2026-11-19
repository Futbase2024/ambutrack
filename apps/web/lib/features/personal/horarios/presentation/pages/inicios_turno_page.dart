import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/features/personal/horarios/data/repositories/inicio_turno_validacion_repository_impl.dart';
import 'package:ambutrack_web/features/personal/horarios/presentation/cubit/inicio_turno_validacion_cubit.dart';
import 'package:ambutrack_web/features/personal/horarios/presentation/widgets/gestion/inicios_turno/inicios_turno_gestion_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Página de inicios de turno: validación por coordinación de los inicios fuera de base
class IniciosTurnoPage extends StatelessWidget {
  const IniciosTurnoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocProvider<InicioTurnoValidacionCubit>(
        create: (BuildContext _) => InicioTurnoValidacionCubit(InicioTurnoValidacionRepositoryImpl())..cargar(),
        child: const Scaffold(backgroundColor: AppColors.backgroundLight, body: IniciosTurnoGestionView()),
      ),
    );
  }
}
