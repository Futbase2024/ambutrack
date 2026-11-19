import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/features/itv_revisiones/presentation/bloc/itv_revision_bloc.dart';
import 'package:ambutrack_web/features/itv_revisiones/presentation/bloc/itv_revision_event.dart';
import 'package:ambutrack_web/features/itv_revisiones/presentation/widgets/gestion/itv_gestion_view.dart';
import 'package:ambutrack_web/features/taller/presentation/bloc/taller_bloc.dart';
import 'package:ambutrack_web/features/taller/presentation/bloc/taller_event.dart';
import 'package:ambutrack_web/features/vehiculos/presentation/bloc/vehiculos_bloc.dart';
import 'package:ambutrack_web/features/vehiculos/presentation/bloc/vehiculos_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Página de gestión de ITV y Revisiones (layout tipo programa de gestión)
class ItvRevisionesPage extends StatelessWidget {
  const ItvRevisionesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: MultiBlocProvider(
        providers: <BlocProvider<dynamic>>[
          BlocProvider<VehiculosBloc>(
            create: (BuildContext _) => getIt<VehiculosBloc>()..add(const VehiculosLoadRequested()),
          ),
          BlocProvider<ItvRevisionBloc>(
            create: (BuildContext _) => getIt<ItvRevisionBloc>()..add(const ItvRevisionLoadRequested()),
          ),
          BlocProvider<TallerBloc>(
            create: (BuildContext _) => getIt<TallerBloc>()..add(const TallerLoadRequested()),
          ),
        ],
        child: const Scaffold(
          backgroundColor: AppColors.backgroundLight,
          body: ItvGestionView(),
        ),
      ),
    );
  }
}
