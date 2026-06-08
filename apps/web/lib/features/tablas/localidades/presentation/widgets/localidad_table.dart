import 'dart:async';

import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/core/theme/app_text_styles.dart';
import 'package:ambutrack_web/core/widgets/dialogs/confirmation_dialog.dart';
import 'package:ambutrack_web/core/widgets/handlers/crud_operation_handler.dart';
import 'package:ambutrack_web/core/widgets/loading/app_loading_indicator.dart';
import 'package:ambutrack_web/core/widgets/tables/app_data_grid_v5.dart';
import 'package:ambutrack_web/features/tablas/localidades/presentation/bloc/localidad_bloc.dart';
import 'package:ambutrack_web/features/tablas/localidades/presentation/bloc/localidad_event.dart';
import 'package:ambutrack_web/features/tablas/localidades/presentation/bloc/localidad_state.dart';
import 'package:ambutrack_web/features/tablas/localidades/presentation/widgets/localidad_filters.dart';
import 'package:ambutrack_web/features/tablas/localidades/presentation/widgets/localidad_form_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

/// Tabla de gestión de Localidades
class LocalidadTable extends StatefulWidget {
  const LocalidadTable({
    super.key,
    required this.searchQuery,
    required this.filterData,
  });

  final String searchQuery;
  final LocalidadFilterData filterData;

  @override
  State<LocalidadTable> createState() => _LocalidadTableState();
}

class _LocalidadTableState extends State<LocalidadTable> {
  int? _sortColumnIndex = 1;
  bool _sortAscending = true;
  bool _isDeleting = false;
  BuildContext? _loadingDialogContext;
  DateTime? _deleteStartTime;
  int _currentPage = 0;
  static const int _itemsPerPage = 25;

