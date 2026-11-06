import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:flutter/material.dart';

/// Estado de dotación de una línea (columna `estado_dotacion` de la vista)
enum EstadoDotacion {
  caducado('caducado', 'Caducado', AppColors.error, 0),
  falta('falta', 'Falta', AppColors.error, 1),
  sinFecha('sin_fecha', 'Sin fecha', AppColors.warning, 2),
  sinAdjunto('sin_adjunto', 'Sin adjunto', AppColors.warning, 3),
  proximo('proximo', 'Caduca pronto', AppColors.warning, 4),
  ok('ok', 'OK', AppColors.success, 5),
  fueraPlantilla('fuera_plantilla', 'Fuera de plantilla', AppColors.gray500, 6),
  excluido('excluido', 'Excluido', AppColors.gray500, 7);

  const EstadoDotacion(this.value, this.label, this.color, this.prioridad);

  final String value;
  final String label;
  final Color color;

  /// Menor = más urgente (para ordenar)
  final int prioridad;

  /// Estados que requieren que alguien actúe
  bool get requiereAtencion => prioridad <= EstadoDotacion.proximo.prioridad;

  static EstadoDotacion of(StockVehiculoEntity l) {
    return EstadoDotacion.values.firstWhere(
      (EstadoDotacion e) => e.value == l.estadoDotacion,
      orElse: () => l.cantidadActual > 0 ? EstadoDotacion.ok : EstadoDotacion.falta,
    );
  }
}

/// Indicador de estado de dotación
class EquipamientoEstadoDot extends StatelessWidget {
  const EquipamientoEstadoDot({required this.linea, super.key});

  final StockVehiculoEntity linea;

  @override
  Widget build(BuildContext context) {
    final EstadoDotacion e = EstadoDotacion.of(linea);
    return GestionDotLabel(label: e.label, color: e.color);
  }
}

/// Badge de origen ajustado al texto: Plantilla / Extra
class EquipamientoOrigenBadge extends StatelessWidget {
  const EquipamientoOrigenBadge({required this.linea, super.key});

  final StockVehiculoEntity linea;

  @override
  Widget build(BuildContext context) {
    final bool plantilla = linea.esDePlantilla;
    final Color color = plantilla ? AppColors.primary : AppColors.secondary;
    return Align(
      alignment: Alignment.centerLeft,
      child: IntrinsicWidth(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            plantilla ? 'Plantilla' : 'Extra',
            style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: color),
          ),
        ),
      ),
    );
  }
}

/// Icono de adjunto: clip verde si existe, gris si se requiere y falta
class EquipamientoAdjuntoIcon extends StatelessWidget {
  const EquipamientoAdjuntoIcon({required this.linea, super.key});

  final StockVehiculoEntity linea;

  @override
  Widget build(BuildContext context) {
    if (linea.tieneAdjunto) {
      return Tooltip(
        message: linea.documentoNombre ?? 'Documento adjunto',
        child: const Icon(Icons.attach_file, size: 16, color: AppColors.success),
      );
    }
    if (linea.requiereAdjunto) {
      return const Tooltip(
        message: 'Requiere documento adjunto',
        child: Icon(Icons.attach_file, size: 16, color: AppColors.warning),
      );
    }
    return const SizedBox.shrink();
  }
}
