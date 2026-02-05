import 'dart:async';

import 'package:ambutrack_core/ambutrack_core.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/core/theme/app_text_styles.dart';
import 'package:ambutrack_web/core/widgets/badges/status_badge.dart';
import 'package:ambutrack_web/core/widgets/dialogs/confirmation_dialog.dart';
import 'package:ambutrack_web/core/widgets/handlers/crud_operation_handler.dart';
import 'package:ambutrack_web/core/widgets/loading/app_loading_indicator.dart';
import 'package:ambutrack_web/core/widgets/tables/app_data_grid_v5.dart';
import 'package:ambutrack_web/features/cuadrante/bases/presentation/bloc/bloc.dart';
import 'package:ambutrack_web/features/cuadrante/bases/presentation/widgets/base_form_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

/// Tabla de gestión de Bases/Centros
class BasesTable extends StatefulWidget {
  const BasesTable({super.key});

  @override
  State<BasesTable> createState() => _BasesTableState();
}

class _BasesTableState extends State<BasesTable> {
  String _searchQuery = '';
  int? _sortColumnIndex;
  bool _sortAscending = true;
  bool _isDeleting = false;
  BuildContext? _loadingDialogContext;
  DateTime? _deleteStartTime;
  int _currentPage = 0;
  static const int _itemsPerPage = 25;

