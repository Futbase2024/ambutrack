import 'dart:async';

import 'package:ambutrack_core/ambutrack_core.dart';
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
  const ProvinciaTable({super.key});

  @override
  State<ProvinciaTable> createState() => _ProvinciaTableState();
}

class _ProvinciaTableState extends State<ProvinciaTable> {
  String _searchQuery = '';
  ProvinciaFilterData _filterData = const ProvinciaFilterData();
  int? _sortColumnIndex = 0; // Ordenar por PROVINCIA por defecto
  bool _sortAscending = true;
  bool _isDeleting = false;
  BuildContext? _loadingDialogContext;
  DateTime? _deleteStartTime;
  int _currentPage = 0;
  static const int _itemsPerPage = 25;

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProvinciaBloc, ProvinciaState>(
      listener: (BuildContext context, Object? state) async {
        // Manejo de loading al eliminar
        if (_isDeleting && _loadingDialogContext != null) {
          if (state is ProvinciaLoaded || state is ProvinciaError) {
            final Duration elapsed = DateTime.now().difference(_deleteStartTime!);

            // Manejar resultado con CrudOperationHandler
            if (state is ProvinciaError) {
              await CrudOperationHandler.handleDeleteError(
                context: _loadingDialogContext!,
                isDeleting: _isDeleting,
                entityName: 'Provincia',
                errorMessage: state.message,
                onClose: () {
                  setState(() {
                    _isDeleting = false;
                    _loadingDialogContext = null;
                    _deleteStartTime = null;
                  });
                },
              );
            } else if (state is ProvinciaLoaded) {
              await CrudOperationHandler.handleDeleteSuccess(
                context: _loadingDialogContext!,
                isDeleting: _isDeleting,
                entityName: 'Provincia',
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
      child: BlocBuilder<ProvinciaBloc, ProvinciaState>(
        builder: (BuildContext context, Object? state) {
          if (state is ProvinciaLoading) {
            return const _LoadingView();
          }

          if (state is ProvinciaError) {
            return _ErrorView(message: state.message);
          }

          if (state is ProvinciaLoaded) {
            // Filtrado y ordenamiento
            List<ProvinciaEntity> filtradas = _filterProvincias(state.provincias);
            filtradas = _sortProvincias(filtradas);

            // Cálculo de paginación
            final int totalItems = filtradas.length;
            final int totalPages = (totalItems / _itemsPerPage).ceil();
            final int startIndex = _currentPage * _itemsPerPage;
            final int endIndex = (startIndex + _itemsPerPage).clamp(0, totalItems);
            final List<ProvinciaEntity> provinciasPaginadas = totalItems > 0
                ? filtradas.sublist(startIndex, endIndex)
                : <ProvinciaEntity>[];

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                // Header: Filtros y búsqueda
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        'Listado de Provincias',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimaryLight,
                        ),
                      ),
                    ),
                    // Filtros
                    ProvinciaFilters(
                      onFiltersChanged: (ProvinciaFilterData filterData) {
                        setState(() {
                          _filterData = filterData;
                          _currentPage = 0; // Reset a primera página al filtrar
                        });
                      },
                    ),
                    const SizedBox(width: AppSizes.spacing),
                    // Búsqueda
                    SizedBox(
                      width: 250,
                      child: _SearchField(
                        searchQuery: _searchQuery,
                        onSearchChanged: (String query) {
                          setState(() {
                            _searchQuery = query;
                            _currentPage = 0; // Reset a primera página al buscar
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.spacing),

                // Info de resultados filtrados
                if (state.provincias.length != filtradas.length)
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

                // Tabla con scroll interno
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
                    rowHeight: 64,
                    outerBorderColor: AppColors.gray300,
                    emptyMessage: _searchQuery.isNotEmpty || _filterData.hasActiveFilters
                        ? 'No se encontraron provincias con los filtros aplicados'
                        : 'No hay provincias registradas',
                    onEdit: (ProvinciaEntity provincia) => _editProvincia(context, provincia),
                    onDelete: (ProvinciaEntity provincia) => _confirmDelete(context, provincia),
                  ),
                ),

                // Paginación (siempre visible)
                const SizedBox(height: AppSizes.spacing),
                _buildPaginationControls(
                  currentPage: _currentPage,
                  totalPages: totalPages.clamp(1, 999),
                  totalItems: totalItems,
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

  // ==================== PAGINACIÓN ====================

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
            'Mostrando $startItem-$endItem de $totalItems items',
            style: AppTextStyles.bodySmallSecondary,
          ),

          // Botones de navegación
          Row(
            children: <Widget>[
              // Primera página
              IconButton(
                icon: const Icon(Icons.first_page),
                onPressed: currentPage > 0
                    ? () => onPageChanged(0)
                    : null,
                tooltip: 'Primera página',
              ),

              // Página anterior
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: currentPage > 0
                    ? () => onPageChanged(currentPage - 1)
                    : null,
                tooltip: 'Página anterior',
              ),

              // Indicador de página
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.paddingMedium,
                  vertical: AppSizes.paddingSmall,
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

              // Página siguiente
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: currentPage < totalPages - 1
                    ? () => onPageChanged(currentPage + 1)
                    : null,
                tooltip: 'Página siguiente',
              ),

              // Última página
              IconButton(
                icon: const Icon(Icons.last_page),
                onPressed: currentPage < totalPages - 1
                    ? () => onPageChanged(totalPages - 1)
                    : null,
                tooltip: 'Última página',
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==================== FILTRADO Y ORDENAMIENTO ====================

  List<ProvinciaEntity> _filterProvincias(List<ProvinciaEntity> provincias) {
    List<ProvinciaEntity> result = provincias;

    // Aplicar filtros de ProvinciaFilterData
    result = _filterData.apply(result);

    // Aplicar búsqueda por texto
    if (_searchQuery.isNotEmpty) {
      final String query = _searchQuery.toLowerCase();
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
          case 0: // Provincia
            comparison = a.nombre.compareTo(b.nombre);
          case 1: // Código
            comparison = (a.codigo ?? '').compareTo(b.codigo ?? '');
          case 2: // Comunidad Autónoma
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
          message: 'Cargando provincias...',
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
            'Error al cargar provincias',
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
