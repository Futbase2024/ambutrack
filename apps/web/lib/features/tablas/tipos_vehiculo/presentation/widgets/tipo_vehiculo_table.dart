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
import 'package:ambutrack_web/features/tablas/tipos_vehiculo/presentation/bloc/tipo_vehiculo_bloc.dart';
import 'package:ambutrack_web/features/tablas/tipos_vehiculo/presentation/bloc/tipo_vehiculo_event.dart';
import 'package:ambutrack_web/features/tablas/tipos_vehiculo/presentation/bloc/tipo_vehiculo_state.dart';
import 'package:ambutrack_web/features/tablas/tipos_vehiculo/presentation/widgets/tipo_vehiculo_form_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

/// Tabla de gestión de Tipos de Vehículo
class TipoVehiculoTable extends StatefulWidget {
  const TipoVehiculoTable({
    super.key,
    required this.searchQuery,
  });

  final String searchQuery;

  @override
  State<TipoVehiculoTable> createState() => _TipoVehiculoTableState();
}

class _TipoVehiculoTableState extends State<TipoVehiculoTable> {
  int? _sortColumnIndex = 0;
  bool _sortAscending = true;
  bool _isDeleting = false;
  BuildContext? _loadingDialogContext;
  DateTime? _deleteStartTime;
  int _currentPage = 0;
  static const int _itemsPerPage = 25;

