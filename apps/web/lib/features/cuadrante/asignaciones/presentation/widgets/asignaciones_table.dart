import 'dart:async';

import 'package:ambutrack_core/ambutrack_core.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/core/theme/app_text_styles.dart';
import 'package:ambutrack_web/core/widgets/dialogs/confirmation_dialog.dart';
import 'package:ambutrack_web/core/widgets/handlers/crud_operation_handler.dart';
import 'package:ambutrack_web/core/widgets/loading/app_loading_indicator.dart';
import 'package:ambutrack_web/core/widgets/tables/app_data_grid_v5.dart';
import 'package:ambutrack_web/features/cuadrante/asignaciones/presentation/bloc/asignaciones/asignaciones_bloc.dart';
import 'package:ambutrack_web/features/cuadrante/asignaciones/presentation/bloc/asignaciones/asignaciones_event.dart';
import 'package:ambutrack_web/features/cuadrante/asignaciones/presentation/bloc/asignaciones/asignaciones_state.dart';
import 'package:ambutrack_web/features/cuadrante/asignaciones/presentation/widgets/asignacion_form_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

/// Tabla de gestión de Asignaciones
class AsignacionesTable extends StatefulWidget {
  const AsignacionesTable({super.key});

  @override
  State<AsignacionesTable> createState() => _AsignacionesTableState();
}

