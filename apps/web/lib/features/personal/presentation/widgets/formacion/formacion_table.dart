import 'dart:async';

import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/core/theme/app_text_styles.dart';
import 'package:ambutrack_web/core/widgets/badges/status_badge.dart';
import 'package:ambutrack_web/core/widgets/tables/app_data_grid_v5.dart';
import 'package:ambutrack_web/features/personal/presentation/bloc/formacion/formacion_bloc.dart';
import 'package:ambutrack_web/features/personal/presentation/bloc/formacion/formacion_event.dart';
import 'package:ambutrack_web/features/personal/presentation/bloc/formacion/formacion_state.dart';
import 'package:ambutrack_web/features/personal/presentation/widgets/formacion/formacion_details_dialog.dart';
import 'package:ambutrack_web/features/personal/presentation/widgets/formacion/formacion_personal_form_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class FormacionTable extends StatefulWidget {
  const FormacionTable({
    super.key,
    required this.searchQuery,
    required this.filterEstado,
    required this.usuariosNombres,
    required this.certificacionesNombres,
    required this.cursosNombres,
  });

  final String searchQuery;
  final String filterEstado;
  final Map<String, String> usuariosNombres;
  final Map<String, String> certificacionesNombres;
  final Map<String, String> cursosNombres;

  @override
  State<FormacionTable> createState() => _FormacionTableState();
}

class _FormacionTableState extends State<FormacionTable> {
  int? _sortColumnIndex;
  bool _sortAscending = true;
  int _currentPage = 0;
  static const int _itemsPerPage = 25;

