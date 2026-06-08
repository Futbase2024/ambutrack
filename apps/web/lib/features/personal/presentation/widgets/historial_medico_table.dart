import 'dart:async';

import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/core/theme/app_text_styles.dart';
import 'package:ambutrack_web/core/widgets/dialogs/confirmation_dialog.dart';
import 'package:ambutrack_web/core/widgets/handlers/crud_operation_handler.dart';
import 'package:ambutrack_web/core/widgets/loading/app_loading_indicator.dart';
import 'package:ambutrack_web/core/widgets/tables/app_data_grid_v5.dart';
import 'package:ambutrack_web/features/personal/domain/entities/personal_entity.dart';
import 'package:ambutrack_web/features/personal/domain/repositories/personal_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../bloc/historial_medico_bloc.dart';
import '../bloc/historial_medico_event.dart';
import '../bloc/historial_medico_state.dart';
import 'historial_medico_form_dialog.dart';

/// Tabla de Historial Médico del Personal
class HistorialMedicoTable extends StatefulWidget {
  const HistorialMedicoTable({
    super.key,
    required this.searchQuery,
  });

  final String searchQuery;

  @override
  State<HistorialMedicoTable> createState() => _HistorialMedicoTableState();
}

class _HistorialMedicoTableState extends State<HistorialMedicoTable> {
  int? _sortColumnIndex = 0;
  bool _sortAscending = true;
  bool _isDeleting = false;
  BuildContext? _loadingDialogContext;
  DateTime? _deleteStartTime;
  int _currentPage = 0;
  static const int _itemsPerPage = 25;

