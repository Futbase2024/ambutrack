import 'dart:async';

import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/core/theme/app_text_styles.dart';
import 'package:ambutrack_web/core/widgets/dialogs/confirmation_dialog.dart';
import 'package:ambutrack_web/core/widgets/handlers/crud_operation_handler.dart';
import 'package:ambutrack_web/core/widgets/loading/app_loading_indicator.dart';
import 'package:ambutrack_web/core/widgets/tables/app_data_grid_v5.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../bloc/equipamiento_personal_bloc.dart';
import '../bloc/equipamiento_personal_event.dart';
import '../bloc/equipamiento_personal_state.dart';
import 'equipamiento_personal_form_dialog.dart';

/// Tabla de Equipamiento Personal
class EquipamientoPersonalTable extends StatefulWidget {
  const EquipamientoPersonalTable({
    super.key,
    required this.searchQuery,
  });

  final String searchQuery;

  @override
  State<EquipamientoPersonalTable> createState() => _EquipamientoPersonalTableState();
}

class _EquipamientoPersonalTableState extends State<EquipamientoPersonalTable> {
  int _sortColumnIndex = 0;
  bool _sortAscending = true;
  bool _isDeleting = false;
  BuildContext? _loadingDialogContext;
  DateTime? _deleteStartTime;
  int _currentPage = 0;
  static const int _itemsPerPage = 25;

