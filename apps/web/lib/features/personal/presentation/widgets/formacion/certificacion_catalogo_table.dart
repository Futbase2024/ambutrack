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
import 'package:ambutrack_web/features/personal/presentation/bloc/certificacion_catalogo/certificacion_catalogo_bloc.dart';
import 'package:ambutrack_web/features/personal/presentation/bloc/certificacion_catalogo/certificacion_catalogo_event.dart';
import 'package:ambutrack_web/features/personal/presentation/bloc/certificacion_catalogo/certificacion_catalogo_state.dart';
import 'package:ambutrack_web/features/personal/presentation/widgets/formacion/certificacion_form_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class CertificacionCatalogoTable extends StatefulWidget {
  const CertificacionCatalogoTable({
    super.key,
    required this.searchQuery,
  });

  final String searchQuery;

  @override
  State<CertificacionCatalogoTable> createState() => _CertificacionCatalogoTableState();
}

class _CertificacionCatalogoTableState extends State<CertificacionCatalogoTable> {
  int? _sortColumnIndex;
  bool _sortAscending = true;
  bool _isDeleting = false;
  BuildContext? _loadingDialogContext;
  DateTime? _deleteStartTime;
  int _currentPage = 0;
  static const int _itemsPerPage = 25;

  @override
  void didUpdateWidget(CertificacionCatalogoTable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.searchQuery != widget.searchQuery) {
      _currentPage = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CertificacionCatalogoBloc, CertificacionCatalogoState>(
      listener: (BuildContext context, Object? state) async {
        if (_isDeleting && _loadingDialogContext != null) {
          if (state is CertificacionCatalogoLoaded || state is CertificacionCatalogoError) {
            final Duration elapsed = DateTime.now().difference(_deleteStartTime!);

            if (state is CertificacionCatalogoError) {
              await CrudOperationHandler.handleDeleteError(
                context: _loadingDialogContext!,
                isDeleting: _isDeleting,
                entityName: 'Certificación',
                errorMessage: state.message,
                onClose: () {
                  setState(() {
                    _isDeleting = false;
                    _loadingDialogContext = null;
                    _deleteStartTime = null;
                  });
                },
              );
            } else if (state is CertificacionCatalogoLoaded) {
              await CrudOperationHandler.handleDeleteSuccess(
                context: _loadingDialogContext!,
                isDeleting: _isDeleting,
                entityName: 'Certificación',
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
      child: BlocBuilder<CertificacionCatalogoBloc, CertificacionCatalogoState>(
        builder: (BuildContext context, Object? state) {
          if (state is CertificacionCatalogoLoading || state is CertificacionCatalogoInitial) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is CertificacionCatalogoError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Icon(Icons.error_outline, size: 64, color: AppColors.error),
                  const SizedBox(height: 16),
                  Text('Error al cargar certificaciones',
                    style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.error)),
                  const SizedBox(height: 8),
                  Text(state.message,
                    style: GoogleFonts.inter(fontSize: 14, color: AppColors.textSecondaryLight)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.read<CertificacionCatalogoBloc>().add(const CertificacionCatalogoLoadRequested()),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          if (state is! CertificacionCatalogoLoaded) {
            return const SizedBox.shrink();
          }

          List<CertificacionEntity> filtrados = _filterItems(state.items);
          filtrados = _sortItems(filtrados);

          final int totalItems = filtrados.length;
          final int totalPages = totalItems > 0 ? (totalItems / _itemsPerPage).ceil() : 1;
          final int startIndex = _currentPage * _itemsPerPage;
          final int endIndex = (startIndex + _itemsPerPage).clamp(0, totalItems);
          final List<CertificacionEntity> paginados = totalItems > 0
              ? filtrados.sublist(startIndex, endIndex)
              : <CertificacionEntity>[];

          final bool hasFilters = widget.searchQuery.isNotEmpty;

          if (totalItems == 0) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Icon(Icons.verified_outlined, size: 80, color: AppColors.gray400),
                  const SizedBox(height: 16),
                  Text(
                    hasFilters ? 'No se encontraron certificaciones con los filtros aplicados' : 'No hay certificaciones registradas',
                    style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.textSecondaryLight)),
                  const SizedBox(height: 8),
                  if (!hasFilters)
                    Text('Crea la primera certificación del catálogo',
                      style: GoogleFonts.inter(fontSize: 14, color: AppColors.textSecondaryLight)),
                ],
              ),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              if (state.items.length != filtrados.length)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSizes.spacing),
                  child: Text(
                    'Mostrando ${filtrados.length} de ${state.items.length} certificaciones',
                    style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondaryLight),
                  ),
                ),
              Expanded(
                child: AppDataGridV5<CertificacionEntity>(
                  columns: const <DataGridColumn>[
                    DataGridColumn(label: 'CÓDIGO', sortable: true),
                    DataGridColumn(label: 'NOMBRE', flexWidth: 3, sortable: true),
                    DataGridColumn(label: 'VIGENCIA', sortable: true),
                    DataGridColumn(label: 'HORAS', sortable: true),
                    DataGridColumn(label: 'ESTADO', sortable: true),
                  ],
                  rows: paginados,
                  buildCells: (CertificacionEntity item) => <DataGridCell>[
                    DataGridCell(child: _buildCodigoCell(item)),
                    DataGridCell(child: _buildNombreCell(item)),
                    DataGridCell(child: _buildVigenciaCell(item)),
                    DataGridCell(child: _buildHorasCell(item)),
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
                  emptyMessage: hasFilters
                      ? 'No se encontraron certificaciones con los filtros aplicados'
                      : 'No hay certificaciones registradas',
                  onEdit: (CertificacionEntity item) => _editItem(context, item),
                  onDelete: (CertificacionEntity item) => _confirmDelete(context, item),
                ),
              ),
              const SizedBox(height: AppSizes.spacing),
              _PaginationBar(
                currentPage: _currentPage,
                totalPages: totalPages.clamp(1, 999),
                totalItems: totalItems,
                itemsPerPage: _itemsPerPage,
                onPageChanged: (int page) {
                  setState(() { _currentPage = page; });
                },
              ),
            ],
          );
        },
      ),
    );
  }

  List<CertificacionEntity> _filterItems(List<CertificacionEntity> items) {
    if (widget.searchQuery.isEmpty) {
      return items;
    }
    final String query = widget.searchQuery.toLowerCase();
    return items.where((CertificacionEntity c) {
      return c.codigo.toLowerCase().contains(query) ||
          c.nombre.toLowerCase().contains(query) ||
          (c.descripcion?.toLowerCase().contains(query) ?? false);
    }).toList();
  }

  List<CertificacionEntity> _sortItems(List<CertificacionEntity> items) {
    if (_sortColumnIndex == null) {
      return items;
    }
    final List<CertificacionEntity> sorted = List<CertificacionEntity>.from(items)
      ..sort((CertificacionEntity a, CertificacionEntity b) {
        int comparison = 0;
        switch (_sortColumnIndex) {
          case 0: comparison = a.codigo.compareTo(b.codigo);
          case 1: comparison = a.nombre.compareTo(b.nombre);
          case 2: comparison = a.vigenciaMeses.compareTo(b.vigenciaMeses);
          case 3: comparison = a.horasRequeridas.compareTo(b.horasRequeridas);
          case 4: comparison = (a.activa == b.activa) ? 0 : (a.activa ? -1 : 1);
        }
        return _sortAscending ? comparison : -comparison;
      });
    return sorted;
  }

  Future<void> _editItem(BuildContext context, CertificacionEntity item) async {
    final bool? result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return CertificacionFormDialog(item: item);
      },
    );
    if (result == true && context.mounted) {
      context.read<CertificacionCatalogoBloc>().add(const CertificacionCatalogoLoadRequested());
    }
  }

  Future<void> _confirmDelete(BuildContext context, CertificacionEntity item) async {
    final bool? confirmed = await showConfirmationDialog(
      context: context,
      title: 'Confirmar Eliminación',
      message: '¿Estás seguro de que deseas eliminar esta certificación? Esta acción no se puede deshacer.',
      itemDetails: <String, String>{
        'Código': item.codigo,
        'Nombre': item.nombre,
        'Estado': item.activa ? 'Activa' : 'Inactiva',
      },
    );

    if (confirmed == true && context.mounted) {
      debugPrint('🗑️ Eliminando certificación: ${item.nombre} (${item.id})');

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
              message: 'Eliminando certificación...',
              color: AppColors.emergency,
              icon: Icons.delete_forever,
            );
          },
        ),
      );

      if (context.mounted) {
        context.read<CertificacionCatalogoBloc>().add(CertificacionCatalogoDeleteRequested(item.id));
      }
    }
  }

  Widget _buildCodigoCell(CertificacionEntity item) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.secondary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        item.codigo,
        style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.secondary),
      ),
    );
  }

  Widget _buildNombreCell(CertificacionEntity item) {
    return Text(
      item.nombre,
      style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimaryLight),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildVigenciaCell(CertificacionEntity item) {
    return Text(
      '${item.vigenciaMeses} meses',
      style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondaryLight),
    );
  }

  Widget _buildHorasCell(CertificacionEntity item) {
    return Text(
      '${item.horasRequeridas}h',
      style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondaryLight),
    );
  }

  Widget _buildEstadoCell(CertificacionEntity item) {
    return Align(
      alignment: Alignment.centerLeft,
      child: StatusBadge(
        label: item.activa ? 'Activa' : 'Inactiva',
        type: item.activa ? StatusBadgeType.success : StatusBadgeType.inactivo,
      ),
    );
  }
}

class CertificacionCatalogoSearchField extends StatefulWidget {
  const CertificacionCatalogoSearchField({
    super.key,
    required this.searchQuery,
    required this.onSearchChanged,
  });

  final String searchQuery;
  final void Function(String) onSearchChanged;

  @override
  State<CertificacionCatalogoSearchField> createState() => _CertificacionCatalogoSearchFieldState();
}

class _CertificacionCatalogoSearchFieldState extends State<CertificacionCatalogoSearchField> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.searchQuery);
  }

  @override
  void didUpdateWidget(CertificacionCatalogoSearchField oldWidget) {
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
        hintText: 'Buscar certificación...',
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
      style: GoogleFonts.inter(fontSize: 14, color: AppColors.textPrimaryLight),
    );
  }
}

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
            'Mostrando $startItem-$endItem de $totalItems certificaciones',
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
