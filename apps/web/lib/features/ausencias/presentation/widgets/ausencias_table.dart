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
import 'package:ambutrack_web/features/ausencias/presentation/bloc/ausencias_bloc.dart';
import 'package:ambutrack_web/features/ausencias/presentation/bloc/ausencias_event.dart';
import 'package:ambutrack_web/features/ausencias/presentation/bloc/ausencias_state.dart';
import 'package:ambutrack_web/features/ausencias/presentation/widgets/ausencia_form_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

/// Tabla de ausencias profesional con filtros integrados
class AusenciasTable extends StatefulWidget {
  const AusenciasTable({super.key});

  @override
  State<AusenciasTable> createState() => _AusenciasTableState();
}

class _AusenciasTableState extends State<AusenciasTable> {
  String _searchQuery = '';
  EstadoAusencia? _estadoFilter;
  bool _isDeleting = false;
  BuildContext? _loadingDialogContext;
  DateTime? _deleteStartTime;
  int? _sortColumnIndex;
  bool _sortAscending = true;

  // Paginación
  int _currentPage = 0;
  static const int _itemsPerPage = 25;

  List<AusenciaEntity> _applyFilters(List<AusenciaEntity> ausencias) {
    return ausencias.where((AusenciaEntity ausencia) {
      // Filtro de búsqueda (buscar en fechas, días, etc)
      if (_searchQuery.isNotEmpty) {
        final String query = _searchQuery.toLowerCase();
        final String searchableText = '${ausencia.fechaInicio} ${ausencia.fechaFin} ${ausencia.diasAusencia}';
        if (!searchableText.toLowerCase().contains(query)) {
          return false;
        }
      }

      // Filtro de estado
      if (_estadoFilter != null && ausencia.estado != _estadoFilter) {
        return false;
      }

      return true;
    }).toList();
  }

  List<AusenciaEntity> _applySorting(List<AusenciaEntity> data) {
    if (_sortColumnIndex == null) {
      return data;
    }

    final List<AusenciaEntity> sorted = List<AusenciaEntity>.from(data)
      ..sort((AusenciaEntity a, AusenciaEntity b) {
        int result = 0;
        switch (_sortColumnIndex) {
          case 0: // Fecha inicio
            result = a.fechaInicio.compareTo(b.fechaInicio);
          case 1: // Fecha fin
            result = a.fechaFin.compareTo(b.fechaFin);
          case 2: // Días
            result = a.diasAusencia.compareTo(b.diasAusencia);
          case 3: // Estado
            result = a.estado.index.compareTo(b.estado.index);
        }
        return _sortAscending ? result : -result;
      });
    return sorted;
  }

