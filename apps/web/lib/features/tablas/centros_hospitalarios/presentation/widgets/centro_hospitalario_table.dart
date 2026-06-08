import 'dart:async';

import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/core/widgets/dialogs/confirmation_dialog.dart';
import 'package:ambutrack_web/core/widgets/handlers/crud_operation_handler.dart';
import 'package:ambutrack_web/core/widgets/loading/app_loading_indicator.dart';
import 'package:ambutrack_web/features/tablas/centros_hospitalarios/presentation/bloc/centro_hospitalario_bloc.dart';
import 'package:ambutrack_web/features/tablas/centros_hospitalarios/presentation/bloc/centro_hospitalario_event.dart';
import 'package:ambutrack_web/features/tablas/centros_hospitalarios/presentation/bloc/centro_hospitalario_state.dart';
import 'package:ambutrack_web/features/tablas/centros_hospitalarios/presentation/widgets/centro_hospitalario_form_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

/// Tabla de gestión de Centros Hospitalarios
class CentroHospitalarioTable extends StatefulWidget {
  const CentroHospitalarioTable({
    super.key,
    required this.centros,
    required this.sortColumnIndex,
    required this.sortAscending,
    required this.onSort,
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    required this.onPageChanged,
    required this.hasFilters,
  });

  final List<CentroHospitalarioEntity> centros;
  final int? sortColumnIndex;
  final bool sortAscending;
  final void Function(int columnIndex, bool ascending) onSort;
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final void Function(int page) onPageChanged;
  final bool hasFilters;

  @override
  State<CentroHospitalarioTable> createState() => _CentroHospitalarioTableState();
}

class _CentroHospitalarioTableState extends State<CentroHospitalarioTable> {
  bool _isDeleting = false;
  BuildContext? _loadingDialogContext;
  DateTime? _deleteStartTime;
  static const int _itemsPerPage = 25;

