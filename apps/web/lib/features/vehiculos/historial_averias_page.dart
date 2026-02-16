import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/core/widgets/dialogs/confirmation_dialog.dart';
import 'package:ambutrack_web/core/widgets/headers/page_header.dart';
import 'package:ambutrack_web/core/widgets/loading/app_loading_indicator.dart';
import 'package:ambutrack_web/features/vehiculos/presentation/bloc/incidencia_vehiculo/incidencia_vehiculo_bloc.dart';
import 'package:ambutrack_web/features/vehiculos/presentation/bloc/incidencia_vehiculo/incidencia_vehiculo_event.dart';
import 'package:ambutrack_web/features/vehiculos/presentation/bloc/incidencia_vehiculo/incidencia_vehiculo_state.dart';
import 'package:ambutrack_web/features/vehiculos/presentation/widgets/incidencias/incidencia_data_table.dart';
import 'package:ambutrack_web/features/vehiculos/presentation/widgets/incidencias/incidencia_filters.dart';
import 'package:ambutrack_web/features/vehiculos/presentation/widgets/incidencias/incidencia_form_modal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Página de Historial de Averías
class HistorialAveriasPage extends StatelessWidget {
  const HistorialAveriasPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<IncidenciaVehiculoBloc>(
      create: (_) => getIt<IncidenciaVehiculoBloc>()
        ..add(const IncidenciaVehiculoEvent.started()),
      child: const _HistorialAveriasView(),
    );
  }
}

