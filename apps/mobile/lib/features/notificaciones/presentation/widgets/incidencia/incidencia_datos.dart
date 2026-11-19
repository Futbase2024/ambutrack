import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../../core/theme/app_colors.dart';
import 'incidencia_chips.dart';

/// Color de cada estado de incidencia
Color colorEstadoIncidencia(EstadoIncidencia estado) {
  return switch (estado) {
    EstadoIncidencia.reportada => AppColors.warning,
    EstadoIncidencia.enRevision => AppColors.info,
    EstadoIncidencia.enReparacion => AppColors.secondary,
    EstadoIncidencia.resuelta => AppColors.success,
    EstadoIncidencia.cerrada => AppColors.gray600,
  };
}

/// Datos de solo lectura de una incidencia de vehículo
class IncidenciaDatos extends StatelessWidget {
  const IncidenciaDatos({super.key, required this.incidencia, this.matricula});

  final IncidenciaVehiculoEntity incidencia;
  final String? matricula;

  @override
  Widget build(BuildContext context) {
    final DateFormat formato = DateFormat('dd/MM/yyyy HH:mm');
    final double? km = incidencia.kilometrajeReporte;
    final String? solucion = incidencia.solucionAplicada;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          incidencia.titulo,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.gray900),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: <Widget>[
            if (matricula != null && matricula!.isNotEmpty)
              IncidenciaChip(
                icon: Icons.directions_car_filled_rounded,
                texto: matricula!,
                color: AppColors.primary,
              ),
            IncidenciaChip(
              icon: Icons.flag_rounded,
              texto: 'Prioridad ${incidencia.prioridad.nombre.toUpperCase()}',
              color: colorPrioridadIncidencia(incidencia.prioridad.name),
            ),
            IncidenciaChip(
              icon: Icons.sync_alt_rounded,
              texto: incidencia.estado.nombre,
              color: colorEstadoIncidencia(incidencia.estado),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          incidencia.descripcion,
          style: const TextStyle(fontSize: 15, color: AppColors.gray800, height: 1.4),
        ),
        const SizedBox(height: 16),
        _Fila(icon: Icons.category_outlined, label: 'Tipo', valor: incidencia.tipo.nombre),
        _Fila(icon: Icons.person_outline, label: 'Reportado por', valor: incidencia.reportadoPorNombre.toUpperCase()),
        _Fila(icon: Icons.schedule, label: 'Fecha', valor: formato.format(incidencia.fechaReporte.toLocal())),
        if (km != null) _Fila(icon: Icons.speed, label: 'Kilometraje', valor: '${km.round()} km'),
        if (incidencia.fechaResolucion != null)
          _Fila(
            icon: Icons.check_circle_outline,
            label: 'Resuelta',
            valor: formato.format(incidencia.fechaResolucion!.toLocal()),
          ),
        if (solucion != null && solucion.isNotEmpty) _Fila(icon: Icons.build_outlined, label: 'Nota', valor: solucion),
      ],
    );
  }
}

class _Fila extends StatelessWidget {
  const _Fila({required this.icon, required this.label, required this.valor});

  final IconData icon;
  final String label;
  final String valor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(icon, size: 18, color: AppColors.gray500),
          const SizedBox(width: 8),
          SizedBox(
            width: 110,
            child: Text(label, style: const TextStyle(fontSize: 13, color: AppColors.gray600)),
          ),
          Expanded(
            child: Text(
              valor,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.gray900),
            ),
          ),
        ],
      ),
    );
  }
}