  @override
  Widget build(BuildContext context) {
    return BlocListener<CentroHospitalarioBloc, CentroHospitalarioState>(
      listener: (BuildContext context, CentroHospitalarioState state) async {
        if (_isDeleting && _loadingDialogContext != null) {
          if (state is CentroHospitalarioLoaded || state is CentroHospitalarioError) {
            final Duration elapsed = DateTime.now().difference(_deleteStartTime!);

            if (state is CentroHospitalarioError) {
              await CrudOperationHandler.handleDeleteError(
                context: _loadingDialogContext!,
                isDeleting: _isDeleting,
                entityName: 'Centro Hospitalario',
                errorMessage: state.message,
                onClose: () {
                  setState(() {
                    _isDeleting = false;
                    _loadingDialogContext = null;
                    _deleteStartTime = null;
                  });
                },
              );
            } else if (state is CentroHospitalarioLoaded) {
              await CrudOperationHandler.handleDeleteSuccess(
                context: _loadingDialogContext!,
                isDeleting: _isDeleting,
                entityName: 'Centro Hospitalario',
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
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
          border: Border.all(color: AppColors.gray200),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: AppColors.gray200.withValues(alpha: 0.5),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Expanded(
              child: widget.centros.isEmpty
                  ? _EmptyState(hasFilters: widget.hasFilters)
                  : _DataTable(
                      centros: widget.centros,
                      sortColumnIndex: widget.sortColumnIndex,
                      sortAscending: widget.sortAscending,
                      onSort: widget.onSort,
                      onEdit: _editCentro,
                      onDelete: _confirmDelete,
                    ),
            ),
            _PaginationBar(
              currentPage: widget.currentPage,
              totalPages: widget.totalPages,
              totalItems: widget.totalItems,
              itemsPerPage: _itemsPerPage,
              onPageChanged: widget.onPageChanged,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _editCentro(CentroHospitalarioEntity centro) async {
    await showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) => BlocProvider<CentroHospitalarioBloc>.value(
        value: context.read<CentroHospitalarioBloc>(),
        child: CentroHospitalarioFormDialog(centro: centro),
      ),
    );
  }

  Future<void> _confirmDelete(CentroHospitalarioEntity centro) async {
    final bool? confirmed = await showConfirmationDialog(
      context: context,
      title: 'Confirmar Eliminación',
      message: '¿Estás seguro de que deseas eliminar este centro hospitalario?',
      itemDetails: <String, String>{
        'Nombre': centro.nombre,
        if (centro.tipoCentro != null && centro.tipoCentro!.isNotEmpty) 'Tipo': centro.tipoCentro!,
        if (centro.localidadNombre != null && centro.localidadNombre!.isNotEmpty)
          'Localidad': centro.localidadNombre!,
        'Estado': centro.activo ? 'Activo' : 'Inactivo',
      },
    );

    if (confirmed == true && context.mounted) {
      debugPrint('Eliminando centro: ${centro.nombre} (${centro.id})');

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
              message: 'Eliminando centro hospitalario...',
              color: AppColors.emergency,
              icon: Icons.delete_forever,
            );
          },
        ),
      );

      if (context.mounted) {
        context.read<CentroHospitalarioBloc>().add(CentroHospitalarioDeleteRequested(centro.id));
      }
    }
  }
}

/// Barra de filtros profesional - usada desde la página
class CentroHospitalarioFilterBar extends StatelessWidget {
  const CentroHospitalarioFilterBar({
    super.key,
    required this.searchQuery,
    required this.statusFilter,
    required this.onSearchChanged,
    required this.onStatusChanged,
    required this.onClear,
    required this.totalCentros,
    required this.filteredCentros,
  });

  final String searchQuery;
  final String statusFilter;
  final void Function(String) onSearchChanged;
  final void Function(String) onStatusChanged;
  final VoidCallback onClear;
  final int totalCentros;
  final int filteredCentros;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.padding,
        vertical: AppSizes.paddingSmall,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Wrap(
        spacing: AppSizes.spacingSmall,
        runSpacing: AppSizes.spacingSmall,
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: <Widget>[
          SizedBox(
            width: 300,
            height: 40,
            child: TextField(
              onChanged: onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Buscar por nombre, localidad, teléfono...',
                hintStyle: GoogleFonts.inter(fontSize: 13, color: AppColors.gray400),
                prefixIcon: const Icon(Icons.search, size: 20, color: AppColors.gray400),
                suffixIcon: searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18, color: AppColors.gray400),
                        onPressed: () => onSearchChanged(''),
                      )
                    : null,
                filled: true,
                fillColor: AppColors.gray50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                height: 40,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: AppColors.gray50,
                  borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: statusFilter.isEmpty ? null : statusFilter,
                    hint: Text('Estado', style: GoogleFonts.inter(fontSize: 13, color: AppColors.gray500)),
                    items: const <DropdownMenuItem<String>>[
                      DropdownMenuItem(value: 'activo', child: Text('Activos')),
                      DropdownMenuItem(value: 'inactivo', child: Text('Inactivos')),
                    ],
                    onChanged: (String? value) => onStatusChanged(value ?? ''),
                    borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                    icon: const Icon(Icons.expand_more, size: 18, color: AppColors.gray400),
                  ),
                ),
              ),
              const SizedBox(width: AppSizes.spacingSmall),
              if (searchQuery.isNotEmpty || statusFilter.isNotEmpty)
                TextButton.icon(
                  onPressed: onClear,
                  icon: const Icon(Icons.close, size: 16, color: AppColors.gray500),
                  label: Text(
                    'Limpiar',
                    style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.gray500),
                  ),
                ),
              const SizedBox(width: AppSizes.spacing),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: filteredCentros != totalCentros ? AppColors.primarySurface : AppColors.gray50,
                  borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                ),
                child: Text(
                  filteredCentros != totalCentros
                      ? '$filteredCentros de $totalCentros centros'
                      : '$totalCentros centros',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: filteredCentros != totalCentros ? AppColors.primary : AppColors.gray600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Tabla de datos
class _DataTable extends StatelessWidget {
  const _DataTable({
    required this.centros,
    required this.sortColumnIndex,
    required this.sortAscending,
    required this.onSort,
    required this.onEdit,
    required this.onDelete,
  });

  final List<CentroHospitalarioEntity> centros;
  final int? sortColumnIndex;
  final bool sortAscending;
  final void Function(int columnIndex, bool ascending) onSort;
  final void Function(CentroHospitalarioEntity) onEdit;
  final void Function(CentroHospitalarioEntity) onDelete;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: DataTable(
        headingRowColor: WidgetStateProperty.all(AppColors.gray50),
        headingRowHeight: 44,
        columnSpacing: 16,
        horizontalMargin: 16,
        sortColumnIndex: sortColumnIndex,
        sortAscending: sortAscending,
        columns: <DataColumn>[
          DataColumn(label: Text('NOMBRE', style: _headerStyle), onSort: onSort),
          DataColumn(label: Text('TIPO', style: _headerStyle), onSort: onSort),
          DataColumn(label: Text('UBICACIÓN', style: _headerStyle), onSort: onSort),
          DataColumn(label: Text('TELÉFONO', style: _headerStyle), onSort: onSort),
          DataColumn(label: Text('ESTADO', style: _headerStyle), onSort: onSort),
          DataColumn(
            label: Align(
              alignment: Alignment.centerRight,
              child: Text('ACCIONES', style: _headerStyle),
            ),
          ),
        ],
        rows: centros.map((CentroHospitalarioEntity centro) {
          return DataRow(
            cells: <DataCell>[
              DataCell(_NombreCell(centro: centro)),
              DataCell(_TipoCell(centro: centro)),
              DataCell(_UbicacionCell(centro: centro)),
              DataCell(_TelefonoCell(centro: centro)),
              DataCell(_EstadoCell(centro: centro)),
              DataCell(
                Align(
                  alignment: Alignment.centerRight,
                  child: _AccionesCell(centro: centro, onEdit: onEdit, onDelete: onDelete),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  TextStyle get _headerStyle => GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.bold,
        color: AppColors.gray500,
        letterSpacing: 0.5,
      );
}

/// Celda de nombre con icono
class _NombreCell extends StatelessWidget {
  const _NombreCell({required this.centro});

  final CentroHospitalarioEntity centro;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.primarySurface,
            borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
          ),
          child: const Icon(Icons.local_hospital, size: 18, color: AppColors.primary),
        ),
        const SizedBox(width: 10),
        Flexible(
          child: Text(
            centro.nombre,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimaryLight,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

/// Celda de tipo
class _TipoCell extends StatelessWidget {
  const _TipoCell({required this.centro});

  final CentroHospitalarioEntity centro;

  @override
  Widget build(BuildContext context) {
    final String tipo = centro.tipoCentro ?? 'Sin tipo';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.gray100,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        tipo,
        style: GoogleFonts.inter(fontSize: 12, color: AppColors.gray700),
      ),
    );
  }
}

/// Celda de ubicación
class _UbicacionCell extends StatelessWidget {
  const _UbicacionCell({required this.centro});

  final CentroHospitalarioEntity centro;

  @override
  Widget build(BuildContext context) {
    final String localidad = centro.localidadNombre ?? 'Sin localidad';
    final String provincia = centro.provinciaNombre ?? '';

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          localidad,
          style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textPrimaryLight),
        ),
        if (provincia.isNotEmpty)
          Text(
            provincia,
            style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondaryLight),
          ),
      ],
    );
  }
}

/// Celda de teléfono
class _TelefonoCell extends StatelessWidget {
  const _TelefonoCell({required this.centro});

  final CentroHospitalarioEntity centro;

  @override
  Widget build(BuildContext context) {
    if (centro.telefono == null || centro.telefono!.isEmpty) {
      return Text(
        '—',
        style: GoogleFonts.inter(fontSize: 13, color: AppColors.gray400),
      );
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        const Icon(Icons.phone_outlined, size: 14, color: AppColors.gray400),
        const SizedBox(width: 4),
        Text(
          centro.telefono!,
          style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondaryLight),
        ),
      ],
    );
  }
}

