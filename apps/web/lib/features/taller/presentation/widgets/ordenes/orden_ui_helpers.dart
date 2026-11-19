import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

final DateFormat _fechaFormat = DateFormat('dd/MM/yyyy');
final DateFormat _fechaHoraFormat = DateFormat('dd/MM/yyyy HH:mm');
final NumberFormat _euroFormat = NumberFormat.currency(locale: 'es_ES', symbol: '€', decimalDigits: 2);

/// Fecha corta dd/MM/yyyy (en hora local) o '-'
String formatFecha(DateTime? fecha) => fecha == null ? '-' : _fechaFormat.format(fecha.toLocal());

/// Fecha y hora dd/MM/yyyy HH:mm (en hora local) o '-'
String formatFechaHora(DateTime? fecha) => fecha == null ? '-' : _fechaHoraFormat.format(fecha.toLocal());

/// Importe en euros con 2 decimales
String formatEuros(double importe) => _euroFormat.format(importe);

/// Color asociado al estado de la orden
Color estadoOrdenColor(EstadoOrdenReparacion estado) {
  switch (estado) {
    case EstadoOrdenReparacion.abierta:
      return AppColors.info;
    case EstadoOrdenReparacion.enProceso:
      return AppColors.primary;
    case EstadoOrdenReparacion.esperandoRepuestos:
      return AppColors.warning;
    case EstadoOrdenReparacion.finalizada:
      return AppColors.success;
    case EstadoOrdenReparacion.cerrada:
      return AppColors.secondaryDark;
    case EstadoOrdenReparacion.anulada:
      return AppColors.inactive;
  }
}

/// Color asociado a la prioridad de la orden
Color prioridadOrdenColor(PrioridadOrdenReparacion prioridad) {
  switch (prioridad) {
    case PrioridadOrdenReparacion.baja:
      return AppColors.lowPriority;
    case PrioridadOrdenReparacion.normal:
      return AppColors.info;
    case PrioridadOrdenReparacion.alta:
      return AppColors.highPriority;
    case PrioridadOrdenReparacion.urgente:
      return AppColors.emergency;
  }
}

/// Color asociado al estado de un repuesto
Color estadoRepuestoColor(EstadoRepuesto estado) {
  switch (estado) {
    case EstadoRepuesto.solicitado:
      return AppColors.inactive;
    case EstadoRepuesto.pedido:
      return AppColors.warning;
    case EstadoRepuesto.recibido:
      return AppColors.info;
    case EstadoRepuesto.instalado:
      return AppColors.success;
  }
}

/// Transiciones de estado permitidas desde el estado actual
List<EstadoOrdenReparacion> transicionesPermitidas(EstadoOrdenReparacion actual) {
  switch (actual) {
    case EstadoOrdenReparacion.abierta:
      return <EstadoOrdenReparacion>[EstadoOrdenReparacion.enProceso, EstadoOrdenReparacion.anulada];
    case EstadoOrdenReparacion.enProceso:
      return <EstadoOrdenReparacion>[EstadoOrdenReparacion.esperandoRepuestos, EstadoOrdenReparacion.finalizada];
    case EstadoOrdenReparacion.esperandoRepuestos:
      return <EstadoOrdenReparacion>[EstadoOrdenReparacion.enProceso];
    case EstadoOrdenReparacion.finalizada:
      return <EstadoOrdenReparacion>[EstadoOrdenReparacion.cerrada];
    case EstadoOrdenReparacion.cerrada:
    case EstadoOrdenReparacion.anulada:
      return <EstadoOrdenReparacion>[];
  }
}

/// La orden ya no admite cambios (cerrada o anulada)
bool ordenBloqueada(EstadoOrdenReparacion estado) =>
    estado == EstadoOrdenReparacion.cerrada || estado == EstadoOrdenReparacion.anulada;

/// Badge de color ajustado al ancho del texto
class OrdenColorBadge extends StatelessWidget {
  const OrdenColorBadge({required this.label, required this.color, super.key});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: IntrinsicWidth(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Text(
            label,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color),
          ),
        ),
      ),
    );
  }
}
