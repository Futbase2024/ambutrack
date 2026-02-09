import 'dart:async';

import 'package:ambutrack_core/ambutrack_core.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/core/theme/app_text_styles.dart';
import 'package:ambutrack_web/core/widgets/dialogs/confirmation_dialog.dart';
import 'package:ambutrack_web/core/widgets/handlers/crud_operation_handler.dart';
import 'package:ambutrack_web/core/widgets/loading/app_loading_indicator.dart';
import 'package:ambutrack_web/core/widgets/tables/app_standard_table.dart';
import 'package:ambutrack_web/features/servicios/pacientes/presentation/bloc/pacientes_bloc.dart';
import 'package:ambutrack_web/features/servicios/pacientes/presentation/bloc/pacientes_event.dart';
import 'package:ambutrack_web/features/servicios/pacientes/presentation/bloc/pacientes_state.dart';
import 'package:ambutrack_web/features/servicios/pacientes/presentation/widgets/paciente_form_dialog.dart';
import 'package:ambutrack_web/features/servicios/pacientes/presentation/widgets/pacientes_filters.dart';
import 'package:ambutrack_web/features/servicios/servicios/presentation/formulario/servicio_form_wizard_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Tabla de gestión de Pacientes
class PacientesTable extends StatefulWidget {
  const PacientesTable({required this.onFilterChanged, super.key});

  final void Function(PacientesFilterData) onFilterChanged;

  @override
  State<PacientesTable> createState() => _PacientesTableState();
}

class _PacientesTableState extends State<PacientesTable> {
  String _searchQuery = '';
  int? _sortColumnIndex = 0; // Ordenar por Nombre por defecto
  bool _sortAscending = true;
  bool _isDeleting = false;
  BuildContext? _loadingDialogContext;
  DateTime? _deleteStartTime;
  int _currentPage = 0;
  static const int _itemsPerPage = 25;

