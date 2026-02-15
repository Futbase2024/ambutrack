import 'package:flutter/material.dart';

import '../../../../../../core/theme/app_colors.dart';

/// Widget Badge para mostrar el estado de documentación de vehículos
class DocumentacionEstadoBadge extends StatelessWidget {
  const DocumentacionEstadoBadge({
    super.key,
    required this.estado,
  });

  final String estado;

  @override
  Widget build(BuildContext context) {
    final Color color = _getEstadoColor(estado);
    final String label = _getEstadoLabel(estado);

    return Align(
      alignment: Alignment.centerLeft,
      child: IntrinsicWidth(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ),
      ),
    );
  }

  Color _getEstadoColor(String estado) {
    switch (estado) {
      case 'vigente':
        return AppColors.success;
      case 'proxima_vencer':
        return AppColors.warning;
      case 'vencida':
      case 'vencido':
        return AppColors.error;
      default:
        return AppColors.inactive;
    }
  }

  String _getEstadoLabel(String estado) {
    switch (estado) {
      case 'vigente':
        return 'Vigente';
      case 'proxima_vencer':
        return 'Próxima a vencer';
      case 'vencida':
      case 'vencido':
        return 'Vencido';
      default:
        return estado;
    }
  }
}

/// Widget Badge para mostrar el tipo de documento
class DocumentacionTipoBadge extends StatelessWidget {
  const DocumentacionTipoBadge({
    super.key,
    required this.tipo,
  });

  final String tipo;

  @override
  Widget build(BuildContext context) {
    final Color color = _getTipoColor(tipo);

    return Align(
      alignment: Alignment.centerLeft,
      child: IntrinsicWidth(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Text(
            tipo,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ),
      ),
    );
  }

  Color _getTipoColor(String tipo) {
    switch (tipo.toLowerCase()) {
      case 'seguro':
        return AppColors.error;
      case 'itv':
        return AppColors.warning;
      case 'permiso':
      case 'licencia':
        return AppColors.info;
      default:
        return AppColors.secondaryLight;
    }
  }
}
