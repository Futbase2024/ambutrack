import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/taller/presentation/widgets/consulta/orden_repuestos_readonly_tab.dart';
import 'package:ambutrack_web/features/taller/presentation/widgets/consulta/taller_consulta_common.dart';
import 'package:ambutrack_web/features/taller/presentation/widgets/gestion/taller_gestion_common.dart';
import 'package:ambutrack_web/features/taller/presentation/widgets/historial/historial_columns.dart';
import 'package:ambutrack_web/features/taller/presentation/widgets/ordenes/orden_ui_helpers.dart';
import 'package:flutter/material.dart';

/// Ficha lateral (solo lectura) de una orden del historial
class HistorialDetailPanel extends StatelessWidget {
  const HistorialDetailPanel({required this.orden, required this.onVerOrdenes, super.key});

  final OrdenReparacionEntity? orden;
  final VoidCallback onVerOrdenes;

  @override
  Widget build(BuildContext context) {
    final OrdenReparacionEntity? o = orden;
    if (o == null) {
      return const GestionDetailEmpty(message: 'Selecciona una orden para ver su ficha');
    }
    return GestionDetailPanel(
      key: ValueKey<String>(o.id),
      title: o.numeroOrden.isEmpty ? 'Orden sin número' : 'Orden ${o.numeroOrden}',
      badges: <Widget>[
        GestionDotLabel(label: o.estado.displayName, color: estadoOrdenColor(o.estado)),
        GestionDotLabel(label: o.origen.displayName, color: AppColors.info),
      ],
      tabs: <GestionDetailTab>[
        GestionDetailTab(label: 'General', child: _GeneralTab(orden: o)),
        GestionDetailTab(label: 'Costes', child: _CostesTab(orden: o)),
        GestionDetailTab(label: 'Repuestos', child: OrdenRepuestosReadonlyTab(ordenId: o.id)),
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

class _GeneralTab extends StatelessWidget {
  const _GeneralTab({required this.orden});

  final OrdenReparacionEntity orden;

  @override
  Widget build(BuildContext context) {
    final OrdenReparacionEntity o = orden;
    final int? dias = historialDiasTaller(o);
    return GestionDetailBody(
      children: <Widget>[
        const GestionDetailSection(title: 'Datos de la orden'),
        GestionDetailField(label: 'Vehículo', value: o.vehiculoMatricula),
        GestionDetailField(label: 'Taller', value: o.tallerNombre),
        GestionDetailField(label: 'Origen', value: o.origen.displayName),
        GestionDetailField(label: 'Prioridad', value: o.prioridad.displayName),
        GestionDetailField(label: 'Mecánico', value: o.mecanicoNombre),
        GestionDetailField(label: 'Km entrada', value: o.kilometrajeEntrada?.toString()),
        GestionDetailField(label: 'Km salida', value: o.kilometrajeSalida?.toString()),
        const GestionDetailSection(title: 'Fechas'),
        GestionDetailField(label: 'Entrada', value: GestionFormatters.fecha(o.fechaEntrada)),
        GestionDetailField(label: 'Finalización', value: formatFechaHora(o.fechaFinalizacion)),
        GestionDetailField(label: 'Cierre', value: formatFechaHora(o.fechaCierre)),
        GestionDetailField(label: 'Días en taller', value: dias == null ? null : '$dias días'),
        const GestionDetailSection(title: 'Garantía'),
        GestionDetailField(label: 'Meses', value: o.garantiaMeses == null ? null : '${o.garantiaMeses} meses'),
        GestionDetailField(
          label: 'Fin garantía',
          value: o.fechaFinGarantia == null ? null : GestionFormatters.fecha(o.fechaFinGarantia),
        ),
        const GestionDetailSection(title: 'Diagnóstico'),
        TallerDetailText(o.diagnostico),
        const GestionDetailSection(title: 'Trabajos realizados'),
        TallerDetailText(o.trabajosRealizados),
        const GestionDetailSection(title: 'Observaciones'),
        TallerDetailText(o.observaciones),
      ],
    );
  }
}

class _CostesTab extends StatelessWidget {
  const _CostesTab({required this.orden});

  final OrdenReparacionEntity orden;

  @override
  Widget build(BuildContext context) {
    final OrdenReparacionEntity o = orden;
    final double h = o.manoObraHoras;
    final String horas = h == h.roundToDouble() ? h.toStringAsFixed(0) : h.toStringAsFixed(2).replaceAll('.', ',');
    return GestionDetailBody(
      children: <Widget>[
        const GestionDetailSection(title: 'Mano de obra'),
        GestionDetailField(label: 'Horas', value: '$horas h'),
        GestionDetailField(label: 'Importe', value: GestionFormatters.moneda(o.costoManoObra)),
        const GestionDetailSection(title: 'Otros costes'),
        GestionDetailField(label: 'Repuestos', value: GestionFormatters.moneda(o.costoRepuestos)),
        GestionDetailField(label: 'Grúa', value: GestionFormatters.moneda(o.costoGrua)),
        const GestionDetailSection(title: 'Total'),
        GestionDetailField(
          label: 'Coste total',
          child: Text(
            GestionFormatters.moneda(o.costoTotal),
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.primary),
          ),
        ),
        GestionDetailField(
          label: 'Seguro',
          child: GestionDotLabel(
            label: o.cubiertoSeguro ? 'Cubierto por seguro' : 'No cubierto',
            color: o.cubiertoSeguro ? AppColors.success : AppColors.inactive,
          ),
        ),
      ],
    );
  }
}
