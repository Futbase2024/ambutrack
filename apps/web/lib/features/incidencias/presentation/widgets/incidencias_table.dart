import 'dart:async';

import 'package:ambutrack_core_datasource/incidencias.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/core/widgets/badges/status_badge.dart';
import 'package:ambutrack_web/core/widgets/data_grid/app_data_grid.dart';
import 'package:ambutrack_web/core/widgets/dialogs/confirmation_dialog.dart';
import 'package:ambutrack_web/core/widgets/loading/app_loading_indicator.dart';
import 'package:ambutrack_web/features/incidencias/presentation/bloc/incidencia/incidencia_bloc.dart';
import 'package:ambutrack_web/features/incidencias/presentation/bloc/incidencia/incidencia_event.dart';
import 'package:ambutrack_web/features/incidencias/presentation/bloc/incidencia/incidencia_state.dart';
import 'package:ambutrack_web/features/incidencias/presentation/widgets/incidencia_form_dialog.dart';
import 'package:ambutrack_web/features/vehiculos/presentation/bloc/vehiculos_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:nested/nested.dart' show SingleChildWidget;

/// Tabla de incidencias con paginación y CRUD
class IncidenciasTable extends StatefulWidget {
  const IncidenciasTable({super.key});

  @override
  State<IncidenciasTable> createState() => _IncidenciasTableState();
}

class _IncidenciasTableState extends State<IncidenciasTable> {
  int _currentPage = 0;
  final int _itemsPerPage = 25;
  int _sortColumnIndex = 4;
  bool _sortAscending = false;
  bool _isDeleting = false;

