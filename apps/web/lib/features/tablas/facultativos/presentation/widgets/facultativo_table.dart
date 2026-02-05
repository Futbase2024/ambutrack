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
import 'package:ambutrack_web/features/tablas/facultativos/presentation/bloc/facultativo_bloc.dart';
import 'package:ambutrack_web/features/tablas/facultativos/presentation/bloc/facultativo_event.dart';
import 'package:ambutrack_web/features/tablas/facultativos/presentation/bloc/facultativo_state.dart';
import 'package:ambutrack_web/features/tablas/facultativos/presentation/widgets/facultativo_form_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

/// Tabla de gestión de Facultativos
class FacultativoTable extends StatefulWidget {
  const FacultativoTable({super.key});

  @override
  State<FacultativoTable> createState() => _FacultativoTableState();
}

class _FacultativoTableState extends State<FacultativoTable> {
  String _searchQuery = '';
  int? _sortColumnIndex = 0; // Ordenar por Nombre por defecto
  bool _sortAscending = true;
  bool _isDeleting = false;
  BuildContext? _loadingDialogContext;
  DateTime? _deleteStartTime;
  int _currentPage = 0;
  static const int _itemsPerPage = 25;

  @override
  Widget build(BuildContext context) {
    return BlocListener<FacultativoBloc, FacultativoState>(
      listener: (BuildContext context, Object? state) async {
        // Manejo de loading al eliminar
        if (_isDeleting && _loadingDialogContext != null) {
          if (state is FacultativoLoaded || state is FacultativoError) {
            final Duration elapsed = DateTime.now().difference(_deleteStartTime!);

            // Manejar resultado con CrudOperationHandler
            if (state is FacultativoError) {
              await CrudOperationHandler.handleDeleteError(
                context: _loadingDialogContext!,
                isDeleting: _isDeleting,
                entityName: 'Facultativo',
                errorMessage: state.message,
                onClose: () {
                  setState(() {
                    _isDeleting = false;
                    _loadingDialogContext = null;
                    _deleteStartTime = null;
                  });
                },
              );
            } else if (state is FacultativoLoaded) {
              await CrudOperationHandler.handleDeleteSuccess(
                context: _loadingDialogContext!,
                isDeleting: _isDeleting,
                entityName: 'Facultativo',
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
      child: BlocBuilder<FacultativoBloc, FacultativoState>(
        builder: (BuildContext context, Object? state) {
          if (state is FacultativoLoading) {
            return const _LoadingView();
          }

          if (state is FacultativoError) {
            return _ErrorView(message: state.message);
          }

          if (state is FacultativoLoaded) {
            // Filtrado y ordenamiento
            List<FacultativoEntity> filtrados = _filterFacultativos(state.facultativos);
            filtrados = _sortFacultativos(filtrados);

            // Cálculo de paginación
            final int totalItems = filtrados.length;
            final int totalPages = (totalItems / _itemsPerPage).ceil();
            final int startIndex = _currentPage * _itemsPerPage;
            final int endIndex = (startIndex + _itemsPerPage).clamp(0, totalItems);
            final List<FacultativoEntity> facultativosPaginados = totalItems > 0
                ? filtrados.sublist(startIndex, endIndex)
                : <FacultativoEntity>[];

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                // Header: Título y búsqueda
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        'Listado de Facultativos',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimaryLight,
                        ),
                      ),
                    ),
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
                if (state.facultativos.length != filtrados.length)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSizes.spacing),
                    child: Text(
                      'Mostrando ${filtrados.length} de ${state.facultativos.length} facultativos',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: AppColors.textSecondaryLight,
                      ),
                    ),
                  ),

                // Tabla con scroll interno
                Expanded(
                  child: AppDataGridV5<FacultativoEntity>(
                    columns: const <DataGridColumn>[
                      DataGridColumn(label: 'NOMBRE', flexWidth: 2, sortable: true),
                      DataGridColumn(label: 'NÚM. COLEGIADO', sortable: true),
                      DataGridColumn(label: 'TELÉFONO'),
                      DataGridColumn(label: 'ESPECIALIDAD', flexWidth: 2),
                      DataGridColumn(label: 'ESTADO', sortable: true),
                    ],
                    rows: facultativosPaginados,
                    buildCells: (FacultativoEntity facultativo) => <DataGridCell>[
                      DataGridCell(child: _buildNombreCell(facultativo)),
                      DataGridCell(child: _buildColegiadoCell(facultativo)),
                      DataGridCell(child: _buildTelefonoCell(facultativo)),
                      DataGridCell(child: _buildEspecialidadCell(facultativo)),
                      DataGridCell(child: _buildEstadoCell(facultativo)),
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
                        ? 'No se encontraron facultativos con los filtros aplicados'
                        : 'No hay facultativos registrados',
                    onEdit: (FacultativoEntity facultativo) => _editFacultativo(context, facultativo),
                    onDelete: (FacultativoEntity facultativo) => _confirmDelete(context, facultativo),
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

  List<FacultativoEntity> _filterFacultativos(List<FacultativoEntity> facultativos) {
    if (_searchQuery.isEmpty) {
      return facultativos;
    }

    final String query = _searchQuery.toLowerCase();
    return facultativos.where((FacultativoEntity facultativo) {
      return facultativo.nombreCompleto.toLowerCase().contains(query) ||
          (facultativo.numColegiado?.toLowerCase().contains(query) ?? false) ||
          (facultativo.especialidadNombre?.toLowerCase().contains(query) ?? false) ||
          (facultativo.telefono?.toLowerCase().contains(query) ?? false) ||
          (facultativo.email?.toLowerCase().contains(query) ?? false);
    }).toList();
  }

  List<FacultativoEntity> _sortFacultativos(List<FacultativoEntity> facultativos) {
    if (_sortColumnIndex == null) {
      return facultativos;
    }

    final List<FacultativoEntity> sorted = List<FacultativoEntity>.from(facultativos)
      ..sort((FacultativoEntity a, FacultativoEntity b) {
        int comparison = 0;

        switch (_sortColumnIndex) {
          case 0: // Nombre
            comparison = a.nombreCompleto.compareTo(b.nombreCompleto);
          case 1: // Número de colegiado
            comparison = (a.numColegiado ?? '').compareTo(b.numColegiado ?? '');
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

  Future<void> _editFacultativo(BuildContext context, FacultativoEntity facultativo) async {
    await showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) => BlocProvider<FacultativoBloc>.value(
        value: context.read<FacultativoBloc>(),
        child: FacultativoFormDialog(facultativo: facultativo),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, FacultativoEntity facultativo) async {
    final bool? confirmed = await showConfirmationDialog(
      context: context,
      title: 'Confirmar Eliminación',
      message: '¿Estás seguro de que deseas eliminar este facultativo? Esta acción no se puede deshacer.',
      itemDetails: <String, String>{
        'Nombre': facultativo.nombre,
        'Apellidos': facultativo.apellidos,
        if (facultativo.numColegiado != null && facultativo.numColegiado!.isNotEmpty)
          'Nº Colegiado': facultativo.numColegiado!,
        if (facultativo.especialidadNombre != null && facultativo.especialidadNombre!.isNotEmpty)
          'Especialidad': facultativo.especialidadNombre!,
        if (facultativo.telefono != null && facultativo.telefono!.isNotEmpty)
          'Teléfono': facultativo.telefono!,
        if (facultativo.email != null && facultativo.email!.isNotEmpty)
          'Email': facultativo.email!,
        'Estado': facultativo.activo ? 'Activo' : 'Inactivo',
      },
    );

    if (confirmed == true && context.mounted) {
      debugPrint('🗑️ Eliminando facultativo: ${facultativo.nombreCompleto} (${facultativo.id})');

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
              message: 'Eliminando facultativo...',
              color: AppColors.emergency,
              icon: Icons.delete_forever,
            );
          },
        ),
      );

      if (context.mounted) {
        context.read<FacultativoBloc>().add(FacultativoDeleteRequested(facultativo.id));
      }
    }
  }

  // ==================== CELL BUILDERS ====================

  Widget _buildNombreCell(FacultativoEntity facultativo) {
    return Text(
      facultativo.nombreCompleto,
      style: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimaryLight,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildColegiadoCell(FacultativoEntity facultativo) {
    return Text(
      facultativo.numColegiado ?? '-',
      style: GoogleFonts.inter(
        fontSize: 13,
        color: facultativo.numColegiado != null
            ? AppColors.textSecondaryLight
            : AppColors.textSecondaryLight.withValues(alpha: 0.5),
        fontStyle: facultativo.numColegiado != null ? FontStyle.normal : FontStyle.italic,
      ),
    );
  }

  Widget _buildTelefonoCell(FacultativoEntity facultativo) {
    return Text(
      facultativo.telefono ?? '-',
      style: GoogleFonts.inter(
        fontSize: 13,
        color: facultativo.telefono != null
            ? AppColors.textSecondaryLight
            : AppColors.textSecondaryLight.withValues(alpha: 0.5),
        fontStyle: facultativo.telefono != null ? FontStyle.normal : FontStyle.italic,
      ),
    );
  }

  Widget _buildEspecialidadCell(FacultativoEntity facultativo) {
    return Text(
      facultativo.especialidadNombre ?? 'Sin especialidad',
      style: GoogleFonts.inter(
        fontSize: 13,
        color: facultativo.especialidadNombre != null
            ? AppColors.textSecondaryLight
            : AppColors.textSecondaryLight.withValues(alpha: 0.5),
        fontStyle: facultativo.especialidadNombre != null ? FontStyle.normal : FontStyle.italic,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildEstadoCell(FacultativoEntity facultativo) {
    return Container(
      width: double.infinity,
      alignment: Alignment.center,
      child: StatusBadge(
        label: facultativo.activo ? 'Activo' : 'Inactivo',
        type: facultativo.activo ? StatusBadgeType.success : StatusBadgeType.inactivo,
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
        hintText: 'Buscar facultativo...',
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
          message: 'Cargando facultativos...',
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
            'Error al cargar facultativos',
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
