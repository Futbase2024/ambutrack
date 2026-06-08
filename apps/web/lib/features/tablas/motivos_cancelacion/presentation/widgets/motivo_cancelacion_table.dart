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
import 'package:ambutrack_web/features/tablas/motivos_cancelacion/presentation/bloc/motivo_cancelacion_bloc.dart';
import 'package:ambutrack_web/features/tablas/motivos_cancelacion/presentation/bloc/motivo_cancelacion_event.dart';
import 'package:ambutrack_web/features/tablas/motivos_cancelacion/presentation/bloc/motivo_cancelacion_state.dart';
import 'package:ambutrack_web/features/tablas/motivos_cancelacion/presentation/widgets/motivo_cancelacion_form_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

/// Tabla de gestión de Motivos de Cancelación
class MotivoCancelacionTable extends StatefulWidget {
  const MotivoCancelacionTable({
    super.key,
    required this.searchQuery,
  });

  final String searchQuery;

  @override
  State<MotivoCancelacionTable> createState() => _MotivoCancelacionTableState();
}

class _MotivoCancelacionTableState extends State<MotivoCancelacionTable> {
  int? _sortColumnIndex = 0;
  bool _sortAscending = true;
  bool _isDeleting = false;
  BuildContext? _loadingDialogContext;
  DateTime? _deleteStartTime;
  int _currentPage = 0;
  static const int _itemsPerPage = 25;