  @override
  void didUpdateWidget(HistorialMedicoTable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.searchQuery != widget.searchQuery) {
      _currentPage = 0;
    }
  }

  // Cache de personal para mostrar nombres
  final Map<String, String> _personalNombres = <String, String>{};

  @override
  void initState() {
    super.initState();
    _cargarPersonal();
  }

  /// Carga la lista de personal para lookup de nombres
  Future<void> _cargarPersonal() async {
    try {
      final PersonalRepository personalRepo = getIt<PersonalRepository>();
      final List<PersonalEntity> personalList = await personalRepo.getAll();

      if (mounted) {
        setState(() {
          for (final PersonalEntity p in personalList) {
            _personalNombres[p.id] = p.nombreCompleto;
          }
        });
      }
    } catch (e) {
      debugPrint('⚠️ Error al cargar personal para lookup: $e');
    }
  }

  /// Obtiene el nombre del personal por ID
  String _getNombrePersonal(String personalId) {
    return _personalNombres[personalId] ?? 'Desconocido';
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<HistorialMedicoBloc, HistorialMedicoState>(
      listener: (BuildContext context, HistorialMedicoState state) async {
        // Manejo de loading al eliminar
        if (_isDeleting && _loadingDialogContext != null) {
          if (state is HistorialMedicoLoaded || state is HistorialMedicoError) {
            final Duration elapsed = DateTime.now().difference(_deleteStartTime!);

            if (state is HistorialMedicoError) {
              await CrudOperationHandler.handleDeleteError(
                context: _loadingDialogContext!,
                isDeleting: _isDeleting,
                entityName: 'Reconocimiento Médico',
                errorMessage: state.message,
                onClose: () {
                  setState(() {
                    _isDeleting = false;
                    _loadingDialogContext = null;
                    _deleteStartTime = null;
                  });
                },
              );
            } else if (state is HistorialMedicoLoaded) {
              await CrudOperationHandler.handleDeleteSuccess(
                context: _loadingDialogContext!,
                isDeleting: _isDeleting,
                entityName: 'Reconocimiento Médico',
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
      child: BlocBuilder<HistorialMedicoBloc, HistorialMedicoState>(
        builder: (BuildContext context, HistorialMedicoState state) {
          if (state is HistorialMedicoLoading) {
            return const _LoadingView();
          }

          if (state is HistorialMedicoError) {
            return _ErrorView(message: state.message);
          }

          if (state is HistorialMedicoLoaded) {
            // Filtrado y ordenamiento
            List<HistorialMedicoEntity> filtrados = _filterItems(state.items);
            filtrados = _sortItems(filtrados);

            // Cálculo de paginación
            final int totalItems = filtrados.length;
            final int totalPages = (totalItems / _itemsPerPage).ceil();
            final int startIndex = _currentPage * _itemsPerPage;
            final int endIndex = (startIndex + _itemsPerPage).clamp(0, totalItems);
            final List<HistorialMedicoEntity> itemsPaginados = totalItems > 0
                ? filtrados.sublist(startIndex, endIndex)
                : <HistorialMedicoEntity>[];

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                if (state.items.length != filtrados.length)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSizes.spacing),
                    child: Text(
                      'Mostrando ${filtrados.length} de ${state.items.length} reconocimientos',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: AppColors.textSecondaryLight,
                      ),
                    ),
                  ),

                Expanded(
                  child: AppDataGridV5<HistorialMedicoEntity>(
                    columns: const <DataGridColumn>[
                      DataGridColumn(label: 'PERSONAL', flexWidth: 2, sortable: true),
                      DataGridColumn(label: 'FECHA RECONOCIMIENTO', flexWidth: 2, sortable: true),
                      DataGridColumn(label: 'FECHA CADUCIDAD', flexWidth: 2, sortable: true),
                      DataGridColumn(label: 'APTITUD', flexWidth: 2, sortable: true),
                      DataGridColumn(label: 'CENTRO MÉDICO', flexWidth: 2, sortable: true),
                      DataGridColumn(label: 'MÉDICO', flexWidth: 2, sortable: true),
                      DataGridColumn(label: 'ESTADO', flexWidth: 2, sortable: true),
                    ],
                    rows: itemsPaginados,
                    buildCells: (HistorialMedicoEntity item) => <DataGridCell>[
                      DataGridCell(child: _buildPersonalCell(item.personalId)),
                      DataGridCell(child: _buildFechaCell(item.fechaReconocimiento)),
                      DataGridCell(child: _buildFechaCell(item.fechaCaducidad)),
                      DataGridCell(child: _buildAptitudCell(item.aptitud)),
                      DataGridCell(child: _buildCentroCell(item.centroMedico)),
                      DataGridCell(child: _buildMedicoCell(item.nombreMedico)),
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
                    emptyMessage: widget.searchQuery.isNotEmpty
                        ? 'No se encontraron reconocimientos con los filtros aplicados'
                        : 'No hay reconocimientos médicos registrados',
                    onEdit: (HistorialMedicoEntity item) => _editItem(context, item),
                    onDelete: (HistorialMedicoEntity item) => _confirmDelete(context, item),
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

  /// Filtra items según el query de búsqueda
  List<HistorialMedicoEntity> _filterItems(List<HistorialMedicoEntity> items) {
    if (widget.searchQuery.isEmpty) {
      return items;
    }

    final String query = widget.searchQuery.toLowerCase();

    return items.where((HistorialMedicoEntity item) {
      final String personal = _getNombrePersonal(item.personalId).toLowerCase();
      final String fecha = _formatDate(item.fechaReconocimiento).toLowerCase();
      final String aptitud = item.aptitud.toLowerCase();
      final String centro = (item.centroMedico ?? '').toLowerCase();
      final String medico = (item.nombreMedico ?? '').toLowerCase();

      return personal.contains(query) ||
          fecha.contains(query) ||
          aptitud.contains(query) ||
          centro.contains(query) ||
          medico.contains(query);
    }).toList();
  }

  /// Ordena items según columna seleccionada
  List<HistorialMedicoEntity> _sortItems(List<HistorialMedicoEntity> items) {
    if (_sortColumnIndex == null) {
      return items;
    }

    return List<HistorialMedicoEntity>.from(items)
      ..sort((HistorialMedicoEntity a, HistorialMedicoEntity b) {
        int comparison = 0;

        switch (_sortColumnIndex) {
          case 0: // Personal
            comparison = _getNombrePersonal(a.personalId).compareTo(_getNombrePersonal(b.personalId));
          case 1: // Fecha Reconocimiento
            comparison = a.fechaReconocimiento.compareTo(b.fechaReconocimiento);
          case 2: // Fecha Caducidad
            comparison = a.fechaCaducidad.compareTo(b.fechaCaducidad);
          case 3: // Aptitud
            comparison = a.aptitud.compareTo(b.aptitud);
          case 4: // Centro Médico
            comparison = (a.centroMedico ?? '').compareTo(b.centroMedico ?? '');
          case 5: // Médico
            comparison = (a.nombreMedico ?? '').compareTo(b.nombreMedico ?? '');
          case 6: // Estado
            final bool aVigente = !a.estaCaducado;
            final bool bVigente = !b.estaCaducado;
            comparison = aVigente == bVigente ? 0 : (aVigente ? 1 : -1);
          default:
            comparison = 0;
        }

        return _sortAscending ? comparison : -comparison;
      });
  }

  Widget _buildAptitudCell(String aptitud) {
    Color color;
    String label;

    switch (aptitud) {
      case 'apto':
        color = AppColors.success;
        label = 'Apto';
      case 'apto_con_restricciones':
        color = AppColors.warning;
        label = 'Apto con restricciones';
      case 'no_apto':
        color = AppColors.error;
        label = 'No apto';
      default:
        color = AppColors.gray400;
        label = aptitud;
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: IntrinsicWidth(
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.paddingSmall,
            vertical: 4,
          ),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
          ),
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEstadoCell(HistorialMedicoEntity item) {
    final bool caducado = item.estaCaducado;
    final bool proximoCaducar = item.estaProximoCaducar;

    Color color;
    String label;
    IconData icon;

    if (caducado) {
      color = AppColors.error;
      label = 'Caducado';
      icon = Icons.error_outline;
    } else if (proximoCaducar) {
      color = AppColors.warning;
      label = 'Próximo a caducar';
      icon = Icons.warning_amber_outlined;
    } else {
      color = AppColors.success;
      label = 'Vigente';
      icon = Icons.check_circle_outline;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 4),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  /// Construye celda de personal
  Widget _buildPersonalCell(String personalId) {
    final String nombre = _getNombrePersonal(personalId);

    return Text(
      nombre,
      style: AppTextStyles.bodySmall.copyWith(
        fontWeight: FontWeight.w600,
        color: nombre == 'Desconocido' ? AppColors.textSecondaryLight : AppColors.textPrimaryLight,
      ),
      overflow: TextOverflow.ellipsis,
    );
  }

  /// Construye celda de fecha
  Widget _buildFechaCell(DateTime fecha) {
    return Text(
      DateFormat('dd/MM/yyyy').format(fecha),
      style: AppTextStyles.bodySmall,
    );
  }

  /// Construye celda de centro médico
  Widget _buildCentroCell(String? centro) {
    return Text(
      centro ?? 'No especificado',
      style: AppTextStyles.bodySmall,
      overflow: TextOverflow.ellipsis,
    );
  }

  /// Construye celda de médico
  Widget _buildMedicoCell(String? medico) {
    return Text(
      medico ?? 'No especificado',
      style: AppTextStyles.bodySmall,
      overflow: TextOverflow.ellipsis,
    );
  }

  /// Edita un reconocimiento médico
  void _editItem(BuildContext context, HistorialMedicoEntity item) {
    showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return BlocProvider<HistorialMedicoBloc>.value(
          value: context.read<HistorialMedicoBloc>(),
          child: HistorialMedicoFormDialog(item: item),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  /// Confirma eliminación de reconocimiento médico
  Future<void> _confirmDelete(BuildContext context, HistorialMedicoEntity item) async {
    final bool? confirmed = await showConfirmationDialog(
      context: context,
      title: 'Confirmar Eliminación',
      message: '¿Estás seguro de que deseas eliminar este Reconocimiento Médico? Esta acción no se puede deshacer.',
      itemDetails: <String, String>{
        'Fecha Reconocimiento': _formatDate(item.fechaReconocimiento),
        'Fecha Caducidad': _formatDate(item.fechaCaducidad),
        'Aptitud': item.aptitud == 'apto'
            ? 'Apto'
            : item.aptitud == 'apto_con_restricciones'
                ? 'Apto con restricciones'
                : 'No apto',
        if (item.centroMedico != null && item.centroMedico!.isNotEmpty) 'Centro Médico': item.centroMedico!,
        if (item.nombreMedico != null && item.nombreMedico!.isNotEmpty) 'Médico': item.nombreMedico!,
        'Estado': item.activo ? 'Activo' : 'Inactivo',
      },
    );

    if (confirmed == true && context.mounted) {
      debugPrint('🗑️ Eliminando reconocimiento médico: ${item.fechaReconocimiento} (${item.id})');

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
              message: 'Eliminando Reconocimiento Médico...',
              color: AppColors.emergency,
              icon: Icons.delete_forever,
            );
          },
        ),
      );

      if (context.mounted) {
        context.read<HistorialMedicoBloc>().add(HistorialMedicoDeleteRequested(item.id));
      }
    }
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
          message: 'Cargando historial médico...',
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
            'Error al cargar el historial médico',
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

/// Campo de búsqueda para Historial Médico (usado en PageHeader.extra)
class HistorialMedicoSearchField extends StatefulWidget {
  const HistorialMedicoSearchField({
    super.key,
    required this.searchQuery,
    required this.onSearchChanged,
  });

  final String searchQuery;
  final void Function(String) onSearchChanged;

  @override
  State<HistorialMedicoSearchField> createState() => _HistorialMedicoSearchFieldState();
}

class _HistorialMedicoSearchFieldState extends State<HistorialMedicoSearchField> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.searchQuery);
  }

  @override
  void didUpdateWidget(HistorialMedicoSearchField oldWidget) {
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
        hintText: 'Buscar reconocimiento...',
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
            'Mostrando $startItem-$endItem de $totalItems reconocimientos',
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
