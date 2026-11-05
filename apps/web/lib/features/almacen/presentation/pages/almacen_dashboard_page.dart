import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/core/theme/app_text_styles.dart';
import 'package:ambutrack_web/core/widgets/badges/status_badge.dart';
import 'package:ambutrack_web/core/widgets/gestion_frame/gestion_frame.dart';
import 'package:ambutrack_web/core/widgets/tables/app_data_grid_v5.dart';
import 'package:ambutrack_web/features/almacen/presentation/bloc/producto/producto_bloc.dart';
import 'package:ambutrack_web/features/almacen/presentation/bloc/producto/producto_event.dart';
import 'package:ambutrack_web/features/almacen/presentation/bloc/producto/producto_state.dart';
import 'package:ambutrack_web/features/almacen/presentation/bloc/stock/stock_bloc.dart';
import 'package:ambutrack_web/features/almacen/presentation/bloc/stock/stock_event.dart';
import 'package:ambutrack_web/features/almacen/presentation/bloc/stock/stock_state.dart';
import 'package:ambutrack_web/features/almacen/presentation/widgets/almacen_header.dart';
import 'package:ambutrack_web/features/almacen/presentation/widgets/stock_edit_form_dialog.dart';
import 'package:ambutrack_web/features/almacen/presentation/widgets/stock_transferencia_form_dialog.dart';
import 'package:ambutrack_web/features/vehiculos/presentation/bloc/vehiculos_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

/// Dashboard principal del almacén general dividido en 5 categorías
///
/// Muestra el stock filtrado por categoría usando pestañas (tabs):
/// - 💊 Medicación
/// - ⚡ Electromedicina
/// - 🩹 Material Fungible
/// - 🫁 Gases Medicinales
/// - 📦 Otros
class AlmacenDashboardPage extends StatelessWidget {
  const AlmacenDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: <BlocProvider<dynamic>>[
        BlocProvider<StockBloc>(create: (_) => getIt<StockBloc>()),
        BlocProvider<ProductoBloc>(create: (_) => getIt<ProductoBloc>()),
        BlocProvider<VehiculosBloc>(create: (_) => getIt<VehiculosBloc>()),
      ],
      child: const _AlmacenDashboardView(),
    );
  }
}

/// Vista interna del dashboard con estado
class _AlmacenDashboardView extends StatefulWidget {
  const _AlmacenDashboardView();

  @override
  State<_AlmacenDashboardView> createState() => _AlmacenDashboardViewState();
}

class _AlmacenDashboardViewState extends State<_AlmacenDashboardView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);

    // Cargar stock y productos al iniciar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StockBloc>().add(const StockLoadAllRequested());
      context.read<ProductoBloc>().add(const ProductoLoadAllRequested());
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.backgroundLight,
        body: GestionFrame(
          toolbar: AlmacenHeader(tabController: _tabController),
          filterBar: AlmacenCategoryTabs(controller: _tabController),
          statusBar: const AlmacenStatusBar(),
          contentPadding: const EdgeInsets.all(AppSizes.paddingMedium),
          content: TabBarView(
            controller: _tabController,
            children: <Widget>[
              for (final CategoriaProducto c in almacenCategoriasTabs) _StockTabView(categoria: c),
            ],
          ),
        ),
      ),
    );
  }
}

/// Vista de tab para mostrar stock de una categoría específica
class _StockTabView extends StatefulWidget {
  const _StockTabView({required this.categoria});

  final CategoriaProducto categoria;

  @override
  State<_StockTabView> createState() => _StockTabViewState();
}

