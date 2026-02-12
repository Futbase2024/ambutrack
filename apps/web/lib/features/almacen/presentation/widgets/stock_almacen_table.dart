import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/core/widgets/badges/status_badge.dart';
import 'package:ambutrack_web/core/widgets/loading/app_loading_indicator.dart';
import 'package:ambutrack_web/core/widgets/tables/app_data_grid_v5.dart';
import 'package:ambutrack_web/features/almacen/presentation/bloc/producto/producto_bloc.dart';
import 'package:ambutrack_web/features/almacen/presentation/bloc/producto/producto_state.dart';
import 'package:ambutrack_web/features/almacen/presentation/bloc/stock/stock_bloc.dart';
import 'package:ambutrack_web/features/almacen/presentation/bloc/stock/stock_event.dart';
import 'package:ambutrack_web/features/almacen/presentation/bloc/stock/stock_state.dart';
import 'package:ambutrack_web/features/almacen/presentation/models/stock_view_mode.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

/// Widget de tabla para gestión de stock de almacén
class StockAlmacenTable extends StatefulWidget {
  const StockAlmacenTable({super.key});

  @override
  State<StockAlmacenTable> createState() => _StockAlmacenTableState();
}

class _StockAlmacenTableState extends State<StockAlmacenTable> {
  String _searchQuery = '';
  final int _sortColumnIndex = 0;
  final bool _sortAscending = true;
  int _currentPage = 0;
  static const int _itemsPerPage = 25;

