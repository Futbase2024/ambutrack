import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/features/tablas/motivos_cancelacion/presentation/bloc/motivo_cancelacion_bloc.dart';
import 'package:ambutrack_web/features/tablas/motivos_cancelacion/presentation/bloc/motivo_cancelacion_event.dart';
import 'package:ambutrack_web/features/tablas/motivos_cancelacion/presentation/widgets/gestion/motivo_cancelacion_gestion_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Página de gestión de motivos de cancelación (layout tipo programa de gestión)
class MotivosCancelacionPage extends StatelessWidget {
  const MotivosCancelacionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocProvider<MotivoCancelacionBloc>(
        create: (BuildContext _) => getIt<MotivoCancelacionBloc>()..add(const MotivoCancelacionLoadRequested()),
        child: const Scaffold(
          backgroundColor: AppColors.backgroundLight,
          body: MotivoCancelacionGestionView(),
        ),
      ),
    );
  }
}