class _StockTabViewState extends State<_StockTabView> {
  String _searchQuery = '';
  int? _sortColumnIndex;
  bool _sortAscending = true;
  int _currentPage = 0;
  static const int _itemsPerPage = 25;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StockBloc, StockState>(
      builder: (BuildContext context, StockState stockState) {
        if (stockState is StockLoading) {
          return _buildLoadingView();
        }

        if (stockState is StockError) {
          return _buildErrorView(stockState.message);
        }

        if (stockState is StockLoaded) {
          // Obtener productos para filtrar por categoría
          return BlocBuilder<ProductoBloc, ProductoState>(
            builder: (BuildContext context, ProductoState productoState) {
              if (productoState is! ProductoLoaded) {
                return _buildLoadingView();
              }

              // Filtrar productos por categoría
              final List<ProductoEntity> productosCategoria = productoState.productos
                  .where((ProductoEntity p) => p.categoria == widget.categoria)
                  .toList();

              // Crear mapa de productos para lookup eficiente
              final Map<String, ProductoEntity> productosMap = <String, ProductoEntity>{
                for (final ProductoEntity p in productosCategoria) p.id: p,
              };

              // Crear Set de IDs para filtrado eficiente
              final Set<String> productosIds = productosMap.keys.toSet();

              // Filtrar stock por productos de esta categoría
              List<StockEntity> stockFiltrado = stockState.stocks
                  .where((StockEntity s) => productosIds.contains(s.idProducto))
                  .toList();

              // Aplicar búsqueda
              if (_searchQuery.isNotEmpty) {
                final String query = _searchQuery.toLowerCase();
                stockFiltrado = stockFiltrado.where((StockEntity s) {
                  final ProductoEntity? producto = productosMap[s.idProducto];
                  if (producto == null) {
                    return false;
                  }

                  final String codigo = producto.codigo?.toLowerCase() ?? '';
                  final String nombre = producto.nombre.toLowerCase();
                  final String ubicacion = s.ubicacionFisica?.toLowerCase() ?? '';

                  return codigo.contains(query) ||
                      nombre.contains(query) ||
                      ubicacion.contains(query);
                }).toList();
              }

              // Aplicar ordenamiento
              stockFiltrado = _sortStock(stockFiltrado, productosMap);

              // Cálculo de paginación
              final int totalItems = stockFiltrado.length;
              final int totalPages = (totalItems / _itemsPerPage).ceil();
              final int startIndex = _currentPage * _itemsPerPage;
              final int endIndex = (startIndex + _itemsPerPage).clamp(0, totalItems);
              final List<StockEntity> stockPaginado = totalItems > 0
                  ? stockFiltrado.sublist(startIndex, endIndex)
                  : <StockEntity>[];

              // Mostrar vista vacía si no hay productos o si no hay stock
              if (productosCategoria.isEmpty || stockFiltrado.isEmpty) {
                return _buildEmptyView();
              }

              return _buildStockTable(
                stockPaginado,
                productosMap,
                totalItems,
                totalPages,
              );
            },
          );
        }

        return _buildEmptyView();
      },
    );
  }

  /// Ordena el stock según columna seleccionada
  List<StockEntity> _sortStock(
    List<StockEntity> stocks,
    Map<String, ProductoEntity> productosMap,
  ) {
    if (_sortColumnIndex == null) {
      return stocks;
    }

    final List<StockEntity> sorted = List<StockEntity>.from(stocks)
      ..sort((StockEntity a, StockEntity b) {
        int comparison = 0;

        switch (_sortColumnIndex) {
          case 0: // Producto
            final String nombreA = productosMap[a.idProducto]?.nombre ?? '';
            final String nombreB = productosMap[b.idProducto]?.nombre ?? '';
            comparison = nombreA.compareTo(nombreB);
          case 1: // Cantidad
            comparison = a.cantidadActual.compareTo(b.cantidadActual);
          case 2: // Mín/Máx
            comparison = a.cantidadMinima.compareTo(b.cantidadMinima);
          case 3: // Ubicación
            final String ubicA = a.ubicacionFisica ?? '';
            final String ubicB = b.ubicacionFisica ?? '';
            comparison = ubicA.compareTo(ubicB);
          default:
            comparison = 0;
        }

        if (_sortAscending) {
          return comparison;
        } else {
          return -comparison;
        }
      });

    return sorted;
  }

  /// Vista de carga
  Widget _buildLoadingView() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingXl),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radius),
        border: Border.all(color: AppColors.gray200),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            CircularProgressIndicator(),
            SizedBox(height: AppSizes.spacing),
            Text('Cargando stock...'),
          ],
        ),
      ),
    );
  }

  /// Vista de error
  Widget _buildErrorView(String message) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingXl),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radius),
        border: Border.all(color: AppColors.error),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Icon(Icons.error_outline, color: AppColors.error, size: 48),
            const SizedBox(height: AppSizes.spacing),
            Text(
              'Error al cargar stock',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: AppSizes.spacingSmall),
            Text(
              message,
              style: AppTextStyles.bodySecondary,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Vista vacía
  Widget _buildEmptyView() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingXl),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radius),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              widget.categoria.icon,
              style: const TextStyle(fontSize: 64),
            ),
            const SizedBox(height: AppSizes.spacing),
            Text(
              'No hay stock registrado',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimaryLight,
              ),
            ),
            const SizedBox(height: AppSizes.spacingSmall),
            Text(
              'Agrega tu primer producto de ${widget.categoria.label.toLowerCase()}',
              style: AppTextStyles.bodySecondary,
            ),
          ],
        ),
      ),
    );
  }

  /// Tabla de stock con formato profesional
  Widget _buildStockTable(
    List<StockEntity> stocks,
    Map<String, ProductoEntity> productosMap,
    int totalItems,
    int totalPages,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        // Header con búsqueda
        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                'Stock de ${widget.categoria.label}',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimaryLight,
                ),
              ),
            ),
            SizedBox(
              width: 300,
              child: _SearchField(
                searchQuery: _searchQuery,
                onSearchChanged: (String query) {
                  setState(() {
                    _searchQuery = query;
                    _currentPage = 0;
                  });
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSizes.spacing),

        // Info de resultados
        if (_searchQuery.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSizes.spacing),
            child: Text(
              'Mostrando $totalItems resultados',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppColors.textSecondaryLight,
              ),
            ),
          ),

        // Tabla con AppDataGridV5
        Expanded(
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minWidth: constraints.maxWidth, // Usar todo el ancho disponible
                  ),
                  child: SizedBox(
                    width: constraints.maxWidth,
                    child: AppDataGridV5<StockEntity>(
                      columns: _getColumnsForCategory(),
                      rows: stocks,
                      buildCells: (StockEntity stock) => _buildCellsForCategory(stock, productosMap),
                      sortColumnIndex: _sortColumnIndex,
                      sortAscending: _sortAscending,
                      onSort: (int columnIndex, {required bool ascending}) {
                        setState(() {
                          _sortColumnIndex = columnIndex;
                          _sortAscending = ascending;
                        });
                      },
                      rowHeight: 64,
                      outerBorderColor: AppColors.gray300,
                      emptyMessage: _searchQuery.isNotEmpty
                          ? 'No se encontraron productos con los filtros aplicados'
                          : 'No hay stock registrado para esta categoría',
                      onView: (StockEntity stock) => _transferirStock(context, stock),
                      onEdit: (StockEntity stock) => _editarStock(context, stock),
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        // Paginación
        const SizedBox(height: AppSizes.spacing),
        _buildPaginationControls(
          currentPage: _currentPage,
          totalPages: totalPages,
          totalItems: totalItems,
          onPageChanged: (int page) => setState(() => _currentPage = page),
        ),
      ],
    );
  }

  /// Obtiene las columnas según la categoría
  List<DataGridColumn> _getColumnsForCategory() {
    final List<DataGridColumn> commonColumns = <DataGridColumn>[
      const DataGridColumn(label: 'NOMBRE / COMERCIAL', flexWidth: 3, sortable: true),
      const DataGridColumn(label: 'CANTIDAD', flexWidth: 1.5, sortable: true),
      const DataGridColumn(label: 'MÍN/MÁX', flexWidth: 1.2, sortable: true),
      const DataGridColumn(label: 'UBICACIÓN', flexWidth: 1.5, sortable: true),
    ];

    switch (widget.categoria) {
      case CategoriaProducto.medicacion:
      case CategoriaProducto.fungibles:
      case CategoriaProducto.gasesMedicinales:
        return <DataGridColumn>[
          ...commonColumns,
          const DataGridColumn(label: 'LOTE', flexWidth: 1.5),
          const DataGridColumn(label: 'CADUCIDAD', flexWidth: 1.5),
          const DataGridColumn(label: 'ESTADO', flexWidth: 1.3),
        ];

      case CategoriaProducto.electromedicina:
        return <DataGridColumn>[
          ...commonColumns,
          const DataGridColumn(label: 'Nº SERIE', flexWidth: 1.8),
          const DataGridColumn(label: 'ESTADO', flexWidth: 1.3),
        ];

      case CategoriaProducto.materialAmbulancia:
        return <DataGridColumn>[
          ...commonColumns,
          const DataGridColumn(label: 'RESERVADO', flexWidth: 1.5),
          const DataGridColumn(label: 'ESTADO', flexWidth: 1.3),
        ];

      case CategoriaProducto.otros:
        return <DataGridColumn>[
          ...commonColumns,
          const DataGridColumn(label: 'ESTADO', flexWidth: 1.3),
        ];
    }
  }

  /// Construye las celdas según la categoría
  List<DataGridCell> _buildCellsForCategory(
    StockEntity stock,
    Map<String, ProductoEntity> productosMap,
  ) {
    final ProductoEntity? producto = productosMap[stock.idProducto];
    final String productoNombre = producto?.nombre ?? 'Producto no encontrado';
    final String? productoComercial = producto?.nombreComercial;

    // Celdas comunes
    final List<DataGridCell> commonCells = <DataGridCell>[
      DataGridCell(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              productoNombre,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimaryLight,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (productoComercial != null && productoComercial.isNotEmpty)
              Text(
                productoComercial,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppColors.textSecondaryLight,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
      ),
      DataGridCell(
        child: Text(
          '${stock.cantidadActual} unidades',
          style: AppTextStyles.body,
        ),
      ),
      DataGridCell(
        child: Text(
          '${stock.cantidadMinima}/${stock.cantidadMaxima ?? '-'}',
          style: AppTextStyles.bodySecondary,
        ),
      ),
      DataGridCell(
        child: Text(
          stock.ubicacionFisica ?? '-',
          style: AppTextStyles.bodySecondary,
        ),
      ),
    ];

    // Celdas específicas por categoría
    switch (widget.categoria) {
      case CategoriaProducto.medicacion:
      case CategoriaProducto.fungibles:
      case CategoriaProducto.gasesMedicinales:
        return <DataGridCell>[
          ...commonCells,
          DataGridCell(
            child: Text(
              stock.lote ?? '-',
              style: AppTextStyles.bodySecondary,
            ),
          ),
          DataGridCell(
            child: Text(
              stock.fechaCaducidad?.toString().substring(0, 10) ?? '-',
              style: AppTextStyles.bodySecondary,
            ),
          ),
          DataGridCell(child: _buildEstadoBadge(stock)),
        ];

      case CategoriaProducto.electromedicina:
        return <DataGridCell>[
          ...commonCells,
          DataGridCell(
            child: Text(
              stock.numeroSerie ?? '-',
              style: AppTextStyles.bodySecondary,
            ),
          ),
          DataGridCell(child: _buildEstadoBadge(stock)),
        ];

      case CategoriaProducto.materialAmbulancia:
        return <DataGridCell>[
          ...commonCells,
          DataGridCell(
            child: Text(
              '${stock.cantidadReservada}',
              style: AppTextStyles.bodySecondary,
            ),
          ),
          DataGridCell(child: _buildEstadoBadge(stock)),
        ];

      case CategoriaProducto.otros:
        return <DataGridCell>[
          ...commonCells,
          DataGridCell(child: _buildEstadoBadge(stock)),
        ];
    }
  }

  /// Badge de estado del stock con StatusBadge
  Widget _buildEstadoBadge(StockEntity stock) {
    if (stock.caducado) {
      return const Align(
        alignment: Alignment.centerLeft,
        child: StatusBadge(
          label: 'CADUCADO',
          type: StatusBadgeType.error,
        ),
      );
    }

    if (stock.proximoACaducar) {
      return const Align(
        alignment: Alignment.centerLeft,
        child: StatusBadge(
          label: 'PROX. CAD.',
          type: StatusBadgeType.warning,
        ),
      );
    }

    if (stock.bajoCantidadMinima) {
      return const Align(
        alignment: Alignment.centerLeft,
        child: StatusBadge(
          label: 'BAJO',
          type: StatusBadgeType.warning,
        ),
      );
    }

    return const Align(
      alignment: Alignment.centerLeft,
      child: StatusBadge(
        label: 'OK',
        type: StatusBadgeType.success,
      ),
    );
  }

  /// Construye controles de paginación profesional
  Widget _buildPaginationControls({
    required int currentPage,
    required int totalPages,
    required int totalItems,
    required void Function(int) onPageChanged,
  }) {
    final int startItem = totalItems == 0 ? 0 : currentPage * _itemsPerPage + 1;
    final int endItem = totalItems == 0
        ? 0
        : ((currentPage + 1) * _itemsPerPage).clamp(0, totalItems);

    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingMedium),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          // Info de elementos mostrados
          Text(
            'Mostrando $startItem-$endItem de $totalItems items',
            style: AppTextStyles.bodySmallSecondary,
          ),

          // Controles de navegación
          Row(
            children: <Widget>[
              // Primera página
              _PaginationButton(
                onPressed: currentPage > 0 ? () => onPageChanged(0) : null,
                icon: Icons.first_page,
                tooltip: 'Primera página',
              ),
              const SizedBox(width: AppSizes.spacingSmall),

              // Página anterior
              _PaginationButton(
                onPressed: currentPage > 0 ? () => onPageChanged(currentPage - 1) : null,
                icon: Icons.chevron_left,
                tooltip: 'Página anterior',
              ),
              const SizedBox(width: AppSizes.spacing),

              // Indicador de página actual (badge azul)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.paddingMedium,
                  vertical: AppSizes.spacingSmall,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                ),
                child: Text(
                  'Página ${currentPage + 1} de ${totalPages > 0 ? totalPages : 1}',
                  style: GoogleFonts.inter(
                    fontSize: AppSizes.fontSmall,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: AppSizes.spacing),

              // Página siguiente
              _PaginationButton(
                onPressed: currentPage < totalPages - 1 ? () => onPageChanged(currentPage + 1) : null,
                icon: Icons.chevron_right,
                tooltip: 'Página siguiente',
              ),
              const SizedBox(width: AppSizes.spacingSmall),

              // Última página
              _PaginationButton(
                onPressed: currentPage < totalPages - 1 ? () => onPageChanged(totalPages - 1) : null,
                icon: Icons.last_page,
                tooltip: 'Última página',
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Editar stock
  Future<void> _editarStock(BuildContext context, StockEntity stock) async {
    debugPrint('✏️ Abriendo formulario de edición para stock: ${stock.id}');

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return MultiBlocProvider(
          providers: <BlocProvider<dynamic>>[
            BlocProvider<StockBloc>.value(value: context.read<StockBloc>()),
            BlocProvider<ProductoBloc>.value(value: context.read<ProductoBloc>()),
          ],
          child: StockEditFormDialog(stock: stock),
        );
      },
    );
  }

  /// Transferir stock
  Future<void> _transferirStock(BuildContext context, StockEntity stock) async {
    debugPrint('🔄 Abriendo formulario de transferencia para stock: ${stock.id}');

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return MultiBlocProvider(
          providers: <BlocProvider<dynamic>>[
            BlocProvider<StockBloc>.value(value: context.read<StockBloc>()),
            BlocProvider<ProductoBloc>.value(value: context.read<ProductoBloc>()),
            BlocProvider<VehiculosBloc>.value(value: context.read<VehiculosBloc>()),
          ],
          child: StockTransferenciaFormDialog(stock: stock),
        );
      },
    );
  }
}