/// Celda de estado con badge
class _EstadoCell extends StatelessWidget {
  const _EstadoCell({required this.centro});

  final CentroHospitalarioEntity centro;

  @override
  Widget build(BuildContext context) {
    final bool isActivo = centro.activo;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isActivo ? const Color(0xFFDCFCE7) : const Color(0xFFFEE2E2),
        borderRadius: BorderRadius.circular(9999),
      ),
      child: Text(
        isActivo ? 'Activo' : 'Inactivo',
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: isActivo ? const Color(0xFF166534) : const Color(0xFF991B1B),
        ),
      ),
    );
  }
}

/// Celda de acciones
class _AccionesCell extends StatelessWidget {
  const _AccionesCell({
    required this.centro,
    required this.onEdit,
    required this.onDelete,
  });

  final CentroHospitalarioEntity centro;
  final void Function(CentroHospitalarioEntity) onEdit;
  final void Function(CentroHospitalarioEntity) onDelete;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        _ActionButton(
          icon: Icons.edit_outlined,
          tooltip: 'Editar',
          color: AppColors.primary,
          onPressed: () => onEdit(centro),
        ),
        const SizedBox(width: 4),
        _ActionButton(
          icon: Icons.delete_outline,
          tooltip: 'Eliminar',
          color: AppColors.error,
          onPressed: () => onDelete(centro),
        ),
      ],
    );
  }
}

