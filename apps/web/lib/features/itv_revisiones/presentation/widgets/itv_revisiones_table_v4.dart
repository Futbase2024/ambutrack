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
import 'package:ambutrack_web/features/itv_revisiones/presentation/bloc/itv_revision_bloc.dart';
import 'package:ambutrack_web/features/itv_revisiones/presentation/bloc/itv_revision_event.dart';
import 'package:ambutrack_web/features/itv_revisiones/presentation/bloc/itv_revision_state.dart';
import 'package:ambutrack_web/features/itv_revisiones/presentation/widgets/itv_revision_edit_dialog.dart';
import 'package:ambutrack_web/features/itv_revisiones/presentation/widgets/itv_revision_view_dialog.dart';
import 'package:ambutrack_web/features/itv_revisiones/presentation/widgets/itv_revisiones_filters.dart';
import 'package:ambutrack_web/features/vehiculos/presentation/bloc/vehiculos_bloc.dart';
import 'package:ambutrack_web/features/vehiculos/presentation/bloc/vehiculos_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

/// Tabla de ITV y Revisiones usando AppDataGridV5
class ItvRevisionesTableV4 extends StatefulWidget {
  const ItvRevisionesTableV4({required this.onFilterChanged, super.key});

  final void Function(ItvRevisionesFilterData) onFilterChanged;

  @override
  State<ItvRevisionesTableV4> createState() => _ItvRevisionesTableV4State();
}

class _ItvRevisionesTableV4State extends State<ItvRevisionesTableV4> {
  ItvRevisionesFilterData _filterData = const ItvRevisionesFilterData();
  bool _isDeleting = false;
  BuildContext? _loadingDialogContext;
  DateTime? _deleteStartTime;
  int _currentPage = 0;
  static const int _itemsPerPage = 25;

  void _onFilterChanged(ItvRevisionesFilterData filterData) {
    setState(() {
      _filterData = filterData;
      _currentPage = 0; // Reset to first page on filter change
    });
    widget.onFilterChanged(filterData);
  }

  StatusBadgeType _getTipoBadgeType(TipoItvRevision tipo) {
    switch (tipo) {
      case TipoItvRevision.itv:
        return StatusBadgeType.disponible; // Azul para ITV
      case TipoItvRevision.revisionTecnica:
        return StatusBadgeType.enServicio; // Verde para revisión técnica
      case TipoItvRevision.inspeccionAnual:
        return StatusBadgeType.warning; // Amarillo para inspección anual
      case TipoItvRevision.inspeccionEspecial:
        return StatusBadgeType.error; // Rojo para inspección especial
    }
  }

  StatusBadgeType _getResultadoBadgeType(ResultadoItvRevision resultado) {
    switch (resultado) {
      case ResultadoItvRevision.favorable:
        return StatusBadgeType.success; // Verde para favorable
      case ResultadoItvRevision.desfavorable:
        return StatusBadgeType.warning; // Amarillo para desfavorable
      case ResultadoItvRevision.negativo:
        return StatusBadgeType.error; // Rojo para negativo
      case ResultadoItvRevision.pendiente:
        return StatusBadgeType.inactivo; // Gris para pendiente
    }
  }

  StatusBadgeType _getEstadoBadgeType(EstadoItvRevision estado) {
    switch (estado) {
      case EstadoItvRevision.pendiente:
        return StatusBadgeType.disponible; // Azul para pendiente
      case EstadoItvRevision.realizada:
        return StatusBadgeType.success; // Verde para realizada
      case EstadoItvRevision.vencida:
        return StatusBadgeType.error; // Rojo para vencida
      case EstadoItvRevision.cancelada:
        return StatusBadgeType.inactivo; // Gris para cancelada
    }
  }

