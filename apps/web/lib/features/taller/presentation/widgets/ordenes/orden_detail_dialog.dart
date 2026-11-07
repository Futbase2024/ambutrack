import 'dart:async';

import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/core/widgets/dialogs/confirmation_dialog.dart';
import 'package:ambutrack_web/core/widgets/dialogs/result_dialog.dart';
import 'package:ambutrack_web/core/widgets/loading/app_loading_indicator.dart';
import 'package:ambutrack_web/features/taller/presentation/bloc/orden_reparacion_bloc.dart';
import 'package:ambutrack_web/features/taller/presentation/bloc/orden_reparacion_event.dart';
import 'package:ambutrack_web/features/taller/presentation/bloc/orden_reparacion_state.dart';
import 'package:ambutrack_web/features/taller/presentation/bloc/repuesto_orden_bloc.dart';
import 'package:ambutrack_web/features/taller/presentation/bloc/repuesto_orden_state.dart';
import 'package:ambutrack_web/features/taller/presentation/widgets/ordenes/orden_detail_sections.dart';
import 'package:ambutrack_web/features/taller/presentation/widgets/ordenes/orden_repuestos_section.dart';
import 'package:ambutrack_web/features/taller/presentation/widgets/ordenes/orden_ui_helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Detalle de una orden: datos, cambio de estado, costes y repuestos.
/// Requiere OrdenReparacionBloc y RepuestoOrdenBloc en el contexto.
class OrdenDetailDialog extends StatefulWidget {
  const OrdenDetailDialog({required this.orden, super.key});

  final OrdenReparacionEntity orden;

  @override
  State<OrdenDetailDialog> createState() => _OrdenDetailDialogState();
}

class _OrdenDetailDialogState extends State<OrdenDetailDialog> {
  bool _cambiandoEstado = false;

  Future<void> _onCambiarEstado(EstadoOrdenReparacion destino) async {
    final bool requiereConfirmacion =
        destino == EstadoOrdenReparacion.anulada || destino == EstadoOrdenReparacion.cerrada;
    if (requiereConfirmacion) {
      final bool anular = destino == EstadoOrdenReparacion.anulada;
      final bool? ok = await showSimpleConfirmationDialog(
        context: context,
        title: anular ? 'Anular orden' : 'Cerrar orden',
        message: anular
            ? '¿Seguro que deseas anular esta orden?\n\nNo podrá modificarse después.'
            : '¿Seguro que deseas cerrar esta orden?\n\nLos repuestos y datos quedarán bloqueados.',
        confirmText: anular ? 'Anular' : 'Cerrar orden',
        icon: anular ? Icons.block : Icons.lock_outline,
        iconColor: anular ? AppColors.error : AppColors.secondaryDark,
        confirmButtonColor: anular ? AppColors.error : AppColors.secondaryDark,
      );
      if (ok != true || !mounted) {
        return;
      }
    }
    setState(() => _cambiandoEstado = true);
    unawaited(
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext _) =>
            const AppLoadingOverlay(message: 'Actualizando estado...', color: AppColors.secondary, icon: Icons.sync),
      ),
    );
    context.read<OrdenReparacionBloc>().add(OrdenReparacionEstadoChangeRequested(id: widget.orden.id, estado: destino));
  }

  Future<void> _onOrdenResult(BuildContext context, OrdenReparacionState state) async {
    final bool esResultado =
        (state is OrdenReparacionOperationSuccess && state.operacion == OrdenOperacion.cambiarEstado) ||
        (state is OrdenReparacionOperationFailure && state.operacion == OrdenOperacion.cambiarEstado);
    if (!_cambiandoEstado || !esResultado) {
      return;
    }
    setState(() => _cambiandoEstado = false);
    Navigator.of(context).pop(); // Cierra el overlay de carga
    if (state is OrdenReparacionOperationFailure) {
      await showResultDialog(
        context: context,
        title: 'Error al cambiar estado',
        message: 'No se pudo actualizar el estado de la orden.',
        type: ResultType.error,
        details: state.message,
      );
    }
  }

  Future<void> _onRepuestoResult(BuildContext context, RepuestoOrdenState state) async {
    if (state is RepuestoOrdenOperationSuccess) {
      // El trigger recalcula costo_repuestos: refrescamos la orden sin parpadeo
      context.read<OrdenReparacionBloc>().add(const OrdenReparacionLoadRequested(silent: true));
    } else if (state is RepuestoOrdenOperationFailure && state.operacion == RepuestoOperacion.eliminar) {
      await showResultDialog(
        context: context,
        title: 'Error al eliminar',
        message: 'No se pudo eliminar el repuesto.',
        type: ResultType.error,
        details: state.message,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: <BlocListener<dynamic, dynamic>>[
        BlocListener<OrdenReparacionBloc, OrdenReparacionState>(listener: _onOrdenResult),
        BlocListener<RepuestoOrdenBloc, RepuestoOrdenState>(listener: _onRepuestoResult),
      ],
      child: BlocBuilder<OrdenReparacionBloc, OrdenReparacionState>(
        builder: (BuildContext context, OrdenReparacionState state) {
          final OrdenReparacionEntity orden =
              (state is OrdenReparacionLoaded ? state.byId(widget.orden.id) : null) ?? widget.orden;
          return _OrdenDetailContent(orden: orden, onCambiarEstado: _onCambiarEstado);
        },
      ),
    );
  }
}

class _OrdenDetailContent extends StatelessWidget {
  const _OrdenDetailContent({required this.orden, required this.onCambiarEstado});

  final OrdenReparacionEntity orden;
  final ValueChanged<EstadoOrdenReparacion> onCambiarEstado;

  static const SizedBox _gap = SizedBox(height: AppSizes.spacingLarge);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusLarge)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900, maxHeight: 780),
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.paddingXl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                OrdenDetailHeader(orden: orden),
                const SizedBox(height: AppSizes.spacingMedium),
                OrdenEstadoActions(estado: orden.estado, onCambiar: onCambiarEstado),
                const Divider(height: AppSizes.spacingXl),
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        OrdenDatosSection(orden: orden),
                        _gap,
                        const OrdenSectionTitle(title: 'Costes'),
                        OrdenCostesSection(orden: orden),
                        _gap,
                        OrdenRepuestosSection(ordenId: orden.id, readOnly: ordenBloqueada(orden.estado)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
