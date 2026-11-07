import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/features/almacen/presentation/bloc/producto/producto_bloc.dart';
import 'package:ambutrack_web/features/almacen/presentation/bloc/proveedores/proveedores_bloc.dart';
import 'package:ambutrack_web/features/almacen/presentation/bloc/proveedores/proveedores_event.dart';
import 'package:ambutrack_web/features/almacen/presentation/widgets/gestion/producto_gestion_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Página de gestión de Productos del Almacén General (layout tipo programa de gestión)
class ProductosPage extends StatelessWidget {
  const ProductosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: MultiBlocProvider(
        providers: <BlocProvider<dynamic>>[
          // La carga inicial de productos la lanza la vista si el estado es Initial
          BlocProvider<ProductoBloc>.value(value: getIt<ProductoBloc>()),
          BlocProvider<ProveedoresBloc>(
            create: (BuildContext _) => getIt<ProveedoresBloc>()..add(const ProveedoresLoadRequested()),
          ),
        ],
        child: const Scaffold(
          backgroundColor: AppColors.backgroundLight,
          body: ProductoGestionView(),
        ),
      ),
    );
  }
}
