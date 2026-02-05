import 'dart:async';

import 'package:ambutrack_core/ambutrack_core.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/core/theme/app_text_styles.dart';
import 'package:ambutrack_web/core/widgets/dialogs/confirmation_dialog.dart';
import 'package:ambutrack_web/core/widgets/handlers/crud_operation_handler.dart';
import 'package:ambutrack_web/core/widgets/loading/app_loading_indicator.dart';
import 'package:ambutrack_web/core/widgets/tables/app_data_grid_v5.dart';
import 'package:ambutrack_web/features/cuadrante/dotaciones/presentation/bloc/dotaciones_bloc_exports.dart';
import 'package:ambutrack_web/features/cuadrante/dotaciones/presentation/widgets/dotacion_form_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

/// Tabla de gestión de Dotaciones
class DotacionesTable extends StatefulWidget {
  const DotacionesTable({super.key});

  @override
  State<DotacionesTable> createState() => _DotacionesTableState();
}

class _DotacionesTableState extends State<DotacionesTable> {
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
    return BlocListener<DotacionesBloc, DotacionesState>(
      listener: (BuildContext context, Object? state) async {
        // Manejo de loading al eliminar
        if (_isDeleting && _loadingDialogContext != null) {
          if (state is DotacionesLoaded || state is DotacionesError || state is DotacionOperationSuccess) {
            final Duration elapsed = DateTime.now().difference(_deleteStartTime!);

            // Manejar resultado con CrudOperationHandler
            if (state is DotacionesError) {
              await CrudOperationHandler.handleDeleteError(
                context: _loadingDialogContext!,
                isDeleting: _isDeleting,
                entityName: 'Dotación',
                errorMessage: state.message,
                onClose: () {
                  setState(() {
                    _isDeleting = false;
                    _loadingDialogContext = null;
                    _deleteStartTime = null;
                  });
                },
              );
            } else if (state is DotacionOperationSuccess) {
              await CrudOperationHandler.handleDeleteSuccess(
                context: _loadingDialogContext!,
                isDeleting: _isDeleting,
                entityName: 'Dotación',
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
      child: BlocBuilder<DotacionesBloc, DotacionesState>(
        builder: (BuildContext context, Object? state) {
          if (state is DotacionesLoading) {
            return const _LoadingView();
          }

          if (state is DotacionesError) {
            return _ErrorView(message: state.message);
          }

          if (state is DotacionesLoaded || state is DotacionOperationSuccess) {
            final List<DotacionEntity> dotaciones = state is DotacionesLoaded
                ? state.dotaciones
                : (state as DotacionOperationSuccess).dotaciones;

            // Filtrado y ordenamiento
            List<DotacionEntity> filtradas = _filterDotaciones(dotaciones);
            filtradas = _sortDotaciones(filtradas);

            // Cálculo de paginación
            final int totalItems = filtradas.length;
            final int totalPages = (totalItems / _itemsPerPage).ceil();
            final int startIndex = _currentPage * _itemsPerPage;
            final int endIndex = (startIndex + _itemsPerPage).clamp(0, totalItems);
            final List<DotacionEntity> dotacionesPaginadas = totalItems > 0
                ? filtradas.sublist(startIndex, endIndex)
                : <DotacionEntity>[];

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                // Header: Búsqueda
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        'Listado de Dotaciones',
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
                if (dotaciones.length != filtradas.length)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSizes.spacing),
                    child: Text(
                      'Mostrando ${filtradas.length} de ${dotaciones.length} dotaciones',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: AppColors.textSecondaryLight,
                      ),
                    ),
                  ),

                // Tabla con scroll interno
                Expanded(
                  child: AppDataGridV5<DotacionEntity>(
                    columns: const <DataGridColumn>[
                      DataGridColumn(label: 'NOMBRE', flexWidth: 2, sortable: true),
                      DataGridColumn(label: 'DESTINO', sortable: true),
                      DataGridColumn(label: 'UNIDADES', sortable: true),
                      DataGridColumn(label: 'PRIORIDAD', sortable: true),
                      DataGridColumn(label: 'VIGENCIA'),
                      DataGridColumn(label: 'ESTADO', sortable: true),
                    ],
                    rows: dotacionesPaginadas,
                    buildCells: (DotacionEntity dotacion) => <DataGridCell>[
                      DataGridCell(child: _buildNombreCell(dotacion)),
                      DataGridCell(child: _buildDestinoCell(dotacion)),
                      DataGridCell(child: _buildUnidadesCell(dotacion)),
                      DataGridCell(child: _buildPrioridadCell(dotacion)),
                      DataGridCell(child: _buildVigenciaCell(dotacion)),
                      DataGridCell(child: _buildEstadoCell(dotacion)),
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
                        ? 'No se encontraron dotaciones con los filtros aplicados'
                        : 'No hay dotaciones registradas',
                    onEdit: (DotacionEntity dotacion) => _editDotacion(context, dotacion),
                    onDelete: (DotacionEntity dotacion) => _confirmDelete(context, dotacion),
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

  Widget _buildNombreCell(DotacionEntity dotacion) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          dotacion.nombre,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimaryLight,
          ),
        ),
        if (dotacion.descripcion != null && dotacion.descripcion!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              dotacion.descripcion!,
              style: GoogleFonts.inter(
                fontSize: 11,
                color: AppColors.textSecondaryLight,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
      ],
    );
  }

  Widget _buildDestinoCell(DotacionEntity dotacion) {
    final String tipoDestino = dotacion.tipoDestino;
    IconData icon;
    Color color;

    switch (tipoDestino) {
      case 'Hospital':
        icon = Icons.local_hospital;
        color = AppColors.error;
        break;
      case 'Base':
        icon = Icons.home_work;
        color = AppColors.primary;
        break;
      case 'Contrato':
        icon = Icons.description;
        color = AppColors.warning;
        break;
      default:
        icon = Icons.help_outline;
        color = AppColors.textSecondaryLight;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 6),
        Text(
          tipoDestino,
          style: GoogleFonts.inter(
            fontSize: 13,
            color: AppColors.textPrimaryLight,
          ),
        ),
      ],
    );
  }

  Widget _buildUnidadesCell(DotacionEntity dotacion) {
    return Container(
      width: double.infinity,
      alignment: Alignment.center,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.primarySurface,
          borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        ),
        child: Text(
          '${dotacion.cantidadUnidades}',
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }

  Widget _buildPrioridadCell(DotacionEntity dotacion) {
    Color color;
    String label;

    if (dotacion.prioridad >= 8) {
      color = AppColors.error;
      label = 'Alta';
    } else if (dotacion.prioridad >= 5) {
      color = AppColors.warning;
      label = 'Media';
    } else {
      color = AppColors.success;
      label = 'Baja';
    }

    return Container(
      width: double.infinity,
      alignment: Alignment.center,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              '${dotacion.prioridad}',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 11,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVigenciaCell(DotacionEntity dotacion) {
    final DateFormat dateFormat = DateFormat('dd/MM/yyyy');
    final String inicio = dateFormat.format(dotacion.fechaInicio);
    final String fin = dotacion.fechaFin != null ? dateFormat.format(dotacion.fechaFin!) : 'Indefinido';

    final bool esVigente = dotacion.esVigenteEn(DateTime.now());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          inicio,
          style: GoogleFonts.inter(
            fontSize: 12,
            color: AppColors.textPrimaryLight,
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              esVigente ? Icons.arrow_forward : Icons.event_busy,
              size: 10,
              color: esVigente ? AppColors.success : AppColors.error,
            ),
            const SizedBox(width: 4),
            Text(
              fin,
              style: GoogleFonts.inter(
                fontSize: 11,
                color: esVigente ? AppColors.success : AppColors.error,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEstadoCell(DotacionEntity dotacion) {
    return Container(
      width: double.infinity,
      alignment: Alignment.center,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: dotacion.activo ? AppColors.success.withValues(alpha: 0.1) : AppColors.error.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
          border: Border.all(
            color: dotacion.activo ? AppColors.success.withValues(alpha: 0.3) : AppColors.error.withValues(alpha: 0.3),
          ),
        ),
        child: Text(
          dotacion.activo ? 'Activa' : 'Inactiva',
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: dotacion.activo ? AppColors.success.withValues(alpha: 0.8) : AppColors.error.withValues(alpha: 0.8),
          ),
        ),
      ),
    );
  }

  // ==================== FILTRADO Y ORDENAMIENTO ====================

  List<DotacionEntity> _filterDotaciones(List<DotacionEntity> dotaciones) {
    if (_searchQuery.isEmpty) {
      return dotaciones;
    }

    final String query = _searchQuery.toLowerCase();
    return dotaciones.where((DotacionEntity dotacion) {
      return dotacion.nombre.toLowerCase().contains(query) ||
          (dotacion.descripcion?.toLowerCase().contains(query) ?? false);
    }).toList();
  }

  List<DotacionEntity> _sortDotaciones(List<DotacionEntity> dotaciones) {
    if (_sortColumnIndex == null) {
      return dotaciones;
    }

    final List<DotacionEntity> sorted = List<DotacionEntity>.from(dotaciones)

    ..sort((DotacionEntity a, DotacionEntity b) {
      int comparison = 0;

      switch (_sortColumnIndex) {
        case 0: // NOMBRE
          comparison = a.nombre.compareTo(b.nombre);
          break;
        case 1: // DESTINO
          comparison = a.tipoDestino.compareTo(b.tipoDestino);
          break;
        case 2: // UNIDADES
          comparison = a.cantidadUnidades.compareTo(b.cantidadUnidades);
          break;
        case 3: // PRIORIDAD
          comparison = a.prioridad.compareTo(b.prioridad);
          break;
        case 5: // ESTADO
          comparison = a.activo == b.activo ? 0 : (a.activo ? -1 : 1);
          break;
      }

      return _sortAscending ? comparison : -comparison;
    });

    return sorted;
  }

  // ==================== ACCIONES ====================

  Future<void> _editDotacion(BuildContext context, DotacionEntity dotacion) async {
    await showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return BlocProvider<DotacionesBloc>.value(
          value: context.read<DotacionesBloc>(),
          child: DotacionFormDialog(dotacion: dotacion),
        );
      },
    );
  }

  Future<void> _confirmDelete(BuildContext context, DotacionEntity dotacion) async {
    final bool? confirmed = await showConfirmationDialog(
      context: context,
      title: 'Confirmar Eliminación',
      message: '¿Estás seguro de que deseas eliminar esta dotación? Esta acción no se puede deshacer.',
      itemDetails: <String, String>{
        'Código': dotacion.codigo ?? 'N/A',
        'Nombre': dotacion.nombre,
        if (dotacion.descripcion != null && dotacion.descripcion!.isNotEmpty) 'Descripción': dotacion.descripcion!,
        'Destino': dotacion.tipoDestino,
        'Unidades': '${dotacion.cantidadUnidades}',
        'Prioridad': '${dotacion.prioridad}',
        'Estado': dotacion.activo ? 'Activa' : 'Inactiva',
      },
    );

    if (confirmed == true && context.mounted) {
      debugPrint('🗑️ Eliminando dotación: ${dotacion.nombre} (${dotacion.id})');

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
              message: 'Eliminando dotación...',
              color: AppColors.emergency,
              icon: Icons.delete_forever,
            );
          },
        ),
      );

      if (context.mounted) {
        context.read<DotacionesBloc>().add(DotacionDeleteRequested(dotacion.id));
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
        hintText: 'Buscar dotación...',
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
          message: 'Cargando dotaciones...',
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
            'Error al cargar dotaciones',
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
