import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/features/almacen/presentation/bloc/producto/producto_bloc.dart';
import 'package:ambutrack_web/features/almacen/presentation/bloc/producto/producto_event.dart';
import 'package:ambutrack_web/features/almacen/presentation/bloc/proveedores/proveedores_bloc.dart';
import 'package:ambutrack_web/features/almacen/presentation/widgets/gestion/proveedor_gestion_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Página de gestión de Proveedores del Almacén (layout tipo programa de gestión)
class ProveedoresPage extends StatelessWidget {
  const ProveedoresPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: MultiBlocProvider(
        providers: <BlocProvider<dynamic>>[
          // La carga inicial de proveedores la lanza la vista si el estado es Initial
          BlocProvider<ProveedoresBloc>.value(value: getIt<ProveedoresBloc>()),
          BlocProvider<ProductoBloc>(
            create: (BuildContext _) => getIt<ProductoBloc>()..add(const ProductoLoadAllRequested()),
          ),
        ],
        child: const Scaffold(
          backgroundColor: AppColors.backgroundLight,
          body: ProveedorGestionView(),
        ),
      ),
    );
  }
}
