import 'dart:async';

import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/core/theme/app_text_styles.dart';
import 'package:ambutrack_web/core/widgets/badges/status_badge.dart';
import 'package:ambutrack_web/core/widgets/dialogs/confirmation_dialog.dart';
import 'package:ambutrack_web/core/widgets/handlers/crud_operation_handler.dart';
import 'package:ambutrack_web/core/widgets/loading/app_loading_indicator.dart';
import 'package:ambutrack_web/core/widgets/tables/app_data_grid_v5.dart';
import 'package:ambutrack_web/features/almacen/presentation/bloc/producto/producto_bloc.dart';
import 'package:ambutrack_web/features/almacen/presentation/bloc/producto/producto_event.dart';
import 'package:ambutrack_web/features/almacen/presentation/bloc/producto/producto_state.dart';
import 'package:ambutrack_web/features/almacen/presentation/widgets/producto_form_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

/// Tabla de gestión de Productos
class ProductosTable extends StatefulWidget {
  const ProductosTable({super.key});

  @override
  State<ProductosTable> createState() => _ProductosTableState();
}

class _ProductosTableState extends State<ProductosTable> {
  String _searchQuery = '';
  CategoriaProducto? _categoriaFiltro; // null = Todas las categorías
  int? _sortColumnIndex = 1; // Ordenar por Nombre por defecto
  bool _sortAscending = true;
  bool _isDeleting = false;
  BuildContext? _loadingDialogContext;
  DateTime? _deleteStartTime;
  int _currentPage = 0;
  static const int _itemsPerPage = 25;

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProductoBloc, ProductoState>(
      listener: (BuildContext context, Object? state) async {
        // Manejo de loading al eliminar
        if (_isDeleting && _loadingDialogContext != null) {
          if (state is ProductoLoaded || state is ProductoError) {
            final Duration elapsed = DateTime.now().difference(_deleteStartTime!);

            // Guardar contexto del loading antes de resetear estado
            final BuildContext loadingCtx = _loadingDialogContext!;

            // Resetear estado inmediatamente para prevenir re-entrada
            setState(() {
              _isDeleting = false;
              _loadingDialogContext = null;
              _deleteStartTime = null;
            });

            // Cerrar loading dialog usando rootNavigator
            Navigator.of(loadingCtx, rootNavigator: true).pop();

            // Esperar a que el Navigator complete la transición
            await Future<void>.delayed(const Duration(milliseconds: 200));

            if (!context.mounted) {
              return;
            }

            // Manejar resultado con CrudOperationHandler
            if (state is ProductoError) {
              await CrudOperationHandler.handleDeleteError(
                context: context,
                isDeleting: false,
                entityName: 'Producto',
                errorMessage: state.message,
              );
            } else if (state is ProductoLoaded) {
              await CrudOperationHandler.handleDeleteSuccess(
                context: context,
                isDeleting: false,
                entityName: 'Producto',
                durationMs: elapsed.inMilliseconds,
              );
            }
          }
        }
      },
      child: BlocBuilder<ProductoBloc, ProductoState>(
        builder: (BuildContext context, Object? state) {
          if (state is ProductoLoading) {
            return const _LoadingView();
          }

          if (state is ProductoError) {
            return _ErrorView(message: state.message);
          }

          if (state is ProductoLoaded) {
            // Filtrado y ordenamiento
            List<ProductoEntity> filtrados = _filterProductos(state.productos);
            filtrados = _sortProductos(filtrados);

            // Cálculo de paginación
            final int totalItems = filtrados.length;
            final int totalPages = (totalItems / _itemsPerPage).ceil();
            final int startIndex = _currentPage * _itemsPerPage;
            final int endIndex = (startIndex + _itemsPerPage).clamp(0, totalItems);
            final List<ProductoEntity> productosPaginados = totalItems > 0
                ? filtrados.sublist(startIndex, endIndex)
                : <ProductoEntity>[];

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                // Header: Título, filtro por categoría y búsqueda
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        'Listado de Productos',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimaryLight,
                        ),
                      ),
                    ),
                    // Filtro por categoría
                    SizedBox(
                      width: 220,
                      child: _CategoryFilterDropdown(
                        selectedCategory: _categoriaFiltro,
                        onCategoryChanged: (CategoriaProducto? categoria) {
                          setState(() {
                            _categoriaFiltro = categoria;
                            _currentPage = 0; // Reset página al filtrar
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: AppSizes.spacing),
                    // Búsqueda
                    SizedBox(
                      width: 300,
                      child: _SearchField(
                        searchQuery: _searchQuery,
                        onSearchChanged: (String query) {
                          setState(() {
                            _searchQuery = query;
                            _currentPage = 0; // Reset página al buscar
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.spacing),

                // Info de resultados filtrados
                if (state.productos.length != filtrados.length)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSizes.spacing),
                    child: Text(
                      'Mostrando ${filtrados.length} de ${state.productos.length} productos',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: AppColors.textSecondaryLight,
                      ),
                    ),
                  ),

                // Tabla
                Expanded(
                  child: AppDataGridV5<ProductoEntity>(
                    columns: const <DataGridColumn>[
                      DataGridColumn(label: 'CÓDIGO', sortable: true),
                      DataGridColumn(label: 'NOMBRE / COMERCIAL', flexWidth: 2, sortable: true),
                      DataGridColumn(label: 'CATEGORÍA', sortable: true),
                      DataGridColumn(label: 'CANTIDAD', sortable: true),
                      DataGridColumn(label: 'PRECIO MEDIO', sortable: true),
                      DataGridColumn(label: 'ESTADO', sortable: true),
                    ],
                    rows: productosPaginados,
                    buildCells: (ProductoEntity producto) => <DataGridCell>[
                      DataGridCell(child: _buildCodigoCell(producto)),
                      DataGridCell(child: _buildNombreCell(producto)),
                      DataGridCell(child: _buildCategoriaCell(producto)),
                      DataGridCell(child: _buildCantidadCell(producto)),
                      DataGridCell(child: _buildPrecioCell(producto)),
                      DataGridCell(child: _buildEstadoCell(producto)),
                    ],
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
                        : 'No hay productos registrados',
                    onEdit: _editProducto,
                    onDelete: _confirmDelete,
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

          return const SizedBox.shrink();
        },
      ),
    );
  }

  /// Filtra productos según búsqueda y categoría
  List<ProductoEntity> _filterProductos(List<ProductoEntity> productos) {
    List<ProductoEntity> filtered = productos;

    // Filtrar por categoría primero
    if (_categoriaFiltro != null) {
      filtered = filtered
          .where((ProductoEntity p) => p.categoria == _categoriaFiltro)
          .toList();
    }

    // Luego filtrar por búsqueda
    if (_searchQuery.isNotEmpty) {
      final String query = _searchQuery.toLowerCase();
      filtered = filtered.where((ProductoEntity p) {
        final String codigo = p.codigo?.toLowerCase() ?? '';
        final String nombre = p.nombre.toLowerCase();
        final String nombreComercial = p.nombreComercial?.toLowerCase() ?? '';
        final String categoria = p.categoria?.label.toLowerCase() ?? '';

        return codigo.contains(query) ||
            nombre.contains(query) ||
            nombreComercial.contains(query) ||
            categoria.contains(query);
      }).toList();
    }

    return filtered;
  }

  /// Ordena productos según columna activa
  List<ProductoEntity> _sortProductos(List<ProductoEntity> productos) {
    if (_sortColumnIndex == null) {
      return productos;
    }

    final List<ProductoEntity> sorted = List<ProductoEntity>.from(productos)
      ..sort((ProductoEntity a, ProductoEntity b) {
        int compare = 0;

        switch (_sortColumnIndex) {
          case 0: // Código
            compare = (a.codigo ?? '').compareTo(b.codigo ?? '');
          case 1: // Nombre
            compare = a.nombre.compareTo(b.nombre);
          case 2: // Categoría
            compare = (a.categoria?.label ?? '').compareTo(b.categoria?.label ?? '');
          case 3: // Unidad
            compare = a.unidadMedida.compareTo(b.unidadMedida);
          case 4: // Precio
            compare = (a.precioMedio ?? 0).compareTo(b.precioMedio ?? 0);
          case 5: // Estado
            compare = a.activo == b.activo
                ? 0
                : a.activo
                    ? -1
                    : 1;
        }

        return _sortAscending ? compare : -compare;
      });

    return sorted;
  }

  // ============================================
  // MÉTODOS DE CONSTRUCCIÓN DE CELDAS
  // ============================================

  Widget _buildCodigoCell(ProductoEntity producto) {
    return Text(
      producto.codigo ?? '-',
      style: AppTextStyles.bodyBold.copyWith(fontSize: 13),
    );
  }

  Widget _buildNombreCell(ProductoEntity producto) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          producto.nombre,
          style: AppTextStyles.bodyBold.copyWith(fontSize: 13),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        if (producto.nombreComercial != null && producto.nombreComercial!.isNotEmpty)
          Text(
            producto.nombreComercial!,
            style: AppTextStyles.bodySmallSecondary.copyWith(fontSize: 11),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
      ],
    );
  }

  Widget _buildCategoriaCell(ProductoEntity producto) {
    return Align(
      alignment: Alignment.centerLeft,
      child: IntrinsicWidth(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _getCategoriaColor(producto.categoria).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                _getCategoriaIcon(producto.categoria),
                size: 14,
                color: _getCategoriaColor(producto.categoria),
              ),
              const SizedBox(width: 4),
              Text(
                producto.categoria?.label ?? 'N/A',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _getCategoriaColor(producto.categoria),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCantidadCell(ProductoEntity producto) {
    // TODO(almacen): Integrar con stock_almacen para mostrar cantidad real
    // Por ahora mostramos 0 como placeholder hasta completar integración
    return Text(
      '0 ${_getUnidadPlural(producto.unidadMedida).toLowerCase()}',
      style: AppTextStyles.bodySmall.copyWith(
        color: AppColors.textSecondaryLight,
      ),
    );
  }

  /// Convierte la unidad de medida a su forma plural
  String _getUnidadPlural(String unidad) {
    final String unidadLower = unidad.toLowerCase();

    // Mapeo de unidades comunes a su forma plural
    const Map<String, String> unidadesPlurales = <String, String>{
      'unidad': 'Unidades',
      'caja': 'Cajas',
      'paquete': 'Paquetes',
      'litro': 'Litros',
      'mililitro': 'Mililitros',
      'ml': 'ML',
      'gramo': 'Gramos',
      'kilogramo': 'Kilogramos',
      'kg': 'KG',
      'par': 'Pares',
      'pieza': 'Piezas',
      'frasco': 'Frascos',
      'ampolla': 'Ampollas',
      'vial': 'Viales',
      'blister': 'Blisters',
      'tubo': 'Tubos',
      'rollo': 'Rollos',
      'sobre': 'Sobres',
    };

    return unidadesPlurales[unidadLower] ?? unidad;
  }

  Widget _buildPrecioCell(ProductoEntity producto) {
    if (producto.precioMedio == null) {
      return Text(
        '-',
        style: AppTextStyles.bodySmallSecondary,
      );
    }

    return Text(
      '${producto.precioMedio!.toStringAsFixed(2)} €',
      style: AppTextStyles.bodySmall,
    );
  }

  Widget _buildEstadoCell(ProductoEntity producto) {
    return Align(
      alignment: Alignment.centerLeft,
      child: StatusBadge(
        label: producto.activo ? 'Activo' : 'Inactivo',
        type: producto.activo ? StatusBadgeType.success : StatusBadgeType.inactivo,
      ),
    );
  }

  Color _getCategoriaColor(CategoriaProducto? categoria) {
    if (categoria == null) {
      return AppColors.gray400;
    }
    switch (categoria) {
      case CategoriaProducto.medicacion:
        return AppColors.primary;
      case CategoriaProducto.electromedicina:
        return AppColors.warning;
      case CategoriaProducto.fungibles:
        return AppColors.success;
      case CategoriaProducto.materialAmbulancia:
        return AppColors.secondary;
      case CategoriaProducto.gasesMedicinales:
        return AppColors.info;
      case CategoriaProducto.otros:
        return AppColors.inactive;
    }
  }

  IconData _getCategoriaIcon(CategoriaProducto? categoria) {
    if (categoria == null) {
      return Icons.help_outline;
    }
    switch (categoria) {
      case CategoriaProducto.medicacion:
        return Icons.medication;
      case CategoriaProducto.electromedicina:
        return Icons.medical_services;
      case CategoriaProducto.fungibles:
        return Icons.health_and_safety;
      case CategoriaProducto.materialAmbulancia:
        return Icons.inventory;
      case CategoriaProducto.gasesMedicinales:
        return Icons.air;
      case CategoriaProducto.otros:
        return Icons.category;
    }
  }

  /// Muestra diálogo de edición
  Future<void> _editProducto(ProductoEntity producto) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return BlocProvider<ProductoBloc>.value(
          value: context.read<ProductoBloc>(),
          child: ProductoFormDialog(producto: producto),
        );
      },
    );
  }

  /// Confirma eliminación
  Future<void> _confirmDelete(ProductoEntity producto) async {
    final bool? confirmed = await showConfirmationDialog(
      context: context,
      title: 'Confirmar Eliminación',
      message: '¿Estás seguro de que deseas eliminar este producto? Esta acción no se puede deshacer.',
      itemDetails: <String, String>{
        if (producto.codigo != null && producto.codigo!.isNotEmpty) 'Código': producto.codigo!,
        'Nombre': producto.nombre,
        if (producto.nombreComercial != null && producto.nombreComercial!.isNotEmpty)
          'Nombre Comercial': producto.nombreComercial!,
        'Categoría': producto.categoria?.label ?? 'N/A',
        'Estado': producto.activo ? 'Activo' : 'Inactivo',
      },
    );

    if (confirmed == true && mounted) {
      debugPrint('🗑️ Eliminando producto: ${producto.nombre} (${producto.id})');

      BuildContext? loadingContext;

      unawaited(
        showDialog<void>(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext dialogContext) {
            loadingContext = dialogContext;

            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted && loadingContext != null) {
                setState(() {
                  _isDeleting = true;
                  _loadingDialogContext = loadingContext;
                  _deleteStartTime = DateTime.now();
                });
              }
            });

            return const AppLoadingOverlay(
              message: 'Eliminando producto...',
              color: AppColors.emergency,
              icon: Icons.delete_forever,
            );
          },
        ),
      );

