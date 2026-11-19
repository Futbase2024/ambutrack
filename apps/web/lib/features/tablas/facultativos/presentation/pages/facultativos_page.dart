import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/features/tablas/facultativos/presentation/bloc/facultativo_bloc.dart';
import 'package:ambutrack_web/features/tablas/facultativos/presentation/bloc/facultativo_event.dart';
import 'package:ambutrack_web/features/tablas/facultativos/presentation/widgets/gestion/facultativo_gestion_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Página principal de facultativos (layout tipo programa de gestión)
class FacultativosPage extends StatelessWidget {
  const FacultativosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocProvider<FacultativoBloc>(
        create: (BuildContext _) =>
            getIt<FacultativoBloc>()..add(const FacultativoLoadAllRequested()),
        child: const Scaffold(
          backgroundColor: AppColors.backgroundLight,
          body: FacultativoGestionView(),
        ),
      ),
    );
  }
}
