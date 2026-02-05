import 'dart:async';

import 'package:ambutrack_web/core/lang/app_strings.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/core/theme/app_text_styles.dart';
import 'package:ambutrack_web/core/widgets/buttons/app_button.dart';
import 'package:ambutrack_web/core/widgets/dialogs/app_dialog.dart';
import 'package:ambutrack_web/core/widgets/dialogs/confirmation_dialog.dart';
import 'package:ambutrack_web/core/widgets/handlers/crud_operation_handler.dart';
import 'package:ambutrack_web/core/widgets/loading/app_loading_indicator.dart';
import 'package:ambutrack_web/core/widgets/tables/app_data_grid_v5.dart';
import 'package:ambutrack_web/core/widgets/tables/modern_data_table_v3.dart';
import 'package:ambutrack_web/features/personal/domain/entities/personal_entity.dart';
import 'package:ambutrack_web/features/personal/presentation/bloc/personal_bloc.dart';
import 'package:ambutrack_web/features/personal/presentation/bloc/personal_event.dart';
import 'package:ambutrack_web/features/personal/presentation/bloc/personal_state.dart';
import 'package:ambutrack_web/features/personal/presentation/widgets/personal_filters.dart';
import 'package:ambutrack_web/features/personal/presentation/widgets/personal_form_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

/// Tabla de personal optimizada con ModernDataTableV3
/// - Usa tabla genérica reutilizable
/// - Ordenamiento integrado
/// - Paginación automática
/// - Estados manejados (Loading/Error/Vacío)
class PersonalTableV4 extends StatefulWidget {
  const PersonalTableV4({super.key});

  @override
  State<PersonalTableV4> createState() => _PersonalTableV4State();
}

class _PersonalTableV4State extends State<PersonalTableV4> {
  PersonalFilterData _filterData = const PersonalFilterData();
  bool _isDeleting = false;
  BuildContext? _loadingDialogContext;
  DateTime? _deleteStartTime;
  int? _sortColumnIndex;
  bool _sortAscending = true;

  // Paginación para mejorar rendimiento
  int _currentPage = 0;
  static const int _itemsPerPage = 25;

  void _onFilterChanged(PersonalFilterData filterData) {
    setState(() {
      _filterData = filterData;
      _currentPage = 0;
    });
  }

  void _onSort(int columnIndex, {required bool ascending}) {
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PersonalBloc, PersonalState>(
      listener: (BuildContext context, PersonalState state) {
        if (_isDeleting && _loadingDialogContext != null) {
          if (state is PersonalLoaded || state is PersonalError) {
            final Duration elapsed = DateTime.now().difference(_deleteStartTime!);
            final int durationMs = elapsed.inMilliseconds;

            setState(() {
              _isDeleting = false;
              _loadingDialogContext = null;
              _deleteStartTime = null;
            });

            if (state is PersonalError) {
              CrudOperationHandler.handleDeleteError(
                context: context,
                isDeleting: true,
                entityName: 'Personal',
                errorMessage: state.message,
              );
            } else if (state is PersonalLoaded) {
              CrudOperationHandler.handleDeleteSuccess(
                context: context,
                isDeleting: true,
                entityName: 'Personal',
                durationMs: durationMs,
              );
            }
          }
        }
      },
      child: BlocBuilder<PersonalBloc, PersonalState>(
        builder: (BuildContext context, PersonalState state) {
          if (state is PersonalLoading) {
            return const LoadingView(message: 'Cargando personal...');
          }

          if (state is PersonalError) {
            return ErrorView(
              message: state.message,
              onRetry: () {
                context.read<PersonalBloc>().add(const PersonalLoadRequested());
              },
            );
          }

          if (state is PersonalLoaded) {
            // Aplicar filtros
            List<PersonalEntity> personalFiltrado = _filterData.apply(state.personal);

            // Aplicar ordenamiento antes de paginar
            if (_sortColumnIndex != null) {
              personalFiltrado = List<PersonalEntity>.from(personalFiltrado)
                ..sort((PersonalEntity a, PersonalEntity b) {
                  int result = 0;
                  switch (_sortColumnIndex) {
                    case 0:
                      result = a.nombreCompleto.compareTo(b.nombreCompleto);
                      break;
                    case 1:
                      result = (a.dni ?? '').compareTo(b.dni ?? '');
                      break;
                    case 2:
                      result = (a.categoria ?? '').compareTo(b.categoria ?? '');
                      break;
                    case 3:
                      result = (a.email ?? '').compareTo(b.email ?? '');
                      break;
                    case 4:
                      if (a.fechaAlta == null && b.fechaAlta == null) {
                        result = 0;
                      } else if (a.fechaAlta == null) {
                        result = 1;
                      } else if (b.fechaAlta == null) {
                        result = -1;
                      } else {
                        result = a.fechaAlta!.compareTo(b.fechaAlta!);
                      }
                      break;
                  }
                  return _sortAscending ? result : -result;
                });
            }

            // Aplicar paginación para mejorar rendimiento (25 items por página)
            final int totalPages = (personalFiltrado.length / _itemsPerPage).ceil();
            final int startIndex = _currentPage * _itemsPerPage;
            final int endIndex = (startIndex + _itemsPerPage).clamp(0, personalFiltrado.length);
            final List<PersonalEntity> personalPaginado = personalFiltrado.sublist(
              startIndex,
              endIndex,
            );

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      AppStrings.personalListaTitulo,
                      style: AppTextStyles.h4,
                    ),
                    PersonalFilters(onFiltersChanged: _onFilterChanged),
                  ],
                ),
                const SizedBox(height: AppSizes.spacing),

                // Info de resultados filtrados
                if (state.personal.length != personalFiltrado.length)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSizes.spacing),
                    child: Text(
                      'Mostrando ${personalFiltrado.length} de ${state.personal.length} personal',
                      style: AppTextStyles.bodySmallSecondary,
                    ),
                  ),

