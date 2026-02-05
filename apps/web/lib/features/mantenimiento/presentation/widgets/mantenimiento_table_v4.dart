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
import 'package:ambutrack_web/features/mantenimiento/presentation/bloc/mantenimiento_bloc.dart';
import 'package:ambutrack_web/features/mantenimiento/presentation/bloc/mantenimiento_event.dart';
import 'package:ambutrack_web/features/mantenimiento/presentation/bloc/mantenimiento_state.dart';
import 'package:ambutrack_web/features/mantenimiento/presentation/widgets/mantenimiento_edit_dialog.dart';
import 'package:ambutrack_web/features/mantenimiento/presentation/widgets/mantenimiento_view_dialog.dart';
import 'package:ambutrack_web/features/mantenimiento/presentation/widgets/mantenimientos_filters.dart';
import 'package:ambutrack_web/features/vehiculos/presentation/bloc/vehiculos_bloc.dart';
import 'package:ambutrack_web/features/vehiculos/presentation/bloc/vehiculos_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

/// Tabla de mantenimientos optimizada con AppDataGridV5
class MantenimientoTableV4 extends StatefulWidget {
  const MantenimientoTableV4({required this.onFilterChanged, super.key});

  final void Function(MantenimientosFilterData) onFilterChanged;

  @override
  State<MantenimientoTableV4> createState() => _MantenimientoTableV4State();
}

class _MantenimientoTableV4State extends State<MantenimientoTableV4> {
  MantenimientosFilterData _filterData = const MantenimientosFilterData();
  bool _isDeleting = false;
  BuildContext? _loadingDialogContext;
  DateTime? _deleteStartTime;
  int? _sortColumnIndex;
  bool _sortAscending = true;

  // Paginación para mejorar rendimiento
  int _currentPage = 0;
  static const int _itemsPerPage = 25;

  void _onFilterChanged(MantenimientosFilterData filterData) {
    setState(() {
      _filterData = filterData;
      _currentPage = 0; // Resetear a primera página cuando cambian filtros
    });
    widget.onFilterChanged(filterData);
  }

