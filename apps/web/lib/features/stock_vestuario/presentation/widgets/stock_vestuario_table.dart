import 'dart:async';

import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/core/theme/app_text_styles.dart';
import 'package:ambutrack_web/core/widgets/dialogs/confirmation_dialog.dart';
import 'package:ambutrack_web/core/widgets/handlers/crud_operation_handler.dart';
import 'package:ambutrack_web/core/widgets/loading/app_loading_indicator.dart';
import 'package:ambutrack_web/core/widgets/tables/app_data_grid_v5.dart';
import 'package:ambutrack_web/features/stock_vestuario/presentation/bloc/stock_vestuario_bloc.dart';
import 'package:ambutrack_web/features/stock_vestuario/presentation/bloc/stock_vestuario_event.dart';
import 'package:ambutrack_web/features/stock_vestuario/presentation/bloc/stock_vestuario_state.dart';
import 'package:ambutrack_web/features/stock_vestuario/presentation/widgets/stock_vestuario_form_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

/// Tabla de Stock de Vestuario
class StockVestuarioTable extends StatefulWidget {
  const StockVestuarioTable({
    super.key,
    required this.searchQuery,
  });

  final String searchQuery;

  @override
  State<StockVestuarioTable> createState() => _StockVestuarioTableState();
}

class _StockVestuarioTableState extends State<StockVestuarioTable> {
  int? _sortColumnIndex = 0;
  bool _sortAscending = true;
  bool _isDeleting = false;
  BuildContext? _loadingDialogContext;
  DateTime? _deleteStartTime;
  int _currentPage = 0;
  static const int _itemsPerPage = 25;