  void _onSort(int columnIndex, {required bool ascending}) {
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
    });
  }

  StatusBadgeType _getStatusBadgeType(EstadoAusencia estado) {
    switch (estado) {
      case EstadoAusencia.pendiente:
        return StatusBadgeType.warning;
      case EstadoAusencia.aprobada:
        return StatusBadgeType.disponible;
      case EstadoAusencia.rechazada:
        return StatusBadgeType.error;
      case EstadoAusencia.cancelada:
        return StatusBadgeType.inactivo;
    }
  }

  String _getEstadoLabel(EstadoAusencia estado) {
    switch (estado) {
      case EstadoAusencia.pendiente:
        return 'Pendiente';
      case EstadoAusencia.aprobada:
        return 'Aprobada';
      case EstadoAusencia.rechazada:
        return 'Rechazada';
      case EstadoAusencia.cancelada:
        return 'Cancelada';
    }
  }

  Future<void> _editAusencia(BuildContext context, AusenciaEntity ausencia) async {
    await showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return BlocProvider<AusenciasBloc>.value(
          value: context.read<AusenciasBloc>(),
          child: AusenciaFormDialog(ausencia: ausencia),
        );
      },
    );
  }

  Future<void> _confirmDelete(BuildContext context, AusenciaEntity ausencia) async {
    final bool? confirmed = await showConfirmationDialog(
      context: context,
      title: 'Confirmar Eliminación',
      message: '¿Estás seguro de que deseas eliminar esta ausencia? Esta acción no se puede deshacer.',
      itemDetails: <String, String>{
        'Fecha Inicio': _formatDate(ausencia.fechaInicio),
        'Fecha Fin': _formatDate(ausencia.fechaFin),
        'Días': ausencia.diasAusencia.toString(),
        'Estado': _getEstadoLabel(ausencia.estado),
      },
    );

    if (confirmed == true && context.mounted) {
      debugPrint('🗑️ Eliminando ausencia: ${ausencia.id}');

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
              message: 'Eliminando ausencia...',
              color: AppColors.emergency,
              icon: Icons.delete_forever,
            );
          },
        ),
      );

      if (context.mounted) {
        context.read<AusenciasBloc>().add(AusenciaDeleteRequested(ausencia.id));
      }
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AusenciasBloc, AusenciasState>(
      listener: (BuildContext context, AusenciasState state) {
        // Manejar resultado de eliminación
        if (_isDeleting && _loadingDialogContext != null) {
          if (state is AusenciasLoaded) {
            final Duration? elapsed = _deleteStartTime != null
                ? DateTime.now().difference(_deleteStartTime!)
                : null;

            CrudOperationHandler.handleDeleteSuccess(
              context: context,
              isDeleting: _isDeleting,
              entityName: 'Ausencia',
              durationMs: elapsed?.inMilliseconds ?? 0,
              onClose: () => setState(() {
                _isDeleting = false;
                _loadingDialogContext = null;
                _deleteStartTime = null;
              }),
            );
          } else if (state is AusenciasError) {
            CrudOperationHandler.handleDeleteError(
              context: context,
              isDeleting: _isDeleting,
              entityName: 'Ausencia',
              errorMessage: state.message,
              onClose: () => setState(() {
                _isDeleting = false;
                _loadingDialogContext = null;
                _deleteStartTime = null;
              }),
            );
          }
        }
      },
      child: BlocBuilder<AusenciasBloc, AusenciasState>(
        builder: (BuildContext context, AusenciasState state) {
          if (state is! AusenciasLoaded) {
            return const SizedBox.shrink();
          }

          // Aplicar filtros y ordenamiento
          List<AusenciaEntity> filteredData = _applyFilters(state.ausencias);
          filteredData = _applySorting(filteredData);

          // Calcular paginación
          final int totalItems = filteredData.length;
          final int totalPages = (totalItems / _itemsPerPage).ceil();
          final int startIndex = _currentPage * _itemsPerPage;
          final int endIndex = (startIndex + _itemsPerPage).clamp(0, totalItems);
          final List<AusenciaEntity> paginatedData = filteredData.sublist(startIndex, endIndex);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // Filtros
              _buildFilters(),
              const SizedBox(height: AppSizes.spacing),

              // Info de resultados filtrados
              if (state.ausencias.length != filteredData.length)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSizes.spacing),
                  child: Text(
                    'Mostrando ${filteredData.length} de ${state.ausencias.length} ausencias',
                    style: AppTextStyles.bodySmallSecondary,
                  ),
                ),

              // Tabla
              Expanded(
                child: AppDataGridV5<AusenciaEntity>(
                  columns: const <DataGridColumn>[
                    DataGridColumn(label: 'Fecha Inicio', sortable: true),
                    DataGridColumn(label: 'Fecha Fin', sortable: true),
                    DataGridColumn(label: 'Días', sortable: true),
                    DataGridColumn(label: 'Estado', sortable: true),
                  ],
                  rows: paginatedData,
                  buildCells: _buildCells,
                  sortColumnIndex: _sortColumnIndex,
                  sortAscending: _sortAscending,
                  onSort: _onSort,
                  onEdit: (AusenciaEntity ausencia) => _editAusencia(context, ausencia),
                  onDelete: (AusenciaEntity ausencia) => _confirmDelete(context, ausencia),
                  emptyMessage: _searchQuery.isNotEmpty || _estadoFilter != null
                      ? 'No se encontraron ausencias con los filtros aplicados'
                      : 'No hay ausencias registradas',
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
        },
      ),
    );
  }

  Widget _buildFilters() {
    return Row(
      children: <Widget>[
        // Búsqueda
        Expanded(
          child: TextField(
            onChanged: (String value) {
              setState(() {
                _searchQuery = value;
                _currentPage = 0;
              });
            },
            decoration: InputDecoration(
              hintText: 'Buscar ausencia...',
              prefixIcon: const Icon(Icons.search, size: 20),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSizes.paddingMedium,
                vertical: AppSizes.paddingSmall,
              ),
              isDense: true,
            ),
          ),
        ),
        const SizedBox(width: AppSizes.spacing),

        // Filtro de estado
        SizedBox(
          width: 200,
          child: DropdownButtonFormField<EstadoAusencia?>(
            initialValue: _estadoFilter,
            decoration: InputDecoration(
              labelText: 'Estado',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSizes.paddingMedium,
                vertical: AppSizes.paddingSmall,
              ),
              isDense: true,
            ),
            items: <DropdownMenuItem<EstadoAusencia?>>[
              const DropdownMenuItem<EstadoAusencia?>(
                child: Text('Todos'),
              ),
              ...EstadoAusencia.values.map((EstadoAusencia estado) {
                return DropdownMenuItem<EstadoAusencia?>(
                  value: estado,
                  child: Text(_getEstadoLabel(estado)),
                );
              }),
            ],
            onChanged: (EstadoAusencia? value) {
              setState(() {
                _estadoFilter = value;
                _currentPage = 0;
              });
            },
          ),
        ),

        // Botón limpiar filtros
        if (_searchQuery.isNotEmpty || _estadoFilter != null)
          Padding(
            padding: const EdgeInsets.only(left: AppSizes.spacing),
            child: IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                setState(() {
                  _searchQuery = '';
                  _estadoFilter = null;
                  _currentPage = 0;
                });
              },
              tooltip: 'Limpiar filtros',
            ),
          ),
      ],
    );
  }

  List<DataGridCell> _buildCells(AusenciaEntity ausencia) {
    return <DataGridCell>[
      DataGridCell(child: Text(_formatDate(ausencia.fechaInicio))),
      DataGridCell(child: Text(_formatDate(ausencia.fechaFin))),
      DataGridCell(
        child: Text(
          '${ausencia.diasAusencia} ${ausencia.diasAusencia == 1 ? 'día' : 'días'}',
        ),
      ),
      DataGridCell(
        child: StatusBadge(
          label: _getEstadoLabel(ausencia.estado),
          type: _getStatusBadgeType(ausencia.estado),
        ),
      ),
    ];
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
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            'Mostrando $startItem-$endItem de $totalItems ausencias',
            style: AppTextStyles.bodySmallSecondary,
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
                onPressed: currentPage < totalPages - 1 ? () => onPageChanged(currentPage + 1) : null,
                icon: Icons.chevron_right,
                tooltip: 'Página siguiente',
              ),
              const SizedBox(width: AppSizes.spacingSmall),
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