  @override
  void didUpdateWidget(TipoVehiculoTable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.searchQuery != widget.searchQuery) {
      _currentPage = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TipoVehiculoBloc, TipoVehiculoState>(
      listener: (BuildContext context, Object? state) async {
        if (_isDeleting && _loadingDialogContext != null) {
          if (state is TipoVehiculoLoaded || state is TipoVehiculoError) {
            final Duration elapsed = DateTime.now().difference(_deleteStartTime!);

            if (state is TipoVehiculoError) {
              await CrudOperationHandler.handleDeleteError(
                context: _loadingDialogContext!,
                isDeleting: _isDeleting,
                entityName: 'Tipo de Vehículo',
                errorMessage: state.message,
                onClose: () {
                  setState(() {
                    _isDeleting = false;
                    _loadingDialogContext = null;
                    _deleteStartTime = null;
                  });
                },
              );
            } else if (state is TipoVehiculoLoaded) {
              await CrudOperationHandler.handleDeleteSuccess(
                context: _loadingDialogContext!,
                isDeleting: _isDeleting,
                entityName: 'Tipo de Vehículo',
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
      child: BlocBuilder<TipoVehiculoBloc, TipoVehiculoState>(
        builder: (BuildContext context, Object? state) {
          if (state is TipoVehiculoLoaded) {
            List<TipoVehiculoEntity> filtrados = _filterTipos(state.tiposVehiculo);
            filtrados = _sortTipos(filtrados);

            final int totalItems = filtrados.length;
            final int totalPages = (totalItems / _itemsPerPage).ceil();
            final int startIndex = _currentPage * _itemsPerPage;
            final int endIndex = (startIndex + _itemsPerPage).clamp(0, totalItems);
            final List<TipoVehiculoEntity> tiposPaginados = totalItems > 0
                ? filtrados.sublist(startIndex, endIndex)
                : <TipoVehiculoEntity>[];

            final bool hasFilters = widget.searchQuery.isNotEmpty;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                if (state.tiposVehiculo.length != filtrados.length && filtrados.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSizes.spacing),
                    child: Text(
                      'Mostrando ${filtrados.length} de ${state.tiposVehiculo.length} tipos',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: AppColors.textSecondaryLight,
                      ),
                    ),
                  ),
                Expanded(
                  child: AppDataGridV5<TipoVehiculoEntity>(
                    columns: const <DataGridColumn>[
                      DataGridColumn(label: 'NOMBRE', flexWidth: 2, sortable: true),
                      DataGridColumn(label: 'DESCRIPCIÓN', flexWidth: 4, sortable: true),
                      DataGridColumn(label: 'ESTADO', sortable: true),
                    ],
                    rows: tiposPaginados,
                    buildCells: (TipoVehiculoEntity tipo) => <DataGridCell>[
                      DataGridCell(child: _buildNombreCell(tipo)),
                      DataGridCell(child: _buildDescripcionCell(tipo)),
                      DataGridCell(child: _buildEstadoCell(tipo)),
                    ],
                    sortColumnIndex: _sortColumnIndex,
                    sortAscending: _sortAscending,
                    onSort: (int columnIndex, {required bool ascending}) {
                      setState(() {
                        _sortColumnIndex = columnIndex;
                        _sortAscending = ascending;
                      });
                    },
                    emptyMessage: hasFilters
                        ? 'No se encontraron tipos con los filtros aplicados'
                        : 'No hay tipos de vehículo registrados',
                    onEdit: (TipoVehiculoEntity tipo) => _editTipo(context, tipo),
                    onDelete: (TipoVehiculoEntity tipo) => _confirmDelete(context, tipo),
                  ),
                ),
                const SizedBox(height: AppSizes.spacing),
                _PaginationBar(
                  currentPage: _currentPage,
                  totalPages: totalPages.clamp(1, 999),
                  totalItems: totalItems,
                  itemsPerPage: _itemsPerPage,
                  onPageChanged: (int page) {
                    setState(() {
                      _currentPage = page;
                    });
                  },
                ),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  // ==================== FILTRADO Y ORDENAMIENTO ====================

  List<TipoVehiculoEntity> _filterTipos(List<TipoVehiculoEntity> tipos) {
    if (widget.searchQuery.isEmpty) {
      return tipos;
    }

    final String query = widget.searchQuery.toLowerCase();
    return tipos.where((TipoVehiculoEntity tipo) {
      return tipo.nombre.toLowerCase().contains(query) ||
          (tipo.descripcion?.toLowerCase().contains(query) ?? false);
    }).toList();
  }

  List<TipoVehiculoEntity> _sortTipos(List<TipoVehiculoEntity> tipos) {
    if (_sortColumnIndex == null) {
      return tipos;
    }

    final List<TipoVehiculoEntity> sorted = List<TipoVehiculoEntity>.from(tipos)
      ..sort((TipoVehiculoEntity a, TipoVehiculoEntity b) {
        int comparison = 0;

        switch (_sortColumnIndex) {
          case 0:
            comparison = a.nombre.compareTo(b.nombre);
          case 1:
            comparison = (a.descripcion ?? '').compareTo(b.descripcion ?? '');
          case 2:
            comparison = a.activo == b.activo ? 0 : (a.activo ? -1 : 1);
          default:
            comparison = 0;
        }

        return _sortAscending ? comparison : -comparison;
      });

    return sorted;
  }

  // ==================== ACCIONES ====================

  Future<void> _editTipo(BuildContext context, TipoVehiculoEntity tipo) async {
    await showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) => BlocProvider<TipoVehiculoBloc>.value(
        value: context.read<TipoVehiculoBloc>(),
        child: TipoVehiculoFormDialog(tipoVehiculo: tipo),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, TipoVehiculoEntity tipo) async {
    final bool? confirmed = await showConfirmationDialog(
      context: context,
      title: 'Confirmar Eliminación',
      message: '¿Estás seguro de que deseas eliminar este tipo de vehículo? Esta acción no se puede deshacer.',
      itemDetails: <String, String>{
        'Nombre': tipo.nombre,
        if (tipo.descripcion != null && tipo.descripcion!.isNotEmpty)
          'Descripción': tipo.descripcion!,
        'Estado': tipo.activo ? 'Activo' : 'Inactivo',
      },
    );

    if (confirmed == true && context.mounted) {
      debugPrint('🗑️ Eliminando tipo: ${tipo.nombre} (${tipo.id})');

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
              message: 'Eliminando tipo de vehículo...',
              color: AppColors.emergency,
              icon: Icons.delete_forever,
            );
          },
        ),
      );

      if (context.mounted) {
        context.read<TipoVehiculoBloc>().add(TipoVehiculoDeleteRequested(tipo.id));
      }
    }
  }

  // ==================== CELL BUILDERS ====================

  Widget _buildNombreCell(TipoVehiculoEntity tipo) {
    return Text(
      tipo.nombre,
      style: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimaryLight,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildDescripcionCell(TipoVehiculoEntity tipo) {
    return Text(
      tipo.descripcion ?? 'Sin descripción',
      style: GoogleFonts.inter(
        fontSize: 13,
        color: tipo.descripcion != null
            ? AppColors.textSecondaryLight
            : AppColors.textSecondaryLight.withValues(alpha: 0.5),
        fontStyle: tipo.descripcion != null ? FontStyle.normal : FontStyle.italic,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildEstadoCell(TipoVehiculoEntity tipo) {
    return Container(
      width: double.infinity,
      alignment: Alignment.center,
      child: StatusBadge(
        label: tipo.activo ? 'Activo' : 'Inactivo',
        type: tipo.activo ? StatusBadgeType.success : StatusBadgeType.inactivo,
      ),
    );
  }
}

/// Campo de búsqueda - usado desde la página
class TipoVehiculoSearchField extends StatefulWidget {
  const TipoVehiculoSearchField({
    super.key,
    required this.searchQuery,
    required this.onSearchChanged,
  });

  final String searchQuery;
  final void Function(String) onSearchChanged;

  @override
  State<TipoVehiculoSearchField> createState() => _TipoVehiculoSearchFieldState();
}

class _TipoVehiculoSearchFieldState extends State<TipoVehiculoSearchField> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.searchQuery);
  }

  @override
  void didUpdateWidget(TipoVehiculoSearchField oldWidget) {
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
        hintText: 'Buscar tipo...',
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

/// Paginación compacta
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
            'Mostrando $startItem-$endItem de $totalItems items',
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