  @override
  Widget build(BuildContext context) {
    return BlocListener<PacientesBloc, PacientesState>(
      listener: (BuildContext context, Object? state) async {
        // Manejo de loading al eliminar
        if (_isDeleting && _loadingDialogContext != null) {
          if (state is PacientesLoaded || state is PacientesError) {
            final Duration elapsed = DateTime.now().difference(_deleteStartTime!);

            // Manejar resultado con CrudOperationHandler
            if (state is PacientesError) {
              await CrudOperationHandler.handleDeleteError(
                context: _loadingDialogContext!,
                isDeleting: _isDeleting,
                entityName: 'Paciente',
                errorMessage: state.message,
                onClose: () {
                  setState(() {
                    _isDeleting = false;
                    _loadingDialogContext = null;
                    _deleteStartTime = null;
                  });
                },
              );
            } else if (state is PacientesLoaded) {
              await CrudOperationHandler.handleDeleteSuccess(
                context: _loadingDialogContext!,
                isDeleting: _isDeleting,
                entityName: 'Paciente',
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
      child: BlocBuilder<PacientesBloc, PacientesState>(
        builder: (BuildContext context, Object? state) {
          if (state is PacientesLoading) {
            return const _LoadingView();
          }

          if (state is PacientesError) {
            return _ErrorView(message: state.message);
          }

          if (state is PacientesLoaded) {
            // Filtrado y ordenamiento
            List<PacienteEntity> filtrados = _filterPacientes(state.pacientes);
            filtrados = _sortPacientes(filtrados);

            // Cálculo de paginación
            final int totalItems = filtrados.length;
            final int totalPages = (totalItems / _itemsPerPage).ceil();
            final int startIndex = _currentPage * _itemsPerPage;
            final int endIndex = (startIndex + _itemsPerPage).clamp(0, totalItems);
            final List<PacienteEntity> pacientesPaginados = totalItems > 0
                ? filtrados.sublist(startIndex, endIndex)
                : <PacienteEntity>[];

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                // Header: Título y búsqueda
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        'Listado de Pacientes',
                        style: AppTextStyles.h4,
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
                            _currentPage = 0; // Reset a primera página al buscar
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.spacing),

                // Info de resultados filtrados
                if (state.pacientes.length != filtrados.length)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSizes.spacing),
                    child: Text(
                      'Mostrando ${filtrados.length} de ${state.pacientes.length} pacientes',
                      style: AppTextStyles.bodySmallSecondary,
                    ),
                  ),

                // Tabla con scroll interno
                Expanded(
                  child: AppStandardTable<PacienteEntity>(
                    columns: const <StandardTableColumn>[
                      StandardTableColumn(label: 'IDENTIFICACIÓN', sortable: true),
                      StandardTableColumn(label: 'NOMBRE', flexWidth: 2, sortable: true),
                      StandardTableColumn(label: 'DIRECCIÓN', flexWidth: 2),
                      StandardTableColumn(label: 'TELÉFONO'),
                    ],
                    rows: pacientesPaginados,
                    buildCells: (PacienteEntity paciente) => <StandardTableCell>[
                      StandardTableCell(child: _buildIdentificacionCell(paciente)),
                      StandardTableCell(child: _buildNombreCell(paciente)),
                      StandardTableCell(child: _buildDireccionCell(paciente)),
                      StandardTableCell(child: _buildTelefonoCell(paciente)),
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
                    emptyMessage: _searchQuery.isNotEmpty
                        ? 'No se encontraron pacientes con los filtros aplicados'
                        : 'No hay pacientes registrados',
                    customActions: <CustomAction<PacienteEntity>>[
                      CustomAction<PacienteEntity>(
                        icon: Icons.add_circle_outline,
                        tooltip: 'Crear Servicio',
                        onPressed: (PacienteEntity paciente) => _createServicio(context, paciente),
                      ),
                    ],
                    onEdit: (PacienteEntity paciente) => _editPaciente(context, paciente),
                    onDelete: (PacienteEntity paciente) => _confirmDelete(context, paciente),
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

  // ==================== FILTRADO Y ORDENAMIENTO ====================

  List<PacienteEntity> _filterPacientes(List<PacienteEntity> pacientes) {
    if (_searchQuery.isEmpty) {
      return pacientes;
    }

    final String query = _searchQuery.toLowerCase();
    return pacientes.where((PacienteEntity paciente) {
      return (paciente.identificacion?.toLowerCase().contains(query) ?? false) ||
          paciente.nombreCompleto.toLowerCase().contains(query) ||
          paciente.documento.toLowerCase().contains(query) ||
          (paciente.telefonoMovil?.toLowerCase().contains(query) ?? false) ||
          (paciente.email?.toLowerCase().contains(query) ?? false);
    }).toList();
  }

  List<PacienteEntity> _sortPacientes(List<PacienteEntity> pacientes) {
    if (_sortColumnIndex == null) {
      return pacientes;
    }

    final List<PacienteEntity> sorted = List<PacienteEntity>.from(pacientes)
      ..sort((PacienteEntity a, PacienteEntity b) {
        int comparison = 0;

        switch (_sortColumnIndex) {
          case 0: // Identificación
            comparison = (a.identificacion ?? '').compareTo(b.identificacion ?? '');
          case 1: // Nombre
            comparison = a.nombreCompleto.compareTo(b.nombreCompleto);
          default:
            comparison = 0;
        }

        return _sortAscending ? comparison : -comparison;
      });

    return sorted;
  }

  // ==================== ACCIONES ====================

  /// Navegar a formulario de creación de servicio con paciente preseleccionado
  Future<void> _createServicio(BuildContext context, PacienteEntity paciente) async {
    debugPrint('🚑 Abriendo wizard de creación de servicio para: ${paciente.nombreCompleto} (${paciente.id})');

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) => ServicioFormWizardDialog(
        paciente: paciente,
      ),
    );
  }

  Future<void> _editPaciente(BuildContext context, PacienteEntity paciente) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) => BlocProvider<PacientesBloc>.value(
        value: context.read<PacientesBloc>(),
        child: PacienteFormDialog(paciente: paciente),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, PacienteEntity paciente) async {
    final bool? confirmed = await showConfirmationDialog(
      context: context,
      title: 'Confirmar Eliminación',
      message: '¿Estás seguro de que deseas eliminar este paciente? Esta acción no se puede deshacer.',
      itemDetails: <String, String>{
        if (paciente.identificacion != null && paciente.identificacion!.isNotEmpty)
          'Identificación': paciente.identificacion!,
        'Nombre': paciente.nombreCompleto,
        'Documento': '${paciente.tipoDocumento} ${paciente.documento}',
        'Edad': '${paciente.edad} años',
        if (paciente.telefonoMovil != null && paciente.telefonoMovil!.isNotEmpty)
          'Teléfono Móvil': paciente.telefonoMovil!,
        if (paciente.telefonoFijo != null && paciente.telefonoFijo!.isNotEmpty)
          'Teléfono Fijo': paciente.telefonoFijo!,
        if (paciente.email != null && paciente.email!.isNotEmpty)
          'Email': paciente.email!,
        'Estado': paciente.activo ? 'Activo' : 'Inactivo',
      },
    );

    if (confirmed == true && context.mounted) {
      debugPrint('🗑️ Eliminando paciente: ${paciente.nombreCompleto} (${paciente.id})');

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
              message: 'Eliminando paciente...',
              color: AppColors.emergency,
              icon: Icons.delete_forever,
            );
          },
        ),
      );

      if (context.mounted) {
        context.read<PacientesBloc>().add(PacientesDeleteRequested(paciente.id));
      }
    }
  }

  // ==================== CELL BUILDERS ====================

  Widget _buildIdentificacionCell(PacienteEntity paciente) {
    return Text(
      paciente.identificacion ?? '-',
      style: AppTextStyles.tableCellBold.copyWith(
        color: paciente.identificacion != null
            ? AppColors.textPrimaryLight
            : AppColors.textSecondaryLight.withValues(alpha: 0.5),
        fontStyle: paciente.identificacion != null ? FontStyle.normal : FontStyle.italic,
      ),
    );
  }

  Widget _buildNombreCell(PacienteEntity paciente) {
    return Text(
      paciente.nombreCompleto,
      style: AppTextStyles.tableCellBold,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildDireccionCell(PacienteEntity paciente) {
    return Text(
      paciente.domicilioDireccion ?? '-',
      style: AppTextStyles.tableCell.copyWith(
        color: paciente.domicilioDireccion != null
            ? AppColors.textSecondaryLight
            : AppColors.textSecondaryLight.withValues(alpha: 0.5),
        fontStyle: paciente.domicilioDireccion != null ? FontStyle.normal : FontStyle.italic,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildTelefonoCell(PacienteEntity paciente) {
    return Text(
      paciente.telefonoMovil ?? paciente.telefonoFijo ?? '-',
      style: AppTextStyles.tableCell.copyWith(
        color: (paciente.telefonoMovil != null || paciente.telefonoFijo != null)
            ? AppColors.textSecondaryLight
            : AppColors.textSecondaryLight.withValues(alpha: 0.5),
        fontStyle: (paciente.telefonoMovil != null || paciente.telefonoFijo != null) ? FontStyle.normal : FontStyle.italic,
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
        hintText: 'Buscar paciente...',
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
      style: AppTextStyles.input,
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
          message: 'Cargando pacientes...',
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
            'Error al cargar pacientes',
            style: AppTextStyles.h5.copyWith(color: AppColors.error),
          ),
          const SizedBox(height: AppSizes.spacingSmall),
          Text(
            message,
            style: AppTextStyles.bodySecondary,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
