import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/core/widgets/buttons/app_button.dart';
import 'package:ambutrack_web/core/widgets/dialogs/confirmation_dialog.dart';
import 'package:ambutrack_web/features/servicios/servicios/domain/entities/servicio_entity.dart';
import 'package:ambutrack_web/features/servicios/servicios/presentation/bloc/servicios_bloc.dart';
import 'package:ambutrack_web/features/servicios/servicios/presentation/bloc/servicios_event.dart';
import 'package:ambutrack_web/features/servicios/servicios/presentation/bloc/servicios_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

/// Toolbar con botones de acción para servicios
class ServiciosToolbar extends StatelessWidget {
  const ServiciosToolbar({
    required this.onNuevo,
    super.key,
  });

  final VoidCallback onNuevo;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ServiciosBloc, ServiciosState>(
      builder: (BuildContext context, ServiciosState state) {
        // Obtener servicio seleccionado desde el estado
        final ServicioEntity? selectedServicio = state.maybeWhen(
          loaded: (
            List<ServicioEntity> servicios,
            String searchQuery,
            int? yearFilter,
            String? estadoFilter,
            bool isRefreshing,
            ServicioEntity? selectedServicio,
            bool isLoadingDetails,
          ) =>
              selectedServicio,
          orElse: () => null,
        );

        final bool hasSelection = selectedServicio != null;
        final bool isActive = hasSelection && selectedServicio.estado == 'ACTIVO';
        final bool isEliminado = hasSelection && selectedServicio.estado == 'ELIMINADO';

        return Container(
          padding: const EdgeInsets.all(AppSizes.paddingMedium),
          decoration: BoxDecoration(
            color: AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
            border: Border.all(color: AppColors.gray200),
          ),
          child: Wrap(
            spacing: AppSizes.spacing,
            runSpacing: AppSizes.spacing,
            children: <Widget>[
              // NUEVO - Siempre habilitado
              AppButton(
                onPressed: onNuevo,
                label: 'NUEVO',
                icon: Icons.add,
              ),

              // EDITAR - Solo si hay selección y está activo o suspendido
              AppButton(
                onPressed: hasSelection
                    ? () => _handleEditar(context, selectedServicio)
                    : null,
                label: 'EDITAR',
                icon: Icons.edit,
              ),

              // ELIMINAR - Solo si hay selección y NO está eliminado
              AppButton(
                onPressed: hasSelection && !isEliminado
                    ? () => _handleEliminar(context, selectedServicio)
                    : null,
                label: 'ELIMINAR',
                icon: Icons.delete_outline,
              ),

              // FINALIZAR - Solo si está activo
              AppButton(
                onPressed: isActive
                    ? () => _handleFinalizar(context, selectedServicio)
                    : null,
                label: 'FINALIZAR',
                icon: Icons.done_all,
              ),

              // SUSPENDER - Solo si está activo
              AppButton(
                onPressed: isActive
                    ? () => _handleSuspender(context, selectedServicio)
                    : null,
                label: 'SUSPENDER',
                icon: Icons.pause_circle_outline,
              ),

              // EXCLUIR - Solo si hay selección y está activo
              AppButton(
                onPressed: isActive
                    ? () => _handleExcluir(context, selectedServicio)
                    : null,
                label: 'EXCLUIR',
                icon: Icons.block,
              ),
            ],
          ),
        );
      },
    );
  }

  /// Maneja la edición de un servicio
  void _handleEditar(BuildContext context, ServicioEntity servicio) {
    // TODO(dev): Implementar formulario de edición
    debugPrint('🖊️ Editar servicio: ${servicio.codigo}');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Funcionalidad de edición en desarrollo'),
        backgroundColor: AppColors.info,
      ),
    );
  }

  /// Maneja la eliminación permanente de un servicio
  Future<void> _handleEliminar(BuildContext context, ServicioEntity servicio) async {
    final bool? confirmed = await showConfirmationDialog(
      context: context,
      title: '⚠️ Confirmar Eliminación PERMANENTE',
      message:
          '¿Estás seguro de que deseas ELIMINAR PERMANENTEMENTE este servicio?\n\n'
          'Esta acción es IRREVERSIBLE y eliminará de la base de datos:\n'
          '• El servicio\n'
          '• El servicio recurrente (si existe)\n'
          '• TODOS los traslados asociados',
      itemDetails: <String, String>{
        if (servicio.codigo != null) 'Código': servicio.codigo!,
        if (servicio.tipoRecurrencia != null)
          'Tipo': servicio.tipoRecurrencia!,
        if (servicio.fechaServicioInicio != null)
          'Fecha Inicio':
              DateFormat('dd/MM/yyyy').format(servicio.fechaServicioInicio!),
        'Estado': servicio.estado.toUpperCase(),
      },
      warningMessage: '🚨 ESTA ACCIÓN NO SE PUEDE DESHACER - LOS DATOS SE BORRARÁN PARA SIEMPRE',
    );

    if (confirmed == true && context.mounted) {
      context.read<ServiciosBloc>().add(
            ServiciosEvent.deleteRequested(id: servicio.id!),
          );
    }
  }

  /// Maneja la finalización de un servicio
  Future<void> _handleFinalizar(BuildContext context, ServicioEntity servicio) async {
    final bool? confirmed = await showConfirmationDialog(
      context: context,
      title: 'Confirmar Finalización',
      message:
          '¿Deseas finalizar este servicio? El servicio se marcará como FINALIZADO y no se generarán más trayectos.',
      itemDetails: <String, String>{
        if (servicio.codigo != null) 'Código': servicio.codigo!,
        if (servicio.tipoRecurrencia != null)
          'Tipo': servicio.tipoRecurrencia!,
        if (servicio.fechaServicioInicio != null)
          'Fecha Inicio':
              DateFormat('dd/MM/yyyy').format(servicio.fechaServicioInicio!),
      },
    );

    if (confirmed == true && context.mounted) {
      context.read<ServiciosBloc>().add(
            ServiciosEvent.updateEstadoRequested(
              id: servicio.id!,
              estado: 'FINALIZADO',
            ),
          );
    }
  }

  /// Maneja la suspensión de un servicio
  Future<void> _handleSuspender(BuildContext context, ServicioEntity servicio) async {
    final bool? confirmed = await showConfirmationDialog(
      context: context,
      title: 'Confirmar Suspensión',
      message:
          '¿Deseas suspender este servicio? Los trayectos ya generados no se cancelarán, pero no se crearán nuevos trayectos.',
      itemDetails: <String, String>{
        if (servicio.codigo != null) 'Código': servicio.codigo!,
        if (servicio.tipoRecurrencia != null)
          'Tipo': servicio.tipoRecurrencia!,
        if (servicio.fechaServicioInicio != null)
          'Fecha Inicio':
              DateFormat('dd/MM/yyyy').format(servicio.fechaServicioInicio!),
      },
      confirmText: 'Suspender',
      confirmButtonColor: AppColors.warning,
      iconColor: AppColors.warning,
    );

    if (confirmed == true && context.mounted) {
      context.read<ServiciosBloc>().add(
            ServiciosEvent.updateEstadoRequested(
              id: servicio.id!,
              estado: 'SUSPENDIDO',
            ),
          );
    }
  }

  /// Maneja la exclusión de fechas de trayectos
  void _handleExcluir(BuildContext context, ServicioEntity servicio) {
    // TODO(dev): Implementar diálogo de exclusión de fechas
    debugPrint('🚫 Excluir trayectos: ${servicio.codigo}');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Funcionalidad de exclusión en desarrollo'),
        backgroundColor: AppColors.info,
      ),
    );
  }
}