class _HistorialAveriasView extends StatelessWidget {
  const _HistorialAveriasView();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.backgroundLight,
        body: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSizes.paddingXl,
            AppSizes.paddingXl,
            AppSizes.paddingXl,
            AppSizes.paddingLarge,
          ),
          child: BlocBuilder<IncidenciaVehiculoBloc, IncidenciaVehiculoState>(
            builder: (BuildContext context, IncidenciaVehiculoState state) {
              return state.when(
                initial: () => const Center(
                  child: AppLoadingIndicator(
                    message: 'Cargando incidencias...',
                  ),
                ),
                loading: () => const Center(
                  child: AppLoadingIndicator(
                    message: 'Cargando incidencias...',
                  ),
                ),
                loaded: (
                  List<IncidenciaVehiculoEntity> incidencias,
                  int currentPage,
                  int totalPages,
                  EstadoIncidencia? filtroEstado,
                  PrioridadIncidencia? filtroPrioridad,
                  TipoIncidencia? filtroTipo,
                ) =>
                    _buildLoadedContent(
                  context: context,
                  incidencias: incidencias,
                  currentPage: currentPage,
                  totalPages: totalPages,
                  filtroEstado: filtroEstado,
                  filtroPrioridad: filtroPrioridad,
                  filtroTipo: filtroTipo,
                ),
                error: (String message) => _buildError(context, message),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildLoadedContent({
    required BuildContext context,
    required List<IncidenciaVehiculoEntity> incidencias,
    required int currentPage,
    required int totalPages,
    required EstadoIncidencia? filtroEstado,
    required PrioridadIncidencia? filtroPrioridad,
    required TipoIncidencia? filtroTipo,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        PageHeader(
          config: PageHeaderConfig(
            icon: Icons.report_problem,
            title: 'Historial de Averías',
            subtitle: 'Registro y seguimiento de averías y reparaciones',
            stats: _buildHeaderStats(incidencias),
            addButtonLabel: 'Reportar Avería',
            onAdd: () => _showFormModal(context),
          ),
        ),
        const SizedBox(height: AppSizes.spacingXl),
        IncidenciaFilters(
          filtroEstado: filtroEstado,
          filtroPrioridad: filtroPrioridad,
          filtroTipo: filtroTipo,
          onEstadoChanged: (EstadoIncidencia? estado) {
            context
                .read<IncidenciaVehiculoBloc>()
                .add(IncidenciaVehiculoEvent.filterByEstado(estado));
          },
          onPrioridadChanged: (PrioridadIncidencia? prioridad) {
            context
                .read<IncidenciaVehiculoBloc>()
                .add(IncidenciaVehiculoEvent.filterByPrioridad(prioridad));
          },
          onTipoChanged: (TipoIncidencia? tipo) {
            context
                .read<IncidenciaVehiculoBloc>()
                .add(IncidenciaVehiculoEvent.filterByTipo(tipo));
          },
          onClearFilters: () {
            context
                .read<IncidenciaVehiculoBloc>()
                .add(const IncidenciaVehiculoEvent.clearFilters());
          },
        ),
        const SizedBox(height: AppSizes.spacing),
        Expanded(
          child: IncidenciaDataTable(
            incidencias: incidencias,
            onView: (IncidenciaVehiculoEntity incidencia) {
              // Nota: Modal de detalle se implementará en el futuro
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Ver detalle: ${incidencia.titulo}'),
                ),
              );
            },
            onEdit: (IncidenciaVehiculoEntity incidencia) {
              _showFormModal(context, incidencia: incidencia);
            },
            onDelete: (IncidenciaVehiculoEntity incidencia) {
              _showDeleteConfirmation(context, incidencia);
            },
          ),
        ),
        _buildPagination(context, currentPage, totalPages),
      ],
    );
  }

  List<HeaderStat> _buildHeaderStats(List<IncidenciaVehiculoEntity> incidencias) {
    final int total = incidencias.length;
    final int pendientes = incidencias
        .where((IncidenciaVehiculoEntity i) =>
            i.estado == EstadoIncidencia.reportada ||
            i.estado == EstadoIncidencia.enRevision)
        .length;
    final int enProceso = incidencias
        .where((IncidenciaVehiculoEntity i) =>
            i.estado == EstadoIncidencia.enReparacion)
        .length;
    final int resueltas = incidencias
        .where((IncidenciaVehiculoEntity i) =>
            i.estado == EstadoIncidencia.resuelta ||
            i.estado == EstadoIncidencia.cerrada)
        .length;

    return <HeaderStat>[
      HeaderStat(
        value: '$total',
        icon: Icons.format_list_numbered,
        color: AppColors.primary,
      ),
      HeaderStat(
        value: '$pendientes',
        icon: Icons.pending,
        color: AppColors.warning,
      ),
      HeaderStat(
        value: '$enProceso',
        icon: Icons.build,
        color: AppColors.info,
      ),
      HeaderStat(
        value: '$resueltas',
        icon: Icons.check_circle,
        color: AppColors.success,
      ),
    ];
  }

  Widget _buildError(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Icon(
            Icons.error_outline,
            size: 64,
            color: AppColors.error,
          ),
          const SizedBox(height: 16),
          const Text(
            'Error al cargar incidencias',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.gray900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.gray600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              context
                  .read<IncidenciaVehiculoBloc>()
                  .add(const IncidenciaVehiculoEvent.loadIncidencias());
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  Widget _buildPagination(BuildContext context, int currentPage, int totalPages) {
    if (totalPages <= 1) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: AppColors.gray300),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          IconButton(
            onPressed: currentPage > 1
                ? () {
                    context.read<IncidenciaVehiculoBloc>().add(
                          IncidenciaVehiculoEvent.changePage(currentPage - 1),
                        );
                  }
                : null,
            icon: const Icon(Icons.chevron_left),
          ),
          const SizedBox(width: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Página $currentPage de $totalPages',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(width: 16),
          IconButton(
            onPressed: currentPage < totalPages
                ? () {
                    context.read<IncidenciaVehiculoBloc>().add(
                          IncidenciaVehiculoEvent.changePage(currentPage + 1),
                        );
                  }
                : null,
            icon: const Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }

  void _showFormModal(
    BuildContext context, {
    IncidenciaVehiculoEntity? incidencia,
  }) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return IncidenciaFormModal(
          incidencia: incidencia,
          onSave: (IncidenciaVehiculoEntity newIncidencia) async {
            if (incidencia == null) {
              context
                  .read<IncidenciaVehiculoBloc>()
                  .add(IncidenciaVehiculoEvent.createIncidencia(newIncidencia));
            } else {
              context
                  .read<IncidenciaVehiculoBloc>()
                  .add(IncidenciaVehiculoEvent.updateIncidencia(newIncidencia));
            }
          },
        );
      },
    );
  }

  Future<void> _showDeleteConfirmation(
    BuildContext context,
    IncidenciaVehiculoEntity incidencia,
  ) async {
    final bool? confirmed = await showSimpleConfirmationDialog(
      context: context,
      title: 'Eliminar incidencia',
      message:
          '¿Estás seguro de que deseas eliminar esta incidencia?\n\n${incidencia.titulo}\n\nEsta acción no se puede deshacer.',
      confirmText: 'Eliminar',
      icon: Icons.delete_outline,
    );

    if (confirmed == true && context.mounted) {
      context
          .read<IncidenciaVehiculoBloc>()
          .add(IncidenciaVehiculoEvent.deleteIncidencia(incidencia.id));
    }
  }
}
