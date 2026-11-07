import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/features/taller/presentation/bloc/orden_reparacion_bloc.dart';
import 'package:ambutrack_web/features/taller/presentation/bloc/orden_reparacion_event.dart';
import 'package:ambutrack_web/features/taller/presentation/widgets/gestion/orden_gestion_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Página de gestión de Órdenes de Reparación del taller (layout tipo programa de gestión)
class OrdenesReparacionPage extends StatelessWidget {
  const OrdenesReparacionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocProvider<OrdenReparacionBloc>(
        create: (BuildContext _) =>
            getIt<OrdenReparacionBloc>()..add(const OrdenReparacionLoadRequested()),
        child: const Scaffold(
          backgroundColor: AppColors.backgroundLight,
          body: OrdenGestionView(),
        ),
      ),
    );
  }
}
