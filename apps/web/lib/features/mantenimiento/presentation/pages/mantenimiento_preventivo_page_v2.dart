import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/features/mantenimiento/presentation/bloc/mantenimiento_bloc.dart';
import 'package:ambutrack_web/features/mantenimiento/presentation/bloc/mantenimiento_event.dart';
import 'package:ambutrack_web/features/mantenimiento/presentation/widgets/gestion/mantenimiento_gestion_view.dart';
import 'package:ambutrack_web/features/taller/presentation/bloc/taller_bloc.dart';
import 'package:ambutrack_web/features/taller/presentation/bloc/taller_event.dart';
import 'package:ambutrack_web/features/vehiculos/presentation/bloc/vehiculos_bloc.dart';
import 'package:ambutrack_web/features/vehiculos/presentation/bloc/vehiculos_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Página de Mantenimiento Preventivo (layout tipo programa de gestión)
class MantenimientoPreventivoPageV2 extends StatelessWidget {
  const MantenimientoPreventivoPageV2({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: MultiBlocProvider(
        providers: <BlocProvider<dynamic>>[
          BlocProvider<VehiculosBloc>(
            create: (BuildContext _) => getIt<VehiculosBloc>()..add(const VehiculosLoadRequested()),
          ),
          BlocProvider<MantenimientoBloc>(
            create: (BuildContext _) => getIt<MantenimientoBloc>()..add(const MantenimientoLoadRequested()),
          ),
          BlocProvider<TallerBloc>(
            create: (BuildContext _) => getIt<TallerBloc>()..add(const TallerLoadRequested()),
          ),
        ],
        child: const Scaffold(
          backgroundColor: AppColors.backgroundLight,
          body: MantenimientoGestionView(),
        ),
      ),
    );
  }
}
