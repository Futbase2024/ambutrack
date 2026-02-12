import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/dialogs/confirmation_dialog.dart';
import 'package:ambutrack_web/core/widgets/loading/app_loading_indicator.dart';
import 'package:ambutrack_web/features/vehiculos/presentation/bloc/incidencia_vehiculo/incidencia_vehiculo_bloc.dart';
import 'package:ambutrack_web/features/vehiculos/presentation/bloc/incidencia_vehiculo/incidencia_vehiculo_event.dart';
import 'package:ambutrack_web/features/vehiculos/presentation/bloc/incidencia_vehiculo/incidencia_vehiculo_state.dart';
import 'package:ambutrack_web/features/vehiculos/presentation/widgets/incidencias/incidencia_data_table.dart';
import 'package:ambutrack_web/features/vehiculos/presentation/widgets/incidencias/incidencia_filters.dart';
import 'package:ambutrack_web/features/vehiculos/presentation/widgets/incidencias/incidencia_form_modal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

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
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: _buildHeader(context),
            ),
            Expanded(
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
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: <Color>[AppColors.emergency, AppColors.averia],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.emergency.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.error, color: Colors.white, size: 40),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Historial de Averías',
                  style: GoogleFonts.inter(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Registro y seguimiento de averías y reparaciones',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton.icon(
            onPressed: () => _showFormModal(context),
            icon: const Icon(Icons.add),
            label: const Text('Reportar Avería'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.emergency,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
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
      children: <Widget>[
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
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
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
        ),
        _buildPagination(context, currentPage, totalPages),
      ],
    );
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
          Text(
            'Error al cargar incidencias',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.gray900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: GoogleFonts.inter(
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
              style: GoogleFonts.inter(
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
