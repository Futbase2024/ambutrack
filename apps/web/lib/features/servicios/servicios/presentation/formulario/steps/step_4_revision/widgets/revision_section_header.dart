import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../../../../core/theme/app_colors.dart';

/// Header profesional para secciones de revisión
///
/// Muestra un icono circular con color y un título
class RevisionSectionHeader extends StatelessWidget {
  const RevisionSectionHeader({
    required this.titulo,
    required this.icono,
    required this.color,
    this.subtitle,
    super.key,
  });

  final String titulo;
  final IconData icono;
  final Color color;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Row(
          children: <Widget>[
            Icon(icono, color: color, size: 16),
            const SizedBox(width: 8),
            Text(
              titulo.toUpperCase(),
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.6,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 10),
            const Expanded(child: Divider(height: 1, color: AppColors.gray200)),
          ],
        ),
        if (subtitle != null) ...<Widget>[
          const SizedBox(height: 4),
          Text(
            subtitle!,
            style: const TextStyle(fontSize: 12, color: AppColors.gray500),
          ),
        ],
      ],
    );
  }
}

/// Item compacto de información con icono
class RevisionItemCompacto extends StatelessWidget {
  const RevisionItemCompacto({
    required this.icono,
    required this.label,
    required this.valor,
    super.key,
  });

  final IconData icono;
  final String label;
  final String valor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Icon(icono, size: 18, color: AppColors.textSecondaryLight),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              children: <TextSpan>[
                TextSpan(
                  text: '$label: ',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondaryLight,
                  ),
                ),
                TextSpan(
                  text: valor,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: AppColors.textPrimaryLight,
                  ),
                ),
              ],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
