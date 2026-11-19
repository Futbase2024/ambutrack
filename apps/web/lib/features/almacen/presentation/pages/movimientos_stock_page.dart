import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/features/almacen/presentation/bloc/movimiento_stock/movimiento_stock_bloc.dart';
import 'package:ambutrack_web/features/almacen/presentation/bloc/movimiento_stock/movimiento_stock_event.dart';
import 'package:ambutrack_web/features/almacen/presentation/bloc/producto/producto_bloc.dart';
import 'package:ambutrack_web/features/almacen/presentation/bloc/producto/producto_event.dart';
import 'package:ambutrack_web/features/almacen/presentation/widgets/gestion/movimiento_gestion_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Página de Movimientos de Stock (historial de entradas, salidas, transferencias y ajustes)
class MovimientosStockPage extends StatelessWidget {
  const MovimientosStockPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: MultiBlocProvider(
        providers: <BlocProvider<dynamic>>[
          BlocProvider<MovimientoStockBloc>(
            create: (BuildContext _) => getIt<MovimientoStockBloc>()
              ..add(const MovimientoStockLoadAllRequested(limit: movimientosLimite)),
          ),
          BlocProvider<ProductoBloc>(
            create: (BuildContext _) => getIt<ProductoBloc>()..add(const ProductoLoadAllRequested()),
          ),
        ],
        child: const Scaffold(
          backgroundColor: AppColors.backgroundLight,
          body: MovimientoGestionView(),
        ),
      ),
    );
  }
}
