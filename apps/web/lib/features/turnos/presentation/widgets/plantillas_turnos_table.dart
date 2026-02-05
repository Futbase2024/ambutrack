import 'dart:async';

import 'package:ambutrack_core/ambutrack_core.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/core/widgets/dialogs/confirmation_dialog.dart';
import 'package:ambutrack_web/core/widgets/handlers/crud_operation_handler.dart';
import 'package:ambutrack_web/core/widgets/loading/app_loading_indicator.dart';
import 'package:ambutrack_web/core/widgets/tables/modern_data_table.dart';
import 'package:ambutrack_web/features/turnos/presentation/bloc/plantillas_turnos_bloc.dart';
import 'package:ambutrack_web/features/turnos/presentation/bloc/plantillas_turnos_event.dart';
import 'package:ambutrack_web/features/turnos/presentation/bloc/plantillas_turnos_state.dart';
import 'package:ambutrack_web/features/turnos/presentation/widgets/plantilla_turno_form_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

/// Tabla de plantillas de turnos
class PlantillasTurnosTable extends StatefulWidget {
  const PlantillasTurnosTable({super.key});

  @override
  State<PlantillasTurnosTable> createState() => _PlantillasTurnosTableState();
}

class _PlantillasTurnosTableState extends State<PlantillasTurnosTable> {
  String _searchQuery = '';
  int? _sortColumnIndex;
  bool _sortAscending = true;
  bool _isDeleting = false;
  BuildContext? _loadingDialogContext;
  DateTime? _deleteStartTime;

