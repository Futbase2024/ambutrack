import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/dialogs/confirmation_dialog.dart';
import 'package:ambutrack_web/core/widgets/dialogs/result_dialog.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/taller/presentation/bloc/orden_reparacion_bloc.dart';
import 'package:ambutrack_web/features/taller/presentation/bloc/orden_reparacion_event.dart';
import 'package:ambutrack_web/features/taller/presentation/bloc/repuesto_orden_bloc.dart';
import 'package:ambutrack_web/features/taller/presentation/bloc/repuesto_orden_event.dart';
import 'package:ambutrack_web/features/taller/presentation/bloc/repuesto_orden_state.dart';
import 'package:ambutrack_web/features/taller/presentation/widgets/ordenes/orden_ui_helpers.dart';
import 'package:ambutrack_web/features/taller/presentation/widgets/ordenes/repuesto_form_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Pestaña "Repuestos" de la ficha de la orden (con su propio RepuestoOrdenBloc)
class OrdenRepuestosTab extends StatelessWidget {
  const OrdenRepuestosTab({required this.orden, super.key});

  final OrdenReparacionEntity orden;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<RepuestoOrdenBloc>(
      key: ValueKey<String>('repuestos_${orden.id}'),
      create: (BuildContext _) =>
          getIt<RepuestoOrdenBloc>()..add(RepuestoOrdenLoadRequested(ordenId: orden.id)),
      child: BlocListener<RepuestoOrdenBloc, RepuestoOrdenState>(
        listener: _onRepuestoResult,
        child: _RepuestosBody(ordenId: orden.id, readOnly: ordenBloqueada(orden.estado)),
      ),
    );
  }

  Future<void> _onRepuestoResult(BuildContext context, RepuestoOrdenState state) async {
    if (state is RepuestoOrdenOperationSuccess) {
      // El trigger recalcula costo_repuestos: refrescamos las órdenes sin parpadeo
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
}

class _RepuestosBody extends StatelessWidget {
  const _RepuestosBody({required this.ordenId, required this.readOnly});

  final String ordenId;
  final bool readOnly;

  Future<void> _openForm(BuildContext context, [RepuestoOrdenEntity? repuesto]) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext _) => BlocProvider<RepuestoOrdenBloc>.value(
        value: context.read<RepuestoOrdenBloc>(),
        child: RepuestoFormDialog(ordenId: ordenId, repuesto: repuesto),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, RepuestoOrdenEntity repuesto) async {
    final bool? confirmed = await showSimpleConfirmationDialog(
      context: context,
      title: 'Eliminar repuesto',
      message: '¿Seguro que deseas eliminar "${repuesto.descripcion}" de la orden?\n\n'
          'Esta acción no se puede deshacer.',
      confirmText: 'Eliminar',
      icon: Icons.delete_outline,
    );
    if (confirmed == true && context.mounted) {
      context.read<RepuestoOrdenBloc>().add(RepuestoOrdenDeleteRequested(repuesto: repuesto));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RepuestoOrdenBloc, RepuestoOrdenState>(
      builder: (BuildContext context, RepuestoOrdenState state) {
        if (state is RepuestoOrdenError) {
          return GestionDetailBody(
            children: <Widget>[
              Text(state.message, style: const TextStyle(fontSize: 12.5, color: AppColors.error)),
            ],
          );
        }
        if (state is! RepuestoOrdenLoaded) {
          return const Center(
            child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
          );
        }
        final List<RepuestoOrdenEntity> repuestos = state.repuestos;
        final double total = repuestos.fold<double>(
          0,
          (double sum, RepuestoOrdenEntity r) => sum + r.precioTotal,
        );
        return GestionDetailBody(
          children: <Widget>[
            if (!readOnly)
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () => _openForm(context),
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Añadir repuesto'),
                ),
              ),
            const GestionDetailSection(title: 'Resumen'),
            GestionDetailField(label: 'Líneas', value: '${repuestos.length}'),
            GestionDetailField(label: 'Importe', value: GestionFormatters.moneda(total)),
            const GestionDetailSection(title: 'Repuestos'),
            if (repuestos.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'Sin repuestos registrados',
                  style: TextStyle(fontSize: 12.5, color: AppColors.gray500),
                ),
              )
            else
              ...repuestos.map(
                (RepuestoOrdenEntity r) => _RepuestoRow(
                  repuesto: r,
                  readOnly: readOnly,
                  onEdit: () => _openForm(context, r),
                  onDelete: () => _confirmDelete(context, r),
                ),
              ),
          ],
        );
      },
    );
  }
}

/// Línea compacta de repuesto: descripción, detalle, estado, importe y acciones
class _RepuestoRow extends StatelessWidget {
  const _RepuestoRow({
    required this.repuesto,
    required this.readOnly,
    required this.onEdit,
    required this.onDelete,
  });

  final RepuestoOrdenEntity repuesto;
  final bool readOnly;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final String detalle = <String>[
      if (repuesto.referencia != null) repuesto.referencia!,
      if (repuesto.proveedorNombre != null) repuesto.proveedorNombre!,
      '${repuesto.cantidad} × ${GestionFormatters.moneda(repuesto.precioUnitario)}',
    ].join(' · ');
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.gray100)),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  repuesto.descripcion,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.gray800),
                ),
                Text(
                  detalle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 11.5, color: AppColors.gray500),
                ),
                const SizedBox(height: 2),
                GestionDotLabel(
                  label: repuesto.estado.displayName,
                  color: estadoRepuestoColor(repuesto.estado),
                  fontSize: 11.5,
                ),
              ],
            ),
          ),
          Text(
            GestionFormatters.moneda(repuesto.precioTotal),
            style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.gray800),
          ),
          if (!readOnly) _RepuestoRowActions(onEdit: onEdit, onDelete: onDelete),
        ],
      ),
    );
  }
}

class _RepuestoRowActions extends StatelessWidget {
  const _RepuestoRowActions({required this.onEdit, required this.onDelete});

  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        IconButton(
          onPressed: onEdit,
          tooltip: 'Editar',
          visualDensity: VisualDensity.compact,
          icon: const Icon(Icons.edit_outlined, size: 16, color: AppColors.secondaryLight),
        ),
        IconButton(
          onPressed: onDelete,
          tooltip: 'Eliminar',
          visualDensity: VisualDensity.compact,
          icon: const Icon(Icons.delete_outline, size: 16, color: AppColors.error),
        ),
      ],
    );
  }
}
