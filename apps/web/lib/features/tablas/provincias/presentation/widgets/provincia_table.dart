import 'dart:async';

import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/core/theme/app_text_styles.dart';
import 'package:ambutrack_web/core/widgets/dialogs/confirmation_dialog.dart';
import 'package:ambutrack_web/core/widgets/handlers/crud_operation_handler.dart';
import 'package:ambutrack_web/core/widgets/loading/app_loading_indicator.dart';
import 'package:ambutrack_web/core/widgets/tables/app_data_grid_v5.dart';
import 'package:ambutrack_web/features/tablas/provincias/presentation/bloc/provincia_bloc.dart';
import 'package:ambutrack_web/features/tablas/provincias/presentation/bloc/provincia_event.dart';
import 'package:ambutrack_web/features/tablas/provincias/presentation/bloc/provincia_state.dart';
import 'package:ambutrack_web/features/tablas/provincias/presentation/widgets/provincia_filters.dart';
import 'package:ambutrack_web/features/tablas/provincias/presentation/widgets/provincia_form_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

/// Tabla de gestión de Provincias
class ProvinciaTable extends StatefulWidget {
  const ProvinciaTable({
    super.key,
    required this.searchQuery,
    required this.filterData,
  });

  final String searchQuery;
  final ProvinciaFilterData filterData;

  @override
  State<ProvinciaTable> createState() => _ProvinciaTableState();
}

class _ProvinciaTableState extends State<ProvinciaTable> {
  int? _sortColumnIndex = 0;
  bool _sortAscending = true;
  bool _isDeleting = false;
  BuildContext? _loadingDialogContext;
  DateTime? _deleteStartTime;
  int _currentPage = 0;
  static const int _itemsPerPage = 25;