                // Tabla con lazy loading (AppDataGridV5)
                Expanded(
                  child: AppDataGridV5<PersonalEntity>(
                    columns: const <DataGridColumn>[
                      DataGridColumn(label: 'PERSONAL', flexWidth: 3, sortable: true),
                      DataGridColumn(label: 'DNI', flexWidth: 2, sortable: true),
                      DataGridColumn(label: 'CATEGORÍA', flexWidth: 2, sortable: true),
                      DataGridColumn(label: 'CONTACTO', flexWidth: 3, sortable: true),
                      DataGridColumn(label: 'FECHA ALTA', flexWidth: 2, sortable: true),
                    ],
                    rows: personalPaginado,
                    buildCells: _buildCells,
                    sortColumnIndex: _sortColumnIndex,
                    sortAscending: _sortAscending,
                    outerBorderColor: AppColors.gray400,
                    onSort: _onSort,
                    rowHeight: 60.0,
                    emptyMessage: _filterData.hasActiveFilters
                        ? 'No se encontraron resultados con los filtros aplicados'
                        : 'No hay personal registrado',
                    onView: (PersonalEntity persona) => _showPersonalDetails(context, persona),
                    onEdit: (PersonalEntity persona) => _editPersonal(context, persona),
                    onDelete: (PersonalEntity persona) => _confirmDelete(context, persona),
                  ),
                ),

                // Controles de paginación (forzados temporalmente para revisión visual)
                if (personalFiltrado.isNotEmpty) ...<Widget>[
                  _buildPaginationControls(
                    currentPage: _currentPage,
                    totalPages: totalPages,
                    totalItems: personalFiltrado.length,
                    onPageChanged: (int page) {
                      setState(() {
                        _currentPage = page;
                      });
                    },
                  ),
                ],

              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

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
            'Mostrando $startItem-$endItem de $totalItems personal',
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


  /// Construye las celdas de cada fila
  List<DataGridCell> _buildCells(PersonalEntity persona) {
    return <DataGridCell>[
      // Personal (nombre)
      DataGridCell(child: _buildPersonalCell(persona)),

      // DNI
      DataGridCell(child: _buildDniCell(persona)),

      // Categoría
      DataGridCell(child: _buildCategoriaChip(persona.categoria)),

      // Contacto
      DataGridCell(child: _buildContactoColumn(persona)),

      // Fecha Alta
      DataGridCell(child: _buildFechaAltaCell(persona)),
    ];
  }

