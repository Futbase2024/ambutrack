import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/taller/presentation/bloc/control_repuestos_state.dart';
import 'package:ambutrack_web/features/taller/presentation/widgets/consulta/taller_consulta_common.dart';
import 'package:ambutrack_web/features/taller/presentation/widgets/gestion/taller_gestion_common.dart';
import 'package:ambutrack_web/features/taller/presentation/widgets/ordenes/orden_ui_helpers.dart';
import 'package:flutter/material.dart';

/// Ficha lateral (solo lectura) del repuesto seleccionado y su orden
class ControlRepuestosDetailPanel extends StatelessWidget {
  const ControlRepuestosDetailPanel({required this.item, required this.onVerOrdenes, super.key});

  final RepuestoControlItem? item;
  final VoidCallback onVerOrdenes;

  @override
  Widget build(BuildContext context) {
    final RepuestoControlItem? i = item;
    if (i == null) {
      return const GestionDetailEmpty(message: 'Selecciona un repuesto para ver su ficha');
    }
    return GestionDetailPanel(
      key: ValueKey<String>(i.id),
      title: i.repuesto.descripcion,
      badges: <Widget>[
        GestionDotLabel(label: i.repuesto.estado.displayName, color: estadoRepuestoColor(i.repuesto.estado)),
        if (i.orden != null)
          GestionDotLabel(label: 'Orden ${i.orden!.estado.displayName}', color: estadoOrdenColor(i.orden!.estado)),
      ],
      tabs: <GestionDetailTab>[
        GestionDetailTab(label: 'Repuesto', child: _RepuestoTab(repuesto: i.repuesto)),
        GestionDetailTab(label: 'Orden', child: _OrdenTab(orden: i.orden)),
      ],
      actions: <Widget>[
        TallerDetailNavButton(
          label: 'Ver en órdenes de reparación',
          tooltip: 'Abrir la pantalla de órdenes de reparación',
          onPressed: onVerOrdenes,
        ),
      ],
    );
  }
}

class _RepuestoTab extends StatelessWidget {
  const _RepuestoTab({required this.repuesto});

  final RepuestoOrdenEntity repuesto;

  @override
  Widget build(BuildContext context) {
    final RepuestoOrdenEntity r = repuesto;
    return GestionDetailBody(
      children: <Widget>[
        const GestionDetailSection(title: 'Datos del repuesto'),
        GestionDetailField(label: 'Descripción', value: r.descripcion),
        GestionDetailField(label: 'Referencia', value: r.referencia),
        GestionDetailField(label: 'Proveedor', value: r.proveedorNombre),
        const GestionDetailSection(title: 'Importe'),
        GestionDetailField(label: 'Cantidad', value: '${r.cantidad}'),
        GestionDetailField(label: 'P. unitario', value: GestionFormatters.moneda(r.precioUnitario)),
        GestionDetailField(
          label: 'Total',
          child: Text(
            GestionFormatters.moneda(r.precioTotal),
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.primary),
          ),
        ),
        const GestionDetailSection(title: 'Seguimiento'),
        GestionDetailField(label: 'Alta', value: GestionFormatters.fecha(r.createdAt)),
        GestionDetailField(
          label: 'Pedido',
          value: r.fechaPedido == null ? null : GestionFormatters.fecha(r.fechaPedido),
        ),
        GestionDetailField(
          label: 'Recibido',
          value: r.fechaRecibido == null ? null : GestionFormatters.fecha(r.fechaRecibido),
        ),
        const GestionDetailSection(title: 'Observaciones'),
        TallerDetailText(r.observaciones),
      ],
    );
  }
}

class _OrdenTab extends StatelessWidget {
  const _OrdenTab({required this.orden});

  final OrdenReparacionEntity? orden;

  @override
  Widget build(BuildContext context) {
    final OrdenReparacionEntity? o = orden;
    if (o == null) {
      return const GestionDetailEmpty(message: 'No se encontró la orden asociada');
    }
    return GestionDetailBody(
      children: <Widget>[
        const GestionDetailSection(title: 'Orden de reparación'),
        GestionDetailField(label: 'Nº orden', value: o.numeroOrden),
        GestionDetailField(
          label: 'Estado',
          child: Align(
            alignment: Alignment.centerLeft,
            child: GestionDotLabel(label: o.estado.displayName, color: estadoOrdenColor(o.estado)),
          ),
        ),
        GestionDetailField(label: 'Vehículo', value: o.vehiculoMatricula),
        GestionDetailField(label: 'Taller', value: o.tallerNombre),
        GestionDetailField(label: 'Origen', value: o.origen.displayName),
        GestionDetailField(label: 'Prioridad', value: o.prioridad.displayName),
        GestionDetailField(label: 'Entrada', value: GestionFormatters.fecha(o.fechaEntrada)),
        GestionDetailField(label: 'Coste repuestos', value: GestionFormatters.moneda(o.costoRepuestos)),
        GestionDetailField(label: 'Coste total', value: GestionFormatters.moneda(o.costoTotal)),
        const GestionDetailSection(title: 'Diagnóstico'),
        TallerDetailText(o.diagnostico),
      ],
    );
  }
}
