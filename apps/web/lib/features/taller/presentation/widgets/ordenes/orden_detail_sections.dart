import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/features/taller/presentation/widgets/ordenes/orden_ui_helpers.dart';
import 'package:flutter/material.dart';

/// Cabecera del detalle: nº orden, estado, prioridad y botón cerrar
class OrdenDetailHeader extends StatelessWidget {
  const OrdenDetailHeader({required this.orden, super.key});

  final OrdenReparacionEntity orden;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(AppSizes.paddingMedium),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
          ),
          child: const Icon(Icons.build, color: AppColors.primary, size: 24),
        ),
        const SizedBox(width: AppSizes.spacingMedium),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Orden ${orden.numeroOrden}',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.gray900),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: AppSizes.spacingSmall,
                children: <Widget>[
                  OrdenColorBadge(label: orden.estado.displayName, color: estadoOrdenColor(orden.estado)),
                  OrdenColorBadge(
                    label: 'Prioridad ${orden.prioridad.displayName}',
                    color: prioridadOrdenColor(orden.prioridad),
                  ),
                ],
              ),
            ],
          ),
        ),
        IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.of(context).pop()),
      ],
    );
  }
}

/// Título de sección del detalle
class OrdenSectionTitle extends StatelessWidget {
  const OrdenSectionTitle({required this.title, this.trailing, super.key});

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.spacingSmall),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              title.toUpperCase(),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
                color: AppColors.gray500,
              ),
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

/// Par etiqueta/valor
class _InfoItem extends StatelessWidget {
  const _InfoItem({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(label, style: const TextStyle(fontSize: 12, color: AppColors.gray500)),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.gray900),
          ),
        ],
      ),
    );
  }
}

/// Datos generales de la orden
class OrdenDatosSection extends StatelessWidget {
  const OrdenDatosSection({required this.orden, super.key});

  final OrdenReparacionEntity orden;

  @override
  Widget build(BuildContext context) {
    final String km = orden.kilometrajeEntrada == null
        ? '-'
        : '${orden.kilometrajeEntrada} → ${orden.kilometrajeSalida?.toString() ?? '...'}';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const OrdenSectionTitle(title: 'Datos de la orden'),
        Wrap(
          runSpacing: AppSizes.spacingMedium,
          children: <Widget>[
            _InfoItem(label: 'Vehículo', value: orden.vehiculoMatricula ?? '-'),
            _InfoItem(label: 'Taller', value: orden.tallerNombre ?? '-'),
            _InfoItem(label: 'Origen', value: orden.origen.displayName),
            _InfoItem(label: 'Mecánico', value: orden.mecanicoNombre ?? '-'),
            _InfoItem(label: 'Kilometraje', value: km),
            _InfoItem(label: 'Entrada', value: formatFecha(orden.fechaEntrada)),
            _InfoItem(label: 'Inicio trabajo', value: formatFechaHora(orden.fechaInicioTrabajo)),
            _InfoItem(label: 'Finalización', value: formatFechaHora(orden.fechaFinalizacion)),
            _InfoItem(label: 'Cierre', value: formatFechaHora(orden.fechaCierre)),
            _InfoItem(label: 'Garantía', value: orden.garantiaMeses == null ? '-' : '${orden.garantiaMeses} meses'),
          ],
        ),
        if (orden.diagnostico != null) ...<Widget>[
          const SizedBox(height: AppSizes.spacingMedium),
          _InfoItem(label: 'Diagnóstico', value: orden.diagnostico!),
        ],
        if (orden.trabajosRealizados != null) ...<Widget>[
          const SizedBox(height: AppSizes.spacingMedium),
          _InfoItem(label: 'Trabajos realizados', value: orden.trabajosRealizados!),
        ],
      ],
    );
  }
}

/// Resumen de costes de la orden
class OrdenCostesSection extends StatelessWidget {
  const OrdenCostesSection({required this.orden, super.key});

  final OrdenReparacionEntity orden;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingMedium),
      decoration: BoxDecoration(
        color: AppColors.gray50,
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: _InfoItem(label: 'Mano de obra', value: formatEuros(orden.costoManoObra)),
          ),
          Expanded(
            child: _InfoItem(label: 'Repuestos', value: formatEuros(orden.costoRepuestos)),
          ),
          Expanded(
            child: _InfoItem(label: 'Grúa', value: formatEuros(orden.costoGrua)),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text('TOTAL', style: TextStyle(fontSize: 12, color: AppColors.gray500)),
                Text(
                  formatEuros(orden.costoTotal),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.primary),
                ),
                if (orden.cubiertoSeguro)
                  const Text('Cubierto por seguro', style: TextStyle(fontSize: 11, color: AppColors.success)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Botones de transición de estado disponibles
class OrdenEstadoActions extends StatelessWidget {
  const OrdenEstadoActions({required this.estado, required this.onCambiar, super.key});

  final EstadoOrdenReparacion estado;
  final ValueChanged<EstadoOrdenReparacion> onCambiar;

  @override
  Widget build(BuildContext context) {
    final List<EstadoOrdenReparacion> destinos = transicionesPermitidas(estado);
    if (destinos.isEmpty) {
      return const SizedBox.shrink();
    }
    return Wrap(
      spacing: AppSizes.spacingSmall,
      runSpacing: AppSizes.spacingSmall,
      children: destinos.map((EstadoOrdenReparacion destino) {
        final Color color = estadoOrdenColor(destino);
        return OutlinedButton.icon(
          onPressed: () => onCambiar(destino),
          icon: Icon(Icons.arrow_forward, size: 18, color: color),
          label: Text(destino.displayName, style: TextStyle(color: color)),
          style: OutlinedButton.styleFrom(side: BorderSide(color: color.withValues(alpha: 0.5))),
        );
      }).toList(),
    );
  }
}