  void _showItvRevisionDetails(BuildContext context, ItvRevisionEntity itvRevision) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) => ItvRevisionViewDialog(itvRevision: itvRevision),
    );
  }

  Future<void> _editItvRevision(BuildContext context, ItvRevisionEntity itvRevision) async {
    await showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return BlocProvider<ItvRevisionBloc>.value(
          value: context.read<ItvRevisionBloc>(),
          child: ItvRevisionEditDialog(itvRevision: itvRevision),
        );
      },
    );
  }

  Future<void> _confirmDelete(BuildContext context, ItvRevisionEntity itvRevision) async {
    final bool? confirmed = await showConfirmationDialog(
      context: context,
      title: 'Confirmar Eliminación',
      message:
          '¿Estás seguro de que deseas eliminar esta ${itvRevision.tipo.displayName}? Esta acción no se puede deshacer.',
      itemDetails: <String, String>{
        'Tipo': itvRevision.tipo.displayName,
        'Fecha': DateFormat('dd/MM/yyyy').format(itvRevision.fecha),
        if (itvRevision.fechaVencimiento != null)
          'Vencimiento': DateFormat('dd/MM/yyyy').format(itvRevision.fechaVencimiento!),
        'Resultado': itvRevision.resultado.displayName,
        'Kilometraje': '${itvRevision.kmVehiculo.toStringAsFixed(0)} km',
        'Costo': '${itvRevision.costoTotal.toStringAsFixed(2)} €',
        'Estado': itvRevision.estado.displayName,
      },
    );

    if (confirmed == true && context.mounted) {
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
              message: 'Eliminando ITV/Revisión...',
              color: AppColors.emergency,
              icon: Icons.delete_forever,
            );
          },
        ),
      );

      if (context.mounted) {
        context.read<ItvRevisionBloc>().add(ItvRevisionDeleteRequested(id: itvRevision.id));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ItvRevisionBloc, ItvRevisionState>(
      listener: (BuildContext context, ItvRevisionState state) {
        if (_isDeleting && _loadingDialogContext != null) {
          if (state is ItvRevisionLoaded || state is ItvRevisionError) {
            final Duration elapsed = DateTime.now().difference(_deleteStartTime!);
            final int durationMs = elapsed.inMilliseconds;

            setState(() {
              _isDeleting = false;
              _loadingDialogContext = null;
              _deleteStartTime = null;
            });

            if (state is ItvRevisionError) {
              CrudOperationHandler.handleDeleteError(
                context: context,
                isDeleting: true,
                entityName: 'ITV/Revisión',
                errorMessage: state.message,
              );
            } else if (state is ItvRevisionLoaded) {
              CrudOperationHandler.handleDeleteSuccess(
                context: context,
                isDeleting: true,
                entityName: 'ITV/Revisión',
                durationMs: durationMs,
              );
            }
          }
        }
      },
      child: BlocBuilder<ItvRevisionBloc, ItvRevisionState>(
        builder: (BuildContext context, ItvRevisionState state) {
          if (state is ItvRevisionLoading) {
            return const _LoadingView();
          }

          if (state is ItvRevisionError) {
            return _ErrorView(message: state.message);
          }

          if (state is ItvRevisionLoaded) {
            final List<ItvRevisionEntity> itvRevisionesFiltradas = _filterData.apply(state.itvRevisiones);

            // Paginación
            final int totalItems = itvRevisionesFiltradas.length;
            final int totalPages = (totalItems / _itemsPerPage).ceil();
            final int startIndex = _currentPage * _itemsPerPage;
            final int endIndex = (startIndex + _itemsPerPage).clamp(0, totalItems);
            final List<ItvRevisionEntity> paginatedData = itvRevisionesFiltradas.sublist(
              startIndex,
              endIndex,
            );

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                // Filtros (siempre arriba)
                ItvRevisionesFilters(onFilterChanged: _onFilterChanged),
                const SizedBox(height: AppSizes.spacing),

                // Info de resultados filtrados
                if (_filterData.hasActiveFilters)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSizes.spacing),
                    child: Text(
                      'Mostrando ${itvRevisionesFiltradas.length} de ${state.itvRevisiones.length} ITV/Revisiones',
                      style: AppTextStyles.bodySmallSecondary,
                    ),
                  ),

                // Tabla (ocupa espacio disponible)
                Expanded(
                  child: BlocBuilder<VehiculosBloc, VehiculosState>(
                    builder: (BuildContext context, VehiculosState vehiculosState) {
                      return AppDataGridV5<ItvRevisionEntity>(
                        columns: const <DataGridColumn>[
                          DataGridColumn(label: 'VEHÍCULO', flexWidth: 2, sortable: true),
                          DataGridColumn(label: 'TIPO', flexWidth: 2, sortable: true),
                          DataGridColumn(label: 'FECHA', flexWidth: 2, sortable: true),
                          DataGridColumn(label: 'VENCIMIENTO', flexWidth: 2, sortable: true),
                          DataGridColumn(label: 'RESULTADO', flexWidth: 2, sortable: true),
                          DataGridColumn(label: 'KM', sortable: true),
                          DataGridColumn(label: 'COSTO', sortable: true),
                          DataGridColumn(label: 'ESTADO', flexWidth: 2, sortable: true),
                        ],
                        rows: paginatedData,
                        buildCells: (ItvRevisionEntity i) => _buildCells(i, vehiculosState),
                        onView: (ItvRevisionEntity i) => _showItvRevisionDetails(context, i),
                        onEdit: (ItvRevisionEntity i) => _editItvRevision(context, i),
                        onDelete: (ItvRevisionEntity i) => _confirmDelete(context, i),
                        emptyMessage: _filterData.hasActiveFilters
                            ? 'No se encontraron ITV/Revisiones con los filtros aplicados'
                            : 'No hay ITV/Revisiones registradas',
                      );
                    },
                  ),
                ),

                // Paginación fija abajo (siempre visible)
                const SizedBox(height: AppSizes.spacing),
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
  List<DataGridCell> _buildCells(ItvRevisionEntity i, VehiculosState vehiculosState) {
    // Obtener matrícula del vehículo
    String vehiculoMatricula = 'Cargando...';

    if (vehiculosState is VehiculosLoaded) {
      final VehiculoEntity? vehiculo = vehiculosState.vehiculos
          .cast<VehiculoEntity?>()
          .firstWhere(
            (VehiculoEntity? v) => v?.id == i.vehiculoId,
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

      // Tipo con StatusBadge (ancho completo)
      DataGridCell(
        child: Container(
          width: double.infinity,
          alignment: Alignment.center,
          child: StatusBadge(
            label: i.tipo.displayName,
            type: _getTipoBadgeType(i.tipo),
          ),
        ),
      ),

      // Fecha
      DataGridCell(
        child: Text(
          DateFormat('dd/MM/yyyy').format(i.fecha),
          style: AppTextStyles.tableCell,
        ),
      ),

      // Vencimiento
      DataGridCell(
        child: i.fechaVencimiento != null
            ? Text(
                DateFormat('dd/MM/yyyy').format(i.fechaVencimiento!),
                style: AppTextStyles.tableCell,
              )
            : Text(
                '-',
                style: AppTextStyles.tableCell.copyWith(
                  color: AppColors.textSecondaryLight,
                ),
              ),
      ),

      // Resultado con StatusBadge (ancho completo)
      DataGridCell(
        child: Container(
          width: double.infinity,
          alignment: Alignment.center,
          child: StatusBadge(
            label: i.resultado.displayName,
            type: _getResultadoBadgeType(i.resultado),
          ),
        ),
      ),

      // Km
      DataGridCell(
        child: Text(
          '${i.kmVehiculo.toStringAsFixed(0)} km',
          style: AppTextStyles.tableCell,
        ),
      ),

      // Costo
      DataGridCell(
        child: Text(
          '${i.costoTotal.toStringAsFixed(2)} €',
          style: AppTextStyles.tableCell.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Estado con StatusBadge (ancho completo)
      DataGridCell(
        child: Container(
          width: double.infinity,
          alignment: Alignment.center,
          child: StatusBadge(
            label: i.estado.displayName,
            type: _getEstadoBadgeType(i.estado),
          ),
        ),
      ),
    ];
  }

  /// Construye controles de paginación profesional
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
            'Mostrando $startItem-$endItem de $totalItems ITV/Revisiones',
            style: AppTextStyles.bodySmallSecondary,
          ),

          // Controles de navegación
          Row(
            children: <Widget>[
              // Primera página
              _PaginationButton(
                onPressed: currentPage > 0 ? () => onPageChanged(0) : null,
                icon: Icons.first_page,
                tooltip: 'Primera página',
              ),
              const SizedBox(width: AppSizes.spacingSmall),

              // Página anterior
              _PaginationButton(
                onPressed: currentPage > 0 ? () => onPageChanged(currentPage - 1) : null,
                icon: Icons.chevron_left,
                tooltip: 'Página anterior',
              ),
              const SizedBox(width: AppSizes.spacing),

              // Indicador de página actual
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

              // Página siguiente
              _PaginationButton(
                onPressed: currentPage < totalPages - 1 ? () => onPageChanged(currentPage + 1) : null,
                icon: Icons.chevron_right,
                tooltip: 'Página siguiente',
              ),
              const SizedBox(width: AppSizes.spacingSmall),

              // Última página
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

/// Botón de paginación reutilizable
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
          message: 'Cargando ITV/Revisiones...',
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
              'Error al cargar ITV/Revisiones',
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
                context.read<ItvRevisionBloc>().add(const ItvRevisionLoadRequested());
              },
              child: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}