  @override
  Widget build(BuildContext context) {
    return BlocListener<BasesBloc, BasesState>(
      listener: (BuildContext context, Object? state) async {
        // Manejo de loading al eliminar/desactivar
        if (_isDeleting && _loadingDialogContext != null) {
          if (state is BasesLoaded || state is BasesError || state is BaseOperationSuccess) {
            final Duration elapsed = DateTime.now().difference(_deleteStartTime!);

            // Manejar resultado con CrudOperationHandler
            if (state is BasesError) {
              await CrudOperationHandler.handleDeleteError(
                context: _loadingDialogContext!,
                isDeleting: _isDeleting,
                entityName: 'Base',
                errorMessage: state.message,
                onClose: () {
                  setState(() {
                    _isDeleting = false;
                    _loadingDialogContext = null;
                    _deleteStartTime = null;
                  });
                },
              );
            } else if (state is BaseOperationSuccess) {
              await CrudOperationHandler.handleDeleteSuccess(
                context: _loadingDialogContext!,
                isDeleting: _isDeleting,
                entityName: 'Base',
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
      child: BlocBuilder<BasesBloc, BasesState>(
        builder: (BuildContext context, Object? state) {
          if (state is BasesLoading) {
            return const _LoadingView();
          }

          if (state is BasesError) {
            return _ErrorView(message: state.message);
          }

          if (state is BasesLoaded || state is BaseOperationSuccess) {
            final List<BaseCentroEntity> bases = state is BasesLoaded
                ? state.bases
                : (state as BaseOperationSuccess).bases;

            // Filtrado y ordenamiento
            List<BaseCentroEntity> filtradas = _filterBases(bases);
            filtradas = _sortBases(filtradas);

            // Cálculo de paginación
            final int totalItems = filtradas.length;
            final int totalPages = (totalItems / _itemsPerPage).ceil();
            final int startIndex = _currentPage * _itemsPerPage;
            final int endIndex = (startIndex + _itemsPerPage).clamp(0, totalItems);
            final List<BaseCentroEntity> basesPaginadas = totalItems > 0
                ? filtradas.sublist(startIndex, endIndex)
                : <BaseCentroEntity>[];

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                // Header: Búsqueda
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        'Listado de Bases',
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
                            _currentPage = 0; // Reset a primera página al filtrar
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.spacing),

                // Info de resultados filtrados
                if (bases.length != filtradas.length)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSizes.spacing),
                    child: Text(
                      'Mostrando ${filtradas.length} de ${bases.length} bases',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: AppColors.textSecondaryLight,
                      ),
                    ),
                  ),

                // Tabla con scroll interno
                Expanded(
                  child: AppDataGridV5<BaseCentroEntity>(
                    columns: const <DataGridColumn>[
                      DataGridColumn(label: 'NOMBRE', flexWidth: 2, sortable: true),
                      DataGridColumn(label: 'DIRECCIÓN'),
                      DataGridColumn(label: 'POBLACIÓN', sortable: true),
                      DataGridColumn(label: 'TIPO', sortable: true),
                      DataGridColumn(label: 'ESTADO', sortable: true),
                    ],
                    rows: basesPaginadas,
                    buildCells: (BaseCentroEntity base) => <DataGridCell>[
                      DataGridCell(child: _buildNombreCell(base)),
                      DataGridCell(child: _buildDireccionCell(base)),
                      DataGridCell(child: _buildPoblacionCell(base)),
                      DataGridCell(child: _buildTipoCell(base)),
                      DataGridCell(child: _buildEstadoCell(base)),
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
                        ? 'No se encontraron bases con los filtros aplicados'
                        : 'No hay bases registradas',
                    onEdit: (BaseCentroEntity base) => _editBase(context, base),
                    onDelete: (BaseCentroEntity base) => _confirmDelete(context, base),
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

  List<BaseCentroEntity> _filterBases(List<BaseCentroEntity> bases) {
    if (_searchQuery.isEmpty) {
      return bases;
    }

    final String query = _searchQuery.toLowerCase();
    return bases.where((BaseCentroEntity base) {
      return base.nombre.toLowerCase().contains(query) ||
          (base.direccion?.toLowerCase().contains(query) ?? false) ||
          (base.poblacionNombre?.toLowerCase().contains(query) ?? false) ||
          (base.tipo?.toLowerCase().contains(query) ?? false);
    }).toList();
  }

  List<BaseCentroEntity> _sortBases(List<BaseCentroEntity> bases) {
    if (_sortColumnIndex == null) {
      return bases;
    }

    final List<BaseCentroEntity> sorted = List<BaseCentroEntity>.from(bases)
      ..sort((BaseCentroEntity a, BaseCentroEntity b) {
        int comparison = 0;

        switch (_sortColumnIndex) {
          case 0: // Nombre
            comparison = a.nombre.compareTo(b.nombre);
          case 2: // Población
            comparison = (a.poblacionNombre ?? '').compareTo(b.poblacionNombre ?? '');
          case 3: // Tipo
            comparison = (a.tipo ?? '').compareTo(b.tipo ?? '');
          case 4: // Estado
            comparison = a.activo == b.activo ? 0 : (a.activo ? -1 : 1);
          default:
            comparison = 0;
        }

        return _sortAscending ? comparison : -comparison;
      });

    return sorted;
  }

  // ==================== ACCIONES ====================

  Future<void> _editBase(BuildContext context, BaseCentroEntity base) async {
    await showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) => BlocProvider<BasesBloc>.value(
        value: context.read<BasesBloc>(),
        child: BaseFormDialog(base: base),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, BaseCentroEntity base) async {
    final bool? confirmed = await showConfirmationDialog(
      context: context,
      title: 'Confirmar Eliminación',
      message: '¿Estás seguro de que deseas ${base.activo ? 'desactivar' : 'activar'} esta base? ${base.activo ? 'Esta acción no se puede deshacer.' : ''}',
      itemDetails: <String, String>{
        if (base.codigo != null && base.codigo!.isNotEmpty)
          'Código': base.codigo!,
        'Nombre': base.nombre,
        if (base.direccion != null && base.direccion!.isNotEmpty)
          'Dirección': base.direccion!,
        if (base.poblacionNombre != null && base.poblacionNombre!.isNotEmpty)
          'Población': base.poblacionNombre!,
        if (base.tipo != null && base.tipo!.isNotEmpty)
          'Tipo': base.tipo!,
        'Estado': base.activo ? 'Activo' : 'Inactivo',
      },
    );

    if (confirmed == true && context.mounted) {
      debugPrint('🗑️ ${base.activo ? 'Desactivando' : 'Activando'} base: ${base.nombre} (${base.id})');

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

            return AppLoadingOverlay(
              message: '${base.activo ? 'Desactivando' : 'Activando'} base...',
              color: base.activo ? AppColors.emergency : AppColors.success,
              icon: base.activo ? Icons.block : Icons.check_circle,
            );
          },
        ),
      );

      if (context.mounted) {
        if (base.activo) {
          context.read<BasesBloc>().add(BaseDeactivateRequested(base.id));
        } else {
          // Reactivar: crear una copia con activo = true
          final BaseCentroEntity reactivated = base.copyWith(activo: true, updatedAt: DateTime.now());
          context.read<BasesBloc>().add(BaseUpdateRequested(reactivated));
        }
      }
    }
  }

  // ==================== CELL BUILDERS ====================

  Widget _buildNombreCell(BaseCentroEntity base) {
    return Text(
      base.nombre,
      style: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimaryLight,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildDireccionCell(BaseCentroEntity base) {
    return Text(
      base.direccion ?? '-',
      style: GoogleFonts.inter(
        fontSize: 13,
        color: AppColors.textSecondaryLight,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildPoblacionCell(BaseCentroEntity base) {
    return Text(
      base.poblacionNombre ?? '-',
      style: GoogleFonts.inter(
        fontSize: 13,
        color: AppColors.textSecondaryLight,
      ),
    );
  }

  Widget _buildTipoCell(BaseCentroEntity base) {
    return Text(
      base.tipo ?? '-',
      style: GoogleFonts.inter(
        fontSize: 13,
        color: AppColors.textSecondaryLight,
      ),
    );
  }

  Widget _buildEstadoCell(BaseCentroEntity base) {
    return Container(
      width: double.infinity,
      alignment: Alignment.center,
      child: StatusBadge(
        label: base.activo ? 'Activo' : 'Inactivo',
        type: base.activo ? StatusBadgeType.success : StatusBadgeType.inactivo,
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
        hintText: 'Buscar base...',
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
          message: 'Cargando bases...',
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
            'Error al cargar bases',
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
