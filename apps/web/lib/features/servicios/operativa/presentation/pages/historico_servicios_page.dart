import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/features/servicios/operativa/presentation/bloc/traslados_consulta_bloc.dart';
import 'package:ambutrack_web/features/servicios/operativa/presentation/widgets/historico/historico_servicios_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Página "Histórico de Servicios" (consulta de servicios realizados)
class HistoricoServiciosPage extends StatelessWidget {
  const HistoricoServiciosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocProvider<TrasladosConsultaBloc>(
        create: (BuildContext _) => getIt<TrasladosConsultaBloc>(),
        child: const Scaffold(
          backgroundColor: AppColors.backgroundLight,
          body: HistoricoServiciosView(),
        ),
      ),
    );
  }
}
