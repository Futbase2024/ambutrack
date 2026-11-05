import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_text_styles.dart';
import 'package:ambutrack_web/core/widgets/badges/status_badge.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Celda de nombre con descripción
class DotacionNombreCell extends StatelessWidget {
  const DotacionNombreCell({super.key, required this.dotacion});

  final DotacionEntity dotacion;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          dotacion.nombre,
          style: AppTextStyles.tableCellBold,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        if (dotacion.descripcion != null &&
            dotacion.descripcion!.isNotEmpty)
          Text(
            dotacion.descripcion!,
            style: AppTextStyles.tableCellSmall,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
      ],
    );
  }
}

/// Celda de destino con icono contextual
class DotacionDestinoCell extends StatelessWidget {
  const DotacionDestinoCell({super.key, required this.dotacion});

  final DotacionEntity dotacion;

  @override
  Widget build(BuildContext context) {
    final String tipoDestino = dotacion.tipoDestino;
    IconData icon = Icons.help_outline;
    Color color = AppColors.textSecondaryLight;

    switch (tipoDestino) {
      case 'Hospital':
        icon = Icons.local_hospital;
        color = AppColors.error;
      case 'Base':
        icon = Icons.home_work;
        color = AppColors.primary;
      case 'Contrato':
        icon = Icons.description;
        color = AppColors.warning;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 6),
        Text(
          tipoDestino,
          style: AppTextStyles.tableCell,
        ),
      ],
    );
  }
}

/// Celda de unidades con badge
class DotacionUnidadesCell extends StatelessWidget {
  const DotacionUnidadesCell({super.key, required this.dotacion});

  final DotacionEntity dotacion;

  @override
  Widget build(BuildContext context) {
    return Text(
      '${dotacion.cantidadUnidades}',
      style: AppTextStyles.tableCellBold.copyWith(
        color: AppColors.primary,
      ),
    );
  }
}

/// Celda de prioridad con StatusBadge
class DotacionPrioridadCell extends StatelessWidget {
  const DotacionPrioridadCell({super.key, required this.dotacion});

  final DotacionEntity dotacion;

  @override
  Widget build(BuildContext context) {
    final StatusBadgeType badgeType =
        _getPrioridadBadgeType(dotacion.prioridad);
    final String label = _getPrioridadLabel(dotacion.prioridad);

    return Align(
      alignment: Alignment.centerLeft,
      child: StatusBadge(
        label: '${dotacion.prioridad} - $label',
        type: badgeType,
      ),
    );
  }

  static StatusBadgeType _getPrioridadBadgeType(int prioridad) {
    if (prioridad >= 8) {
      return StatusBadgeType.error;
    }
    if (prioridad >= 5) {
      return StatusBadgeType.warning;
    }
    return StatusBadgeType.success;
  }

  static String _getPrioridadLabel(int prioridad) {
    if (prioridad >= 8) {
      return 'Alta';
    }
    if (prioridad >= 5) {
      return 'Media';
    }
    return 'Baja';
  }
}

/// Celda de vigencia con fechas y estado visual
class DotacionVigenciaCell extends StatelessWidget {
  const DotacionVigenciaCell({super.key, required this.dotacion});

  final DotacionEntity dotacion;

  @override
  Widget build(BuildContext context) {
    final DateFormat dateFormat = DateFormat('dd/MM/yyyy');
    final String inicio = dateFormat.format(dotacion.fechaInicio);
    final String fin = dotacion.fechaFin != null
        ? dateFormat.format(dotacion.fechaFin!)
        : 'Indefinido';
    final bool esVigente = dotacion.esVigenteEn(DateTime.now());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          inicio,
          style: AppTextStyles.tableCell,
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              esVigente ? Icons.arrow_forward : Icons.event_busy,
              size: 10,
              color: esVigente ? AppColors.success : AppColors.error,
            ),
            const SizedBox(width: 4),
            Text(
              fin,
              style: AppTextStyles.tableCellSmall.copyWith(
                color: esVigente ? AppColors.success : AppColors.error,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Celda de estado con StatusBadge
class DotacionEstadoCell extends StatelessWidget {
  const DotacionEstadoCell({super.key, required this.dotacion});

  final DotacionEntity dotacion;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: StatusBadge(
        label: dotacion.activo ? 'Activa' : 'Inactiva',
        type: dotacion.activo
            ? StatusBadgeType.success
            : StatusBadgeType.inactivo,
      ),
    );
  }
}
