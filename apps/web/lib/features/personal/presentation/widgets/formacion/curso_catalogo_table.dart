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
import 'package:ambutrack_web/features/personal/presentation/bloc/curso_catalogo/curso_catalogo_bloc.dart';
import 'package:ambutrack_web/features/personal/presentation/bloc/curso_catalogo/curso_catalogo_event.dart';
import 'package:ambutrack_web/features/personal/presentation/bloc/curso_catalogo/curso_catalogo_state.dart';
import 'package:ambutrack_web/features/personal/presentation/widgets/formacion/curso_form_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class CursoCatalogoTable extends StatefulWidget {
  const CursoCatalogoTable({
    super.key,
    required this.searchQuery,
  });

  final String searchQuery;

  @override
  State<CursoCatalogoTable> createState() => _CursoCatalogoTableState();
}

class _CursoCatalogoTableState extends State<CursoCatalogoTable> {
  int? _sortColumnIndex;
  bool _sortAscending = true;
  bool _isDeleting = false;
  BuildContext? _loadingDialogContext;
  DateTime? _deleteStartTime;
  int _currentPage = 0;
  static const int _itemsPerPage = 25;

  @override
  void didUpdateWidget(CursoCatalogoTable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.searchQuery != widget.searchQuery) {
      _currentPage = 0;
    }
  }

  Color _getTipoColor(String tipo) {
    switch (tipo) {
      case 'presencial': return AppColors.primary;
      case 'online': return AppColors.info;
      case 'mixto': return AppColors.warning;
      default: return AppColors.gray600;
    }
  }

  String _getTipoLabel(String tipo) {
    switch (tipo) {
      case 'presencial': return 'Presencial';
      case 'online': return 'Online';
      case 'mixto': return 'Mixto';
      default: return tipo;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CursoCatalogoBloc, CursoCatalogoState>(
      listener: (BuildContext context, Object? state) async {
        if (_isDeleting && _loadingDialogContext != null) {
          if (state is CursoCatalogoLoaded || state is CursoCatalogoError) {
            final Duration elapsed = DateTime.now().difference(_deleteStartTime!);

            if (state is CursoCatalogoError) {
              await CrudOperationHandler.handleDeleteError(
                context: _loadingDialogContext!,
                isDeleting: _isDeleting,
                entityName: 'Curso',
                errorMessage: state.message,
                onClose: () {
                  setState(() {
                    _isDeleting = false;
                    _loadingDialogContext = null;
                    _deleteStartTime = null;
                  });
                },
              );
            } else if (state is CursoCatalogoLoaded) {
              await CrudOperationHandler.handleDeleteSuccess(
                context: _loadingDialogContext!,
                isDeleting: _isDeleting,
                entityName: 'Curso',
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
      child: BlocBuilder<CursoCatalogoBloc, CursoCatalogoState>(
        builder: (BuildContext context, Object? state) {
          if (state is CursoCatalogoLoading || state is CursoCatalogoInitial) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is CursoCatalogoError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Icon(Icons.error_outline, size: 64, color: AppColors.error),
                  const SizedBox(height: 16),
                  Text('Error al cargar cursos',
                    style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.error)),
                  const SizedBox(height: 8),
                  Text(state.message,
                    style: GoogleFonts.inter(fontSize: 14, color: AppColors.textSecondaryLight)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.read<CursoCatalogoBloc>().add(const CursoCatalogoLoadRequested()),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          if (state is! CursoCatalogoLoaded) {
            return const SizedBox.shrink();
          }

          List<CursoEntity> filtrados = _filterItems(state.items);
          filtrados = _sortItems(filtrados);

          final int totalItems = filtrados.length;
          final int totalPages = totalItems > 0 ? (totalItems / _itemsPerPage).ceil() : 1;
          final int startIndex = _currentPage * _itemsPerPage;
          final int endIndex = (startIndex + _itemsPerPage).clamp(0, totalItems);
          final List<CursoEntity> paginados = totalItems > 0
              ? filtrados.sublist(startIndex, endIndex)
              : <CursoEntity>[];

          final bool hasFilters = widget.searchQuery.isNotEmpty;

          if (totalItems == 0) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Icon(Icons.menu_book_outlined, size: 80, color: AppColors.gray400),
                  const SizedBox(height: 16),
                  Text(
                    hasFilters ? 'No se encontraron cursos con los filtros aplicados' : 'No hay cursos registrados',
                    style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.textSecondaryLight)),
                  const SizedBox(height: 8),
                  if (!hasFilters)
                    Text('Crea el primer curso del catálogo',
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
                    'Mostrando ${filtrados.length} de ${state.items.length} cursos',
                    style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondaryLight),
                  ),
                ),
              Expanded(
                child: AppDataGridV5<CursoEntity>(
                  columns: const <DataGridColumn>[
                    DataGridColumn(label: 'NOMBRE', flexWidth: 3, sortable: true),
                    DataGridColumn(label: 'TIPO', sortable: true),
                    DataGridColumn(label: 'DURACIÓN', sortable: true),
                    DataGridColumn(label: 'ESTADO', sortable: true),
                  ],
                  rows: paginados,
                  buildCells: (CursoEntity item) => <DataGridCell>[
                    DataGridCell(child: _buildNombreCell(item)),
                    DataGridCell(child: _buildTipoCell(item)),
                    DataGridCell(child: _buildDuracionCell(item)),
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
                      ? 'No se encontraron cursos con los filtros aplicados'
                      : 'No hay cursos registrados',
                  onEdit: (CursoEntity item) => _editItem(context, item),
                  onDelete: (CursoEntity item) => _confirmDelete(context, item),
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

  List<CursoEntity> _filterItems(List<CursoEntity> items) {
    if (widget.searchQuery.isEmpty) {
      return items;
    }
    final String query = widget.searchQuery.toLowerCase();
    return items.where((CursoEntity c) {
      return c.nombre.toLowerCase().contains(query) ||
          (c.descripcion?.toLowerCase().contains(query) ?? false);
    }).toList();
  }

  List<CursoEntity> _sortItems(List<CursoEntity> items) {
    if (_sortColumnIndex == null) {
      return items;
    }
    final List<CursoEntity> sorted = List<CursoEntity>.from(items)
      ..sort((CursoEntity a, CursoEntity b) {
        int comparison = 0;
        switch (_sortColumnIndex) {
          case 0: comparison = a.nombre.compareTo(b.nombre);
          case 1: comparison = a.tipo.compareTo(b.tipo);
          case 2: comparison = a.duracionHoras.compareTo(b.duracionHoras);
          case 3: comparison = (a.activo == b.activo) ? 0 : (a.activo ? -1 : 1);
        }
        return _sortAscending ? comparison : -comparison;
      });
    return sorted;
  }

  Future<void> _editItem(BuildContext context, CursoEntity item) async {
    final bool? result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return CursoFormDialog(item: item);
      },
    );
    if (result == true && context.mounted) {
      context.read<CursoCatalogoBloc>().add(const CursoCatalogoLoadRequested());
    }
  }

  Future<void> _confirmDelete(BuildContext context, CursoEntity item) async {
    final bool? confirmed = await showConfirmationDialog(
      context: context,
      title: 'Confirmar Eliminación',
      message: '¿Estás seguro de que deseas eliminar este curso? Esta acción no se puede deshacer.',
      itemDetails: <String, String>{
        'Nombre': item.nombre,
        'Tipo': _getTipoLabel(item.tipo),
        'Duración': '${item.duracionHoras}h',
      },
    );

    if (confirmed == true && context.mounted) {
      debugPrint('🗑️ Eliminando curso: ${item.nombre} (${item.id})');

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
              message: 'Eliminando curso...',
              color: AppColors.emergency,
              icon: Icons.delete_forever,
            );
          },
        ),
      );

      if (context.mounted) {
        context.read<CursoCatalogoBloc>().add(CursoCatalogoDeleteRequested(item.id));
      }
    }
  }

  Widget _buildNombreCell(CursoEntity item) {
    return Text(
      item.nombre,
      style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimaryLight),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildTipoCell(CursoEntity item) {
    final Color color = _getTipoColor(item.tipo);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        _getTipoLabel(item.tipo),
        style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: color),
      ),
    );
  }

  Widget _buildDuracionCell(CursoEntity item) {
    return Text(
      '${item.duracionHoras}h',
      style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondaryLight),
    );
  }

  Widget _buildEstadoCell(CursoEntity item) {
    return Align(
      alignment: Alignment.centerLeft,
      child: StatusBadge(
        label: item.activo ? 'Activo' : 'Inactivo',
        type: item.activo ? StatusBadgeType.success : StatusBadgeType.inactivo,
      ),
    );
  }
}

class CursoCatalogoSearchField extends StatefulWidget {
  const CursoCatalogoSearchField({
    super.key,
    required this.searchQuery,
    required this.onSearchChanged,
  });

  final String searchQuery;
  final void Function(String) onSearchChanged;

  @override
  State<CursoCatalogoSearchField> createState() => _CursoCatalogoSearchFieldState();
}

class _CursoCatalogoSearchFieldState extends State<CursoCatalogoSearchField> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.searchQuery);
  }

  @override
  void didUpdateWidget(CursoCatalogoSearchField oldWidget) {
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
        hintText: 'Buscar curso...',
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
            'Mostrando $startItem-$endItem de $totalItems cursos',
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