  @override
  void didUpdateWidget(StockVestuarioTable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.searchQuery != widget.searchQuery) {
      _currentPage = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<StockVestuarioBloc, StockVestuarioState>(
      listener: (BuildContext context, StockVestuarioState state) {
        if (_isDeleting && _loadingDialogContext != null) {
          if (state is StockVestuarioLoaded || state is StockVestuarioError) {
            final Duration elapsed = DateTime.now().difference(_deleteStartTime!);

            if (state is StockVestuarioError) {
              CrudOperationHandler.handleDeleteError(
                context: _loadingDialogContext!,
                isDeleting: _isDeleting,
                entityName: 'Stock',
                errorMessage: state.message,
                onClose: () {
                  setState(() {
                    _isDeleting = false;
                    _loadingDialogContext = null;
                    _deleteStartTime = null;
                  });
                },
              );
            } else if (state is StockVestuarioLoaded) {
              CrudOperationHandler.handleDeleteSuccess(
                context: _loadingDialogContext!,
                isDeleting: _isDeleting,
                entityName: 'Stock',
                durationMs: elapsed.inMilliseconds,
                onClose: () {
                  setState(() {
                    _isDeleting = false;
                    _loadingDialogContext = null;
                    _deleteStartTime = null;
                  });
                },
              );
            }
          }
        }
      },
      child: BlocBuilder<StockVestuarioBloc, StockVestuarioState>(
        builder: (BuildContext context, StockVestuarioState state) {
          if (state is StockVestuarioLoading) {
            return const _LoadingView();
          }

          if (state is StockVestuarioError) {
            return _ErrorView(message: state.message);
          }

          if (state is StockVestuarioLoaded) {
            // Filtrado y ordenamiento
            List<StockVestuarioEntity> filtrados = _filterItems(state.items);
            filtrados = _sortItems(filtrados);

            // Cálculo de paginación
            final int totalItems = filtrados.length;
            final int totalPages = (totalItems / _itemsPerPage).ceil();
            final int startIndex = _currentPage * _itemsPerPage;
            final int endIndex = (startIndex + _itemsPerPage).clamp(0, totalItems);
            final List<StockVestuarioEntity> itemsPaginados = totalItems > 0
                ? filtrados.sublist(startIndex, endIndex)
                : <StockVestuarioEntity>[];

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                if (state.items.length != filtrados.length)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSizes.spacing),
                    child: Text(
                      'Mostrando ${filtrados.length} de ${state.items.length} artículos',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: AppColors.textSecondaryLight,
                      ),
                    ),
                  ),

                Expanded(
                  child: AppDataGridV5<StockVestuarioEntity>(
                    columns: const <DataGridColumn>[
                      DataGridColumn(label: 'PRENDA', flexWidth: 2, sortable: true),
                      DataGridColumn(label: 'TALLA', flexWidth: 1, sortable: true),
                      DataGridColumn(label: 'MARCA', flexWidth: 2, sortable: true),
                      DataGridColumn(label: 'COLOR', flexWidth: 1, sortable: true),
                      DataGridColumn(label: 'TOTAL', flexWidth: 1, sortable: true),
                      DataGridColumn(label: 'ASIGNADA', flexWidth: 1, sortable: true),
                      DataGridColumn(label: 'DISPONIBLE', flexWidth: 1, sortable: true),
                      DataGridColumn(label: 'ESTADO', flexWidth: 2, sortable: true),
                    ],
                    rows: itemsPaginados,
                    buildCells: (StockVestuarioEntity item) => <DataGridCell>[
                      DataGridCell(child: _buildPrendaCell(item)),
                      DataGridCell(child: _buildTallaCell(item)),
                      DataGridCell(child: _buildMarcaCell(item)),
                      DataGridCell(child: _buildColorCell(item)),
                      DataGridCell(child: _buildCantidadTotalCell(item)),
                      DataGridCell(child: _buildCantidadAsignadaCell(item)),
                      DataGridCell(child: _buildCantidadDisponibleCell(item)),
                      DataGridCell(child: _buildEstadoCell(item)),
                    ],
                    onEdit: (StockVestuarioEntity item) => _editItem(context, item),
                    onDelete: (StockVestuarioEntity item) => _confirmDelete(context, item),
                    emptyMessage: widget.searchQuery.isNotEmpty
                        ? 'No se encontraron artículos con los filtros aplicados'
                        : 'No hay artículos de stock registrados',
                    sortColumnIndex: _sortColumnIndex,
                    sortAscending: _sortAscending,
                    onSort: (int columnIndex, {required bool ascending}) {
                      setState(() {
                        _sortColumnIndex = columnIndex;
                        _sortAscending = ascending;
                      });
                    },
                    rowHeight: 42.0,
                    headerHeight: 48.0,
                  ),
                ),

                const SizedBox(height: AppSizes.spacing),
                _PaginationBar(
                  currentPage: _currentPage,
                  totalPages: totalPages.clamp(1, 999),
                  totalItems: totalItems,
                  itemsPerPage: _itemsPerPage,
                  onPageChanged: (int page) { setState(() { _currentPage = page; }); },
                ),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  List<StockVestuarioEntity> _filterItems(List<StockVestuarioEntity> items) {
    if (widget.searchQuery.isEmpty) {
      return items;
    }

    final String queryLower = widget.searchQuery.toLowerCase();

    return items.where((StockVestuarioEntity item) {
      return item.prenda.toLowerCase().contains(queryLower) ||
          item.talla.toLowerCase().contains(queryLower) ||
          (item.marca?.toLowerCase().contains(queryLower) ?? false) ||
          (item.color?.toLowerCase().contains(queryLower) ?? false) ||
          (item.proveedor?.toLowerCase().contains(queryLower) ?? false);
    }).toList();
  }

  /// Ordena los items según la columna seleccionada
  List<StockVestuarioEntity> _sortItems(List<StockVestuarioEntity> items) {
    if (_sortColumnIndex == null) {
      return items;
    }

    return List<StockVestuarioEntity>.from(items)
      ..sort((StockVestuarioEntity a, StockVestuarioEntity b) {
        int comparison = 0;

        switch (_sortColumnIndex) {
          case 0: // PRENDA
            comparison = a.prenda.compareTo(b.prenda);
          case 1: // TALLA
            comparison = a.talla.compareTo(b.talla);
          case 2: // MARCA
            comparison = (a.marca ?? '').compareTo(b.marca ?? '');
          case 3: // COLOR
            comparison = (a.color ?? '').compareTo(b.color ?? '');
          case 4: // TOTAL
            comparison = a.cantidadTotal.compareTo(b.cantidadTotal);
          case 5: // ASIGNADA
            comparison = a.cantidadAsignada.compareTo(b.cantidadAsignada);
          case 6: // DISPONIBLE
            comparison = a.cantidadDisponible.compareTo(b.cantidadDisponible);
        }

        return _sortAscending ? comparison : -comparison;
      });
  }

  /// Construye celda de prenda
  Widget _buildPrendaCell(StockVestuarioEntity item) {
    return Text(
      item.prenda,
      style: GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimaryLight,
      ),
    );
  }

  /// Construye celda de talla
  Widget _buildTallaCell(StockVestuarioEntity item) {
    return Text(
      item.talla,
      style: GoogleFonts.inter(
        fontSize: 13,
        color: AppColors.textPrimaryLight,
      ),
    );
  }

  /// Construye celda de marca
  Widget _buildMarcaCell(StockVestuarioEntity item) {
    return Text(
      item.marca ?? '-',
      style: GoogleFonts.inter(
        fontSize: 13,
        color: AppColors.textSecondaryLight,
      ),
    );
  }

  /// Construye celda de color
  Widget _buildColorCell(StockVestuarioEntity item) {
    return Text(
      item.color ?? '-',
      style: GoogleFonts.inter(
        fontSize: 13,
        color: AppColors.textSecondaryLight,
      ),
    );
  }

  /// Construye celda de cantidad total
  Widget _buildCantidadTotalCell(StockVestuarioEntity item) {
    return Text(
      item.cantidadTotal.toString(),
      style: GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimaryLight,
      ),
    );
  }

  /// Construye celda de cantidad asignada
  Widget _buildCantidadAsignadaCell(StockVestuarioEntity item) {
    return Text(
      item.cantidadAsignada.toString(),
      style: GoogleFonts.inter(
        fontSize: 13,
        color: AppColors.warning,
      ),
    );
  }