/// Campo de búsqueda reutilizable
class _SearchField extends StatefulWidget {
  const _SearchField({
    required this.searchQuery,
    required this.onSearchChanged,
  });

  final String searchQuery;
  final void Function(String) onSearchChanged;

  @override
  State<_SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<_SearchField> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.searchQuery);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      onChanged: widget.onSearchChanged,
      decoration: InputDecoration(
        hintText: 'Buscar producto...',
        prefixIcon: const Icon(Icons.search, size: 20, color: AppColors.textSecondaryLight),
        suffixIcon: _controller.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear, size: 18, color: AppColors.textSecondaryLight),
                onPressed: () {
                  _controller.clear();
                  widget.onSearchChanged('');
                },
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
          borderSide: const BorderSide(color: AppColors.gray300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
          borderSide: const BorderSide(color: AppColors.gray300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSizes.paddingMedium,
          vertical: AppSizes.paddingSmall,
        ),
        isDense: true,
      ),
      style: GoogleFonts.inter(
        fontSize: 14,
        color: AppColors.textPrimaryLight,
      ),
    );
  }
}

/// Botón de paginación reutilizable
class _PaginationButton extends StatelessWidget {
  const _PaginationButton({
    required this.onPressed,
    required this.icon,
    required this.tooltip,
  });

  final VoidCallback? onPressed;
  final IconData icon;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        child: Container(
          padding: const EdgeInsets.all(AppSizes.spacingSmall),
          decoration: BoxDecoration(
            color: onPressed != null ? AppColors.primary.withValues(alpha: 0.1) : AppColors.gray200,
            borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
            border: Border.all(
              color: onPressed != null ? AppColors.primary.withValues(alpha: 0.3) : AppColors.gray300,
            ),
          ),
          child: Icon(
            icon,
            size: AppSizes.iconSmall,
            color: onPressed != null ? AppColors.primary : AppColors.gray400,
          ),
        ),
      ),
    );
  }
}
