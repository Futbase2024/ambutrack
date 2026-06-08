import 'dart:async';

import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
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
  const PacientesTable({required this.filterData, super.key});

  final PacientesFilterData filterData;

  @override
  State<PacientesTable> createState() => _PacientesTableState();
}

class _PacientesTableState extends State<PacientesTable> {
  int? _sortColumnIndex = 0;
  bool _sortAscending = true;
  bool _isDeleting = false;
  BuildContext? _loadingDialogContext;
  DateTime? _deleteStartTime;
  int _currentPage = 0;
  static const int _itemsPerPage = 25;

  @override
  void didUpdateWidget(PacientesTable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.filterData != oldWidget.filterData) {
      _currentPage = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PacientesBloc, PacientesState>(
      listener: (BuildContext context, Object? state) async {
        if (_isDeleting && _loadingDialogContext != null) {
          if (state is PacientesLoaded || state is PacientesError) {
            final Duration elapsed = DateTime.now().difference(_deleteStartTime!);

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
            final List<PacienteEntity> allPacientes = state.pacientes;
            final List<PacienteEntity> filtrados = widget.filterData.apply(allPacientes);
            final List<PacienteEntity> sorted = _sortPacientes(filtrados);

            final int totalItems = sorted.length;
            final int totalPages = (totalItems / _itemsPerPage).ceil();
            final int startIndex = _currentPage * _itemsPerPage;
            final int endIndex = (startIndex + _itemsPerPage).clamp(0, totalItems);
            final List<PacienteEntity> pacientesPaginados = totalItems > 0
                ? sorted.sublist(startIndex, endIndex)
                : <PacienteEntity>[];

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                if (allPacientes.length != filtrados.length)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSizes.spacing),
                    child: Text(
                      'Mostrando ${filtrados.length} de ${allPacientes.length} pacientes',
                      style: AppTextStyles.bodySmallSecondary,
                    ),
                  ),

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
                    headerHeight: 44,
                    emptyMessage: widget.filterData.hasActiveFilters
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
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                onPressed: currentPage > 0
                    ? () => onPageChanged(0)
                    : null,
                tooltip: 'Primera página',
              ),
              IconButton(
                icon: const Icon(Icons.chevron_left),
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                onPressed: currentPage > 0
                    ? () => onPageChanged(currentPage - 1)
                    : null,
                tooltip: 'Página anterior',
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
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                onPressed: currentPage < totalPages - 1
                    ? () => onPageChanged(currentPage + 1)
                    : null,
                tooltip: 'Página siguiente',
              ),
              IconButton(
                icon: const Icon(Icons.last_page),
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
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

  // ==================== ORDENAMIENTO ====================

  List<PacienteEntity> _sortPacientes(List<PacienteEntity> pacientes) {
    if (_sortColumnIndex == null) {
      return pacientes;
    }

    final List<PacienteEntity> sorted = List<PacienteEntity>.from(pacientes)
      ..sort((PacienteEntity a, PacienteEntity b) {
        int comparison = 0;

        switch (_sortColumnIndex) {
          case 0:
            comparison = (a.identificacion ?? '').compareTo(b.identificacion ?? '');
          case 1:
            comparison = a.nombreCompleto.compareTo(b.nombreCompleto);
          default:
            comparison = 0;
        }

        return _sortAscending ? comparison : -comparison;
      });

    return sorted;
  }

  // ==================== ACCIONES ====================

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
