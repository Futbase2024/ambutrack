import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/features/tablas/centros_hospitalarios/presentation/bloc/centro_hospitalario_bloc.dart';
import 'package:ambutrack_web/features/tablas/centros_hospitalarios/presentation/bloc/centro_hospitalario_event.dart';
import 'package:ambutrack_web/features/tablas/centros_hospitalarios/presentation/widgets/gestion/centro_hospitalario_gestion_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Página de gestión de centros hospitalarios (layout tipo programa de gestión)
class CentrosHospitalariosPage extends StatelessWidget {
  const CentrosHospitalariosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocProvider<CentroHospitalarioBloc>(
        create: (BuildContext _) =>
            getIt<CentroHospitalarioBloc>()..add(const CentroHospitalarioLoadAllRequested()),
        child: const Scaffold(
          backgroundColor: AppColors.backgroundLight,
          body: CentroHospitalarioGestionView(),
        ),
      ),
    );
  }
}