class _AsignacionesTableState extends State<AsignacionesTable> {
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
    return BlocListener<AsignacionesBloc, AsignacionesState>(
      listener: (BuildContext context, Object? state) async {
        // Manejo de loading al eliminar
        if (_isDeleting && _loadingDialogContext != null) {
          if (state is AsignacionesLoaded || state is AsignacionesError || state is AsignacionOperationSuccess) {
            final Duration elapsed = DateTime.now().difference(_deleteStartTime!);

            // Manejar resultado con CrudOperationHandler
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
            } else if (state is AsignacionOperationSuccess) {
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
        builder: (BuildContext context, Object? state) {
          if (state is AsignacionesLoading) {
            return const _LoadingView();
          }

          if (state is AsignacionesError) {
            return _ErrorView(message: state.message);
          }

          if (state is AsignacionesLoaded || state is AsignacionOperationSuccess) {
            final List<AsignacionVehiculoTurnoEntity> asignaciones = state is AsignacionesLoaded
                ? state.asignaciones
                : (state as AsignacionOperationSuccess).asignaciones;

            // Filtrado y ordenamiento
            List<AsignacionVehiculoTurnoEntity> filtradas = _filterAsignaciones(asignaciones);
            filtradas = _sortAsignaciones(filtradas);

            // Cálculo de paginación
            final int totalItems = filtradas.length;
            final int totalPages = (totalItems / _itemsPerPage).ceil();
            final int startIndex = _currentPage * _itemsPerPage;
            final int endIndex = (startIndex + _itemsPerPage).clamp(0, totalItems);
            final List<AsignacionVehiculoTurnoEntity> asignacionesPaginadas = totalItems > 0
                ? filtradas.sublist(startIndex, endIndex)
                : <AsignacionVehiculoTurnoEntity>[];

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                // Header: Búsqueda
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        'Listado de Asignaciones',
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
                if (asignaciones.length != filtradas.length)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSizes.spacing),
                    child: Text(
                      'Mostrando ${filtradas.length} de ${asignaciones.length} asignaciones',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: AppColors.textSecondaryLight,
                      ),
                    ),
                  ),

                // Tabla con scroll interno
                Expanded(
                  child: AppDataGridV5<AsignacionVehiculoTurnoEntity>(
                    columns: const <DataGridColumn>[
                      DataGridColumn(label: 'FECHA', sortable: true),
                      DataGridColumn(label: 'VEHÍCULO', sortable: true),
                      DataGridColumn(label: 'DOTACIÓN', flexWidth: 2, sortable: true),
                      DataGridColumn(label: 'TURNO', sortable: true),
                      DataGridColumn(label: 'ESTADO', sortable: true),
                      DataGridColumn(label: 'HOSPITAL/BASE'),
                    ],
                    rows: asignacionesPaginadas,
                    buildCells: (AsignacionVehiculoTurnoEntity asignacion) => <DataGridCell>[
                      DataGridCell(child: _buildFechaCell(asignacion)),
                      DataGridCell(child: _buildVehiculoCell(asignacion)),
                      DataGridCell(child: _buildDotacionCell(asignacion)),
                      DataGridCell(child: _buildTurnoCell(asignacion)),
                      DataGridCell(child: _buildEstadoCell(asignacion)),
                      DataGridCell(child: _buildLugarCell(asignacion)),
                    ],
                    sortColumnIndex: _sortColumnIndex,
                    sortAscending: _sortAscending,
                    onSort: (int columnIndex, {required bool ascending}) {
                      setState(() {
                        _sortColumnIndex = columnIndex;
                        _sortAscending = ascending;
                      });
                    },
                    rowHeight: 72,
                    outerBorderColor: AppColors.gray300,
                    emptyMessage: _searchQuery.isNotEmpty
                        ? 'No se encontraron asignaciones con los filtros aplicados'
                        : 'No hay asignaciones registradas',
                    onEdit: (AsignacionVehiculoTurnoEntity asignacion) => _editAsignacion(context, asignacion),
                    onDelete: (AsignacionVehiculoTurnoEntity asignacion) => _confirmDelete(context, asignacion),
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

  // ==================== CÉLULAS ====================

  Widget _buildFechaCell(AsignacionVehiculoTurnoEntity asignacion) {
    final DateFormat dateFormat = DateFormat('dd/MM/yyyy');
    return Text(
      dateFormat.format(asignacion.fecha),
      style: GoogleFonts.inter(
        fontSize: 13,
        color: AppColors.textPrimaryLight,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildVehiculoCell(AsignacionVehiculoTurnoEntity asignacion) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        const Icon(Icons.directions_car, size: 16, color: AppColors.primary),
        const SizedBox(width: 6),
        Text(
          asignacion.vehiculoId,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimaryLight,
          ),
        ),
      ],
    );
  }

  Widget _buildDotacionCell(AsignacionVehiculoTurnoEntity asignacion) {
    return Text(
      asignacion.dotacionId,
      style: GoogleFonts.inter(
        fontSize: 13,
        color: AppColors.textPrimaryLight,
      ),
    );
  }

  Widget _buildTurnoCell(AsignacionVehiculoTurnoEntity asignacion) {
    return Text(
      asignacion.plantillaTurnoId ?? 'Sin turno',
      style: GoogleFonts.inter(
        fontSize: 13,
        color: asignacion.plantillaTurnoId != null
            ? AppColors.textPrimaryLight
            : AppColors.textSecondaryLight,
        fontStyle: asignacion.plantillaTurnoId == null ? FontStyle.italic : null,
      ),
    );
  }

  Widget _buildEstadoCell(AsignacionVehiculoTurnoEntity asignacion) {
    final Color color = _getEstadoColor(asignacion.estado);
    final String label = _getEstadoLabel(asignacion.estado);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
        ),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildLugarCell(AsignacionVehiculoTurnoEntity asignacion) {
    if (asignacion.hospitalId != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Icon(Icons.local_hospital, size: 16, color: AppColors.error),
          const SizedBox(width: 6),
          Text(
            'Hospital: ${asignacion.hospitalId}',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AppColors.textSecondaryLight,
            ),
          ),
        ],
      );
    }

    if (asignacion.baseId != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Icon(Icons.home_work, size: 16, color: AppColors.primary),
          const SizedBox(width: 6),
          Text(
            'Base: ${asignacion.baseId}',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AppColors.textSecondaryLight,
            ),
          ),
        ],
      );
    }

    return Text(
      'Sin asignar',
      style: GoogleFonts.inter(
        fontSize: 13,
        color: AppColors.textSecondaryLight,
        fontStyle: FontStyle.italic,
      ),
    );
  }

  Color _getEstadoColor(String estado) {
    switch (estado.toLowerCase()) {
      case 'planificada':
        return AppColors.info;
      case 'confirmada':
        return AppColors.success;
      case 'en_curso':
        return AppColors.warning;
      case 'finalizada':
        return AppColors.textSecondaryLight;
      case 'cancelada':
        return AppColors.error;
      default:
        return AppColors.textSecondaryLight;
    }
  }

  String _getEstadoLabel(String estado) {
    switch (estado.toLowerCase()) {
      case 'planificada':
        return 'Planificada';
      case 'confirmada':
        return 'Confirmada';
      case 'en_curso':
        return 'En Curso';
      case 'finalizada':
        return 'Finalizada';
      case 'cancelada':
        return 'Cancelada';
      default:
        return estado;
    }
  }

  // ==================== FILTRADO Y ORDENAMIENTO ====================

  List<AsignacionVehiculoTurnoEntity> _filterAsignaciones(List<AsignacionVehiculoTurnoEntity> asignaciones) {
    if (_searchQuery.isEmpty) {
      return asignaciones;
    }

    final String query = _searchQuery.toLowerCase();
    return asignaciones.where((AsignacionVehiculoTurnoEntity asignacion) {
      return asignacion.vehiculoId.toLowerCase().contains(query) ||
          asignacion.dotacionId.toLowerCase().contains(query) ||
          asignacion.estado.toLowerCase().contains(query) ||
          (asignacion.hospitalId?.toLowerCase().contains(query) ?? false) ||
          (asignacion.baseId?.toLowerCase().contains(query) ?? false) ||
          (asignacion.plantillaTurnoId?.toLowerCase().contains(query) ?? false);
    }).toList();
  }

  List<AsignacionVehiculoTurnoEntity> _sortAsignaciones(List<AsignacionVehiculoTurnoEntity> asignaciones) {
    if (_sortColumnIndex == null) {
      return asignaciones;
    }

    final List<AsignacionVehiculoTurnoEntity> sorted = List<AsignacionVehiculoTurnoEntity>.from(asignaciones)
      ..sort((AsignacionVehiculoTurnoEntity a, AsignacionVehiculoTurnoEntity b) {
        int comparison = 0;

        switch (_sortColumnIndex) {
          case 0: // FECHA
            comparison = a.fecha.compareTo(b.fecha);
            break;
          case 1: // VEHÍCULO
            comparison = a.vehiculoId.compareTo(b.vehiculoId);
            break;
          case 2: // DOTACIÓN
            comparison = a.dotacionId.compareTo(b.dotacionId);
            break;
          case 3: // TURNO
            comparison = (a.plantillaTurnoId ?? '').compareTo(b.plantillaTurnoId ?? '');
            break;
          case 4: // ESTADO
            comparison = a.estado.compareTo(b.estado);
            break;
        }

        return _sortAscending ? comparison : -comparison;
      });

    return sorted;
  }

  // ==================== ACCIONES ====================

  Future<void> _editAsignacion(BuildContext context, AsignacionVehiculoTurnoEntity asignacion) async {
    await showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return BlocProvider<AsignacionesBloc>.value(
          value: context.read<AsignacionesBloc>(),
          child: AsignacionFormDialog(asignacion: asignacion),
        );
      },
    );
  }

  Future<void> _confirmDelete(BuildContext context, AsignacionVehiculoTurnoEntity asignacion) async {
    final DateFormat dateFormat = DateFormat('dd/MM/yyyy');
    final bool? confirmed = await showConfirmationDialog(
      context: context,
      title: 'Confirmar Eliminación',
      message: '¿Estás seguro de que deseas eliminar esta asignación? Esta acción no se puede deshacer.',
      itemDetails: <String, String>{
        'Fecha': dateFormat.format(asignacion.fecha),
        'Vehículo': asignacion.vehiculoId,
        'Dotación': asignacion.dotacionId,
        if (asignacion.plantillaTurnoId != null) 'Turno': asignacion.plantillaTurnoId!,
        'Estado': _getEstadoLabel(asignacion.estado),
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
        context.read<AsignacionesBloc>().add(AsignacionesEvent.delete(asignacion.id));
      }
    }
  }
}

// ==================== WIDGETS AUXILIARES ====================

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
        hintText: 'Buscar asignación...',
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
          message: 'Cargando asignaciones...',
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
            'Error al cargar asignaciones',
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