  /// Construye celda de cantidad disponible
  Widget _buildCantidadDisponibleCell(StockVestuarioEntity item) {
    final Color color = item.sinStock
        ? AppColors.error
        : item.tieneStockBajo
            ? AppColors.warning
            : AppColors.success;

    return Text(
      item.cantidadDisponible.toString(),
      style: GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: color,
      ),
    );
  }

  /// Construye celda de estado
  Widget _buildEstadoCell(StockVestuarioEntity item) {
    final Color backgroundColor = item.activo ? AppColors.success.withValues(alpha: 0.1) : AppColors.error.withValues(alpha: 0.1);
    final Color textColor = item.activo ? AppColors.success : AppColors.error;

    return Align(
      alignment: Alignment.centerLeft,
      child: IntrinsicWidth(
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 6,
            vertical: 2,
          ),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            item.activo ? 'ACTIVO' : 'INACTIVO',
            maxLines: 1,
            overflow: TextOverflow.visible,
            softWrap: false,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }

  /// Muestra el diálogo de edición
  Future<void> _editItem(BuildContext context, StockVestuarioEntity item) async {
    final StockVestuarioBloc stockVestuarioBloc = context.read<StockVestuarioBloc>();

    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return BlocProvider<StockVestuarioBloc>.value(
          value: stockVestuarioBloc,
          child: StockVestuarioFormDialog(item: item),
        );
      },
    );
  }

  /// Confirma la eliminación del item
  Future<void> _confirmDelete(BuildContext context, StockVestuarioEntity item) async {
    final bool? confirmed = await showConfirmationDialog(
      context: context,
      title: 'Confirmar Eliminación',
      message: '¿Estás seguro de que deseas eliminar este artículo de stock? Esta acción no se puede deshacer.',
      itemDetails: <String, String>{
        'Prenda': item.prenda,
        'Talla': item.talla,
        if (item.marca != null && item.marca!.isNotEmpty) 'Marca': item.marca!,
        if (item.color != null && item.color!.isNotEmpty) 'Color': item.color!,
        'Cantidad Total': item.cantidadTotal.toString(),
        'Cantidad Asignada': item.cantidadAsignada.toString(),
        'Cantidad Disponible': item.cantidadDisponible.toString(),
        'Estado': item.activo ? 'Activo' : 'Inactivo',
      },
    );

    if (confirmed == true && context.mounted) {
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
              message: 'Eliminando artículo...',
              color: AppColors.emergency,
              icon: Icons.delete_forever,
            );
          },
        ),
      );

      if (context.mounted) {
        context.read<StockVestuarioBloc>().add(StockVestuarioDeleteRequested(item.id));
      }
    }
  }
}

/// Campo de búsqueda para Stock de Vestuario (usado en PageHeader.extra)
class StockVestuarioSearchField extends StatefulWidget {
  const StockVestuarioSearchField({
    super.key,
    required this.searchQuery,
    required this.onSearchChanged,
  });

  final String searchQuery;
  final void Function(String) onSearchChanged;

  @override
  State<StockVestuarioSearchField> createState() => _StockVestuarioSearchFieldState();
}

class _StockVestuarioSearchFieldState extends State<StockVestuarioSearchField> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.searchQuery);
  }

  @override
  void didUpdateWidget(StockVestuarioSearchField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.searchQuery != widget.searchQuery && _controller.text != widget.searchQuery) {
      _controller.text = widget.searchQuery;
    }
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
        hintText: 'Buscar artículo...',
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

/// Barra de paginación compacta
class _PaginationBar extends StatelessWidget {
  const _PaginationBar({
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    required this.itemsPerPage,
    required this.onPageChanged,
  });

  final int currentPage;
  final int totalPages;
  final int totalItems;
  final int itemsPerPage;
  final void Function(int) onPageChanged;

  @override
  Widget build(BuildContext context) {
    final int startItem = totalItems == 0 ? 0 : currentPage * itemsPerPage + 1;
    final int endItem = totalItems == 0
        ? 0
        : ((currentPage + 1) * itemsPerPage).clamp(0, totalItems);

    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingSmall),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            'Mostrando $startItem-$endItem de $totalItems artículos',
            style: AppTextStyles.bodySmallSecondary,
          ),
          Row(
            children: <Widget>[
              IconButton(
                icon: const Icon(Icons.first_page),
                onPressed: currentPage > 0 ? () => onPageChanged(0) : null,
                tooltip: 'Primera página',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: currentPage > 0 ? () => onPageChanged(currentPage - 1) : null,
                tooltip: 'Página anterior',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.paddingSmall,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                ),
                child: Text(
                  'Página ${currentPage + 1} de $totalPages',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textPrimaryDark,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: currentPage < totalPages - 1 ? () => onPageChanged(currentPage + 1) : null,
                tooltip: 'Página siguiente',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
              ),
              IconButton(
                icon: const Icon(Icons.last_page),
                onPressed: currentPage < totalPages - 1 ? () => onPageChanged(totalPages - 1) : null,
                tooltip: 'Última página',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
              ),
            ],
          ),
        ],
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
          message: 'Cargando stock...',
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
