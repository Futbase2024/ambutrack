import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/features/servicios/operativa/presentation/bloc/generacion_traslados_bloc.dart';
import 'package:ambutrack_web/features/servicios/operativa/presentation/bloc/traslados_consulta_bloc.dart';
import 'package:ambutrack_web/features/servicios/operativa/presentation/widgets/generar/generar_diarios_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Página "Generar Servicios Diarios"
class GenerarDiariosPage extends StatelessWidget {
  const GenerarDiariosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: MultiBlocProvider(
        providers: <BlocProvider<dynamic>>[
          BlocProvider<TrasladosConsultaBloc>(
            create: (BuildContext _) => getIt<TrasladosConsultaBloc>(),
          ),
          BlocProvider<GeneracionTrasladosBloc>(
            create: (BuildContext _) => getIt<GeneracionTrasladosBloc>(),
          ),
        ],
        child: const Scaffold(
          backgroundColor: AppColors.backgroundLight,
          body: GenerarDiariosView(),
        ),
      ),
    );
  }
}
