import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_sizes.dart';

/// Tarjeta con el turno planificado en el cuadrante (casos A y B)
class TurnoAsignadoCard extends StatelessWidget {
  const TurnoAsignadoCard({
    required this.turno,
    this.vehiculo,
    this.onCambiarVehiculo,
    super.key,
  });

  final TurnoEntity turno;
  final VehiculoEntity? vehiculo;

  /// null = no se muestra el botón "No es este vehículo"
  final VoidCallback? onCambiarVehiculo;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primarySurface,
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _Fila(
            icono: Icons.event_available_rounded,
            titulo: 'Turno ${turno.tipoTurno.nombre}',
            detalle: '${turno.horaInicio} - ${turno.horaFin}',
          ),
          const SizedBox(height: 12),
          _Fila(
            icono: Icons.local_shipping_rounded,
            titulo: vehiculo?.matricula ?? 'Sin vehículo asignado',
            detalle: vehiculo == null ? 'Elige el vehículo con el que sales' : _detalleVehiculo(vehiculo!),
          ),
          if (onCambiarVehiculo != null) ...<Widget>[
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: onCambiarVehiculo,
                icon: const Icon(Icons.swap_horiz_rounded, size: 18),
                label: const Text('No es este vehículo'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _detalleVehiculo(VehiculoEntity v) {
    final String interno = v.numeroInterno?.isNotEmpty ?? false ? 'Nº ${v.numeroInterno} · ' : '';
    return '$interno${v.marca} ${v.modelo}'.trim();
  }
}

/// Aviso del caso C: no hay turno planificado y se creará desde la app
class SinTurnoAviso extends StatelessWidget {
  const SinTurnoAviso({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(Icons.info_outline_rounded, color: AppColors.warning),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'No tienes turno planificado ahora. Elige el tipo de turno y el vehículo: '
              'se creará en el cuadrante y quedará pendiente de validar por coordinación.',
              style: TextStyle(fontSize: 13, color: AppColors.gray800, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}

class _Fila extends StatelessWidget {
  const _Fila({required this.icono, required this.titulo, required this.detalle});

  final IconData icono;
  final String titulo;
  final String detalle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(10),
          decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
          child: Icon(icono, color: AppColors.primary, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                titulo,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.gray900),
              ),
              const SizedBox(height: 2),
              Text(detalle, style: const TextStyle(fontSize: 13, color: AppColors.gray600)),
            ],
          ),
        ),
      ],
    );
  }
}
