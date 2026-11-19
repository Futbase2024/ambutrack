import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/features/almacen/presentation/bloc/producto/producto_bloc.dart';
import 'package:ambutrack_web/features/almacen/presentation/bloc/producto/producto_event.dart';
import 'package:ambutrack_web/features/almacen/presentation/bloc/stock/stock_bloc.dart';
import 'package:ambutrack_web/features/almacen/presentation/bloc/stock/stock_event.dart';
import 'package:ambutrack_web/features/almacen/presentation/widgets/gestion/stock_gestion_view.dart';
import 'package:ambutrack_web/features/vehiculos/presentation/bloc/vehiculos_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Página del Almacén General: stock de todas las categorías
/// (layout tipo programa de gestión)
class AlmacenDashboardPage extends StatelessWidget {
  const AlmacenDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: MultiBlocProvider(
        providers: <BlocProvider<dynamic>>[
          BlocProvider<StockBloc>(
            create: (BuildContext _) => getIt<StockBloc>()..add(const StockLoadAllRequested()),
          ),
          BlocProvider<ProductoBloc>(
            create: (BuildContext _) => getIt<ProductoBloc>()..add(const ProductoLoadAllRequested()),
          ),
          BlocProvider<VehiculosBloc>(create: (BuildContext _) => getIt<VehiculosBloc>()),
        ],
        child: const Scaffold(
          backgroundColor: AppColors.backgroundLight,
          body: StockGestionView(),
        ),
      ),
    );
  }
}
