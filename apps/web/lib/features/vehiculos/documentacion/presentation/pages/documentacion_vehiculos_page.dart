import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/features/vehiculos/documentacion/presentation/bloc/documentacion_vehiculos_bloc.dart';
import 'package:ambutrack_web/features/vehiculos/documentacion/presentation/bloc/documentacion_vehiculos_event.dart';
import 'package:ambutrack_web/features/vehiculos/documentacion/presentation/widgets/gestion/documentacion_gestion_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Página de Documentación de Vehículos (layout tipo programa de gestión)
class DocumentacionVehiculosPage extends StatelessWidget {
  const DocumentacionVehiculosPage({super.key, this.vehiculoId});

  final String? vehiculoId;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocProvider<DocumentacionVehiculosBloc>(
        create: (BuildContext _) =>
            getIt<DocumentacionVehiculosBloc>()..add(const DocumentacionVehiculosLoadRequested()),
        child: Scaffold(
          backgroundColor: AppColors.backgroundLight,
          body: DocumentacionGestionView(vehiculoId: vehiculoId),
        ),
      ),
    );
  }
}
