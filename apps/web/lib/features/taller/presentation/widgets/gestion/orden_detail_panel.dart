import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/taller/presentation/widgets/gestion/orden_repuestos_tab.dart';
import 'package:ambutrack_web/features/taller/presentation/widgets/gestion/taller_gestion_common.dart';
import 'package:ambutrack_web/features/taller/presentation/widgets/ordenes/orden_detail_sections.dart';
import 'package:ambutrack_web/features/taller/presentation/widgets/ordenes/orden_ui_helpers.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

final DateFormat _fechaHora = DateFormat('dd/MM/yyyy HH:mm');

String? _fh(DateTime? value) => value == null ? null : _fechaHora.format(value.toLocal());

/// Ficha lateral de la orden seleccionada: datos, costes y repuestos
class OrdenDetailPanel extends StatelessWidget {
  const OrdenDetailPanel({
    required this.orden,
    required this.onEdit,
    required this.onDelete,
    required this.onCambiarEstado,
    required this.onVerDetalle,
    super.key,
  });

  final OrdenReparacionEntity? orden;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final ValueChanged<EstadoOrdenReparacion> onCambiarEstado;
  final VoidCallback onVerDetalle;

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
        GestionDotLabel(
          label: 'Prioridad ${o.prioridad.displayName}',
          color: prioridadOrdenColor(o.prioridad),
        ),
      ],
      tabs: <GestionDetailTab>[
        GestionDetailTab(
          label: 'General',
          child: _OrdenGeneralTab(orden: o, onCambiarEstado: onCambiarEstado),
        ),
        GestionDetailTab(label: 'Costes', child: _OrdenCostesTab(orden: o)),
        GestionDetailTab(label: 'Repuestos', child: OrdenRepuestosTab(orden: o)),
      ],
      actions: <Widget>[
        TallerDetailEditButton(onPressed: onEdit),
        TallerDetailDeleteButton(onPressed: onDelete),
        Tooltip(
          message: 'Abrir el detalle completo de la orden',
          child: OutlinedButton.icon(
            onPressed: onVerDetalle,
            icon: const Icon(Icons.open_in_new, size: 16),
            label: const Text('Detalle'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.gray700,
              minimumSize: const Size(0, 34),
              textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }
}

class _OrdenGeneralTab extends StatelessWidget {
  const _OrdenGeneralTab({required this.orden, required this.onCambiarEstado});

  final OrdenReparacionEntity orden;
  final ValueChanged<EstadoOrdenReparacion> onCambiarEstado;

  @override
  Widget build(BuildContext context) {
    final OrdenReparacionEntity o = orden;
    final bool hayTransiciones = transicionesPermitidas(o.estado).isNotEmpty;
    return GestionDetailBody(
      children: <Widget>[
        if (hayTransiciones) ...<Widget>[
          const GestionDetailSection(title: 'Cambiar estado'),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: OrdenEstadoActions(estado: o.estado, onCambiar: onCambiarEstado),
          ),
        ],
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
        GestionDetailField(label: 'Inicio trabajo', value: _fh(o.fechaInicioTrabajo)),
        GestionDetailField(label: 'Espera repuestos', value: _fh(o.fechaEsperaRepuestos)),
        GestionDetailField(label: 'Finalización', value: _fh(o.fechaFinalizacion)),
        GestionDetailField(label: 'Cierre', value: _fh(o.fechaCierre)),
        const GestionDetailSection(title: 'Garantía'),
        GestionDetailField(
          label: 'Meses',
          value: o.garantiaMeses == null ? null : '${o.garantiaMeses} meses',
        ),
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
        const GestionDetailSection(title: 'Registro'),
        GestionDetailField(label: 'Alta', value: GestionFormatters.fecha(o.createdAt)),
        GestionDetailField(
          label: 'Modificado',
          value: o.updatedAt == null ? null : GestionFormatters.fecha(o.updatedAt),
        ),
      ],
    );
  }
}

class _OrdenCostesTab extends StatelessWidget {
  const _OrdenCostesTab({required this.orden});

  final OrdenReparacionEntity orden;

  @override
  Widget build(BuildContext context) {
    final OrdenReparacionEntity o = orden;
    return GestionDetailBody(
      children: <Widget>[
        const GestionDetailSection(title: 'Mano de obra'),
        GestionDetailField(label: 'Horas', value: _horas(o.manoObraHoras)),
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

  String _horas(double horas) {
    final String texto = horas == horas.roundToDouble()
        ? horas.toStringAsFixed(0)
        : horas.toStringAsFixed(2).replaceAll('.', ',');
    return '$texto h';
  }
}