/// Botón de acción
class _ActionButton extends StatefulWidget {
  const _ActionButton({
    required this.icon,
    required this.tooltip,
    required this.color,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final Color color;
  final VoidCallback onPressed;

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.tooltip,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: GestureDetector(
          onTap: widget.onPressed,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: _isHovered ? widget.color.withValues(alpha: 0.1) : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              widget.icon,
              size: 18,
              color: _isHovered ? widget.color : AppColors.gray400,
            ),
          ),
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
    final int endItem = ((currentPage + 1) * itemsPerPage).clamp(0, totalItems);

    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingSmall),
      decoration: const BoxDecoration(
        color: AppColors.gray50,
        border: Border(top: BorderSide(color: AppColors.gray200)),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(AppSizes.radiusLarge),
          bottomRight: Radius.circular(AppSizes.radiusLarge),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            'Mostrando $startItem-$endItem de $totalItems',
            style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.gray500),
          ),
          Row(
            children: <Widget>[
              _PageButton(
                icon: Icons.chevron_left,
                enabled: currentPage > 0,
                onPressed: () => onPageChanged(currentPage - 1),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${currentPage + 1} / $totalPages',
                  style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
              _PageButton(
                icon: Icons.chevron_right,
                enabled: currentPage < totalPages - 1,
                onPressed: () => onPageChanged(currentPage + 1),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Botón de página
class _PageButton extends StatelessWidget {
  const _PageButton({
    required this.icon,
    required this.enabled,
    required this.onPressed,
  });

  final IconData icon;
  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon, size: 18),
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
      color: enabled ? AppColors.gray600 : AppColors.gray300,
      onPressed: enabled ? onPressed : null,
    );
  }
}

/// Estado vacío
class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.hasFilters});

  final bool hasFilters;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            hasFilters ? Icons.search_off : Icons.local_hospital_outlined,
            size: 48,
            color: AppColors.gray300,
          ),
          const SizedBox(height: AppSizes.spacing),
          Text(
            hasFilters ? 'No se encontraron resultados' : 'No hay centros hospitalarios',
            style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.gray500),
          ),
        ],
      ),
    );
  }
}
