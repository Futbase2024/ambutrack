import 'dart:async';

import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/core/widgets/dialogs/confirmation_dialog.dart';
import 'package:ambutrack_web/core/widgets/handlers/crud_operation_handler.dart';
import 'package:ambutrack_web/core/widgets/loading/app_loading_indicator.dart';
import 'package:ambutrack_web/core/widgets/tables/modern_data_table.dart';
import 'package:ambutrack_web/features/turnos/presentation/bloc/intercambios_bloc.dart';
import 'package:ambutrack_web/features/turnos/presentation/bloc/intercambios_event.dart';
import 'package:ambutrack_web/features/turnos/presentation/bloc/intercambios_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

/// Tabla de solicitudes de intercambio
class IntercambiosTable extends StatefulWidget {
  const IntercambiosTable({super.key});

  @override
  State<IntercambiosTable> createState() => _IntercambiosTableState();
}

class _IntercambiosTableState extends State<IntercambiosTable> {
  String _searchQuery = '';
  int? _sortColumnIndex;
  bool _sortAscending = true;
  bool _isDeleting = false;
  BuildContext? _loadingDialogContext;
  DateTime? _deleteStartTime;

  @override
  Widget build(BuildContext context) {
    return BlocListener<IntercambiosBloc, IntercambiosState>(
      listener: (BuildContext context, IntercambiosState state) async {
        // Manejo de loading al eliminar
        if (_isDeleting && _loadingDialogContext != null) {
          if (state is IntercambiosLoaded || state is IntercambiosError) {
            final Duration elapsed = DateTime.now().difference(_deleteStartTime!);

            // Manejar resultado con CrudOperationHandler
            if (state is IntercambiosError) {
              await CrudOperationHandler.handleDeleteError(
                context: _loadingDialogContext!,
                isDeleting: _isDeleting,
                entityName: 'Intercambio',
                errorMessage: state.message,
                onClose: () {
                  setState(() {
                    _isDeleting = false;
                    _loadingDialogContext = null;
                    _deleteStartTime = null;
                  });
                },
              );
            } else if (state is IntercambiosLoaded) {
              await CrudOperationHandler.handleDeleteSuccess(
                context: _loadingDialogContext!,
                isDeleting: _isDeleting,
                entityName: 'Intercambio',
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
      child: BlocBuilder<IntercambiosBloc, IntercambiosState>(
        builder: (BuildContext context, IntercambiosState state) {
          if (state is IntercambiosLoading) {
            return const _LoadingView();
          }

          if (state is IntercambiosError) {
            return _ErrorView(message: state.message);
          }

          if (state is IntercambiosLoaded) {
            List<SolicitudIntercambioEntity> filtradas = _filterItems(state.solicitudes);
            filtradas = _sortItems(filtradas);

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  // Header: Título + Búsqueda
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          'Solicitudes de Intercambio de Turnos',
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
                    ],
                  ),
                  const SizedBox(height: AppSizes.spacing),

                  // Info de resultados filtrados
                  if (state.solicitudes.length != filtradas.length)
                    Padding(
                      padding: const EdgeInsets.only(
                        bottom: AppSizes.spacing,
                      ),
                      child: Text(
                        'Mostrando ${filtradas.length} de ${state.solicitudes.length} solicitudes',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: AppColors.textSecondaryLight,
                        ),
                      ),
                    ),

                  // Tabla
                  ModernDataTable<SolicitudIntercambioEntity>(
                    onView: (SolicitudIntercambioEntity solicitud) =>
                        _verDetalle(context, solicitud),
                    onDelete: (SolicitudIntercambioEntity solicitud) =>
                        _confirmDelete(context, solicitud),
                    sortColumnIndex: _sortColumnIndex,
                    sortAscending: _sortAscending,
                    onSort:
                        (int columnIndex, bool ascending) {
                      setState(() {
                        _sortColumnIndex = columnIndex;
                        _sortAscending = ascending;
                      });
                    },
                    columns: const <ModernDataColumn>[
                      ModernDataColumn(label: 'SOLICITANTE', sortable: true),
                      ModernDataColumn(label: 'DESTINO', sortable: true),
                      ModernDataColumn(label: 'FECHA SOLICITUD', sortable: true),
                      ModernDataColumn(label: 'ESTADO', sortable: true),
                      ModernDataColumn(label: 'MOTIVO'),
                    ],
                    rows: filtradas.map((SolicitudIntercambioEntity solicitud) {
                      return ModernDataRow<SolicitudIntercambioEntity>(
                        data: solicitud,
                        cells: <Widget>[
                          _buildSolicitanteCell(solicitud),
                          _buildDestinoCell(solicitud),
                          _buildFechaCell(solicitud),
                          _buildEstadoCell(solicitud),
                          _buildMotivoCell(solicitud),
                        ],
                      );
                    }).toList(),
                    emptyMessage: _searchQuery.isNotEmpty
                        ? 'No se encontraron solicitudes con los filtros aplicados'
                        : 'No hay solicitudes registradas',
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

  List<SolicitudIntercambioEntity> _filterItems(
    List<SolicitudIntercambioEntity> items,
  ) {
    if (_searchQuery.isEmpty) {
      return items;
    }

    return items.where((SolicitudIntercambioEntity solicitud) {
      final String query = _searchQuery.toLowerCase();
      return solicitud.nombrePersonalSolicitante.toLowerCase().contains(query) ||
          solicitud.nombrePersonalDestino.toLowerCase().contains(query) ||
          solicitud.estado.displayText.toLowerCase().contains(query);
    }).toList();
  }

  List<SolicitudIntercambioEntity> _sortItems(
    List<SolicitudIntercambioEntity> items,
  ) {
    if (_sortColumnIndex == null) {
      return items;
    }

    return List<SolicitudIntercambioEntity>.from(items)
      ..sort((SolicitudIntercambioEntity a, SolicitudIntercambioEntity b) {
        int comparison = 0;

        switch (_sortColumnIndex) {
          case 0:
            // SOLICITANTE
            comparison = a.nombrePersonalSolicitante
                .compareTo(b.nombrePersonalSolicitante);
          case 1:
            // DESTINO
            comparison =
                a.nombrePersonalDestino.compareTo(b.nombrePersonalDestino);
          case 2:
            // FECHA SOLICITUD
            comparison = a.fechaSolicitud.compareTo(b.fechaSolicitud);
          case 3:
            // ESTADO
            comparison = a.estado.displayText.compareTo(b.estado.displayText);
          default:
            comparison = 0;
        }

        return _sortAscending ? comparison : -comparison;
      });
  }

  Widget _buildSolicitanteCell(SolicitudIntercambioEntity solicitud) {
    return Text(
      solicitud.nombrePersonalSolicitante,
      style: GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimaryLight,
      ),
    );
  }

  Widget _buildDestinoCell(SolicitudIntercambioEntity solicitud) {
    return Text(
      solicitud.nombrePersonalDestino,
      style: GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimaryLight,
      ),
    );
  }

  Widget _buildFechaCell(SolicitudIntercambioEntity solicitud) {
    final DateFormat formatter = DateFormat('dd/MM/yyyy HH:mm');
    return Text(
      formatter.format(solicitud.fechaSolicitud),
      style: GoogleFonts.inter(
        fontSize: 13,
        color: AppColors.textSecondaryLight,
      ),
    );
  }

  Widget _buildEstadoCell(SolicitudIntercambioEntity solicitud) {
    final Color color = _getEstadoColor(solicitud.estado);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.paddingSmall,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
      ),
      child: Text(
        solicitud.estado.displayText,
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
    );
  }

  Widget _buildMotivoCell(SolicitudIntercambioEntity solicitud) {
    final String motivo =
        solicitud.motivoSolicitud ?? 'Sin motivo especificado';
    return Text(
      motivo.length > 40 ? '${motivo.substring(0, 40)}...' : motivo,
      style: GoogleFonts.inter(
        fontSize: 13,
        color: AppColors.textSecondaryLight,
      ),
    );
  }

  Color _getEstadoColor(EstadoSolicitud estado) {
    if (estado.isPendiente) {
      return AppColors.warning;
    }
    if (estado == EstadoSolicitud.aprobada) {
      return AppColors.success;
    }
    if (estado.isRechazada) {
      return AppColors.error;
    }
    return AppColors.textSecondaryLight;
  }

  Future<void> _verDetalle(
    BuildContext context,
    SolicitudIntercambioEntity solicitud,
  ) async {
    // TODO(dev): Implementar diálogo de detalle con acciones
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Ver detalle de solicitud: ${solicitud.id}'),
        backgroundColor: AppColors.info,
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    SolicitudIntercambioEntity solicitud,
  ) async {
    final bool? confirmed = await showConfirmationDialog(
      context: context,
      title: 'Confirmar Eliminación',
      message: '¿Estás seguro de que deseas eliminar esta solicitud de intercambio? Esta acción no se puede deshacer.',
      itemDetails: <String, String>{
        'Solicitante': solicitud.nombrePersonalSolicitante,
        'Destino': solicitud.nombrePersonalDestino,
        'Fecha Solicitud': DateFormat('dd/MM/yyyy HH:mm').format(solicitud.fechaSolicitud),
        if (solicitud.motivoSolicitud != null && solicitud.motivoSolicitud!.isNotEmpty)
          'Motivo': solicitud.motivoSolicitud!,
        'Estado': solicitud.estado.displayText,
      },
    );

    if (confirmed == true && context.mounted) {
      debugPrint('🗑️ Eliminando intercambio: ${solicitud.nombrePersonalSolicitante} -> ${solicitud.nombrePersonalDestino} (${solicitud.id})');

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
              message: 'Eliminando intercambio...',
              color: AppColors.emergency,
              icon: Icons.delete_forever,
            );
          },
        ),
      );

      if (context.mounted) {
        // TODO(dev): Implementar evento de eliminación en el BLoC
        // Por ahora, usar IntercambioCancelarRequested para cancelar la solicitud
        context.read<IntercambiosBloc>().add(
          const IntercambioCancelarRequested(''),
        );
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
        hintText: 'Buscar solicitud...',
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
          message: 'Cargando solicitudes...',
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
            'Error al cargar solicitudes',
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
