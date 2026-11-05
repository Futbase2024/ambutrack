import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion_frame/gestion_frame.dart';
import 'package:ambutrack_web/features/almacen/presentation/bloc/producto/producto_bloc.dart';
import 'package:ambutrack_web/features/almacen/presentation/bloc/stock/stock_bloc.dart';
import 'package:ambutrack_web/features/almacen/presentation/bloc/stock/stock_state.dart';
import 'package:ambutrack_web/features/almacen/presentation/widgets/stock_entrada_form_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Categorías mostradas en las pestañas del almacén (en orden)
const List<CategoriaProducto> almacenCategoriasTabs = <CategoriaProducto>[
  CategoriaProducto.medicacion,
  CategoriaProducto.electromedicina,
  CategoriaProducto.fungibles,
  CategoriaProducto.gasesMedicinales,
  CategoriaProducto.otros,
];

/// Barra de herramientas compacta del almacén general
class AlmacenHeader extends StatelessWidget {
  const AlmacenHeader({required this.tabController, super.key});

  /// Controlador de pestañas para preseleccionar la categoría del formulario
  final TabController tabController;

  @override
  Widget build(BuildContext context) {
    return GestionToolbar(
      title: 'Almacén General',
      icon: Icons.warehouse,
      groups: <List<GestionToolbarAction>>[
        <GestionToolbarAction>[
          GestionToolbarAction(
            icon: Icons.add,
            label: 'Nueva Entrada',
            primary: true,
            onPressed: () => _nuevaEntrada(context),
          ),
        ],
      ],
    );
  }

  Future<void> _nuevaEntrada(BuildContext context) async {
    final int tabIndex = tabController.index;
    debugPrint('🚀 Abriendo formulario de nueva entrada... (Tab: $tabIndex)');

    final StockBloc stockBloc = context.read<StockBloc>();
    final ProductoBloc productoBloc = context.read<ProductoBloc>();

    // Mapear índice de tab a categoría
    CategoriaProducto categoriaInicial;
    switch (tabIndex) {
      case 0:
        categoriaInicial = CategoriaProducto.medicacion;
      case 1:
        categoriaInicial = CategoriaProducto.electromedicina;
      case 2:
        categoriaInicial = CategoriaProducto.materialAmbulancia;
      default:
        categoriaInicial = CategoriaProducto.medicacion;
    }

    debugPrint('📦 Categoría preseleccionada: ${categoriaInicial.label}');

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return MultiBlocProvider(
          providers: <BlocProvider<dynamic>>[
            BlocProvider<StockBloc>.value(value: stockBloc),
            BlocProvider<ProductoBloc>.value(value: productoBloc),
          ],
          child: StockEntradaFormDialog(categoriaInicial: categoriaInicial),
        );
      },
    );
  }
}

/// Pestañas compactas de categorías del almacén
class AlmacenCategoryTabs extends StatelessWidget {
  const AlmacenCategoryTabs({required this.controller, super.key});

  final TabController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      decoration: const BoxDecoration(
        color: AppColors.gray50,
        border: Border(bottom: BorderSide(color: AppColors.gray200)),
      ),
      child: TabBar(
        controller: controller,
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.textSecondaryLight,
        indicatorColor: AppColors.primary,
        dividerColor: Colors.transparent,
        labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        tabs: <Widget>[
          for (final CategoriaProducto c in almacenCategoriasTabs)
            Tab(
              height: 38,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(c.icon, style: const TextStyle(fontSize: 16)),
                  const SizedBox(width: 6),
                  Text(c.label),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// Barra de estado con las estadísticas del stock (antes tarjetas de la cabecera)
class AlmacenStatusBar extends StatelessWidget {
  const AlmacenStatusBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StockBloc, StockState>(
      builder: (BuildContext context, StockState state) {
        String total = '-';
        String disponible = '-';
        String stockBajo = '-';
        String reservado = '-';

        if (state is StockLoaded) {
          total = '${state.stocks.length}';
          disponible = '${state.stocks.where((StockEntity s) => s.cantidadActual > 0).length}';
          stockBajo = '${state.stocks.where((StockEntity s) => s.bajoCantidadMinima).length}';
          reservado = '${state.stocks.where((StockEntity s) => s.cantidadReservada > 0).length}';
        }

        return GestionStatusBar(
          items: <String>[
            'Total stock: $total',
            'Disponible: $disponible',
            'Stock bajo: $stockBajo',
            'Reservado: $reservado',
          ],
        );
      },
    );
  }
}