  // Filtros avanzados
  String? _filtroProveedor;
  bool _soloConStock = false;
  bool _soloBajoMinimo = false;
  StockViewMode _vistaActual = StockViewMode.all;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductoBloc, ProductoState>(
      builder: (BuildContext context, ProductoState productoState) {
        // Obtener mapa de productos por ID para lookup rápido
        final Map<String, ProductoEntity> productosMap = productoState is ProductoLoaded
            ? <String, ProductoEntity>{for (final ProductoEntity p in productoState.productos) p.id: p}
            : <String, ProductoEntity>{};

        return BlocBuilder<StockBloc, StockState>(
          builder: (BuildContext context, StockState state) {
            if (state is StockLoading) {
              return const _LoadingView();
            }

            if (state is StockError) {
              return _ErrorView(message: state.message);
            }

            if (state is StockLoaded) {
              List<StockEntity> filtrados = _filterStock(state.stock);
              filtrados = _sortStock(filtrados);

              final int totalItems = filtrados.length;
              final int totalPages = (totalItems / _itemsPerPage).ceil();
              final int startIndex = _currentPage * _itemsPerPage;
              final int endIndex = (startIndex + _itemsPerPage).clamp(0, totalItems);
              final List<StockEntity> stockPaginado =
                  totalItems > 0 ? filtrados.sublist(startIndex, endIndex) : <StockEntity>[];

              return DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppSizes.radius),
              border: Border.all(color: AppColors.gray200),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                // Filtros y búsqueda
                _buildFiltersSection(state),

                const SizedBox(height: AppSizes.spacing),

                // Info de resultados
                if (state.stock.length != filtrados.length || _searchQuery.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingMedium),
                    child: Text(
                      'Mostrando ${filtrados.length} de ${state.stock.length} items',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: AppColors.textSecondaryLight,
                      ),
                    ),
                  ),

                const SizedBox(height: AppSizes.spacingSmall),

                // Tabla
                Expanded(
                  child: AppDataGridV5<StockEntity>(
                    columns: const <DataGridColumn>[
                      DataGridColumn(label: 'PRODUCTO', flexWidth: 2, sortable: true),
                      DataGridColumn(label: 'LOTE', sortable: true),
                      DataGridColumn(label: 'DISPONIBLE', sortable: true),
                      DataGridColumn(label: 'RESERVADA', sortable: true),
                      DataGridColumn(label: 'MÍNIMA', sortable: true),
                      DataGridColumn(label: 'CADUCIDAD', sortable: true),
                      DataGridColumn(label: 'UBICACIÓN', sortable: true),
                      DataGridColumn(label: 'PRECIO/U', sortable: true),
                      DataGridColumn(label: 'ESTADO', sortable: true),
                    ],
                    rows: stockPaginado,
                    buildCells: (StockEntity stock) => <DataGridCell>[
                      DataGridCell(child: _buildProductoCell(stock, productosMap)),
                      DataGridCell(child: _buildLoteCell(stock)),
                      DataGridCell(child: _buildDisponibleCell(stock)),
                      DataGridCell(child: _buildReservadaCell(stock)),
                      DataGridCell(child: _buildMinimaCell(stock)),
                      DataGridCell(child: _buildCaducidadCell(stock)),
                      DataGridCell(child: _buildUbicacionCell(stock)),
                      DataGridCell(child: _buildPrecioCell(stock)),
                      DataGridCell(child: _buildEstadoCell(stock)),
                    ],
                    emptyMessage: _searchQuery.isNotEmpty
                        ? 'No se encontraron items con los filtros aplicados'
                        : 'No hay stock registrado en el almacén',
                  ),
                ),

                const SizedBox(height: AppSizes.spacing),

                // Paginación
                _buildPaginationControls(
                  currentPage: _currentPage,
                  totalPages: totalPages,
                  totalItems: totalItems,
                  onPageChanged: (int page) {
                    setState(() {
                      _currentPage = page;
                    });
                  },
                ),
              ],
            ),
          );
            }

            return const SizedBox.shrink();
          },
        );
      },
    );
  }

  Widget _buildFiltersSection(StockLoaded state) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingMedium),
      decoration: const BoxDecoration(
        color: AppColors.gray50,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppSizes.radius),
          topRight: Radius.circular(AppSizes.radius),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Fila 1: Búsqueda y vistas rápidas
          Row(
            children: <Widget>[
              Expanded(
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
              const SizedBox(width: AppSizes.spacing),
              _buildQuickViewButton(
                label: 'Todos',
                icon: Icons.inventory_2,
                isActive: _vistaActual == StockViewMode.all,
                onTap: () {
                  setState(() {
                    _vistaActual = StockViewMode.all;
                    _soloBajoMinimo = false;
                    _currentPage = 0;
                  });
                },
              ),
              const SizedBox(width: AppSizes.spacingSmall),
              _buildQuickViewButton(
                label: 'Stock Bajo',
                icon: Icons.warning_amber,
                color: AppColors.warning,
                isActive: _vistaActual == StockViewMode.bajo,
                onTap: () {
                  setState(() {
                    _vistaActual = StockViewMode.bajo;
                    _soloBajoMinimo = true;
                    _currentPage = 0;
                  });
                },
              ),
              const SizedBox(width: AppSizes.spacingSmall),
              _buildQuickViewButton(
                label: 'Por Caducar',
                icon: Icons.schedule,
                color: AppColors.error,
                isActive: _vistaActual == StockViewMode.proximoACaducar,
                onTap: () {
                  setState(() {
                    _vistaActual = StockViewMode.proximoACaducar;
                    _currentPage = 0;
                  });
                  context.read<StockBloc>().add(const StockProximoACaducarLoadRequested());
                },
              ),
            ],
          ),

          const SizedBox(height: AppSizes.spacing),

          // Fila 2: Filtros adicionales
          Row(
            children: <Widget>[
              // Checkbox: Solo con stock
              InkWell(
                onTap: () {
                  setState(() {
                    _soloConStock = !_soloConStock;
                    _currentPage = 0;
                  });
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Checkbox(
                      value: _soloConStock,
                      onChanged: (bool? value) {
                        setState(() {
                          _soloConStock = value ?? false;
                          _currentPage = 0;
                        });
                      },
                      activeColor: AppColors.primary,
                    ),
                    Text(
                      'Solo con stock disponible',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: AppColors.textPrimaryLight,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: AppSizes.spacing),

              // Botón: Limpiar filtros
              if (_searchQuery.isNotEmpty ||
                  _filtroProveedor != null ||
                  _soloConStock ||
                  _soloBajoMinimo)
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _searchQuery = '';
                      _filtroProveedor = null;
                      _soloConStock = false;
                      _soloBajoMinimo = false;
                      _vistaActual = StockViewMode.all;
                      _currentPage = 0;
                    });
                    context.read<StockBloc>().add(const StockLoadRequested());
                  },
                  icon: const Icon(Icons.clear, size: 18),
                  label: const Text('Limpiar filtros'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.error,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickViewButton({
    required String label,
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
    Color? color,
  }) {
    final Color buttonColor = color ?? AppColors.primary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.paddingMedium,
          vertical: AppSizes.paddingSmall,
        ),
        decoration: BoxDecoration(
          color: isActive ? buttonColor.withValues(alpha: 0.1) : Colors.white,
          borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
          border: Border.all(
            color: isActive ? buttonColor : AppColors.gray300,
            width: isActive ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              icon,
              size: 18,
              color: isActive ? buttonColor : AppColors.textSecondaryLight,
            ),
            const SizedBox(width: AppSizes.spacingSmall),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                color: isActive ? buttonColor : AppColors.textSecondaryLight,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductoCell(StockEntity stock, Map<String, ProductoEntity> productosMap) {
    final ProductoEntity? producto = productosMap[stock.idProducto];
    final String nombreProducto = producto?.nombre ?? 'Producto no encontrado';
    final String? codigoProducto = producto?.codigo;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingSmall),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          // Nombre del producto
          Text(
            nombreProducto,
            style: GoogleFonts.inter(
              fontSize: AppSizes.fontSmall,
              color: AppColors.textPrimaryLight,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          // Código del producto (si existe)
          if (codigoProducto != null && codigoProducto.isNotEmpty) ...<Widget>[
            const SizedBox(height: 2),
            Text(
              codigoProducto,
              style: GoogleFonts.inter(
                fontSize: 11,
                color: AppColors.textSecondaryLight,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLoteCell(StockEntity stock) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingSmall),
      child: Text(
        stock.lote ?? '-',
        style: GoogleFonts.inter(
          fontSize: AppSizes.fontSmall,
          color: AppColors.textSecondaryLight,
        ),
      ),
    );
  }

  Widget _buildDisponibleCell(StockEntity stock) {
    final bool esBajo = stock.cantidadDisponible <= stock.cantidadMinima;

    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: esBajo
              ? AppColors.error.withValues(alpha: 0.1)
              : AppColors.success.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        ),
        child: Text(
          '${stock.cantidadDisponible}',
          style: GoogleFonts.inter(
            fontSize: AppSizes.fontSmall,
            fontWeight: FontWeight.w600,
            color: esBajo ? AppColors.error : AppColors.success,
          ),
        ),
      ),
    );
  }

  Widget _buildReservadaCell(StockEntity stock) {
    return Center(
      child: Text(
        '${stock.cantidadReservada}',
        style: GoogleFonts.inter(
          fontSize: AppSizes.fontSmall,
          color: stock.cantidadReservada > 0
              ? AppColors.warning
              : AppColors.textSecondaryLight,
          fontWeight: stock.cantidadReservada > 0 ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
    );
  }

  Widget _buildMinimaCell(StockEntity stock) {
    return Center(
      child: Text(
        '${stock.cantidadMinima}',
        style: GoogleFonts.inter(
          fontSize: AppSizes.fontSmall,
          color: AppColors.textSecondaryLight,
        ),
      ),
    );
  }

  Widget _buildCaducidadCell(StockEntity stock) {
    if (stock.fechaCaducidad == null) {
      return Center(
        child: Text(
          '-',
          style: GoogleFonts.inter(
            fontSize: AppSizes.fontSmall,
            color: AppColors.textSecondaryLight,
          ),
        ),
      );
    }

    final DateTime fechaCaducidad = stock.fechaCaducidad!;
    final DateTime now = DateTime.now();
    final int diasRestantes = fechaCaducidad.difference(now).inDays;

    Color color = AppColors.textSecondaryLight;
    if (diasRestantes < 0) {
      color = AppColors.error;
    } else if (diasRestantes <= 30) {
      color = AppColors.warning;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            DateFormat('dd/MM/yyyy').format(fechaCaducidad),
            style: GoogleFonts.inter(
              fontSize: AppSizes.fontSmall,
              color: color,
              fontWeight: diasRestantes <= 30 ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
          if (diasRestantes >= 0 && diasRestantes <= 30)
            Text(
              '($diasRestantes días)',
              style: GoogleFonts.inter(
                fontSize: 11,
                color: color,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildUbicacionCell(StockEntity stock) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingSmall),
      child: Text(
        stock.ubicacionFisica ?? '-',
        style: GoogleFonts.inter(
          fontSize: AppSizes.fontSmall,
          color: AppColors.textSecondaryLight,
        ),
      ),
    );
  }

  Widget _buildPrecioCell(StockEntity stock) {
    if (stock.precioUnitario == null) {
      return const Center(child: Text('-'));
    }

    return Center(
      child: Text(
        '${stock.precioUnitario!.toStringAsFixed(2)}€',
        style: GoogleFonts.inter(
          fontSize: AppSizes.fontSmall,
          color: AppColors.textPrimaryLight,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildEstadoCell(StockEntity stock) {
    if (!stock.activo) {
      return const Center(
        child: StatusBadge(
          label: 'Inactivo',
          type: StatusBadgeType.inactivo,
        ),
      );
    }

    // Determinar estado basado en stock
    final bool esBajo = stock.cantidadDisponible <= stock.cantidadMinima;
    final bool sinStock = stock.cantidadDisponible == 0;

    if (sinStock) {
      return const Center(
        child: StatusBadge(
          label: 'Sin Stock',
          type: StatusBadgeType.error,
        ),
      );
    }

    if (esBajo) {
      return const Center(
        child: StatusBadge(
          label: 'Stock Bajo',
          type: StatusBadgeType.warning,
        ),
      );
    }

    return const Center(
      child: StatusBadge(
        label: 'Disponible',
        type: StatusBadgeType.success,
      ),
    );
  }

  List<StockEntity> _filterStock(List<StockEntity> stock) {
    List<StockEntity> filtrados = stock;

    // Filtro de búsqueda
    if (_searchQuery.isNotEmpty) {
      final String query = _searchQuery.toLowerCase();
      filtrados = filtrados.where((StockEntity s) {
        return s.idProducto.toLowerCase().contains(query) ||
               (s.lote?.toLowerCase().contains(query) ?? false) ||
               (s.ubicacionFisica?.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    // Filtro: Solo con stock
    if (_soloConStock) {
      filtrados = filtrados.where((StockEntity s) => s.cantidadDisponible > 0).toList();
    }

    // Filtro: Solo bajo mínimo
    if (_soloBajoMinimo) {
      filtrados = filtrados.where((StockEntity s) =>
          s.cantidadDisponible <= s.cantidadMinima).toList();
    }

    // Filtro: Vista próximo a caducar
    if (_vistaActual == StockViewMode.proximoACaducar) {
      final DateTime fechaLimite = DateTime.now().add(const Duration(days: 30));
      filtrados = filtrados.where((StockEntity s) {
        if (s.fechaCaducidad == null) {
          return false;
        }
        return s.fechaCaducidad!.isBefore(fechaLimite) &&
               s.fechaCaducidad!.isAfter(DateTime.now());
      }).toList();
    }

    // Filtro: Proveedor
    if (_filtroProveedor != null) {
      filtrados = filtrados.where((StockEntity s) =>
          s.proveedorId == _filtroProveedor).toList();
    }

    return filtrados;
  }

  List<StockEntity> _sortStock(List<StockEntity> stock) {
    final List<StockEntity> sorted = List<StockEntity>.from(stock)

    ..sort((StockEntity a, StockEntity b) {
      int comparison = 0;

      switch (_sortColumnIndex) {
        case 0: // Producto
          comparison = a.idProducto.compareTo(b.idProducto);
        case 1: // Lote
          comparison = (a.lote ?? '').compareTo(b.lote ?? '');
        case 2: // Disponible
          comparison = a.cantidadDisponible.compareTo(b.cantidadDisponible);
        case 3: // Reservada
          comparison = a.cantidadReservada.compareTo(b.cantidadReservada);
        case 4: // Mínima
          comparison = a.cantidadMinima.compareTo(b.cantidadMinima);
        case 5: // Caducidad
          if (a.fechaCaducidad == null && b.fechaCaducidad == null) {
            comparison = 0;
          } else if (a.fechaCaducidad == null) {
            comparison = 1;
          } else if (b.fechaCaducidad == null) {
            comparison = -1;
          } else {
            comparison = a.fechaCaducidad!.compareTo(b.fechaCaducidad!);
          }
        case 6: // Ubicación
          comparison = (a.ubicacionFisica ?? '').compareTo(b.ubicacionFisica ?? '');
        case 7: // Precio
          if (a.precioUnitario == null && b.precioUnitario == null) {
            comparison = 0;
          } else if (a.precioUnitario == null) {
            comparison = 1;
          } else if (b.precioUnitario == null) {
            comparison = -1;
          } else {
            comparison = a.precioUnitario!.compareTo(b.precioUnitario!);
          }
        default:
          comparison = 0;
      }

      return _sortAscending ? comparison : -comparison;
    });

    return sorted;
  }

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
      decoration: const BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(AppSizes.radius),
          bottomRight: Radius.circular(AppSizes.radius),
        ),
        border: Border(
          top: BorderSide(color: AppColors.gray200),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            'Mostrando $startItem-$endItem de $totalItems items',
            style: GoogleFonts.inter(
              fontSize: AppSizes.fontSmall,
              color: AppColors.textSecondaryLight,
            ),
          ),
          Row(
            children: <Widget>[
              _PaginationButton(
                onPressed: currentPage > 0 ? () => onPageChanged(0) : null,
                icon: Icons.first_page,
                tooltip: 'Primera página',
              ),
              const SizedBox(width: AppSizes.spacingSmall),
              _PaginationButton(
                onPressed: currentPage > 0 ? () => onPageChanged(currentPage - 1) : null,
                icon: Icons.chevron_left,
                tooltip: 'Página anterior',
              ),
              const SizedBox(width: AppSizes.spacing),
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
              _PaginationButton(
                onPressed: currentPage < totalPages - 1
                    ? () => onPageChanged(currentPage + 1)
                    : null,
                icon: Icons.chevron_right,
                tooltip: 'Página siguiente',
              ),
              const SizedBox(width: AppSizes.spacingSmall),
              _PaginationButton(
                onPressed: currentPage < totalPages - 1
                    ? () => onPageChanged(totalPages - 1)
                    : null,
                icon: Icons.last_page,
                tooltip: 'Última página',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

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
        hintText: 'Buscar por producto, lote, ubicación o zona...',
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
            color: onPressed != null
                ? AppColors.primary.withValues(alpha: 0.1)
                : AppColors.gray200,
            borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
            border: Border.all(
              color: onPressed != null
                  ? AppColors.primary.withValues(alpha: 0.3)
                  : AppColors.gray300,
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

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.spacingMassive),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radius),
        border: Border.all(color: AppColors.gray200),
      ),
      constraints: const BoxConstraints(minHeight: 400),
      child: const Center(
        child: AppLoadingIndicator(
          message: 'Cargando stock del almacén...',
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingXl),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radius),
        border: Border.all(color: AppColors.error),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
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
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppColors.textSecondaryLight,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