  void _onSort(int columnIndex, {required bool ascending}) {
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
    });
  }

  StatusBadgeType _getTipoBadgeType(TipoMantenimiento tipo) {
    switch (tipo) {
      case TipoMantenimiento.basico:
      case TipoMantenimiento.completo:
      case TipoMantenimiento.especial:
        return StatusBadgeType.disponible; // Azul para todos los normales
      case TipoMantenimiento.urgente:
        return StatusBadgeType.error; // Rojo SOLO para urgente
    }
  }

  StatusBadgeType _getEstadoBadgeType(EstadoMantenimiento estado) {
    switch (estado) {
      case EstadoMantenimiento.programado:
      case EstadoMantenimiento.enProceso:
        return StatusBadgeType.warning; // Amarillo para pendiente/proceso
      case EstadoMantenimiento.completado:
        return StatusBadgeType.success; // Verde para completado
      case EstadoMantenimiento.cancelado:
        return StatusBadgeType.error; // Rojo para cancelado
    }
  }

  void _showMantenimientoDetails(BuildContext context, MantenimientoEntity mantenimiento) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) => MantenimientoViewDialog(mantenimiento: mantenimiento),
    );
  }

  Future<void> _editMantenimiento(BuildContext context, MantenimientoEntity mantenimiento) async {
    await showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return BlocProvider<MantenimientoBloc>.value(
          value: context.read<MantenimientoBloc>(),
          child: MantenimientoEditDialog(mantenimiento: mantenimiento),
        );
      },
    );
  }

  Future<void> _confirmDelete(BuildContext context, MantenimientoEntity mantenimiento) async {
    final bool? confirmed = await showConfirmationDialog(
      context: context,
      title: 'Confirmar Eliminación',
      message: '¿Estás seguro de que deseas eliminar este mantenimiento? Esta acción no se puede deshacer.',
      itemDetails: <String, String>{
        'Descripción': mantenimiento.descripcion,
        'Tipo': mantenimiento.tipoMantenimiento.displayName,
        'Fecha': mantenimiento.fechaProgramada != null
            ? DateFormat('dd/MM/yyyy').format(mantenimiento.fechaProgramada!)
            : 'Sin fecha',
        'Estado': mantenimiento.estado.displayName,
        'Costo': '${mantenimiento.costoTotal.toStringAsFixed(2)} €',
      },
    );

    if (confirmed == true && context.mounted) {
      debugPrint('🗑️ Eliminando mantenimiento: ${mantenimiento.descripcion}');

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
              message: 'Eliminando mantenimiento...',
              color: AppColors.emergency,
              icon: Icons.delete_forever,
            );
          },
        ),
      );

      if (context.mounted) {
        context.read<MantenimientoBloc>().add(MantenimientoDeleteRequested(id: mantenimiento.id));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<MantenimientoBloc, MantenimientoState>(
      listener: (BuildContext context, MantenimientoState state) {
        if (_isDeleting && _loadingDialogContext != null) {
          if (state is MantenimientoLoaded || state is MantenimientoError) {
            final Duration elapsed = DateTime.now().difference(_deleteStartTime!);

            CrudOperationHandler.handleDeleteSuccess(
              context: context,
              isDeleting: _isDeleting,
              entityName: 'Mantenimiento',
              durationMs: elapsed.inMilliseconds,
              onClose: () => setState(() {
                _isDeleting = false;
                _loadingDialogContext = null;
                _deleteStartTime = null;
              }),
            );
          }
        }
      },
      child: BlocBuilder<MantenimientoBloc, MantenimientoState>(
        builder: (BuildContext context, MantenimientoState state) {
          if (state is MantenimientoLoading) {
            return const _LoadingView();
          }

          if (state is MantenimientoError) {
            return _ErrorView(message: state.message);
          }

          if (state is MantenimientoLoaded) {
            List<MantenimientoEntity> mantenimientosFiltrados = _filterData.apply(state.mantenimientos);

            // Aplicar sort
            if (_sortColumnIndex != null) {
              mantenimientosFiltrados = _sortMantenimientos(mantenimientosFiltrados);
            }

            // Aplicar paginación
            final int totalItems = mantenimientosFiltrados.length;
            final int totalPages = (totalItems / _itemsPerPage).ceil();
            final int startIndex = _currentPage * _itemsPerPage;
            final int endIndex = (startIndex + _itemsPerPage).clamp(0, totalItems);
            final List<MantenimientoEntity> mantenimientosPaginados =
                mantenimientosFiltrados.sublist(startIndex, endIndex);

            return Column(
              children: <Widget>[
                // Filtros + Info de resultados
                Padding(
                  padding: const EdgeInsets.all(AppSizes.paddingLarge),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      MantenimientosFilters(onFilterChanged: _onFilterChanged),
                      if (_filterData.hasActiveFilters || totalItems != state.mantenimientos.length) ...<Widget>[
                        const SizedBox(height: AppSizes.spacing),
                        Row(
                          children: <Widget>[
                            Text(
                              'Mostrando ${mantenimientosPaginados.length} de $totalItems mantenimientos',
                              style: GoogleFonts.inter(
                                fontSize: AppSizes.fontXs,
                                color: AppColors.textSecondaryLight,
                              ),
                            ),
                            if (_filterData.hasActiveFilters) ...<Widget>[
                              const SizedBox(width: AppSizes.spacingSmall),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSizes.paddingSmall,
                                  vertical: AppSizes.spacingXs,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.warning.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                                ),
                                child: Text(
                                  'Filtros activos',
                                  style: GoogleFonts.inter(
                                    fontSize: AppSizes.fontXs,
                                    color: AppColors.warning,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
            
                // Tabla
                Expanded(
                  child: BlocBuilder<VehiculosBloc, VehiculosState>(
                    builder: (BuildContext context, VehiculosState vehiculosState) {
                      return AppDataGridV5<MantenimientoEntity>(
                        columns: const <DataGridColumn>[
                          DataGridColumn(label: 'VEHÍCULO', flexWidth: 2, sortable: true),
                          DataGridColumn(label: 'FECHA', flexWidth: 2, sortable: true),
                          DataGridColumn(label: 'TIPO', flexWidth: 2, sortable: true),
                          DataGridColumn(label: 'KM', sortable: true),
                          DataGridColumn(label: 'DESCRIPCIÓN', flexWidth: 3),
                          DataGridColumn(label: 'COSTO', sortable: true),
                          DataGridColumn(label: 'ESTADO', flexWidth: 2, sortable: true),
                        ],
                        rows: mantenimientosPaginados,
                        buildCells: (MantenimientoEntity m) => _buildCells(m, vehiculosState),
                        sortColumnIndex: _sortColumnIndex,
                        sortAscending: _sortAscending,
                        onSort: _onSort,
                        rowHeight: 72,
                        outerBorderColor: AppColors.gray300,
                        emptyMessage: _filterData.hasActiveFilters
                            ? 'No se encontraron mantenimientos con los filtros aplicados'
                            : 'No hay mantenimientos registrados',
                        onView: (MantenimientoEntity m) => _showMantenimientoDetails(context, m),
                        onEdit: (MantenimientoEntity m) => _editMantenimiento(context, m),
                        onDelete: (MantenimientoEntity m) => _confirmDelete(context, m),
                      );
                    },
                  ),
                ),

                // Paginación (siempre visible)
                _buildPaginationControls(
                  currentPage: _currentPage,
                  totalPages: totalPages,
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

  /// Construye las celdas de cada fila
  List<DataGridCell> _buildCells(MantenimientoEntity m, VehiculosState vehiculosState) {
    // Obtener matrícula del vehículo
    String vehiculoMatricula = 'Cargando...';

    if (vehiculosState is VehiculosLoaded) {
      final VehiculoEntity? vehiculo = vehiculosState.vehiculos
          .cast<VehiculoEntity?>()
          .firstWhere(
            (VehiculoEntity? v) => v?.id == m.vehiculoId,
            orElse: () => null,
          );

      vehiculoMatricula = vehiculo?.matricula ?? 'Desconocido';
    }

    return <DataGridCell>[
      // Vehículo matrícula
      DataGridCell(
        child: Text(
          vehiculoMatricula,
          style: AppTextStyles.tableCell.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Fecha
      DataGridCell(
        child: Text(
          DateFormat('dd/MM/yyyy').format(m.fecha),
          style: AppTextStyles.tableCell,
        ),
      ),

      // Tipo con badge (ancho completo)
      DataGridCell(
        child: Container(
          width: double.infinity,
          alignment: Alignment.center,
          child: StatusBadge(
            label: m.tipoMantenimiento.displayName,
            type: _getTipoBadgeType(m.tipoMantenimiento),
          ),
        ),
      ),

      // Km
      DataGridCell(
        child: Text(
          '${m.kmVehiculo.toStringAsFixed(0)} km',
          style: AppTextStyles.tableCell.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ),

      // Descripción (truncar si es muy larga)
      DataGridCell(
        child: Text(
          m.descripcion.length > 50 ? '${m.descripcion.substring(0, 50)}...' : m.descripcion,
          style: AppTextStyles.tableCell.copyWith(
            color: AppColors.textSecondaryLight,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ),

      // Costo
      DataGridCell(
        child: Text(
          '${m.costoTotal.toStringAsFixed(2)} €',
          style: AppTextStyles.tableCell.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
      ),

      // Estado con badge (ancho completo)
      DataGridCell(
        child: Container(
          width: double.infinity,
          alignment: Alignment.center,
          child: StatusBadge(
            label: m.estado.displayName,
            type: _getEstadoBadgeType(m.estado),
          ),
        ),
      ),
    ];
  }

  List<MantenimientoEntity> _sortMantenimientos(List<MantenimientoEntity> mantenimientos) {
    final List<MantenimientoEntity> sorted = List<MantenimientoEntity>.from(mantenimientos)
      ..sort((MantenimientoEntity a, MantenimientoEntity b) {
        int compare = 0;

        switch (_sortColumnIndex) {
          case 0: // Vehículo
            compare = a.vehiculoId.compareTo(b.vehiculoId);
          case 1: // Fecha
            compare = a.fecha.compareTo(b.fecha);
          case 2: // Tipo
            compare = a.tipoMantenimiento.index.compareTo(b.tipoMantenimiento.index);
          case 3: // KM
            compare = a.kmVehiculo.compareTo(b.kmVehiculo);
          case 5: // Costo
            compare = a.costoTotal.compareTo(b.costoTotal);
          case 6: // Estado
            compare = a.estado.index.compareTo(b.estado.index);
          default:
            compare = 0;
        }

        return _sortAscending ? compare : -compare;
      });

    return sorted;
  }

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
          'Mostrando $startItem-$endItem de $totalItems mantenimientos',
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
          message: 'Cargando mantenimientos...',
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
      padding: const EdgeInsets.all(AppSizes.spacingMassive),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radius),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Icon(
              Icons.error_outline,
              size: AppSizes.iconMassive,
              color: AppColors.error,
            ),
            const SizedBox(height: AppSizes.spacing),
            Text(
              'Error al cargar mantenimientos',
              style: GoogleFonts.inter(
                fontSize: AppSizes.font,
                fontWeight: FontWeight.w600,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: AppSizes.spacingSmall),
            Text(
              message,
              style: GoogleFonts.inter(
                fontSize: AppSizes.fontSmall,
                color: AppColors.textSecondaryLight,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSizes.spacing),
            ElevatedButton(
              onPressed: () {
                context.read<MantenimientoBloc>().add(const MantenimientoLoadRequested());
              },
              child: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}