  static final DateFormat _dateFormat = DateFormat('dd/MM/yyyy HH:mm');

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<IncidenciaBloc, IncidenciaState>(
      listener: (BuildContext context, IncidenciaState state) async {
        if (_isDeleting) {
          Navigator.of(context, rootNavigator: true).pop();
          _isDeleting = false;

          await Future<void>.delayed(const Duration(milliseconds: 100));

          if (!context.mounted) {
            return;
          }

          if (state is IncidenciaError) {
            _showResultDialog(
              context,
              title: 'Error al eliminar',
              message: state.message,
              isError: true,
            );
          } else if (state is IncidenciaLoaded) {
            _showResultDialog(
              context,
              title: 'Incidencia eliminada',
              message: 'La incidencia se ha eliminado correctamente.',
              isError: false,
            );
          }
        }
      },
      builder: (BuildContext context, IncidenciaState state) {
        if (state is IncidenciaInitial || state is IncidenciaLoading) {
          return const _LoadingView();
        }
        if (state is IncidenciaError) {
          return _ErrorView(message: state.message);
        }
        if (state is IncidenciaLoaded) {
          final List<IncidenciaEntity> filtered = state.filteredIncidencias;

          return DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
              border: Border.all(color: AppColors.gray200),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: AppColors.gray200.withValues(alpha: 0.5),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Expanded(
                  child: filtered.isEmpty
                      ? _EmptyView(hasFilters: state.filters.hasActiveFilters)
                      : _buildDataGrid(context, filtered),
                ),
                if (filtered.isNotEmpty)
                  _PaginationBar(
                    currentPage: _currentPage,
                    totalPages: (filtered.length / _itemsPerPage).ceil(),
                    totalItems: filtered.length,
                    itemsPerPage: _itemsPerPage,
                    onPageChanged: (int page) =>
                        setState(() => _currentPage = page),
                  ),
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildDataGrid(BuildContext context, List<IncidenciaEntity> items) {
    final int start = _currentPage * _itemsPerPage;
    final int end = (start + _itemsPerPage).clamp(0, items.length);
    final List<IncidenciaEntity> pageItems = items.sublist(start, end);
    final List<IncidenciaEntity> sorted = _sortItems(pageItems);

    final List<AppDataRow<IncidenciaEntity>> rows = sorted
        .map((IncidenciaEntity item) => AppDataRow<IncidenciaEntity>(
              data: item,
              cells: _buildCells(item),
            ))
        .toList();

    return AppDataGrid<IncidenciaEntity>(
      columns: _buildColumns(),
      rows: rows,
      showActions: true,
      onEdit: (IncidenciaEntity item) => _editIncidencia(context, item),
      onDelete: (IncidenciaEntity item) => _confirmDelete(context, item),
      sortColumnIndex: _sortColumnIndex,
      sortAscending: _sortAscending,
      onSort: (int columnIndex, {required bool ascending}) {
        setState(() {
          _sortColumnIndex = columnIndex;
          _sortAscending = ascending;
        });
      },
    );
  }

  List<AppDataColumn> _buildColumns() {
    return const <AppDataColumn>[
      AppDataColumn(label: 'Título', sortable: true),
      AppDataColumn(label: 'Categoría', sortable: true),
      AppDataColumn(label: 'Prioridad', sortable: true),
      AppDataColumn(label: 'Estado', sortable: true),
      AppDataColumn(label: 'Fecha', sortable: true),
      AppDataColumn(label: 'Responsable', sortable: true),
    ];
  }

  List<Widget> _buildCells(IncidenciaEntity item) {
    return <Widget>[
      AppDataCell.text(item.titulo, fontWeight: FontWeight.w500),
      AppDataCell.badge(item.categoria.displayName,
          color: _getCategoriaColor(item.categoria)),
      AppDataCell.badge(item.prioridad.displayName,
          color: _getPrioridadColor(item.prioridad)),
      StatusBadge(
        label: item.estado.displayName,
        type: _getEstadoBadgeType(item.estado),
      ),
      AppDataCell.text(_dateFormat.format(item.fechaIncidencia)),
      AppDataCell.text(
        item.responsableNombre ?? '—',
        color: item.responsableNombre != null
            ? AppColors.textPrimaryLight
            : AppColors.gray400,
      ),
    ];
  }

  Color _getCategoriaColor(CategoriaIncidencia c) {
    switch (c) {
      case CategoriaIncidencia.servicio:
        return AppColors.primary;
      case CategoriaIncidencia.vehiculo:
        return AppColors.averia;
      case CategoriaIncidencia.personal:
        return AppColors.secondary;
      case CategoriaIncidencia.instalacion:
        return AppColors.warning;
      case CategoriaIncidencia.equipamiento:
        return AppColors.info;
      case CategoriaIncidencia.otro:
        return AppColors.gray500;
    }
  }

  Color _getPrioridadColor(PrioridadIncidencia p) {
    switch (p) {
      case PrioridadIncidencia.critica:
        return AppColors.error;
      case PrioridadIncidencia.alta:
        return AppColors.highPriority;
      case PrioridadIncidencia.media:
        return AppColors.mediumPriority;
      case PrioridadIncidencia.baja:
        return AppColors.lowPriority;
    }
  }

  StatusBadgeType _getEstadoBadgeType(EstadoIncidencia e) {
    switch (e) {
      case EstadoIncidencia.reportada:
        return StatusBadgeType.warning;
      case EstadoIncidencia.enProceso:
        return StatusBadgeType.enServicio;
      case EstadoIncidencia.resuelta:
        return StatusBadgeType.success;
      case EstadoIncidencia.cerrada:
        return StatusBadgeType.inactivo;
    }
  }

  List<IncidenciaEntity> _sortItems(List<IncidenciaEntity> items) {
    final List<IncidenciaEntity> sorted = List<IncidenciaEntity>.from(items)
      ..sort((IncidenciaEntity a, IncidenciaEntity b) {
        int result = 0;
        switch (_sortColumnIndex) {
          case 0:
            result = a.titulo.compareTo(b.titulo);
          case 1:
            result = a.categoria.displayName
                .compareTo(b.categoria.displayName);
          case 2:
            result = a.prioridad.index.compareTo(b.prioridad.index);
          case 3:
            result = a.estado.displayName.compareTo(b.estado.displayName);
          case 4:
            result = a.fechaIncidencia.compareTo(b.fechaIncidencia);
          case 5:
            result = (a.responsableNombre ?? '')
                .compareTo(b.responsableNombre ?? '');
          default:
            result = 0;
        }
        return _sortAscending ? result : -result;
      });
    return sorted;
  }

  void _editIncidencia(BuildContext context, IncidenciaEntity incidencia) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) => MultiBlocProvider(
        providers: <SingleChildWidget>[
          BlocProvider<IncidenciaBloc>.value(
            value: context.read<IncidenciaBloc>(),
          ),
          BlocProvider<VehiculosBloc>.value(
            value: context.read<VehiculosBloc>(),
          ),
        ],
        child: IncidenciaFormDialog(
          incidencia: incidencia,
          onSave: (IncidenciaEntity entity) async {
            context
                .read<IncidenciaBloc>()
                .add(IncidenciaUpdateRequested(entity));
            return;
          },
        ),
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    IncidenciaEntity incidencia,
  ) async {
    final bool? confirmed = await showSimpleConfirmationDialog(
      context: context,
      title: 'Eliminar Incidencia',
      message:
          '¿Estás seguro de que deseas eliminar la incidencia "${incidencia.titulo}"?\n\n'
          'Esta acción no se puede deshacer.',
      confirmText: 'Eliminar',
      icon: Icons.delete_outline,
    );

    if (confirmed == true && context.mounted) {
      setState(() => _isDeleting = true);
      unawaited(showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (_) => const AppLoadingOverlay(
          message: 'Eliminando incidencia...',
        ),
      ));
      if (context.mounted) {
        context
            .read<IncidenciaBloc>()
            .add(IncidenciaDeleteRequested(incidencia.id));
      }
    }
  }

  void _showResultDialog(
    BuildContext context, {
    required String title,
    required String message,
    required bool isError,
  }) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              size: AppSizes.iconMassive,
              color: isError ? AppColors.error : AppColors.success,
            ),
            const SizedBox(height: AppSizes.spacingMedium),
            Text(
              title,
              style: const TextStyle(
                fontSize: AppSizes.fontMedium,
                fontWeight: FontWeight.w700,
                color: AppColors.gray900,
              ),
            ),
            const SizedBox(height: AppSizes.spacingSmall),
            Text(
              message,
              style: const TextStyle(
                fontSize: AppSizes.fontSmall,
                color: AppColors.gray600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }
}

// ==================== PAGINACIÓN ====================

/// Barra de paginación profesional
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
  final ValueChanged<int> onPageChanged;

