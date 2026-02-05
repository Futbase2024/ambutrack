import 'dart:async';

import 'package:ambutrack_core/ambutrack_core.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/core/theme/app_text_styles.dart';
import 'package:ambutrack_web/core/widgets/badges/status_badge.dart';
import 'package:ambutrack_web/core/widgets/dialogs/confirmation_dialog.dart';
import 'package:ambutrack_web/core/widgets/handlers/crud_operation_handler.dart';
import 'package:ambutrack_web/core/widgets/loading/app_loading_indicator.dart';
import 'package:ambutrack_web/core/widgets/tables/app_data_grid_v5.dart';
import 'package:ambutrack_web/features/almacen/presentation/bloc/proveedores/proveedores_bloc.dart';
import 'package:ambutrack_web/features/almacen/presentation/bloc/proveedores/proveedores_event.dart';
import 'package:ambutrack_web/features/almacen/presentation/bloc/proveedores/proveedores_state.dart';
import 'package:ambutrack_web/features/almacen/presentation/widgets/proveedor_form_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

/// Tabla de gestión de Proveedores
class ProveedoresTable extends StatefulWidget {
  const ProveedoresTable({super.key});

  @override
  State<ProveedoresTable> createState() => _ProveedoresTableState();
}

class _ProveedoresTableState extends State<ProveedoresTable> {
  String _searchQuery = '';
  int? _sortColumnIndex = 1; // Ordenar por Nombre Comercial por defecto
  bool _sortAscending = true;
  bool _isDeleting = false;
  BuildContext? _loadingDialogContext;
  DateTime? _deleteStartTime;
  int _currentPage = 0;
  static const int _itemsPerPage = 25;

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProveedoresBloc, ProveedoresState>(
      listener: (BuildContext context, Object? state) async {
        // Manejo de loading al eliminar
        if (_isDeleting && _loadingDialogContext != null) {
          if (state is ProveedoresLoaded || state is ProveedoresError) {
            final Duration elapsed = DateTime.now().difference(_deleteStartTime!);

            // Manejar resultado con CrudOperationHandler
            if (state is ProveedoresError) {
              await CrudOperationHandler.handleDeleteError(
                context: _loadingDialogContext!,
                isDeleting: _isDeleting,
                entityName: 'Proveedor',
                errorMessage: state.message,
                onClose: () {
                  setState(() {
                    _isDeleting = false;
                    _loadingDialogContext = null;
                    _deleteStartTime = null;
                  });
                },
              );
            } else if (state is ProveedoresLoaded) {
              await CrudOperationHandler.handleDeleteSuccess(
                context: _loadingDialogContext!,
                isDeleting: _isDeleting,
                entityName: 'Proveedor',
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
      child: BlocBuilder<ProveedoresBloc, ProveedoresState>(
        builder: (BuildContext context, Object? state) {
          if (state is ProveedoresLoading) {
            return const _LoadingView();
          }

          if (state is ProveedoresError) {
            return _ErrorView(message: state.message);
          }

          if (state is ProveedoresLoaded) {
            // Filtrado y ordenamiento
            List<ProveedorEntity> filtrados = _filterProveedores(state.proveedores);
            filtrados = _sortProveedores(filtrados);

            // Cálculo de paginación
            final int totalItems = filtrados.length;
            final int totalPages = (totalItems / _itemsPerPage).ceil();
            final int startIndex = _currentPage * _itemsPerPage;
            final int endIndex = (startIndex + _itemsPerPage).clamp(0, totalItems);
            final List<ProveedorEntity> proveedoresPaginados = totalItems > 0
                ? filtrados.sublist(startIndex, endIndex)
                : <ProveedorEntity>[];

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                // Header: Título y búsqueda
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        'Listado de Proveedores',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimaryLight,
                        ),
                      ),
                    ),
                    // Búsqueda
                    SizedBox(
                      width: 300,
                      child: _SearchField(
                        searchQuery: _searchQuery,
                        onSearchChanged: (String query) {
                          setState(() {
                            _searchQuery = query;
                            _currentPage = 0; // Reset a primera página
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.spacing),

                // Info de resultados filtrados
                if (state.proveedores.length != filtrados.length)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSizes.spacing),
                    child: Text(
                      'Mostrando ${filtrados.length} de ${state.proveedores.length} proveedores',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: AppColors.textSecondaryLight,
                      ),
                    ),
                  ),

                // Tabla con scroll interno
                Expanded(
                  child: AppDataGridV5<ProveedorEntity>(
                    columns: const <DataGridColumn>[
                      DataGridColumn(label: 'CÓDIGO', sortable: true),
                      DataGridColumn(label: 'NOMBRE COMERCIAL', flexWidth: 2, sortable: true),
                      DataGridColumn(label: 'CIF/NIF', sortable: true),
                      DataGridColumn(label: 'TELÉFONO', sortable: true),
                      DataGridColumn(label: 'EMAIL', flexWidth: 2, sortable: true),
                      DataGridColumn(label: 'CIUDAD', sortable: true),
                      DataGridColumn(label: 'ESTADO', sortable: true),
                    ],
                    rows: proveedoresPaginados,
                    buildCells: (ProveedorEntity proveedor) => <DataGridCell>[
                      DataGridCell(child: _buildCodigoCell(proveedor)),
                      DataGridCell(child: _buildNombreComercialCell(proveedor)),
                      DataGridCell(child: _buildCifNifCell(proveedor)),
                      DataGridCell(child: _buildTelefonoCell(proveedor)),
                      DataGridCell(child: _buildEmailCell(proveedor)),
                      DataGridCell(child: _buildCiudadCell(proveedor)),
                      DataGridCell(child: _buildEstadoCell(proveedor)),
                    ],
                    sortColumnIndex: _sortColumnIndex,
                    sortAscending: _sortAscending,
                    onSort: (int columnIndex, {required bool ascending}) {
                      setState(() {
                        _sortColumnIndex = columnIndex;
                        _sortAscending = ascending;
                      });
                    },
                    rowHeight: 64,
                    outerBorderColor: AppColors.gray300,
                    emptyMessage: _searchQuery.isNotEmpty
                        ? 'No se encontraron proveedores con los filtros aplicados'
                        : 'No hay proveedores registrados',
                    onEdit: (ProveedorEntity proveedor) => _editProveedor(context, proveedor),
                    onDelete: (ProveedorEntity proveedor) => _confirmDelete(context, proveedor),
                  ),
                ),

                // Paginación
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

  // ============================================
  // MÉTODOS DE CONSTRUCCIÓN DE CELDAS
  // ============================================

  Widget _buildCodigoCell(ProveedorEntity proveedor) {
    return Text(
      proveedor.codigo,
      style: AppTextStyles.bodyBold.copyWith(fontSize: 13),
    );
  }

  Widget _buildNombreComercialCell(ProveedorEntity proveedor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          proveedor.nombreComercial,
          style: AppTextStyles.bodyBold.copyWith(fontSize: 13),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        if (proveedor.razonSocial != null && proveedor.razonSocial!.isNotEmpty)
          Text(
            proveedor.razonSocial!,
            style: AppTextStyles.bodySmallSecondary.copyWith(fontSize: 11),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
      ],
    );
  }

  Widget _buildCifNifCell(ProveedorEntity proveedor) {
    if (proveedor.cifNif == null || proveedor.cifNif!.isEmpty) {
      return Text(
        '-',
        style: AppTextStyles.bodySmallSecondary,
      );
    }

    return Text(
      proveedor.cifNif!,
      style: AppTextStyles.bodySmall,
    );
  }

  Widget _buildTelefonoCell(ProveedorEntity proveedor) {
    if (proveedor.telefono == null || proveedor.telefono!.isEmpty) {
      return Text(
        '-',
        style: AppTextStyles.bodySmallSecondary,
      );
    }

    return Text(
      proveedor.telefono!,
      style: AppTextStyles.bodySmall,
    );
  }

  Widget _buildEmailCell(ProveedorEntity proveedor) {
    if (proveedor.email == null || proveedor.email!.isEmpty) {
      return Text(
        '-',
        style: AppTextStyles.bodySmallSecondary,
      );
    }

    return Text(
      proveedor.email!,
      style: AppTextStyles.bodySmall,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildCiudadCell(ProveedorEntity proveedor) {
    if (proveedor.ciudad == null || proveedor.ciudad!.isEmpty) {
      return Text(
        '-',
        style: AppTextStyles.bodySmallSecondary,
      );
    }

    return Text(
      proveedor.ciudad!,
      style: AppTextStyles.bodySmall,
    );
  }

  Widget _buildEstadoCell(ProveedorEntity proveedor) {
    return Align(
      alignment: Alignment.centerLeft,
      child: StatusBadge(
        label: proveedor.activo ? 'Activo' : 'Inactivo',
        type: proveedor.activo ? StatusBadgeType.success : StatusBadgeType.inactivo,
      ),
    );
  }

  // ============================================
  // FILTRADO Y ORDENAMIENTO
  // ============================================

  List<ProveedorEntity> _filterProveedores(List<ProveedorEntity> proveedores) {
    if (_searchQuery.trim().isEmpty) {
      return proveedores;
    }

    final String query = _searchQuery.toLowerCase();

    return proveedores.where((ProveedorEntity p) {
      return p.codigo.toLowerCase().contains(query) ||
          p.nombreComercial.toLowerCase().contains(query) ||
          (p.razonSocial?.toLowerCase().contains(query) ?? false) ||
          (p.cifNif?.toLowerCase().contains(query) ?? false) ||
          (p.email?.toLowerCase().contains(query) ?? false) ||
          (p.telefono?.toLowerCase().contains(query) ?? false) ||
          (p.ciudad?.toLowerCase().contains(query) ?? false);
    }).toList();
  }

  List<ProveedorEntity> _sortProveedores(List<ProveedorEntity> proveedores) {
    if (_sortColumnIndex == null) {
      return proveedores;
    }

    proveedores.sort((ProveedorEntity a, ProveedorEntity b) {
      int comparison = 0;

      switch (_sortColumnIndex) {
        case 0: // Código
          comparison = a.codigo.compareTo(b.codigo);
        case 1: // Nombre Comercial
          comparison = a.nombreComercial.compareTo(b.nombreComercial);
        case 2: // CIF/NIF
          comparison = (a.cifNif ?? '').compareTo(b.cifNif ?? '');
        case 3: // Teléfono
          comparison = (a.telefono ?? '').compareTo(b.telefono ?? '');
        case 4: // Email
          comparison = (a.email ?? '').compareTo(b.email ?? '');
        case 5: // Ciudad
          comparison = (a.ciudad ?? '').compareTo(b.ciudad ?? '');
        case 6: // Estado
          comparison = (a.activo ? 1 : 0).compareTo(b.activo ? 1 : 0);
      }

      return _sortAscending ? comparison : -comparison;
    });

    return proveedores;
  }

  // ============================================
  // ACCIONES
  // ============================================

  Future<void> _editProveedor(BuildContext context, ProveedorEntity proveedor) async {
    await showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) => BlocProvider<ProveedoresBloc>.value(
        value: context.read<ProveedoresBloc>(),
        child: ProveedorFormDialog(proveedor: proveedor),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, ProveedorEntity proveedor) async {
    final bool? confirmed = await showConfirmationDialog(
      context: context,
      title: 'Confirmar Eliminación',
      message: '¿Estás seguro de que deseas eliminar este proveedor? Esta acción no se puede deshacer.',
      itemDetails: <String, String>{
        'Código': proveedor.codigo,
        'Nombre Comercial': proveedor.nombreComercial,
        if (proveedor.razonSocial != null && proveedor.razonSocial!.isNotEmpty)
          'Razón Social': proveedor.razonSocial!,
        if (proveedor.cifNif != null && proveedor.cifNif!.isNotEmpty) 'CIF/NIF': proveedor.cifNif!,
        if (proveedor.telefono != null && proveedor.telefono!.isNotEmpty) 'Teléfono': proveedor.telefono!,
        if (proveedor.email != null && proveedor.email!.isNotEmpty) 'Email': proveedor.email!,
        'Estado': proveedor.activo ? 'Activo' : 'Inactivo',
      },
    );

    if (confirmed == true && context.mounted) {
      debugPrint('🗑️ Eliminando proveedor: ${proveedor.nombreComercial} (${proveedor.id})');

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
              message: 'Eliminando proveedor...',
              color: AppColors.emergency,
              icon: Icons.delete_forever,
            );
          },
        ),
      );

      if (context.mounted) {
        context.read<ProveedoresBloc>().add(ProveedorDeleteRequested(proveedor.id));
      }
    }
  }

  // ============================================
  // PAGINACIÓN
  // ============================================

  Widget _buildPaginationControls({
    required int currentPage,
    required int totalPages,
    required int totalItems,
    required void Function(int) onPageChanged,
  }) {
    final int startItem = totalItems == 0 ? 0 : currentPage * _itemsPerPage + 1;
    final int endItem = totalItems == 0 ? 0 : ((currentPage + 1) * _itemsPerPage).clamp(0, totalItems);

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
            'Mostrando $startItem-$endItem de $totalItems proveedores',
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

// ============================================
// WIDGETS AUXILIARES
// ============================================

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
        hintText: 'Buscar proveedor...',
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
          message: 'Cargando proveedores...',
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
            'Error al cargar proveedores',
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
