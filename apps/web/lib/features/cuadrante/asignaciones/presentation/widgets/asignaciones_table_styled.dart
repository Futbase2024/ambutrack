import 'dart:async';

import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/core/theme/app_text_styles.dart';
import 'package:ambutrack_web/core/widgets/dialogs/confirmation_dialog.dart';
import 'package:ambutrack_web/core/widgets/handlers/crud_operation_handler.dart';
import 'package:ambutrack_web/core/widgets/loading/app_loading_indicator.dart';
import 'package:ambutrack_web/features/cuadrante/asignaciones/presentation/bloc/asignaciones/asignaciones_bloc.dart';
import 'package:ambutrack_web/features/cuadrante/asignaciones/presentation/bloc/asignaciones/asignaciones_event.dart';
import 'package:ambutrack_web/features/cuadrante/asignaciones/presentation/bloc/asignaciones/asignaciones_state.dart';
import 'package:ambutrack_web/features/cuadrante/asignaciones/presentation/widgets/asignacion_form_dialog.dart';
import 'package:ambutrack_web/features/cuadrante/asignaciones/presentation/widgets/asignaciones_filters.dart';
import 'package:ambutrack_web/features/cuadrante/asignaciones/presentation/widgets/asignaciones_table_cells.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

/// Tabla de gestión de Asignaciones con agrupación por fecha
class AsignacionesTableStyled extends StatefulWidget {
  const AsignacionesTableStyled({
    super.key,
    required this.filterData,
  });

  final AsignacionesFilterData filterData;

  @override
  State<AsignacionesTableStyled> createState() =>
      _AsignacionesTableStyledState();
}

class _AsignacionesTableStyledState extends State<AsignacionesTableStyled> {
  bool _isDeleting = false;
  BuildContext? _loadingDialogContext;
  DateTime? _deleteStartTime;
  int _currentPage = 0;
  static const int _itemsPerPage = 25;
  final Map<String, bool> _expandedGroups = <String, bool>{};