  @override
  Widget build(BuildContext context) {
    final int startItem =
        totalItems == 0 ? 0 : currentPage * itemsPerPage + 1;
    final int endItem =
        ((currentPage + 1) * itemsPerPage).clamp(0, totalItems);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.padding,
        vertical: AppSizes.paddingSmall + 4,
      ),
      decoration: const BoxDecoration(
        color: AppColors.gray50,
        border: Border(top: BorderSide(color: AppColors.gray200)),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(AppSizes.radiusLarge),
          bottomRight: Radius.circular(AppSizes.radiusLarge),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            'Mostrando $startItem-$endItem de $totalItems',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.gray500,
            ),
          ),
          Row(
            children: <Widget>[
              _PageButton(
                icon: Icons.chevron_left,
                enabled: currentPage > 0,
                onPressed: () => onPageChanged(currentPage - 1),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${currentPage + 1} / $totalPages',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              _PageButton(
                icon: Icons.chevron_right,
                enabled: currentPage < totalPages - 1,
                onPressed: () => onPageChanged(currentPage + 1),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Botón de navegación de página
class _PageButton extends StatelessWidget {
  const _PageButton({
    required this.icon,
    required this.enabled,
    required this.onPressed,
  });

  final IconData icon;
  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon, size: 18),
      padding: const EdgeInsets.all(8),
      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
      color: enabled ? AppColors.gray600 : AppColors.gray300,
      onPressed: enabled ? onPressed : null,
    );
  }
}

// ==================== VISTAS AUXILIARES ====================

/// Vista de carga
class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
        border: Border.all(color: AppColors.gray200),
      ),
      child: const Center(
        child: AppLoadingIndicator(message: 'Cargando incidencias...'),
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
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
        border: Border.all(color: AppColors.error),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingXl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(Icons.error_outline, color: AppColors.error, size: 48),
            const SizedBox(height: AppSizes.spacing),
            Text(
              'Error al cargar incidencias',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: AppSizes.spacingSmall),
            Text(
              message,
              style: GoogleFonts.inter(
                  fontSize: 13, color: AppColors.textSecondaryLight),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSizes.spacing),
            ElevatedButton.icon(
              onPressed: () => context
                  .read<IncidenciaBloc>()
                  .add(const IncidenciaLoadAllRequested()),
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Vista vacía
class _EmptyView extends StatelessWidget {
  const _EmptyView({required this.hasFilters});

  final bool hasFilters;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            hasFilters ? Icons.search_off : Icons.report_problem_outlined,
            size: 48,
            color: AppColors.gray300,
          ),
          const SizedBox(height: AppSizes.spacing),
          Text(
            hasFilters
                ? 'No se encontraron resultados'
                : 'No hay incidencias registradas',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.gray500,
            ),
          ),
        ],
      ),
    );
  }
}
