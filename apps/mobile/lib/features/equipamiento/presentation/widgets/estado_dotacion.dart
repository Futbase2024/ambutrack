import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Estado de dotación de una línea (columna `estado_dotacion` de la vista)
enum EstadoDotacion {
  caducado('caducado', 'Caducado', AppColors.error, Icons.dangerous_rounded, 0),
  falta('falta', 'Falta', AppColors.error, Icons.remove_circle_rounded, 1),
  sinFecha('sin_fecha', 'Sin fecha', AppColors.warning, Icons.event_busy_rounded, 2),
  sinAdjunto('sin_adjunto', 'Pendiente oficina', AppColors.gray500, Icons.cloud_upload_outlined, 3),
  proximo('proximo', 'Caduca pronto', AppColors.warning, Icons.schedule_rounded, 4),
  ok('ok', 'OK', AppColors.success, Icons.check_circle_rounded, 5),
  noLleva('no_lleva', 'Opcional', AppColors.gray400, Icons.remove_circle_outline_rounded, 6),
  fueraPlantilla('fuera_plantilla', 'Fuera de plantilla', AppColors.gray500, Icons.help_outline_rounded, 7),
  excluido('excluido', 'No lo lleva', AppColors.gray500, Icons.block_rounded, 8);

  const EstadoDotacion(this.value, this.label, this.color, this.icon, this.prioridad);

  final String value;
  final String label;
  final Color color;
  final IconData icon;

  /// Menor = más urgente
  final int prioridad;

  /// Requiere que el técnico haga algo.
  /// "PDF en oficina" no: subir el documento lo hace la oficina desde la web.
  bool get requiereAtencion =>
      prioridad <= EstadoDotacion.proximo.prioridad && this != EstadoDotacion.sinAdjunto;

  /// Correcto para el técnico: OK, opcional que no lleva o solo falta el PDF de oficina
  bool get correcto =>
      this == EstadoDotacion.ok || this == EstadoDotacion.noLleva || this == EstadoDotacion.sinAdjunto;

  static EstadoDotacion of(StockVehiculoEntity l) {
    final EstadoDotacion estado = EstadoDotacion.values.firstWhere(
      (EstadoDotacion e) => e.value == l.estadoDotacion,
      orElse: () => l.cantidadActual > 0 ? EstadoDotacion.ok : EstadoDotacion.falta,
    );
    // En documentos, la fecha y el PDF los gestiona la oficina desde la web:
    // para el técnico solo cuenta si el papel está (SÍ) o no (NO).
    if (l.esDocumento && estado == EstadoDotacion.sinFecha) {
      return EstadoDotacion.sinAdjunto;
    }
    return estado;
  }
}

/// Sección visible (las líneas manuales van a "Extras")
String seccionDe(StockVehiculoEntity l) => l.seccion ?? 'Extras';

/// Badge compacto de estado ajustado al texto
class EstadoDotacionBadge extends StatelessWidget {
  const EstadoDotacionBadge({required this.estado, super.key});

  final EstadoDotacion estado;

  @override
  Widget build(BuildContext context) {
    return IntrinsicWidth(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: estado.color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          estado.label,
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: estado.color),
        ),
      ),
    );
  }
}