      if (mounted) {
        context.read<ProductoBloc>().add(ProductoDeleteRequested(producto.id));
      }
    }
  }

  /// Construye controles de paginación
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
            'Mostrando $startItem-$endItem de $totalItems productos',
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

              // Indicador de página actual
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
}

/// Botón de paginación
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

/// Campo de búsqueda
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
          borderSide: const BorderSide(color: AppColors.secondary, width: 2),
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

/// Vista de carga
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
          message: 'Cargando productos...',
        ),
      ),
    );
  }
}

/// Vista de error
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
            'Error al cargar productos',
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

/// Dropdown para filtrar por categoría de producto
class _CategoryFilterDropdown extends StatelessWidget {
  const _CategoryFilterDropdown({
    required this.selectedCategory,
    required this.onCategoryChanged,
  });

  final CategoriaProducto? selectedCategory;
  final void Function(CategoriaProducto?) onCategoryChanged;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        border: Border.all(color: AppColors.gray300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<CategoriaProducto?>(
          value: selectedCategory,
          isExpanded: true,
          hint: Row(
            children: <Widget>[
              const Icon(
                Icons.filter_list,
                size: 18,
                color: AppColors.textSecondaryLight,
              ),
              const SizedBox(width: AppSizes.spacingSmall),
              Text(
                'Todas las categorías',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppColors.textSecondaryLight,
                ),
              ),
            ],
          ),
          icon: const Icon(
            Icons.arrow_drop_down,
            color: AppColors.textSecondaryLight,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.paddingMedium,
            vertical: AppSizes.paddingSmall,
          ),
          borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
          dropdownColor: Colors.white,
          items: <DropdownMenuItem<CategoriaProducto?>>[
            // Opción "Todas"
            DropdownMenuItem<CategoriaProducto?>(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      const Icon(
                        Icons.select_all,
                        size: 18,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: AppSizes.spacingSmall),
                      Text(
                        'Todas las categorías',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: AppColors.textPrimaryLight,
                          fontWeight: selectedCategory == null
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.spacingSmall),
                  const Divider(height: 1),
                ],
              ),
            ),
            // Categorías específicas
            ...CategoriaProducto.values.map((CategoriaProducto categoria) {
              final IconData icon = _getCategoryIcon(categoria);
              final Color color = _getCategoryColor(categoria);

              return DropdownMenuItem<CategoriaProducto?>(
                value: categoria,
                child: Row(
                  children: <Widget>[
                    Icon(
                      icon,
                      size: 18,
                      color: color,
                    ),
                    const SizedBox(width: AppSizes.spacingSmall),
                    Expanded(
                      child: Text(
                        categoria.label,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: AppColors.textPrimaryLight,
                          fontWeight: selectedCategory == categoria
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (selectedCategory == categoria)
                      const Icon(
                        Icons.check,
                        size: 18,
                        color: AppColors.success,
                      ),
                  ],
                ),
              );
            }),
          ],
          onChanged: onCategoryChanged,
        ),
      ),
    );
  }

  /// Obtiene el icono según la categoría
  IconData _getCategoryIcon(CategoriaProducto categoria) {
    switch (categoria) {
      case CategoriaProducto.medicacion:
        return Icons.medication;
      case CategoriaProducto.materialAmbulancia:
        return Icons.medical_services;
      case CategoriaProducto.electromedicina:
        return Icons.electrical_services;
      case CategoriaProducto.fungibles:
        return Icons.healing;
      case CategoriaProducto.gasesMedicinales:
        return Icons.air;
      case CategoriaProducto.otros:
        return Icons.category;
    }
  }

  /// Obtiene el color según la categoría
  Color _getCategoryColor(CategoriaProducto categoria) {
    switch (categoria) {
      case CategoriaProducto.medicacion:
        return AppColors.primary;
      case CategoriaProducto.materialAmbulancia:
        return AppColors.error;
      case CategoriaProducto.electromedicina:
        return AppColors.warning;
      case CategoriaProducto.fungibles:
        return AppColors.secondary;
      case CategoriaProducto.gasesMedicinales:
        return AppColors.info;
      case CategoriaProducto.otros:
        return AppColors.textSecondaryLight;
    }
  }
}
