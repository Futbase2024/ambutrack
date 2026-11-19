import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/features/tablas/provincias/presentation/bloc/provincia_bloc.dart';
import 'package:ambutrack_web/features/tablas/provincias/presentation/bloc/provincia_event.dart';
import 'package:ambutrack_web/features/tablas/provincias/presentation/widgets/gestion/provincia_gestion_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Página de gestión de provincias (layout tipo programa de gestión)
class ProvinciasPage extends StatelessWidget {
  const ProvinciasPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocProvider<ProvinciaBloc>(
        create: (BuildContext _) => getIt<ProvinciaBloc>()..add(const ProvinciaLoadAllRequested()),
        child: const Scaffold(
          backgroundColor: AppColors.backgroundLight,
          body: ProvinciaGestionView(),
        ),
      ),
    );
  }
}
