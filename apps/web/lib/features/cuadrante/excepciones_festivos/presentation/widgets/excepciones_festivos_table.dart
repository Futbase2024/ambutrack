import 'dart:async';

import 'package:ambutrack_core/ambutrack_core.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/core/theme/app_text_styles.dart';
import 'package:ambutrack_web/core/widgets/dialogs/confirmation_dialog.dart';
import 'package:ambutrack_web/core/widgets/handlers/crud_operation_handler.dart';
import 'package:ambutrack_web/core/widgets/loading/app_loading_indicator.dart';
import 'package:ambutrack_web/core/widgets/tables/app_data_grid_v5.dart';
import 'package:ambutrack_web/features/cuadrante/excepciones_festivos/presentation/bloc/excepciones_festivos_bloc_exports.dart';
import 'package:ambutrack_web/features/cuadrante/excepciones_festivos/presentation/widgets/excepcion_festivo_form_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

/// Tabla de gestión de Excepciones y Festivos
class ExcepcionesFestivosTable extends StatefulWidget {
  const ExcepcionesFestivosTable({super.key});

  @override
  State<ExcepcionesFestivosTable> createState() => _ExcepcionesFestivosTableState();
}

class _ExcepcionesFestivosTableState extends State<ExcepcionesFestivosTable> {
  String _searchQuery = '';
  int? _sortColumnIndex = 0; // Ordenar por FECHA por defecto
  bool _sortAscending = true; // Ascendente = más próxima primero
  bool _isDeleting = false;
  BuildContext? _loadingDialogContext;
  DateTime? _deleteStartTime;
  int _currentPage = 0;
  static const int _itemsPerPage = 25;

  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');

