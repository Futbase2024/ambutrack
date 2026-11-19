import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Badge ajustado al texto
class BadgeVestuario extends StatelessWidget {
  const BadgeVestuario({required this.texto, required this.color, super.key});

  final String texto;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: IntrinsicWidth(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
          child: Text(
            texto,
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color),
          ),
        ),
      ),
    );
  }
}

/// Color del estado de una solicitud
Color colorEstadoSolicitud(EstadoSolicitudVestuario estado) {
  switch (estado) {
    case EstadoSolicitudVestuario.pendiente:
      return AppColors.warning;
    case EstadoSolicitudVestuario.aprobada:
      return AppColors.info;
    case EstadoSolicitudVestuario.entregada:
      return AppColors.success;
    case EstadoSolicitudVestuario.rechazada:
      return AppColors.error;
    case EstadoSolicitudVestuario.cancelada:
      return AppColors.gray500;
  }
}

/// Color del estado de una prenda (nuevo, bueno, desgastado, devuelto, baja...)
Color colorEstadoPrenda(String? estado) {
  switch ((estado ?? '').toLowerCase()) {
    case 'nuevo':
      return AppColors.success;
    case 'bueno':
      return AppColors.info;
    case 'desgastado':
    case 'regular':
      return AppColors.warning;
    case 'roto':
    case 'malo':
    case 'baja':
      return AppColors.error;
    default:
      return AppColors.gray500;
  }
}

String capitalizar(String? texto) {
  final String t = (texto ?? '').trim();
  return t.isEmpty ? '-' : '${t[0].toUpperCase()}${t.substring(1).toLowerCase()}';
}

/// Mensaje centrado para listas vacías
class VestuarioVacio extends StatelessWidget {
  const VestuarioVacio({required this.icono, required this.texto, super.key});

  final IconData icono;
  final String texto;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(icono, size: 56, color: AppColors.gray300),
            const SizedBox(height: 12),
            Text(
              texto,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.gray600, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}
