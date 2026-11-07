import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/features/administracion/multicentro/presentation/bloc/multicentro_bloc.dart';
import 'package:ambutrack_web/features/administracion/multicentro/presentation/bloc/multicentro_event.dart';
import 'package:ambutrack_web/features/administracion/multicentro/presentation/widgets/multicentro_gestion_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Página Multi-centro / Multi-empresa (empresas de la tabla `empresas`)
class MulticentroPage extends StatelessWidget {
  const MulticentroPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocProvider<MulticentroBloc>(
        create: (BuildContext _) => getIt<MulticentroBloc>()..add(const MulticentroLoadRequested()),
        child: const Scaffold(
          backgroundColor: AppColors.backgroundLight,
          body: MulticentroGestionView(),
        ),
      ),
    );
  }
}
