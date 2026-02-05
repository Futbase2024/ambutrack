import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/features/almacen/presentation/bloc/producto/producto_bloc.dart';
import 'package:ambutrack_web/features/almacen/presentation/bloc/producto/producto_event.dart';
import 'package:ambutrack_web/features/almacen/presentation/bloc/producto/producto_state.dart';
import 'package:ambutrack_web/features/almacen/presentation/widgets/productos_header.dart';
import 'package:ambutrack_web/features/almacen/presentation/widgets/productos_table.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Página de gestión de Productos del Almacén General
class ProductosPage extends StatelessWidget {
  const ProductosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocProvider<ProductoBloc>.value(
        value: getIt<ProductoBloc>(),
        child: const _ProductosView(),
      ),
    );
  }
}

/// Vista principal de productos
class _ProductosView extends StatefulWidget {
  const _ProductosView();

  @override
  State<_ProductosView> createState() => _ProductosViewState();
}

class _ProductosViewState extends State<_ProductosView> {
  @override
  void initState() {
    super.initState();
    // Cargar datos solo si el estado es Initial
    final ProductoBloc bloc = context.read<ProductoBloc>();
    if (bloc.state is ProductoInitial) {
      bloc.add(const ProductoLoadAllRequested());
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: Padding(
        padding: EdgeInsets.all(AppSizes.paddingXl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // Header personalizado con estadísticas y botón agregar
            ProductosHeader(),
            SizedBox(height: AppSizes.spacingXl),

            // Tabla ocupa el espacio restante
            Expanded(child: ProductosTable()),
          ],
        ),
      ),
    );
  }
}