  @override
  void didUpdateWidget(ProvinciaTable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.searchQuery != widget.searchQuery ||
        oldWidget.filterData.comunidadId != widget.filterData.comunidadId) {
      _currentPage = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProvinciaBloc, ProvinciaState>(
      listener: (BuildContext context, Object? state) async {
        if (_isDeleting && _loadingDialogContext != null) {
          if (state is ProvinciaLoaded || state is ProvinciaError) {
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

            if (state is ProvinciaError) {
              await CrudOperationHandler.handleDeleteError(
                context: context,
                isDeleting: false,
                entityName: 'Provincia',
                errorMessage: state.message,
              );
            } else if (state is ProvinciaLoaded) {
              await CrudOperationHandler.handleDeleteSuccess(
                context: context,
                isDeleting: false,
                entityName: 'Provincia',
                durationMs: elapsed.inMilliseconds,
              );
            }
          }
        }
      },
      child: BlocBuilder<ProvinciaBloc, ProvinciaState>(
        builder: (BuildContext context, Object? state) {
          if (state is ProvinciaLoaded) {
            List<ProvinciaEntity> filtradas = _filterProvincias(state.provincias);
            filtradas = _sortProvincias(filtradas);

            final int totalItems = filtradas.length;
            final int totalPages = (totalItems / _itemsPerPage).ceil();
            final int startIndex = _currentPage * _itemsPerPage;
            final int endIndex = (startIndex + _itemsPerPage).clamp(0, totalItems);
            final List<ProvinciaEntity> provinciasPaginadas = totalItems > 0
                ? filtradas.sublist(startIndex, endIndex)
                : <ProvinciaEntity>[];

            final bool hasFilters = widget.searchQuery.isNotEmpty || widget.filterData.hasActiveFilters;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                if (state.provincias.length != filtradas.length && filtradas.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSizes.spacing),
                    child: Text(
                      'Mostrando ${filtradas.length} de ${state.provincias.length} provincias',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: AppColors.textSecondaryLight,
                      ),
                    ),
                  ),
                Expanded(
                  child: AppDataGridV5<ProvinciaEntity>(
                    columns: const <DataGridColumn>[
                      DataGridColumn(label: 'PROVINCIA', flexWidth: 2, sortable: true),
                      DataGridColumn(label: 'CÓDIGO', sortable: true),
                      DataGridColumn(label: 'COMUNIDAD AUTÓNOMA', flexWidth: 2, sortable: true),
                    ],
                    rows: provinciasPaginadas,
                    buildCells: (ProvinciaEntity provincia) => <DataGridCell>[
                      DataGridCell(child: _buildNombreCell(provincia)),
                      DataGridCell(child: _buildCodigoCell(provincia)),
                      DataGridCell(child: _buildComunidadCell(provincia)),
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
                        ? 'No se encontraron provincias con los filtros aplicados'
                        : 'No hay provincias registradas',
                    onEdit: (ProvinciaEntity provincia) => _editProvincia(context, provincia),
                    onDelete: (ProvinciaEntity provincia) => _confirmDelete(context, provincia),
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

  List<ProvinciaEntity> _filterProvincias(List<ProvinciaEntity> provincias) {
    List<ProvinciaEntity> result = provincias;

    result = widget.filterData.apply(result);

    if (widget.searchQuery.isNotEmpty) {
      final String query = widget.searchQuery.toLowerCase();
      result = result.where((ProvinciaEntity provincia) {
        return provincia.nombre.toLowerCase().contains(query) ||
            (provincia.codigo?.toLowerCase().contains(query) ?? false) ||
            (provincia.comunidadAutonoma?.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    return result;
  }

  List<ProvinciaEntity> _sortProvincias(List<ProvinciaEntity> provincias) {
    if (_sortColumnIndex == null) {
      return provincias;
    }

    final List<ProvinciaEntity> sorted = List<ProvinciaEntity>.from(provincias)
      ..sort((ProvinciaEntity a, ProvinciaEntity b) {
        int comparison = 0;

        switch (_sortColumnIndex) {
          case 0:
            comparison = a.nombre.compareTo(b.nombre);
          case 1:
            comparison = (a.codigo ?? '').compareTo(b.codigo ?? '');
          case 2:
            comparison = (a.comunidadAutonoma ?? '').compareTo(b.comunidadAutonoma ?? '');
          default:
            comparison = 0;
        }

        return _sortAscending ? comparison : -comparison;
      });

    return sorted;
  }

  // ==================== ACCIONES ====================

  Future<void> _editProvincia(BuildContext context, ProvinciaEntity provincia) async {
    await showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) => BlocProvider<ProvinciaBloc>.value(
        value: context.read<ProvinciaBloc>(),
        child: ProvinciaFormDialog(provincia: provincia),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, ProvinciaEntity provincia) async {
    final bool? confirmed = await showConfirmationDialog(
      context: context,
      title: 'Confirmar Eliminación',
      message: '¿Estás seguro de que deseas eliminar esta provincia? Esta acción no se puede deshacer.',
      itemDetails: <String, String>{
        'Provincia': provincia.nombre,
        if (provincia.codigo != null && provincia.codigo!.isNotEmpty)
          'Código': provincia.codigo!,
        if (provincia.comunidadAutonoma != null && provincia.comunidadAutonoma!.isNotEmpty)
          'Comunidad Autónoma': provincia.comunidadAutonoma!,
      },
    );

    if (confirmed == true && context.mounted) {
      debugPrint('🗑️ Eliminando provincia: ${provincia.nombre} (${provincia.id})');

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
              message: 'Eliminando provincia...',
              color: AppColors.emergency,
              icon: Icons.delete_forever,
            );
          },
        ),
      );

      if (context.mounted) {
        context.read<ProvinciaBloc>().add(ProvinciaDeleteRequested(provincia.id));
      }
    }
  }

  // ==================== CELL BUILDERS ====================

  Widget _buildNombreCell(ProvinciaEntity provincia) {
    return Text(
      provincia.nombre,
      style: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimaryLight,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildCodigoCell(ProvinciaEntity provincia) {
    return Text(
      provincia.codigo ?? '-',
      style: GoogleFonts.inter(
        fontSize: 13,
        color: AppColors.textSecondaryLight,
      ),
    );
  }

  Widget _buildComunidadCell(ProvinciaEntity provincia) {
    return Text(
      provincia.comunidadAutonoma ?? '-',
      style: GoogleFonts.inter(
        fontSize: 13,
        color: AppColors.textSecondaryLight,
      ),
    );
  }
}

/// Campo de búsqueda - usado desde la página
class ProvinciaSearchField extends StatefulWidget {
  const ProvinciaSearchField({
    super.key,
    required this.searchQuery,
    required this.onSearchChanged,
  });

  final String searchQuery;
  final void Function(String) onSearchChanged;

  @override
  State<ProvinciaSearchField> createState() => _ProvinciaSearchFieldState();
}

class _ProvinciaSearchFieldState extends State<ProvinciaSearchField> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.searchQuery);
  }

  @override
  void didUpdateWidget(ProvinciaSearchField oldWidget) {
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
        hintText: 'Buscar provincia...',
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