  @override
  void didUpdateWidget(MotivoCancelacionTable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.searchQuery != widget.searchQuery) {
      _currentPage = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<MotivoCancelacionBloc, MotivoCancelacionState>(
      listener: (BuildContext context, Object? state) async {
        if (_isDeleting && _loadingDialogContext != null) {
          if (state is MotivoCancelacionLoaded || state is MotivoCancelacionError) {
            final Duration elapsed = DateTime.now().difference(_deleteStartTime!);

            if (state is MotivoCancelacionError) {
              await CrudOperationHandler.handleDeleteError(
                context: _loadingDialogContext!,
                isDeleting: _isDeleting,
                entityName: 'Motivo de Cancelación',
                errorMessage: state.message,
                onClose: () {
                  setState(() {
                    _isDeleting = false;
                    _loadingDialogContext = null;
                    _deleteStartTime = null;
                  });
                },
              );
            } else if (state is MotivoCancelacionLoaded) {
              await CrudOperationHandler.handleDeleteSuccess(
                context: _loadingDialogContext!,
                isDeleting: _isDeleting,
                entityName: 'Motivo de Cancelación',
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
      child: BlocBuilder<MotivoCancelacionBloc, MotivoCancelacionState>(
        builder: (BuildContext context, Object? state) {
          if (state is MotivoCancelacionLoaded) {
            List<MotivoCancelacionEntity> filtrados = _filterMotivos(state.motivos);
            filtrados = _sortMotivos(filtrados);

            final int totalItems = filtrados.length;
            final int totalPages = (totalItems / _itemsPerPage).ceil();
            final int startIndex = _currentPage * _itemsPerPage;
            final int endIndex = (startIndex + _itemsPerPage).clamp(0, totalItems);
            final List<MotivoCancelacionEntity> motivosPaginados = totalItems > 0
                ? filtrados.sublist(startIndex, endIndex)
                : <MotivoCancelacionEntity>[];

            final bool hasFilters = widget.searchQuery.isNotEmpty;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                if (state.motivos.length != filtrados.length && filtrados.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSizes.spacing),
                    child: Text(
                      'Mostrando ${filtrados.length} de ${state.motivos.length} motivos',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: AppColors.textSecondaryLight,
                      ),
                    ),
                  ),
                Expanded(
                  child: AppDataGridV5<MotivoCancelacionEntity>(
                    columns: const <DataGridColumn>[
                      DataGridColumn(label: 'NOMBRE', flexWidth: 2, sortable: true),
                      DataGridColumn(label: 'DESCRIPCIÓN', flexWidth: 4, sortable: true),
                      DataGridColumn(label: 'ESTADO', sortable: true),
                    ],
                    rows: motivosPaginados,
                    buildCells: (MotivoCancelacionEntity motivo) => <DataGridCell>[
                      DataGridCell(child: _buildNombreCell(motivo)),
                      DataGridCell(child: _buildDescripcionCell(motivo)),
                      DataGridCell(child: _buildEstadoCell(motivo)),
                    ],
                    sortColumnIndex: _sortColumnIndex,
                    sortAscending: _sortAscending,
                    onSort: (int columnIndex, {required bool ascending}) {
                      setState(() {
                        _sortColumnIndex = columnIndex;
                        _sortAscending = ascending;
                      });
                    },
                    outerBorderColor: AppColors.gray300,
                    emptyMessage: hasFilters
                        ? 'No se encontraron motivos con los filtros aplicados'
                        : 'No hay motivos de cancelación registrados',
                    onEdit: (MotivoCancelacionEntity motivo) => _editMotivo(context, motivo),
                    onDelete: (MotivoCancelacionEntity motivo) => _confirmDelete(context, motivo),
                  ),
                ),
                const SizedBox(height: AppSizes.spacing),
                _PaginationBar(
                  currentPage: _currentPage,
                  totalPages: totalPages.clamp(1, 999),
                  totalItems: totalItems,
                  itemsPerPage: _itemsPerPage,
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

  // ==================== FILTRADO Y ORDENAMIENTO ====================

  List<MotivoCancelacionEntity> _filterMotivos(List<MotivoCancelacionEntity> motivos) {
    if (widget.searchQuery.isEmpty) {
      return motivos;
    }

    final String query = widget.searchQuery.toLowerCase();
    return motivos.where((MotivoCancelacionEntity motivo) {
      return motivo.nombre.toLowerCase().contains(query) ||
          (motivo.descripcion ?? '').toLowerCase().contains(query);
    }).toList();
  }

  List<MotivoCancelacionEntity> _sortMotivos(List<MotivoCancelacionEntity> motivos) {
    if (_sortColumnIndex == null) {
      return motivos;
    }

    final List<MotivoCancelacionEntity> sorted = List<MotivoCancelacionEntity>.from(motivos)
      ..sort((MotivoCancelacionEntity a, MotivoCancelacionEntity b) {
        int comparison = 0;

        switch (_sortColumnIndex) {
          case 0:
            comparison = a.nombre.compareTo(b.nombre);
          case 1:
            comparison = (a.descripcion ?? '').compareTo(b.descripcion ?? '');
          case 2:
            comparison = a.activo == b.activo ? 0 : (a.activo ? -1 : 1);
          default:
            comparison = 0;
        }

        return _sortAscending ? comparison : -comparison;
      });

    return sorted;
  }

  // ==================== ACCIONES ====================

  Future<void> _editMotivo(BuildContext context, MotivoCancelacionEntity motivo) async {
    await showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) => BlocProvider<MotivoCancelacionBloc>.value(
        value: context.read<MotivoCancelacionBloc>(),
        child: MotivoCancelacionFormDialog(motivo: motivo),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, MotivoCancelacionEntity motivo) async {
    final bool? confirmed = await showConfirmationDialog(
      context: context,
      title: 'Confirmar Eliminación',
      message: '¿Estás seguro de que deseas eliminar este motivo de cancelación? Esta acción no se puede deshacer.',
      itemDetails: <String, String>{
        'Nombre': motivo.nombre,
        'Descripción': motivo.descripcion ?? '',
        'Estado': motivo.activo ? 'Activo' : 'Inactivo',
      },
    );

    if (confirmed == true && context.mounted) {
      debugPrint('Eliminando motivo: ${motivo.nombre} (${motivo.id})');

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
              message: 'Eliminando motivo de cancelación...',
              color: AppColors.emergency,
              icon: Icons.delete_forever,
            );
          },
        ),
      );

      if (context.mounted) {
        context.read<MotivoCancelacionBloc>().add(MotivoCancelacionDeleteRequested(motivo.id));
      }
    }
  }

  // ==================== CELL BUILDERS ====================

  Widget _buildNombreCell(MotivoCancelacionEntity motivo) {
    return Text(
      motivo.nombre,
      style: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimaryLight,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildDescripcionCell(MotivoCancelacionEntity motivo) {
    final String desc = motivo.descripcion ?? '';
    return Text(
      desc.isEmpty ? 'Sin descripción' : desc,
      style: GoogleFonts.inter(
        fontSize: 13,
        color: desc.isNotEmpty
            ? AppColors.textSecondaryLight
            : AppColors.textSecondaryLight.withValues(alpha: 0.5),
        fontStyle: desc.isNotEmpty ? FontStyle.normal : FontStyle.italic,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildEstadoCell(MotivoCancelacionEntity motivo) {
    return Container(
      width: double.infinity,
      alignment: Alignment.center,
      child: StatusBadge(
        label: motivo.activo ? 'Activo' : 'Inactivo',
        type: motivo.activo ? StatusBadgeType.success : StatusBadgeType.inactivo,
      ),
    );
  }
}

/// Campo de búsqueda - usado desde la página
class MotivoCancelacionSearchField extends StatefulWidget {
  const MotivoCancelacionSearchField({
    super.key,
    required this.searchQuery,
    required this.onSearchChanged,
  });

  final String searchQuery;
  final void Function(String) onSearchChanged;

  @override
  State<MotivoCancelacionSearchField> createState() => _MotivoCancelacionSearchFieldState();
}

class _MotivoCancelacionSearchFieldState extends State<MotivoCancelacionSearchField> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.searchQuery);
  }

  @override
  void didUpdateWidget(MotivoCancelacionSearchField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.searchQuery != widget.searchQuery && _controller.text != widget.searchQuery) {
      _controller.text = widget.searchQuery;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 250,
      child: TextField(
        controller: _controller,
        onChanged: widget.onSearchChanged,
        decoration: InputDecoration(
          hintText: 'Buscar motivo...',
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
      ),
    );
  }
}

/// Paginación compacta
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
  final void Function(int) onPageChanged;

  @override
  Widget build(BuildContext context) {
    final int startItem = totalItems == 0 ? 0 : currentPage * itemsPerPage + 1;
    final int endItem = totalItems == 0
        ? 0
        : ((currentPage + 1) * itemsPerPage).clamp(0, totalItems);

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
            'Mostrando $startItem-$endItem de $totalItems items',
            style: AppTextStyles.bodySmallSecondary,
          ),
          Row(
            children: <Widget>[
              IconButton(
                icon: const Icon(Icons.first_page),
                onPressed: currentPage > 0 ? () => onPageChanged(0) : null,
                tooltip: 'Primera página',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: currentPage > 0 ? () => onPageChanged(currentPage - 1) : null,
                tooltip: 'Página anterior',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.paddingSmall,
                  vertical: 4,
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
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: currentPage < totalPages - 1 ? () => onPageChanged(currentPage + 1) : null,
                tooltip: 'Página siguiente',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
              ),
              IconButton(
                icon: const Icon(Icons.last_page),
                onPressed: currentPage < totalPages - 1 ? () => onPageChanged(totalPages - 1) : null,
                tooltip: 'Última página',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