  @override
  void didUpdateWidget(FormacionTable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.searchQuery != widget.searchQuery ||
        oldWidget.filterEstado != widget.filterEstado) {
      _currentPage = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FormacionBloc, FormacionState>(
      builder: (BuildContext context, FormacionState state) {
        if (state is FormacionLoading || state is FormacionInitial) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is FormacionError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Icon(Icons.error_outline, size: 64, color: AppColors.error),
                const SizedBox(height: 16),
                Text('Error al cargar la formación',
                  style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.error)),
                const SizedBox(height: 8),
                Text(state.message,
                  style: GoogleFonts.inter(fontSize: 14, color: AppColors.textSecondaryLight)),
              ],
            ),
          );
        }

        if (state is! FormacionLoaded) {
          return const SizedBox.shrink();
        }

        List<FormacionPersonalEntity> filtrados = _filterItems(state.items);
        filtrados = _sortItems(filtrados);

        final int totalItems = filtrados.length;
        final int totalPages = totalItems > 0 ? (totalItems / _itemsPerPage).ceil() : 1;
        final int startIndex = _currentPage * _itemsPerPage;
        final int endIndex = (startIndex + _itemsPerPage).clamp(0, totalItems);
        final List<FormacionPersonalEntity> paginados = totalItems > 0
            ? filtrados.sublist(startIndex, endIndex)
            : <FormacionPersonalEntity>[];

        final bool hasFilters = widget.searchQuery.isNotEmpty || widget.filterEstado != 'todos';

        if (totalItems == 0) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Icon(Icons.school_outlined, size: 80, color: AppColors.gray400),
                const SizedBox(height: 16),
                Text(
                  hasFilters ? 'No se encontró formación con los filtros aplicados' : 'No hay registros de formación',
                  style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.textSecondaryLight)),
                const SizedBox(height: 8),
                if (hasFilters)
                  Text('Ajusta los filtros para ver más resultados',
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
                  'Mostrando ${filtrados.length} de ${state.items.length} registros',
                  style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondaryLight),
                ),
              ),
            Expanded(
              child: AppDataGridV5<FormacionPersonalEntity>(
                columns: const <DataGridColumn>[
                  DataGridColumn(label: 'PERSONAL', flexWidth: 3, sortable: true),
                  DataGridColumn(label: 'CERTIFICACIÓN/CURSO', flexWidth: 2, sortable: true),
                  DataGridColumn(label: 'INICIO', flexWidth: 2, sortable: true),
                  DataGridColumn(label: 'FIN', flexWidth: 2, sortable: true),
                  DataGridColumn(label: 'EXPIRACIÓN', flexWidth: 2, sortable: true),
                  DataGridColumn(label: 'HORAS', sortable: true),
                  DataGridColumn(label: 'ESTADO', flexWidth: 2, sortable: true),
                ],
                rows: paginados,
                buildCells: (FormacionPersonalEntity item) => <DataGridCell>[
                  DataGridCell(child: _buildPersonalCell(item)),
                  DataGridCell(child: _buildFormacionCell(item)),
                  DataGridCell(child: _buildDateCell(item.fechaInicio)),
                  DataGridCell(child: _buildDateCell(item.fechaFin)),
                  DataGridCell(child: _buildDateCell(item.fechaExpiracion)),
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
                    ? 'No se encontraron registros con los filtros aplicados'
                    : 'No hay registros de formación',
                onEdit: (FormacionPersonalEntity item) => _editItem(context, item),
                customActions: <CustomAction<FormacionPersonalEntity>>[
                  CustomAction<FormacionPersonalEntity>(
                    icon: Icons.visibility_outlined,
                    tooltip: 'Ver Detalles',
                    color: AppColors.info,
                    onPressed: (FormacionPersonalEntity item) => _viewDetails(context, item),
                  ),
                ],
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
    );
  }

  List<FormacionPersonalEntity> _filterItems(List<FormacionPersonalEntity> items) {
    List<FormacionPersonalEntity> result = items;

    if (widget.filterEstado != 'todos') {
      result = result.where((FormacionPersonalEntity f) => f.estado == widget.filterEstado).toList();
    }

    if (widget.searchQuery.isNotEmpty) {
      final String query = widget.searchQuery.toLowerCase();
      result = result.where((FormacionPersonalEntity f) {
        final String nombre = widget.usuariosNombres[f.personalId] ?? f.personalId;
        return nombre.toLowerCase().contains(query);
      }).toList();
    }

    return result;
  }

  List<FormacionPersonalEntity> _sortItems(List<FormacionPersonalEntity> items) {
    if (_sortColumnIndex == null) {
      return items;
    }

    final List<FormacionPersonalEntity> sorted = List<FormacionPersonalEntity>.from(items)
      ..sort((FormacionPersonalEntity a, FormacionPersonalEntity b) {
        int comparison = 0;
        switch (_sortColumnIndex) {
          case 0:
            comparison = (widget.usuariosNombres[a.personalId] ?? a.personalId)
                .compareTo(widget.usuariosNombres[b.personalId] ?? b.personalId);
          case 1:
            comparison = _getFormacionNombre(a).compareTo(_getFormacionNombre(b));
          case 2:
            comparison = a.fechaInicio.compareTo(b.fechaInicio);
          case 3:
            comparison = a.fechaFin.compareTo(b.fechaFin);
          case 4:
            comparison = a.fechaExpiracion.compareTo(b.fechaExpiracion);
          case 5:
            comparison = a.horasAcumuladas.compareTo(b.horasAcumuladas);
          case 6:
            comparison = a.estado.compareTo(b.estado);
        }
        return _sortAscending ? comparison : -comparison;
      });

    return sorted;
  }

  String _getFormacionNombre(FormacionPersonalEntity f) {
    if (f.certificacionId != null) {
      return widget.certificacionesNombres[f.certificacionId] ?? f.certificacionId ?? 'N/A';
    }
    if (f.cursoId != null) {
      return widget.cursosNombres[f.cursoId] ?? f.cursoId ?? 'N/A';
    }
    return 'N/A';
  }

  Future<void> _editItem(BuildContext context, FormacionPersonalEntity item) async {
    final bool? result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return BlocProvider<FormacionBloc>.value(
          value: context.read<FormacionBloc>(),
          child: FormacionPersonalFormDialog(item: item),
        );
      },
    );
    if (result == true && context.mounted) {
      context.read<FormacionBloc>().add(const FormacionLoadRequested());
    }
  }

  Future<void> _viewDetails(BuildContext context, FormacionPersonalEntity item) async {
    await showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return FormacionDetailsDialog(
          formacion: item,
          nombreEmpleado: widget.usuariosNombres[item.personalId] ?? item.personalId,
          nombreFormacion: _getFormacionNombre(item),
        );
      },
    );
  }

  Widget _buildPersonalCell(FormacionPersonalEntity item) {
    return Text(
      widget.usuariosNombres[item.personalId] ?? item.personalId,
      style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimaryLight),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildFormacionCell(FormacionPersonalEntity item) {
    return Text(
      _getFormacionNombre(item),
      style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondaryLight),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildDateCell(DateTime date) {
    return Text(
      DateFormat('dd/MM/yyyy').format(date),
      style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondaryLight),
    );
  }

  Widget _buildHorasCell(FormacionPersonalEntity item) {
    return Text(
      '${item.horasAcumuladas}h',
      style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondaryLight),
    );
  }

  Widget _buildEstadoCell(FormacionPersonalEntity item) {
    final (StatusBadgeType type, String label) = switch (item.estado) {
      'vigente' => (StatusBadgeType.success, 'Vigente'),
      'proxima_vencer' => (StatusBadgeType.warning, 'Próxima'),
      'vencida' => (StatusBadgeType.error, 'Vencida'),
      _ => (StatusBadgeType.inactivo, item.estado),
    };

    return Align(
      alignment: Alignment.centerLeft,
      child: StatusBadge(label: label, type: type),
    );
  }
}

class FormacionSearchField extends StatefulWidget {
  const FormacionSearchField({
    super.key,
    required this.searchQuery,
    required this.onSearchChanged,
  });

  final String searchQuery;
  final void Function(String) onSearchChanged;

  @override
  State<FormacionSearchField> createState() => _FormacionSearchFieldState();
}

class _FormacionSearchFieldState extends State<FormacionSearchField> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.searchQuery);
  }

  @override
  void didUpdateWidget(FormacionSearchField oldWidget) {
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
        hintText: 'Buscar por nombre...',
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
            'Mostrando $startItem-$endItem de $totalItems registros',
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
