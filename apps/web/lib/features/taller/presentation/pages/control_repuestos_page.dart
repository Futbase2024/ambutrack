import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/features/taller/presentation/bloc/control_repuestos_bloc.dart';
import 'package:ambutrack_web/features/taller/presentation/bloc/control_repuestos_event.dart';
import 'package:ambutrack_web/features/taller/presentation/widgets/repuestos/control_repuestos_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Página de consulta del Control de Repuestos del taller
class ControlRepuestosPage extends StatelessWidget {
  const ControlRepuestosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocProvider<ControlRepuestosBloc>(
        create: (BuildContext _) => getIt<ControlRepuestosBloc>()..add(const ControlRepuestosLoadRequested()),
        child: const Scaffold(
          backgroundColor: AppColors.backgroundLight,
          body: ControlRepuestosView(),
        ),
      ),
    );
  }
}
