import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';

/// Tile para seleccionar un tipo de trámite.
/// Se usa en la pantalla principal para navegar a los formularios.
class TramiteTipoTile extends StatelessWidget {
  const TramiteTipoTile({
    required this.titulo,
    required this.icono,
    required this.colorIcono,
    required this.onTap,
    this.subtitulo,
    this.trailing,
    super.key,
  });

  final String titulo;
  final IconData icono;
  final Color colorIcono;
  final VoidCallback onTap;
  final String? subtitulo;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSizes.paddingMedium,
        vertical: AppSizes.paddingSmall,
      ),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        side: BorderSide(
          color: AppColors.gray200,
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.paddingMedium),
          child: Row(
            children: [
              // Icono
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorIcono.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                ),
                child: Icon(
                  icono,
                  color: colorIcono,
                  size: AppSizes.iconLarge,
                ),
              ),

              const SizedBox(width: AppSizes.spacingMedium),

              // Título y subtítulo
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titulo,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.gray900,
                      ),
                    ),
                    if (subtitulo != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitulo!,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.gray600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Trailing (ícono de flecha o widget personalizado)
              trailing ??
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 18,
                    color: AppColors.gray400,
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
