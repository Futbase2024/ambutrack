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
    return Row(
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
          child: Icon(icono, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                titulo,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimaryLight,
                ),
              ),
              if (subtitle != null) ...<Widget>[
                const SizedBox(height: 2),
                Text(
                  subtitle!,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ],
          ),
        ),
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