  Widget _buildPersonalCell(PersonalEntity persona) {
    return Text(
      persona.nombreCompleto,
      style: AppTextStyles.tableCellBold,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildDniCell(PersonalEntity persona) {
    return Text(
      persona.dni ?? 'Sin DNI',
      style: persona.dni != null
          ? AppTextStyles.tableCell
          : AppTextStyles.tableCellSecondary.copyWith(fontStyle: FontStyle.italic),
    );
  }

  Widget _buildFechaAltaCell(PersonalEntity persona) {
    return Text(
      persona.fechaAlta != null
          ? DateFormat('dd/MM/yyyy').format(persona.fechaAlta!)
          : 'Sin fecha',
      style: persona.fechaAlta != null
          ? AppTextStyles.tableCell
          : AppTextStyles.tableCellSecondary.copyWith(fontStyle: FontStyle.italic),
    );
  }

  Widget _buildCategoriaChip(String? categoria) {
    if (categoria == null) {
      return Text(
        'Sin categoría',
        style: AppTextStyles.tableCellSecondary.copyWith(fontStyle: FontStyle.italic),
      );
    }

    final Color categoriaColor = _getCategoriaColor(categoria);

    return Text(
      categoria,
      style: AppTextStyles.chipText.copyWith(color: categoriaColor),
    );
  }

  Color _getCategoriaColor(String categoria) {
    switch (categoria.toLowerCase()) {
      case 'médico':
      case 'medico':
        return AppColors.primary;
      case 'enfermero':
      case 'enfermera':
        return AppColors.success;
      case 'técnico':
      case 'tecnico':
      case 'técnico sanitario':
      case 'tecnico sanitario':
      case 'tes':
        return AppColors.info;
      case 'conductor':
      case 'conductora':
        return AppColors.warning;
      case 'administrativo':
      case 'administrativa':
        return AppColors.secondary;
      default:
        return AppColors.textSecondaryLight;
    }
  }

  Widget _buildContactoColumn(PersonalEntity persona) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (persona.email != null)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Icon(Icons.email, size: 11, color: AppColors.textSecondaryLight),
              const SizedBox(width: 3),
              Flexible(
                child: Text(
                  persona.email!,
                  style: AppTextStyles.tableCellSmall.copyWith(color: AppColors.textPrimaryLight),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        if (persona.telefono != null || persona.movil != null)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Icon(Icons.phone, size: 11, color: AppColors.textSecondaryLight),
              const SizedBox(width: 3),
              Text(
                persona.movil ?? persona.telefono ?? '',
                style: AppTextStyles.tableCellSmall.copyWith(color: AppColors.textPrimaryLight),
              ),
            ],
          ),
        if (persona.email == null && persona.telefono == null && persona.movil == null)
          Text(
            'Sin contacto',
            style: AppTextStyles.tableCellSmall.copyWith(fontStyle: FontStyle.italic),
          ),
      ],
    );
  }

  void _showPersonalDetails(BuildContext context, PersonalEntity persona) {
    showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AppDialog(
          title: 'Detalles del Personal',
          icon: Icons.person,
          maxWidth: 700,
          content: _PersonalDetailsContent(persona: persona),
          actions: <Widget>[
            AppButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              label: 'Cerrar',
              variant: AppButtonVariant.text,
            ),
            AppButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _editPersonal(context, persona);
              },
              label: 'Editar',
              icon: Icons.edit,
            ),
          ],
        );
      },
    );
  }

  void _editPersonal(BuildContext context, PersonalEntity persona) {
    showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return BlocProvider<PersonalBloc>.value(
          value: context.read<PersonalBloc>(),
          child: PersonalFormDialog(persona: persona),
        );
      },
    );
  }

  Future<void> _confirmDelete(BuildContext context, PersonalEntity persona) async {
    final bool? confirmed = await showConfirmationDialog(
      context: context,
      title: 'Confirmar Eliminación',
      message: '¿Estás seguro de que deseas eliminar este personal? Esta acción no se puede deshacer.',
      itemDetails: <String, String>{
        'Nombre': persona.nombre,
        'Apellidos': persona.apellidos,
        if (persona.dni != null && persona.dni!.isNotEmpty) 'DNI': persona.dni!,
        if (persona.categoria != null && persona.categoria!.isNotEmpty)
          'Categoría': persona.categoria!,
        if (persona.telefono != null && persona.telefono!.isNotEmpty)
          'Teléfono': persona.telefono!,
        if (persona.movil != null && persona.movil!.isNotEmpty) 'Móvil': persona.movil!,
        if (persona.email != null && persona.email!.isNotEmpty) 'Email': persona.email!,
        if (persona.fechaInicio != null)
          'Fecha Inicio':
              '${persona.fechaInicio!.day}/${persona.fechaInicio!.month}/${persona.fechaInicio!.year}',
      },
    );

    if (confirmed == true && context.mounted) {
      debugPrint('🗑️ Eliminando personal: ${persona.nombreCompleto} (${persona.id})');

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
              message: 'Eliminando personal...',
              color: AppColors.emergency,
              icon: Icons.delete_forever,
            );
          },
        ),
      );

      if (context.mounted) {
        context.read<PersonalBloc>().add(PersonalDeleteRequested(id: persona.id));
      }
    }
  }
}

/// Widget de detalles del personal
class _PersonalDetailsContent extends StatelessWidget {
  const _PersonalDetailsContent({required this.persona});

  final PersonalEntity persona;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        _buildDetailRow('Nombre completo', persona.nombreCompleto),
        _buildDetailRow('DNI', persona.dni ?? 'No especificado'),
        _buildDetailRow('NASS', persona.nass ?? 'No especificado'),
        _buildDetailRow('Categoría', persona.categoria ?? 'No especificado'),
        _buildDetailRow('Email', persona.email ?? 'No especificado'),
        _buildDetailRow('Teléfono', persona.telefono ?? 'No especificado'),
        _buildDetailRow('Móvil', persona.movil ?? 'No especificado'),
        _buildDetailRow('Dirección', persona.direccion ?? 'No especificado'),
        _buildDetailRow('Código Postal', persona.codigoPostal ?? 'No especificado'),
        if (persona.fechaNacimiento != null)
          _buildDetailRow(
            'Fecha de Nacimiento',
            DateFormat('dd/MM/yyyy').format(persona.fechaNacimiento!),
          ),
        if (persona.fechaInicio != null)
          _buildDetailRow(
            'Fecha de Inicio',
            DateFormat('dd/MM/yyyy').format(persona.fechaInicio!),
          ),
        if (persona.fechaAlta != null)
          _buildDetailRow(
            'Fecha de Alta',
            DateFormat('dd/MM/yyyy').format(persona.fechaAlta!),
          ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.spacingMedium),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: 180,
            child: Text(
              label,
              style: AppTextStyles.labelBold.copyWith(
                color: AppColors.textSecondaryLight,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.body,
            ),
          ),
        ],
      ),
    );
  }
}
