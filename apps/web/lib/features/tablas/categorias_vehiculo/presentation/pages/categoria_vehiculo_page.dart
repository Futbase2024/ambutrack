import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/features/tablas/categorias_vehiculo/presentation/bloc/categoria_vehiculo_bloc.dart';
import 'package:ambutrack_web/features/tablas/categorias_vehiculo/presentation/bloc/categoria_vehiculo_event.dart';
import 'package:ambutrack_web/features/tablas/categorias_vehiculo/presentation/widgets/gestion/categoria_vehiculo_gestion_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Página de gestión de categorías de vehículo (layout tipo programa de gestión)
class CategoriasVehiculoPage extends StatelessWidget {
  const CategoriasVehiculoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocProvider<CategoriaVehiculoBloc>(
        create: (BuildContext _) =>
            getIt<CategoriaVehiculoBloc>()..add(const CategoriaVehiculoLoadAllRequested()),
        child: const Scaffold(
          backgroundColor: AppColors.backgroundLight,
          body: CategoriaVehiculoGestionView(),
        ),
      ),
    );
  }
}
