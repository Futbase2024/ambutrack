import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/features/tablas/localidades/presentation/bloc/localidad_bloc.dart';
import 'package:ambutrack_web/features/tablas/localidades/presentation/bloc/localidad_event.dart';
import 'package:ambutrack_web/features/tablas/localidades/presentation/widgets/gestion/localidad_gestion_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Página de gestión de localidades (layout tipo programa de gestión)
class LocalidadesPage extends StatelessWidget {
  const LocalidadesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocProvider<LocalidadBloc>(
        create: (BuildContext _) => getIt<LocalidadBloc>()..add(const LocalidadLoadAllRequested()),
        child: const Scaffold(
          backgroundColor: AppColors.backgroundLight,
          body: LocalidadGestionView(),
        ),
      ),
    );
  }
}