  @override
  Widget build(BuildContext context) {
    return BlocListener<PlantillasTurnosBloc, PlantillasTurnosState>(
      listener: (BuildContext context, PlantillasTurnosState state) async {
        // Manejo de loading al eliminar
        if (_isDeleting && _loadingDialogContext != null) {
          if (state is PlantillasTurnosLoaded ||
              state is PlantillasTurnosError) {
            final Duration elapsed =
                DateTime.now().difference(_deleteStartTime!);

            // Manejar resultado con CrudOperationHandler
            if (state is PlantillasTurnosError) {
              await CrudOperationHandler.handleDeleteError(
                context: _loadingDialogContext!,
                isDeleting: _isDeleting,
                entityName: 'Plantilla de Turno',
                errorMessage: state.message,
                onClose: () {
                  setState(() {
                    _isDeleting = false;
                    _loadingDialogContext = null;
                    _deleteStartTime = null;
                  });
                },
              );
            } else {
              await CrudOperationHandler.handleDeleteSuccess(
                context: _loadingDialogContext!,
                isDeleting: _isDeleting,
                entityName: 'Plantilla de Turno',
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
      child: BlocBuilder<PlantillasTurnosBloc, PlantillasTurnosState>(
        builder: (BuildContext context, PlantillasTurnosState state) {
          if (state is PlantillasTurnosLoading) {
            return const _LoadingView();
          }

          if (state is PlantillasTurnosError) {
            return _ErrorView(message: state.message);
          }

          if (state is PlantillasTurnosLoaded) {
            List<PlantillaTurnoEntity> filtradas =
                _filterPlantillas(state.plantillas);
            filtradas = _sortPlantillas(filtradas);

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  // Header: Título + Búsqueda + Botón Crear
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          'Plantillas de Turnos',
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimaryLight,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 300,
                        child: _SearchField(
                          searchQuery: _searchQuery,
                          onSearchChanged: (String query) {
                            setState(() => _searchQuery = query);
                          },
                        ),
                      ),
                      const SizedBox(width: AppSizes.spacing),
                      ElevatedButton.icon(
                        onPressed: () => _crearPlantilla(context),
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Nueva Plantilla'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSizes.paddingMedium,
                            vertical: AppSizes.paddingSmall,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.spacing),

                  // Info de resultados filtrados
                  if (state.plantillas.length != filtradas.length)
                    Padding(
                      padding:
                          const EdgeInsets.only(bottom: AppSizes.spacing),
                      child: Text(
                        'Mostrando ${filtradas.length} de ${state.plantillas.length} plantillas',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: AppColors.textSecondaryLight,
                        ),
                      ),
                    ),

                  // Tabla
                  ModernDataTable<PlantillaTurnoEntity>(
                    onEdit: (PlantillaTurnoEntity plantilla) =>
                        _editarPlantilla(context, plantilla),
                    onDelete: (PlantillaTurnoEntity plantilla) =>
                        _confirmDelete(context, plantilla),
                    sortColumnIndex: _sortColumnIndex,
                    sortAscending: _sortAscending,
                    onSort: (int columnIndex, bool ascending) {
                      setState(() {
                        _sortColumnIndex = columnIndex;
                        _sortAscending = ascending;
                      });
                    },
                    columns: const <ModernDataColumn>[
                      ModernDataColumn(label: 'NOMBRE', sortable: true),
                      ModernDataColumn(label: 'TIPO', sortable: true),
                      ModernDataColumn(label: 'HORARIO'),
                      ModernDataColumn(label: 'DURACIÓN', sortable: true),
                      ModernDataColumn(label: 'COLOR'),
                      ModernDataColumn(label: 'ESTADO', sortable: true),
                    ],
                    rows: filtradas.map((PlantillaTurnoEntity plantilla) {
                      return ModernDataRow<PlantillaTurnoEntity>(
                        data: plantilla,
                        cells: <Widget>[
                          _buildNombreCell(plantilla),
                          _buildTipoCell(plantilla),
                          _buildHorarioCell(plantilla),
                          _buildDuracionCell(plantilla),
                          _buildColorCell(plantilla),
                          _buildEstadoCell(plantilla),
                        ],
                      );
                    }).toList(),
                    emptyMessage: _searchQuery.isNotEmpty
                        ? 'No se encontraron plantillas con los filtros aplicados'
                        : 'No hay plantillas registradas',
                  ),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  /// Filtra las plantillas según búsqueda
  List<PlantillaTurnoEntity> _filterPlantillas(
    List<PlantillaTurnoEntity> plantillas,
  ) {
    if (_searchQuery.isEmpty) {
      return plantillas;
    }

    final String query = _searchQuery.toLowerCase();
    return plantillas.where((PlantillaTurnoEntity p) {
      return p.nombre.toLowerCase().contains(query) ||
          p.tipoTurno.nombre.toLowerCase().contains(query) ||
          (p.descripcion?.toLowerCase().contains(query) ?? false);
    }).toList();
  }

  /// Ordena las plantillas según columna seleccionada
  List<PlantillaTurnoEntity> _sortPlantillas(
    List<PlantillaTurnoEntity> plantillas,
  ) {
    if (_sortColumnIndex == null) {
      return plantillas;
    }

    final List<PlantillaTurnoEntity> sorted =
        List<PlantillaTurnoEntity>.from(plantillas)
          ..sort((PlantillaTurnoEntity a, PlantillaTurnoEntity b) {
            int comparison = 0;

            switch (_sortColumnIndex) {
              case 0: // Nombre
                comparison = a.nombre.compareTo(b.nombre);
              case 1: // Tipo
                comparison = a.tipoTurno.nombre.compareTo(b.tipoTurno.nombre);
              case 3: // Duración
                comparison = a.duracionDias.compareTo(b.duracionDias);
              case 5: // Estado
                comparison = a.activo == b.activo ? 0 : (a.activo ? -1 : 1);
              default:
                comparison = 0;
            }

            return _sortAscending ? comparison : -comparison;
          });

    return sorted;
  }

  /// Construye celda de nombre con descripción
  Widget _buildNombreCell(PlantillaTurnoEntity plantilla) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          plantilla.nombre,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimaryLight,
          ),
        ),
        if (plantilla.descripcion != null &&
            plantilla.descripcion!.isNotEmpty) ...<Widget>[
          const SizedBox(height: 2),
          Text(
            plantilla.descripcion!,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: AppColors.textSecondaryLight,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }

  /// Construye celda de tipo de turno
  Widget _buildTipoCell(PlantillaTurnoEntity plantilla) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: Color(
          int.parse(plantilla.tipoTurno.colorHex.substring(1), radix: 16) +
              0x33000000,
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        plantilla.tipoTurno.nombre,
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: Color(
            int.parse(plantilla.tipoTurno.colorHex.substring(1), radix: 16) +
                0xFF000000,
          ),
        ),
      ),
    );
  }

  /// Construye celda de horario
  Widget _buildHorarioCell(PlantillaTurnoEntity plantilla) {
    return Text(
      '${plantilla.horaInicio} - ${plantilla.horaFin}',
      style: GoogleFonts.inter(
        fontSize: 13,
        color: AppColors.textPrimaryLight,
      ),
    );
  }

  /// Construye celda de duración
  Widget _buildDuracionCell(PlantillaTurnoEntity plantilla) {
    final String duracion = plantilla.duracionDias == 1
        ? '1 día'
        : '${plantilla.duracionDias} días';

    return Text(
      duracion,
      style: GoogleFonts.inter(
        fontSize: 13,
        color: AppColors.textPrimaryLight,
      ),
    );
  }

  /// Construye celda de color
  Widget _buildColorCell(PlantillaTurnoEntity plantilla) {
    final String colorHex = plantilla.getColorHex();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: Color(int.parse(colorHex.substring(1), radix: 16) + 0xFF000000),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: AppColors.gray300),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          colorHex.toUpperCase(),
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondaryLight,
            fontFamily: 'monospace',
          ),
        ),
      ],
    );
  }

  /// Construye celda de estado
  Widget _buildEstadoCell(PlantillaTurnoEntity plantilla) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: plantilla.activo ? AppColors.success : AppColors.inactive,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        plantilla.activo ? 'Activo' : 'Inactivo',
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
      ),
    );
  }

  /// Abre diálogo para crear plantilla
  Future<void> _crearPlantilla(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return PlantillaTurnoFormDialog(
          onSave: (PlantillaTurnoEntity plantilla) {
            context
                .read<PlantillasTurnosBloc>()
                .add(PlantillaTurnoCreateRequested(plantilla));
          },
        );
      },
    );
  }

  /// Abre diálogo para editar plantilla
  Future<void> _editarPlantilla(
    BuildContext context,
    PlantillaTurnoEntity plantilla,
  ) async {
    await showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return PlantillaTurnoFormDialog(
          plantilla: plantilla,
          onSave: (PlantillaTurnoEntity updated) {
            context
                .read<PlantillasTurnosBloc>()
                .add(PlantillaTurnoUpdateRequested(updated));
          },
        );
      },
    );
  }

  /// Confirma y elimina plantilla
  Future<void> _confirmDelete(
    BuildContext context,
    PlantillaTurnoEntity plantilla,
  ) async {
    final bool? confirmed = await showConfirmationDialog(
      context: context,
      title: 'Confirmar Eliminación',
      message:
          '¿Estás seguro de que deseas eliminar esta plantilla? Esta acción no se puede deshacer.',
      itemDetails: <String, String>{
        'Nombre': plantilla.nombre,
        if (plantilla.descripcion != null &&
            plantilla.descripcion!.isNotEmpty)
          'Descripción': plantilla.descripcion!,
        'Tipo': plantilla.tipoTurno.nombre,
        'Horario': '${plantilla.horaInicio} - ${plantilla.horaFin}',
        'Estado': plantilla.activo ? 'Activo' : 'Inactivo',
      },
    );

    if (confirmed == true && context.mounted) {
      debugPrint(
        '🗑️ Eliminando plantilla: ${plantilla.nombre} (${plantilla.id})',
      );

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
              message: 'Eliminando plantilla...',
              color: AppColors.emergency,
              icon: Icons.delete_forever,
            );
          },
        ),
      );

      if (context.mounted) {
        context
            .read<PlantillasTurnosBloc>()
            .add(PlantillaTurnoDeleteRequested(plantilla.id));
      }
    }
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
        hintText: 'Buscar plantilla...',
        prefixIcon: const Icon(
          Icons.search,
          size: 20,
          color: AppColors.textSecondaryLight,
        ),
        suffixIcon: _controller.text.isNotEmpty
            ? IconButton(
                icon: const Icon(
                  Icons.clear,
                  size: 18,
                  color: AppColors.textSecondaryLight,
                ),
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
          message: 'Cargando plantillas...',
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
            'Error al cargar plantillas',
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
