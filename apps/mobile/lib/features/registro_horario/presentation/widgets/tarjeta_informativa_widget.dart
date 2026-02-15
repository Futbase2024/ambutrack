import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Widget genérico para mostrar información contextual con icono
///
/// Diseñado para mostrar información resumida como vehículo asignado,
/// compañero, último registro, próximo turno, etc.
class TarjetaInformativaWidget extends StatelessWidget {
  const TarjetaInformativaWidget({
    required this.icon,
    required this.iconColor,
    required this.titulo,
    required this.valor,
    this.subtitulo,
    this.onTap,
    this.actionIcon,
    super.key,
  });

  final IconData icon;
  final Color iconColor;
  final String titulo;
  final String? subtitulo;
  final String valor;
  final VoidCallback? onTap;
  final IconData? actionIcon;

  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Icono circular con background de color
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 24,
              color: iconColor,
            ),
          ),
          const SizedBox(width: 12),
          // Textos verticales
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Título
                Text(
                  titulo,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.gray600,
                    fontWeight: FontWeight.w400,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                // Valor principal
                Text(
                  valor,
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.gray900,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                // Subtítulo opcional
                if (subtitulo != null && subtitulo!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitulo!,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.gray500,
                      fontWeight: FontWeight.w400,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          // Icono de acción si está disponible
          if (actionIcon != null) ...[
            const SizedBox(width: 8),
            Icon(
              actionIcon,
              size: 20,
              color: AppColors.primary,
            ),
          ],
        ],
      ),
    );

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: onTap != null
          ? InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(12),
              child: content,
            )
          : content,
    );
  }
}