  @override
  Widget build(BuildContext context) {
    return BlocListener<ExcepcionesFestivosBloc, ExcepcionesFestivosState>(
      listener: (BuildContext context, Object? state) async {
        // Manejo de loading al eliminar
        if (_isDeleting && _loadingDialogContext != null) {
          if (state is ExcepcionesFestivosLoaded || state is ExcepcionesFestivosError || state is ExcepcionFestivoOperationSuccess) {
            final Duration elapsed = DateTime.now().difference(_deleteStartTime!);

            // Manejar resultado con CrudOperationHandler
            if (state is ExcepcionesFestivosError) {
              await CrudOperationHandler.handleDeleteError(
                context: _loadingDialogContext!,
                isDeleting: _isDeleting,
                entityName: 'Excepción/Festivo',
                errorMessage: state.message,
                onClose: () {
                  setState(() {
                    _isDeleting = false;
                    _loadingDialogContext = null;
                    _deleteStartTime = null;
                  });
                },
              );
            } else if (state is ExcepcionFestivoOperationSuccess) {
              await CrudOperationHandler.handleDeleteSuccess(
                context: _loadingDialogContext!,
                isDeleting: _isDeleting,
                entityName: 'Excepción/Festivo',
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
      child: BlocBuilder<ExcepcionesFestivosBloc, ExcepcionesFestivosState>(
        builder: (BuildContext context, Object? state) {
          if (state is ExcepcionesFestivosLoading) {
            return const _LoadingView();
          }

          if (state is ExcepcionesFestivosError) {
            return _ErrorView(message: state.message);
          }

          if (state is ExcepcionesFestivosLoaded || state is ExcepcionFestivoOperationSuccess) {
            final List<ExcepcionFestivoEntity> items = state is ExcepcionesFestivosLoaded
                ? state.items
                : (state as ExcepcionFestivoOperationSuccess).items;

            // Filtrado y ordenamiento
            List<ExcepcionFestivoEntity> filtrados = _filterItems(items);
            filtrados = _sortItems(filtrados);

            // Cálculo de paginación
            final int totalItems = filtrados.length;
            final int totalPages = (totalItems / _itemsPerPage).ceil();
            final int startIndex = _currentPage * _itemsPerPage;
            final int endIndex = (startIndex + _itemsPerPage).clamp(0, totalItems);
            final List<ExcepcionFestivoEntity> itemsPaginados = totalItems > 0
                ? filtrados.sublist(startIndex, endIndex)
                : <ExcepcionFestivoEntity>[];

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                // Header: Búsqueda
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        'Listado de Excepciones y Festivos',
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
                if (items.length != filtrados.length)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSizes.spacing),
                    child: Text(
                      'Mostrando ${filtrados.length} de ${items.length} excepciones/festivos',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: AppColors.textSecondaryLight,
                      ),
                    ),
                  ),

                // Tabla con scroll interno
                Expanded(
                  child: AppDataGridV5<ExcepcionFestivoEntity>(
                    columns: const <DataGridColumn>[
                      DataGridColumn(label: 'FECHA', sortable: true),
                      DataGridColumn(label: 'NOMBRE', flexWidth: 2, sortable: true),
                      DataGridColumn(label: 'TIPO', sortable: true),
                      DataGridColumn(label: 'REPETIR ANUAL', sortable: true),
                      DataGridColumn(label: 'AFECTA DOTACIONES', sortable: true),
                      DataGridColumn(label: 'ESTADO', sortable: true),
                    ],
                    rows: itemsPaginados,
                    buildCells: (ExcepcionFestivoEntity item) => <DataGridCell>[
                      DataGridCell(child: _buildFechaCell(item)),
                      DataGridCell(child: _buildNombreCell(item)),
                      DataGridCell(child: _buildTipoCell(item)),
                      DataGridCell(child: _buildRepetirCell(item)),
                      DataGridCell(child: _buildAfectaDotacionesCell(item)),
                      DataGridCell(child: _buildEstadoCell(item)),
                    ],
                    sortColumnIndex: _sortColumnIndex,
                    sortAscending: _sortAscending,
                    onSort: (int columnIndex, {required bool ascending}) {
                      setState(() {
                        _sortColumnIndex = columnIndex;
                        _sortAscending = ascending;
                      });
                    },
                    rowHeight: 68,
                    outerBorderColor: AppColors.gray300,
                    emptyMessage: _searchQuery.isNotEmpty
                        ? 'No se encontraron excepciones/festivos con los filtros aplicados'
                        : 'No hay excepciones/festivos registradas',
                    onEdit: (ExcepcionFestivoEntity item) => _editItem(context, item),
                    onDelete: (ExcepcionFestivoEntity item) => _confirmDelete(context, item),
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

  // ==================== CELDAS ====================

  Widget _buildNombreCell(ExcepcionFestivoEntity item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          item.nombre,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimaryLight,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        if (item.descripcion != null && item.descripcion!.isNotEmpty) ...<Widget>[
          const SizedBox(height: 4),
          Text(
            item.descripcion!,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: AppColors.textSecondaryLight,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }

  Widget _buildFechaCell(ExcepcionFestivoEntity item) {
    return Text(
      _dateFormat.format(item.fecha),
      style: GoogleFonts.inter(
        fontSize: 14,
        color: AppColors.textPrimaryLight,
      ),
    );
  }

  Widget _buildTipoCell(ExcepcionFestivoEntity item) {
    return Text(
      item.tipo,
      style: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimaryLight,
      ),
    );
  }

  Widget _buildRepetirCell(ExcepcionFestivoEntity item) {
    final Color color = item.repetirAnualmente ? AppColors.success : AppColors.gray400;
    final String label = item.repetirAnualmente ? 'Sí' : 'No';

    return Container(
      width: double.infinity,
      alignment: Alignment.center,
      child: Container(
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
      ),
    );
  }

  Widget _buildAfectaDotacionesCell(ExcepcionFestivoEntity item) {
    final Color color = item.afectaDotaciones ? AppColors.warning : AppColors.gray400;
    final String label = item.afectaDotaciones ? 'Sí' : 'No';

    return Container(
      width: double.infinity,
      alignment: Alignment.center,
      child: Container(
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
      ),
    );
  }

  Widget _buildEstadoCell(ExcepcionFestivoEntity item) {
    final Color color = item.activo ? AppColors.success : AppColors.gray400;
    final String label = item.activo ? 'Activo' : 'Inactivo';

    return Container(
      width: double.infinity,
      alignment: Alignment.center,
      child: Container(
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
      ),
    );
  }

  // ==================== FILTRADO Y ORDENAMIENTO ====================

  List<ExcepcionFestivoEntity> _filterItems(List<ExcepcionFestivoEntity> items) {
    if (_searchQuery.isEmpty) {
      return items;
    }

    final String query = _searchQuery.toLowerCase();
    return items.where((ExcepcionFestivoEntity item) {
      return item.nombre.toLowerCase().contains(query) ||
          item.tipo.toLowerCase().contains(query) ||
          (item.descripcion?.toLowerCase().contains(query) ?? false) ||
          _dateFormat.format(item.fecha).contains(query);
    }).toList();
  }

  List<ExcepcionFestivoEntity> _sortItems(List<ExcepcionFestivoEntity> items) {
    if (_sortColumnIndex == null) {
      return items;
    }

    final List<ExcepcionFestivoEntity> sorted = List<ExcepcionFestivoEntity>.from(items);
    final DateTime now = DateTime.now();

    return sorted
      ..sort((ExcepcionFestivoEntity a, ExcepcionFestivoEntity b) {
        int comparison = 0;

        switch (_sortColumnIndex) {
          case 0: // Fecha (ordenar por proximidad a fecha actual)
            // Calcular diferencia absoluta con la fecha actual
            final Duration diffA = a.fecha.difference(now).abs();
            final Duration diffB = b.fecha.difference(now).abs();
            comparison = diffA.compareTo(diffB);
            break;
          case 1: // Nombre
            comparison = a.nombre.compareTo(b.nombre);
            break;
          case 2: // Tipo
            comparison = a.tipo.compareTo(b.tipo);
            break;
          case 3: // Repetir Anual
            comparison = a.repetirAnualmente == b.repetirAnualmente ? 0 : (a.repetirAnualmente ? -1 : 1);
            break;
          case 4: // Afecta Dotaciones
            comparison = a.afectaDotaciones == b.afectaDotaciones ? 0 : (a.afectaDotaciones ? -1 : 1);
            break;
          case 5: // Estado
            comparison = a.activo == b.activo ? 0 : (a.activo ? -1 : 1);
            break;
        }

        return _sortAscending ? comparison : -comparison;
      });
  }

  // ==================== ACCIONES ====================

  void _editItem(BuildContext context, ExcepcionFestivoEntity item) {
    showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) => BlocProvider<ExcepcionesFestivosBloc>.value(
        value: context.read<ExcepcionesFestivosBloc>(),
        child: ExcepcionFestivoFormDialog(item: item),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, ExcepcionFestivoEntity item) async {
    final bool? confirmed = await showConfirmationDialog(
      context: context,
      title: 'Confirmar Eliminación',
      message: '¿Estás seguro de que deseas eliminar esta excepción/festivo? Esta acción no se puede deshacer.',
      itemDetails: <String, String>{
        'Nombre': item.nombre,
        'Fecha': _dateFormat.format(item.fecha),
        'Tipo': item.tipo,
        if (item.descripcion != null && item.descripcion!.isNotEmpty)
          'Descripción': item.descripcion!,
        'Repetir Anualmente': item.repetirAnualmente ? 'Sí' : 'No',
        'Afecta Dotaciones': item.afectaDotaciones ? 'Sí' : 'No',
        'Estado': item.activo ? 'Activo' : 'Inactivo',
      },
    );

    if (confirmed == true && context.mounted) {
      debugPrint('🗑️ Eliminando excepción/festivo: ${item.nombre} (${item.id})');

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
              message: 'Eliminando excepción/festivo...',
              color: AppColors.emergency,
              icon: Icons.delete_forever,
            );
          },
        ),
      );

      if (context.mounted) {
        context.read<ExcepcionesFestivosBloc>().add(ExcepcionFestivoDeleteRequested(item.id));
      }
    }
  }
}

// ==================== CAMPO DE BÚSQUEDA ====================

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
        hintText: 'Buscar excepción/festivo...',
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

// ==================== VISTAS DE ESTADO ====================

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
          message: 'Cargando excepciones/festivos...',
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
            'Error al cargar excepciones/festivos',
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