  @override
  void didUpdateWidget(covariant AsignacionesTableStyled oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.filterData != oldWidget.filterData) {
      _currentPage = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AsignacionesBloc, AsignacionesState>(
      listener: (BuildContext context, AsignacionesState state) async {
        if (_isDeleting && _loadingDialogContext != null) {
          if (state is AsignacionesLoaded || state is AsignacionesError) {
            final Duration elapsed =
                DateTime.now().difference(_deleteStartTime!);

            if (state is AsignacionesError) {
              await CrudOperationHandler.handleDeleteError(
                context: _loadingDialogContext!,
                isDeleting: _isDeleting,
                entityName: 'Asignación',
                errorMessage: state.message,
                onClose: () {
                  setState(() {
                    _isDeleting = false;
                    _loadingDialogContext = null;
                    _deleteStartTime = null;
                  });
                },
              );
            } else {
              await CrudOperationHandler.handleDeleteSuccess(
                context: _loadingDialogContext!,
                isDeleting: _isDeleting,
                entityName: 'Asignación',
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
      child: BlocBuilder<AsignacionesBloc, AsignacionesState>(
        builder: (BuildContext context, AsignacionesState state) {
          if (state is AsignacionesLoading) {
            return const _TableLoadingView();
          }

          if (state is AsignacionesError) {
            return _TableErrorView(message: state.message);
          }

          if (state is AsignacionesLoaded) {
            final List<AsignacionVehiculoTurnoEntity> filtradas =
                widget.filterData.apply(state.asignaciones);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                // Info de resultados filtrados
                if (widget.filterData.hasActiveFilters)
                  Padding(
                    padding:
                        const EdgeInsets.only(bottom: AppSizes.spacing),
                    child: Text(
                      'Mostrando ${filtradas.length} de ${state.asignaciones.length} asignaciones',
                      style: AppTextStyles.bodySmallSecondary,
                    ),
                  ),

                Expanded(child: _buildGroupedTable(filtradas)),
                const SizedBox(height: AppSizes.spacing),
                _TablePagination(
                  currentPage: _currentPage,
                  totalPages:
                      (filtradas.length / _itemsPerPage).ceil().clamp(1, 999),
                  totalItems: filtradas.length,
                  onPageChanged: (int page) {
                    setState(() => _currentPage = page);
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

  // ==================== TABLA AGRUPADA ====================

  Widget _buildGroupedTable(List<AsignacionVehiculoTurnoEntity> asignaciones) {
    if (asignaciones.isEmpty) {
      return _buildEmptyState();
    }

    final Map<String, List<AsignacionVehiculoTurnoEntity>> grouped =
        _groupByFecha(asignaciones);
    final List<String> sortedDates = grouped.keys.toList()
      ..sort((String a, String b) => b.compareTo(a));

    // Paginación por grupos
    final int startIndex = _currentPage * _itemsPerPage;
    int currentIndex = 0;
    final List<MapEntry<String, List<AsignacionVehiculoTurnoEntity>>>
        paginatedGroups = <MapEntry<String,
            List<AsignacionVehiculoTurnoEntity>>>[];

    for (final String date in sortedDates) {
      if (currentIndex >= startIndex &&
          paginatedGroups.length < _itemsPerPage) {
        paginatedGroups.add(
          MapEntry<String, List<AsignacionVehiculoTurnoEntity>>(
            date,
            grouped[date]!,
          ),
        );
      }
      currentIndex += grouped[date]!.length;
      if (paginatedGroups.length >= _itemsPerPage) {
        break;
      }
    }

    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          const _TableHeader(),
          ...paginatedGroups.map(
            (MapEntry<String, List<AsignacionVehiculoTurnoEntity>> entry) {
              return _GroupWidget(
                fechaStr: entry.key,
                items: entry.value,
                isExpanded: _expandedGroups[entry.key] ?? true,
                onToggle: () {
                  setState(() {
                    _expandedGroups[entry.key] =
                        !(_expandedGroups[entry.key] ?? true);
                  });
                },
                onEdit: (AsignacionVehiculoTurnoEntity a) =>
                    _editAsignacion(context, a),
                onDelete: (AsignacionVehiculoTurnoEntity a) =>
                    _confirmDelete(context, a),
                onToggleConfirm: _toggleConfirmacion,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      constraints: const BoxConstraints(minHeight: 400),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radius),
        border: Border.all(color: AppColors.gray300),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              widget.filterData.hasActiveFilters
                  ? Icons.search_off
                  : Icons.inbox_outlined,
              size: 64,
              color: AppColors.gray400,
            ),
            const SizedBox(height: AppSizes.spacing),
            Text(
              widget.filterData.hasActiveFilters
                  ? 'No se encontraron asignaciones con los filtros aplicados'
                  : 'No hay asignaciones registradas',
              style: AppTextStyles.bodySecondary,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Map<String, List<AsignacionVehiculoTurnoEntity>> _groupByFecha(
    List<AsignacionVehiculoTurnoEntity> asignaciones,
  ) {
    final Map<String, List<AsignacionVehiculoTurnoEntity>> grouped =
        <String, List<AsignacionVehiculoTurnoEntity>>{};

    for (final AsignacionVehiculoTurnoEntity a in asignaciones) {
      final String key = DateFormat('yyyy-MM-dd').format(a.fecha);
      grouped.putIfAbsent(key, () => <AsignacionVehiculoTurnoEntity>[]);
      grouped[key]!.add(a);
    }

    return grouped;
  }

  // ==================== ACCIONES ====================

  Future<void> _toggleConfirmacion(
    AsignacionVehiculoTurnoEntity asignacion,
  ) async {
    debugPrint('🔄 Toggle confirmación: ${asignacion.id}');
  }

  Future<void> _editAsignacion(
    BuildContext context,
    AsignacionVehiculoTurnoEntity asignacion,
  ) async {
    await showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) =>
          BlocProvider<AsignacionesBloc>.value(
            value: context.read<AsignacionesBloc>(),
            child: AsignacionFormDialog(asignacion: asignacion),
          ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    AsignacionVehiculoTurnoEntity asignacion,
  ) async {
    final DateFormat dateFormat = DateFormat('dd/MM/yyyy');
    final bool? confirmed = await showConfirmationDialog(
      context: context,
      title: 'Confirmar Eliminación',
      message:
          '¿Estás seguro de que deseas eliminar esta asignación? '
          'Esta acción no se puede deshacer.',
      itemDetails: <String, String>{
        'Fecha': dateFormat.format(asignacion.fecha),
        'Vehículo': asignacion.vehiculoId,
        'Dotación': asignacion.dotacionId,
        'Estado': getEstadoLabel(asignacion.estado),
      },
    );

    if (confirmed == true && context.mounted) {
      debugPrint('🗑️ Eliminando asignación: ${asignacion.id}');

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
              message: 'Eliminando asignación...',
              color: AppColors.emergency,
              icon: Icons.delete_forever,
            );
          },
        ),
      );

      if (context.mounted) {
        context
            .read<AsignacionesBloc>()
            .add(AsignacionDeleteRequested(asignacion.id));
      }
    }
  }
}

// ==================== HEADER DE TABLA ====================

class _TableHeader extends StatelessWidget {
  const _TableHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      decoration: const BoxDecoration(
        color: Color(0xFFE3F2FD),
        border: Border(bottom: BorderSide(color: AppColors.gray300)),
      ),
      child: const Row(
        children: <Widget>[
          _HeaderCell(width: 80, label: 'FECHA'),
          _HeaderCell(width: 150, label: 'VEHÍCULO'),
          _HeaderCell(flex: true, label: 'DOTACIÓN'),
          _HeaderCell(width: 120, label: 'TURNO'),
          _HeaderCell(width: 120, label: 'ESTADO'),
          _HeaderCell(width: 200, label: 'DESTINO'),
          _HeaderCell(width: 100, label: 'CONF.', center: true),
          _HeaderCell(width: 80, label: 'KM REAL'),
          _HeaderCell(width: 80, label: 'COMP.'),
          _HeaderCell(width: 100, label: 'KMS'),
          _HeaderCell(width: 100, label: 'SERV.'),
          _HeaderCell(width: 100, label: 'HORAS'),
          _HeaderCell(width: 80, label: 'ACC.', center: true),
        ],
      ),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  const _HeaderCell({
    this.width,
    this.flex = false,
    required this.label,
    this.center = false,
  });

  final double? width;
  final bool flex;
  final String label;
  final bool center;

  @override
  Widget build(BuildContext context) {
    final Widget text = Text(
      label,
      style: GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF333333),
      ),
    );

    if (flex) {
      return Expanded(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: text,
        ),
      );
    }

    return SizedBox(
      width: width,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: center ? Center(child: text) : text,
      ),
    );
  }
}

// ==================== GRUPO POR FECHA ====================

class _GroupWidget extends StatelessWidget {
  const _GroupWidget({
    required this.fechaStr,
    required this.items,
    required this.isExpanded,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleConfirm,
  });

  final String fechaStr;
  final List<AsignacionVehiculoTurnoEntity> items;
  final bool isExpanded;
  final VoidCallback onToggle;
  final void Function(AsignacionVehiculoTurnoEntity) onEdit;
  final void Function(AsignacionVehiculoTurnoEntity) onDelete;
  final void Function(AsignacionVehiculoTurnoEntity) onToggleConfirm;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        // Header del grupo
        InkWell(
          onTap: onToggle,
          child: Container(
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.gray100,
              border: Border.all(color: AppColors.gray300),
            ),
            child: Row(
              children: <Widget>[
                const SizedBox(width: 12),
                Icon(
                  isExpanded ? Icons.expand_more : Icons.chevron_right,
                  size: 18,
                  color: AppColors.gray700,
                ),
                const SizedBox(width: 8),
                Text(
                  DateFormat('dd/MM/yyyy').format(DateTime.parse(fechaStr)),
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.gray900,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${items.length}',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Filas del grupo
        if (isExpanded)
          ...items.asMap().entries.map(
            (MapEntry<int, AsignacionVehiculoTurnoEntity> entry) {
              final bool isEven = entry.key % 2 == 0;
              return _AsignacionRow(
                asignacion: entry.value,
                isEven: isEven,
                onEdit: onEdit,
                onDelete: onDelete,
                onToggleConfirm: onToggleConfirm,
              );
            },
          ),
      ],
    );
  }
}

// ==================== FILA DE ASIGNACIÓN ====================

class _AsignacionRow extends StatelessWidget {
  const _AsignacionRow({
    required this.asignacion,
    required this.isEven,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleConfirm,
  });

  final AsignacionVehiculoTurnoEntity asignacion;
  final bool isEven;
  final void Function(AsignacionVehiculoTurnoEntity) onEdit;
  final void Function(AsignacionVehiculoTurnoEntity) onDelete;
  final void Function(AsignacionVehiculoTurnoEntity) onToggleConfirm;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: isEven ? Colors.white : const Color(0xFFF0FDF4),
        border: const Border(bottom: BorderSide(color: AppColors.gray200)),
      ),
      child: Row(
        children: <Widget>[
          const SizedBox(width: 80), // Fecha en grupo
          SizedBox(
            width: 150,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: AsignacionVehiculoCell(asignacion: asignacion),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: AsignacionDotacionCell(asignacion: asignacion),
            ),
          ),
          SizedBox(
            width: 120,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: AsignacionTurnoCell(asignacion: asignacion),
            ),
          ),
          SizedBox(
            width: 120,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: AsignacionEstadoBadge(estado: asignacion.estado),
            ),
          ),
          SizedBox(
            width: 200,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: AsignacionDestinoCell(asignacion: asignacion),
            ),
          ),
          SizedBox(
            width: 100,
            child: Center(
              child: Checkbox(
                value: asignacion.confirmadaPor != null,
                onChanged: (bool? _) => onToggleConfirm(asignacion),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ),
          SizedBox(
            width: 80,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: AsignacionSiNoCell(
                valor:
                    asignacion.kmFinal != null && asignacion.kmFinal! > 0,
              ),
            ),
          ),
          SizedBox(
            width: 80,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: AsignacionSiNoCell(valor: asignacion.esCompletada),
            ),
          ),
          SizedBox(
            width: 100,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                asignacion.kmInicial != null && asignacion.kmFinal != null
                    ? (asignacion.kmFinal! - asignacion.kmInicial!)
                        .toStringAsFixed(0)
                    : '-',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: AppColors.textPrimaryLight,
                ),
              ),
            ),
          ),
          SizedBox(
            width: 100,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                '${asignacion.serviciosRealizados ?? 0}',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: AppColors.textPrimaryLight,
                ),
              ),
            ),
          ),
          SizedBox(
            width: 100,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                asignacion.horasEfectivas != null
                    ? '${asignacion.horasEfectivas!.toStringAsFixed(1)}h'
                    : '-',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: AppColors.textPrimaryLight,
                ),
              ),
            ),
          ),
          SizedBox(
            width: 80,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                AsignacionActionButton(
                  icon: Icons.edit_outlined,
                  tooltip: 'Editar',
                  onPressed: () => onEdit(asignacion),
                ),
                const SizedBox(width: 4),
                AsignacionActionButton(
                  icon: Icons.delete_outline,
                  tooltip: 'Eliminar',
                  onPressed: () => onDelete(asignacion),
                  color: AppColors.error,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== VISTAS AUXILIARES ====================

class _TableLoadingView extends StatelessWidget {
  const _TableLoadingView();

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
        child: AppLoadingIndicator(message: 'Cargando asignaciones...'),
      ),
    );
  }
}