  @override
  void didUpdateWidget(EquipamientoPersonalTable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.searchQuery != widget.searchQuery) {
      _currentPage = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<EquipamientoPersonalBloc, EquipamientoPersonalState>(
      listener: (BuildContext context, EquipamientoPersonalState state) {
        if (_isDeleting && _loadingDialogContext != null) {
          if (state is EquipamientoPersonalLoaded || state is EquipamientoPersonalError) {
            final Duration elapsed = DateTime.now().difference(_deleteStartTime!);

            if (state is EquipamientoPersonalLoaded) {
              CrudOperationHandler.handleDeleteSuccess(
                context: context,
                isDeleting: _isDeleting,
                entityName: 'Equipamiento',
                durationMs: elapsed.inMilliseconds,
                onClose: () => setState(() {
                  _isDeleting = false;
                  _loadingDialogContext = null;
                }),
              );
            } else if (state is EquipamientoPersonalError) {
              CrudOperationHandler.handleDeleteError(
                context: context,
                isDeleting: _isDeleting,
                entityName: 'Equipamiento',
                errorMessage: state.message,
                onClose: () => setState(() {
                  _isDeleting = false;
                  _loadingDialogContext = null;
                }),
              );
            }
          }
        }
      },
      child: BlocBuilder<EquipamientoPersonalBloc, EquipamientoPersonalState>(
        builder: (BuildContext context, EquipamientoPersonalState state) {
          if (state is EquipamientoPersonalLoading) {
            return const _LoadingView();
          }

          if (state is EquipamientoPersonalError) {
            return _ErrorView(message: state.message);
          }

          if (state is EquipamientoPersonalLoaded) {
            List<EquipamientoPersonalEntity> filtrados = _filterItems(state.items);
            filtrados = _sortItems(filtrados);

            // Cálculo de paginación
            final int totalItems = filtrados.length;
            final int totalPages = (totalItems / _itemsPerPage).ceil();
            final int startIndex = _currentPage * _itemsPerPage;
            final int endIndex = (startIndex + _itemsPerPage).clamp(0, totalItems);
            final List<EquipamientoPersonalEntity> itemsPaginados =
                filtrados.sublist(startIndex, endIndex);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                if (state.items.length != filtrados.length)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSizes.spacing),
                    child: Text(
                      'Mostrando ${filtrados.length} de ${state.items.length} registros',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: AppColors.textSecondaryLight,
                      ),
                    ),
                  ),

                Expanded(
                  child: AppDataGridV5<EquipamientoPersonalEntity>(
                    columns: const <DataGridColumn>[
                      DataGridColumn(label: 'TIPO', flexWidth: 1, sortable: true),
                      DataGridColumn(label: 'NOMBRE', flexWidth: 2, sortable: true),
                      DataGridColumn(label: 'FECHA ASIGNACIÓN', flexWidth: 2, sortable: true),
                      DataGridColumn(label: 'TALLA', flexWidth: 1, sortable: true),
                      DataGridColumn(label: 'ESTADO', flexWidth: 1, sortable: true),
                    ],
                    rows: itemsPaginados,
                    buildCells: (EquipamientoPersonalEntity item) => <DataGridCell>[
                      DataGridCell(child: _buildTipoCell(item.tipoEquipamiento)),
                      DataGridCell(child: _buildNombreCell(item)),
                      DataGridCell(child: _buildFechaAsignacionCell(item)),
                      DataGridCell(child: _buildTallaCell(item)),
                      DataGridCell(child: _buildEstadoCell(item)),
                    ],
                    onEdit: (EquipamientoPersonalEntity item) => _showEditDialog(context, item),
                    onDelete: (EquipamientoPersonalEntity item) => _confirmDelete(context, item),
                    emptyMessage: widget.searchQuery.isNotEmpty
                        ? 'No se encontraron registros con los filtros aplicados'
                        : 'No hay equipamiento registrado',
                    sortColumnIndex: _sortColumnIndex,
                    sortAscending: _sortAscending,
                    onSort: (int columnIndex, {required bool ascending}) {
                      setState(() {
                        _sortColumnIndex = columnIndex;
                        _sortAscending = ascending;
                      });
                    },
                  ),
                ),

                const SizedBox(height: AppSizes.spacing),
                _PaginationBar(
                  currentPage: _currentPage,
                  totalPages: totalPages.clamp(1, 999),
                  totalItems: totalItems,
                  itemsPerPage: _itemsPerPage,
                  onPageChanged: (int page) { setState(() { _currentPage = page; }); },
                ),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  /// Construye controles de paginación profesional
  List<EquipamientoPersonalEntity> _filterItems(List<EquipamientoPersonalEntity> items) {
    if (widget.searchQuery.isEmpty) {
      return items;
    }

    final String query = widget.searchQuery.toLowerCase();

    return items.where((EquipamientoPersonalEntity item) {
      return item.nombreEquipamiento.toLowerCase().contains(query) ||
          item.tipoEquipamiento.toLowerCase().contains(query) ||
          (item.talla?.toLowerCase().contains(query) ?? false) ||
          (item.numeroSerie?.toLowerCase().contains(query) ?? false) ||
          (item.estado?.toLowerCase().contains(query) ?? false);
    }).toList();
  }

  List<EquipamientoPersonalEntity> _sortItems(List<EquipamientoPersonalEntity> items) {
    final List<EquipamientoPersonalEntity> sorted = List<EquipamientoPersonalEntity>.from(items)

    ..sort((EquipamientoPersonalEntity a, EquipamientoPersonalEntity b) {
      int compare = 0;

      switch (_sortColumnIndex) {
        case 0:
          compare = a.tipoEquipamiento.compareTo(b.tipoEquipamiento);
        case 1:
          compare = a.nombreEquipamiento.compareTo(b.nombreEquipamiento);
        case 2:
          compare = a.fechaAsignacion.compareTo(b.fechaAsignacion);
        case 3:
          compare = (a.talla ?? '').compareTo(b.talla ?? '');
        case 4:
          compare = a.estaAsignado.toString().compareTo(b.estaAsignado.toString());
      }

      return _sortAscending ? compare : -compare;
    });

    return sorted;
  }

  Widget _buildTipoCell(String tipo) {
    Color color;
    String label;

    switch (tipo) {
      case 'uniforme':
        color = AppColors.primary;
        label = 'Uniforme';
      case 'epi':
        color = AppColors.warning;
        label = 'EPI';
      case 'tecnologico':
        color = AppColors.info;
        label = 'Tecnológico';
      case 'sanitario':
        color = AppColors.success;
        label = 'Sanitario';
      default:
        color = AppColors.gray400;
        label = tipo;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
    );
  }

  Widget _buildNombreCell(EquipamientoPersonalEntity item) {
    return Text(
      item.nombreEquipamiento,
      style: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimaryLight,
      ),
    );
  }

  Widget _buildFechaAsignacionCell(EquipamientoPersonalEntity item) {
    final String fecha = DateFormat('dd/MM/yyyy').format(item.fechaAsignacion);
    return Text(
      fecha,
      style: AppTextStyles.tableCell,
    );
  }

  Widget _buildTallaCell(EquipamientoPersonalEntity item) {
    return Text(
      item.talla ?? '-',
      style: AppTextStyles.tableCell,
    );
  }

  Widget _buildEstadoCell(EquipamientoPersonalEntity item) {
    final bool asignado = item.estaAsignado;
    return Align(
      alignment: Alignment.centerLeft,
      child: IntrinsicWidth(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: asignado
                ? AppColors.success.withValues(alpha: 0.1)
                : AppColors.gray300.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
          ),
          child: Text(
            asignado ? 'Asignado' : 'Devuelto',
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: asignado ? AppColors.success : AppColors.gray600,
            ),
          ),
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context, EquipamientoPersonalEntity item) {
    showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return BlocProvider<EquipamientoPersonalBloc>.value(
          value: context.read<EquipamientoPersonalBloc>(),
          child: EquipamientoPersonalFormDialog(item: item),
        );
      },
    );
  }

  Future<void> _confirmDelete(BuildContext context, EquipamientoPersonalEntity item) async {
    final bool? confirmed = await showConfirmationDialog(
      context: context,
      title: 'Confirmar Eliminación',
      message:
          '¿Estás seguro de que deseas eliminar este equipamiento? Esta acción no se puede deshacer.',
      itemDetails: <String, String>{
        'Nombre': item.nombreEquipamiento,
        'Tipo': item.tipoEquipamiento,
        if (item.talla != null && item.talla!.isNotEmpty) 'Talla': item.talla!,
        if (item.numeroSerie != null && item.numeroSerie!.isNotEmpty)
          'Nº Serie': item.numeroSerie!,
        'Fecha Asignación': DateFormat('dd/MM/yyyy').format(item.fechaAsignacion),
        'Estado': item.estaAsignado ? 'Asignado' : 'Devuelto',
      },
    );

    if (confirmed == true && context.mounted) {
      debugPrint('🗑️ Eliminando equipamiento: ${item.nombreEquipamiento} (${item.id})');

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
              message: 'Eliminando equipamiento...',
              color: AppColors.emergency,
              icon: Icons.delete_forever,
            );
          },
        ),
      );

      if (context.mounted) {
        context.read<EquipamientoPersonalBloc>().add(EquipamientoPersonalDeleteRequested(item.id));
      }
    }
  }
}

/// Campo de búsqueda para Equipamiento Personal (usado en PageHeader.extra)
class EquipamientoPersonalSearchField extends StatefulWidget {
  const EquipamientoPersonalSearchField({
    super.key,
    required this.searchQuery,
    required this.onSearchChanged,
  });

  final String searchQuery;
  final void Function(String) onSearchChanged;

  @override
  State<EquipamientoPersonalSearchField> createState() => _EquipamientoPersonalSearchFieldState();
}

class _EquipamientoPersonalSearchFieldState extends State<EquipamientoPersonalSearchField> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.searchQuery);
  }

  @override
  void didUpdateWidget(EquipamientoPersonalSearchField oldWidget) {
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
    return TextField(
      controller: _controller,
      onChanged: widget.onSearchChanged,
      decoration: InputDecoration(
        hintText: 'Buscar equipamiento...',
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

/// Barra de paginación compacta
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
            'Mostrando $startItem-$endItem de $totalItems equipamientos',
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
          message: 'Cargando equipamiento...',
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
            'Error al cargar equipamiento',
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
