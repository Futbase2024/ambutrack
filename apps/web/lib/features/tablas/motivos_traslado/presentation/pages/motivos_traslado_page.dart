import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/features/tablas/motivos_traslado/presentation/bloc/motivo_traslado_bloc.dart';
import 'package:ambutrack_web/features/tablas/motivos_traslado/presentation/bloc/motivo_traslado_event.dart';
import 'package:ambutrack_web/features/tablas/motivos_traslado/presentation/widgets/gestion/motivo_traslado_gestion_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Página de gestión de motivos de traslado (layout tipo programa de gestión)
class MotivosTrasladoPage extends StatelessWidget {
  const MotivosTrasladoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocProvider<MotivoTrasladoBloc>(
        create: (BuildContext _) => getIt<MotivoTrasladoBloc>()..add(const MotivoTrasladoLoadAllRequested()),
        child: const Scaffold(
          backgroundColor: AppColors.backgroundLight,
          body: MotivoTrasladoGestionView(),
        ),
      ),
    );
  }
}
