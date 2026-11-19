import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/features/contratos/presentation/bloc/bloc.dart';
import 'package:ambutrack_web/features/contratos/presentation/widgets/gestion/contratos_gestion_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Página de gestión de contratos (layout tipo programa de gestión)
class ContratosPage extends StatelessWidget {
  const ContratosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocProvider<ContratoBloc>.value(
        value: getIt<ContratoBloc>(),
        child: const Scaffold(
          backgroundColor: AppColors.backgroundLight,
          body: ContratosGestionView(),
        ),
      ),
    );
  }
}
