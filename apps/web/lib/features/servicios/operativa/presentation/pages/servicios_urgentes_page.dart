import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/features/servicios/operativa/presentation/bloc/traslados_consulta_bloc.dart';
import 'package:ambutrack_web/features/servicios/operativa/presentation/widgets/urgentes/servicios_urgentes_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Página "Servicios Urgentes" (traslados activos de alta prioridad)
class ServiciosUrgentesPage extends StatelessWidget {
  const ServiciosUrgentesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocProvider<TrasladosConsultaBloc>(
        create: (BuildContext _) => getIt<TrasladosConsultaBloc>(),
        child: const Scaffold(
          backgroundColor: AppColors.backgroundLight,
          body: ServiciosUrgentesView(),
        ),
      ),
    );
  }
}