class _TableErrorView extends StatelessWidget {
  const _TableErrorView({required this.message});

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
            'Error al cargar asignaciones',
            style: AppTextStyles.h6.copyWith(color: AppColors.error),
          ),
          const SizedBox(height: AppSizes.spacingSmall),
          Text(
            message,
            style: AppTextStyles.bodySecondary,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _TablePagination extends StatelessWidget {
  const _TablePagination({
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    required this.onPageChanged,
  });

  final int currentPage;
  final int totalPages;
  final int totalItems;
  final void Function(int) onPageChanged;

  @override
  Widget build(BuildContext context) {
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
            'Total: $totalItems asignaciones',
            style: AppTextStyles.bodySmallSecondary,
          ),
          Row(
            children: <Widget>[
              IconButton(
                icon: const Icon(Icons.first_page),
                constraints:
                    const BoxConstraints(minWidth: 36, minHeight: 36),
                onPressed:
                    currentPage > 0 ? () => onPageChanged(0) : null,
              ),
              IconButton(
                icon: const Icon(Icons.chevron_left),
                constraints:
                    const BoxConstraints(minWidth: 36, minHeight: 36),
                onPressed: currentPage > 0
                    ? () => onPageChanged(currentPage - 1)
                    : null,
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.paddingSmall,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius:
                      BorderRadius.circular(AppSizes.radiusSmall),
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
                constraints:
                    const BoxConstraints(minWidth: 36, minHeight: 36),
                onPressed: currentPage < totalPages - 1
                    ? () => onPageChanged(currentPage + 1)
                    : null,
              ),
              IconButton(
                icon: const Icon(Icons.last_page),
                constraints:
                    const BoxConstraints(minWidth: 36, minHeight: 36),
                onPressed: currentPage < totalPages - 1
                    ? () => onPageChanged(totalPages - 1)
                    : null,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