  @override
  void didUpdateWidget(LocalidadTable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.searchQuery != widget.searchQuery ||
        oldWidget.filterData.provinciaId != widget.filterData.provinciaId) {
      _currentPage = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LocalidadBloc, LocalidadState>(
      listener: (BuildContext context, Object? state) async {
        if (_isDeleting && _loadingDialogContext != null) {
          if (state is LocalidadLoaded || state is LocalidadError) {
            final Duration elapsed = DateTime.now().difference(_deleteStartTime!);

            if (state is LocalidadError) {
              await CrudOperationHandler.handleDeleteError(
                context: _loadingDialogContext!,
                isDeleting: _isDeleting,
                entityName: 'Localidad',
                errorMessage: state.message,
                onClose: () {
                  setState(() {
                    _isDeleting = false;
                    _loadingDialogContext = null;
                    _deleteStartTime = null;
                  });
                },
              );
            } else if (state is LocalidadLoaded) {
              await CrudOperationHandler.handleDeleteSuccess(
                context: _loadingDialogContext!,
                isDeleting: _isDeleting,
                entityName: 'Localidad',
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
      child: BlocBuilder<LocalidadBloc, LocalidadState>(
        builder: (BuildContext context, Object? state) {
          if (state is LocalidadLoaded) {
            List<LocalidadEntity> filtradas = _filterLocalidades(state.localidades);
            filtradas = _sortLocalidades(filtradas);

            final int totalItems = filtradas.length;
            final int totalPages = (totalItems / _itemsPerPage).ceil();
            final int startIndex = _currentPage * _itemsPerPage;
            final int endIndex = (startIndex + _itemsPerPage).clamp(0, totalItems);
            final List<LocalidadEntity> localidadesPaginadas = totalItems > 0
                ? filtradas.sublist(startIndex, endIndex)
                : <LocalidadEntity>[];

            final bool hasFilters = widget.searchQuery.isNotEmpty || widget.filterData.hasActiveFilters;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                if (state.localidades.length != filtradas.length && filtradas.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSizes.spacing),
                    child: Text(
                      'Mostrando ${filtradas.length} de ${state.localidades.length} localidades',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: AppColors.textSecondaryLight,
                      ),
                    ),
                  ),
                Expanded(
                  child: AppDataGridV5<LocalidadEntity>(
                    columns: const <DataGridColumn>[
                      DataGridColumn(label: 'C.P.', sortable: true),
                      DataGridColumn(label: 'LOCALIDAD', flexWidth: 2, sortable: true),
                      DataGridColumn(label: 'PROVINCIA', flexWidth: 2, sortable: true),
                    ],
                    rows: localidadesPaginadas,
                    buildCells: (LocalidadEntity localidad) => <DataGridCell>[
                      DataGridCell(child: _buildCodigoPostalCell(localidad)),
                      DataGridCell(child: _buildNombreCell(localidad)),
                      DataGridCell(child: _buildProvinciaCell(localidad)),
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
                        ? 'No se encontraron localidades con los filtros aplicados'
                        : 'No hay localidades registradas',
                    onEdit: (LocalidadEntity localidad) => _editLocalidad(context, localidad),
                    onDelete: (LocalidadEntity localidad) => _confirmDelete(context, localidad),
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

  List<LocalidadEntity> _filterLocalidades(List<LocalidadEntity> localidades) {
    List<LocalidadEntity> result = localidades;

    result = widget.filterData.apply(result);

    if (widget.searchQuery.isNotEmpty) {
      final String query = widget.searchQuery.toLowerCase();
      result = result.where((LocalidadEntity localidad) {
        return localidad.nombre.toLowerCase().contains(query) ||
            (localidad.codigoPostal?.toLowerCase().contains(query) ?? false) ||
            (localidad.provinciaNombre?.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    return result;
  }

  List<LocalidadEntity> _sortLocalidades(List<LocalidadEntity> localidades) {
    if (_sortColumnIndex == null) {
      return localidades;
    }

    final List<LocalidadEntity> sorted = List<LocalidadEntity>.from(localidades)
      ..sort((LocalidadEntity a, LocalidadEntity b) {
        int comparison = 0;

        switch (_sortColumnIndex) {
          case 0:
            comparison = (a.codigoPostal ?? '').compareTo(b.codigoPostal ?? '');
          case 1:
            comparison = a.nombre.compareTo(b.nombre);
          case 2:
            comparison = (a.provinciaNombre ?? '').compareTo(b.provinciaNombre ?? '');
          default:
            comparison = 0;
        }

        return _sortAscending ? comparison : -comparison;
      });

    return sorted;
  }

  // ==================== ACCIONES ====================

  Future<void> _editLocalidad(BuildContext context, LocalidadEntity localidad) async {
    await showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) => BlocProvider<LocalidadBloc>.value(
        value: context.read<LocalidadBloc>(),
        child: LocalidadFormDialog(localidad: localidad),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, LocalidadEntity localidad) async {
    final bool? confirmed = await showConfirmationDialog(
      context: context,
      title: 'Confirmar Eliminación',
      message: '¿Estás seguro de que deseas eliminar esta localidad? Esta acción no se puede deshacer.',
      itemDetails: <String, String>{
        'Localidad': localidad.nombre,
        if (localidad.codigoPostal != null && localidad.codigoPostal!.isNotEmpty)
          'Código Postal': localidad.codigoPostal!,
        if (localidad.provinciaNombre != null && localidad.provinciaNombre!.isNotEmpty)
          'Provincia': localidad.provinciaNombre!,
      },
    );

    if (confirmed == true && context.mounted) {
      debugPrint('🗑️ Eliminando localidad: ${localidad.nombre} (${localidad.id})');

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
              message: 'Eliminando localidad...',
              color: AppColors.emergency,
              icon: Icons.delete_forever,
            );
          },
        ),
      );

      if (context.mounted) {
        context.read<LocalidadBloc>().add(LocalidadDeleteRequested(localidad.id));
      }
    }
  }

  // ==================== CELL BUILDERS ====================

  Widget _buildCodigoPostalCell(LocalidadEntity localidad) {
    return Text(
      localidad.codigoPostal ?? '-',
      style: GoogleFonts.inter(
        fontSize: 13,
        color: AppColors.textSecondaryLight,
      ),
    );
  }

  Widget _buildNombreCell(LocalidadEntity localidad) {
    return Text(
      localidad.nombre,
      style: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimaryLight,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildProvinciaCell(LocalidadEntity localidad) {
    return Text(
      localidad.provinciaNombre ?? '-',
      style: GoogleFonts.inter(
        fontSize: 13,
        color: AppColors.textSecondaryLight,
      ),
    );
  }
}

/// Campo de búsqueda - usado desde la página
class LocalidadSearchField extends StatefulWidget {
  const LocalidadSearchField({
    super.key,
    required this.searchQuery,
    required this.onSearchChanged,
  });

  final String searchQuery;
  final void Function(String) onSearchChanged;

  @override
  State<LocalidadSearchField> createState() => _LocalidadSearchFieldState();
}

class _LocalidadSearchFieldState extends State<LocalidadSearchField> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.searchQuery);
  }

  @override
  void didUpdateWidget(LocalidadSearchField oldWidget) {
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
        hintText: 'Buscar localidad...',
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
