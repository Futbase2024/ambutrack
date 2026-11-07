import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/features/personal/horarios/presentation/bloc/registro_horario_bloc.dart';
import 'package:ambutrack_web/features/personal/horarios/presentation/widgets/gestion/fichajes/fichajes_gestion_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Página de fichajes con ubicaciones GPS (layout tipo programa de gestión)
class FichajesPage extends StatelessWidget {
  const FichajesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocProvider<RegistroHorarioBloc>(
        // Fichajes de los últimos 30 días por defecto
        create: (BuildContext _) => getIt<RegistroHorarioBloc>()..add(fichajesUltimos30Dias()),
        child: const Scaffold(
          backgroundColor: AppColors.backgroundLight,
          body: FichajesGestionView(),
        ),
      ),
    );
  }
}
