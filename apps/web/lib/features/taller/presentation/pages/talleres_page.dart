import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/features/taller/presentation/bloc/orden_reparacion_bloc.dart';
import 'package:ambutrack_web/features/taller/presentation/bloc/orden_reparacion_event.dart';
import 'package:ambutrack_web/features/taller/presentation/bloc/taller_bloc.dart';
import 'package:ambutrack_web/features/taller/presentation/bloc/taller_event.dart';
import 'package:ambutrack_web/features/taller/presentation/widgets/gestion/taller_gestion_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Página de gestión del Catálogo de Talleres (layout tipo programa de gestión)
class TalleresPage extends StatelessWidget {
  const TalleresPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: MultiBlocProvider(
        providers: <BlocProvider<dynamic>>[
          BlocProvider<TallerBloc>(
            create: (BuildContext _) =>
                getIt<TallerBloc>()..add(const TallerLoadRequested()),
          ),
          BlocProvider<OrdenReparacionBloc>(
            create: (BuildContext _) =>
                getIt<OrdenReparacionBloc>()..add(const OrdenReparacionLoadRequested()),
          ),
        ],
        child: const Scaffold(
          backgroundColor: AppColors.backgroundLight,
          body: TallerGestionView(),
        ),
      ),
    );
  }
}
