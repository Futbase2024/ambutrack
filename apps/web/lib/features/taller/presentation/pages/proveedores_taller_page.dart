import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/features/taller/presentation/bloc/proveedor_taller_bloc.dart';
import 'package:ambutrack_web/features/taller/presentation/bloc/proveedor_taller_event.dart';
import 'package:ambutrack_web/features/taller/presentation/widgets/gestion/proveedor_taller_gestion_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Página de gestión del Catálogo de Proveedores de Taller (layout tipo programa de gestión)
class ProveedoresTallerPage extends StatelessWidget {
  const ProveedoresTallerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocProvider<ProveedorTallerBloc>(
        create: (BuildContext _) =>
            getIt<ProveedorTallerBloc>()..add(const ProveedorTallerLoadRequested()),
        child: const Scaffold(
          backgroundColor: AppColors.backgroundLight,
          body: ProveedorTallerGestionView(),
        ),
      ),
    );
  }
}
