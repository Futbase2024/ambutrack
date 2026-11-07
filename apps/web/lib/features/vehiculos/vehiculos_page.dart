import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/features/itv_revisiones/presentation/bloc/itv_revision_bloc.dart';
import 'package:ambutrack_web/features/itv_revisiones/presentation/bloc/itv_revision_event.dart';
import 'package:ambutrack_web/features/taller/presentation/bloc/orden_reparacion_bloc.dart';
import 'package:ambutrack_web/features/taller/presentation/bloc/orden_reparacion_event.dart';
import 'package:ambutrack_web/features/vehiculos/documentacion/presentation/bloc/documentacion_vehiculos_bloc.dart';
import 'package:ambutrack_web/features/vehiculos/documentacion/presentation/bloc/documentacion_vehiculos_event.dart';
import 'package:ambutrack_web/features/vehiculos/presentation/bloc/vehiculos_bloc.dart';
import 'package:ambutrack_web/features/vehiculos/presentation/bloc/vehiculos_event.dart';
import 'package:ambutrack_web/features/vehiculos/widgets/gestion/vehiculo_gestion_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Página de gestión de Vehículos (layout tipo programa de gestión).
///
/// Los BLoCs de ITV, documentación, reparaciones y stock alimentan las pestañas
/// de la ficha lateral y se crean de forma perezosa (al abrir cada pestaña).
class VehiculosPage extends StatelessWidget {
  const VehiculosPage({super.key});

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
          BlocProvider<DocumentacionVehiculosBloc>(
            create: (BuildContext _) =>
                getIt<DocumentacionVehiculosBloc>()..add(const DocumentacionVehiculosLoadRequested()),
          ),
          BlocProvider<OrdenReparacionBloc>(
            create: (BuildContext _) =>
                getIt<OrdenReparacionBloc>()..add(const OrdenReparacionLoadRequested()),
          ),
        ],
        child: const Scaffold(
          backgroundColor: AppColors.backgroundLight,
          body: VehiculoGestionView(),
        ),
      ),
    );
  }
}
