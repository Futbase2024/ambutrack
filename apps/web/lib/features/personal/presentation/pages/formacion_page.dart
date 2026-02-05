import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Página de Formación y Certificaciones del Personal
class FormacionPage extends StatelessWidget {
  const FormacionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      child: _FormacionView(),
    );
  }
}

class _FormacionView extends StatelessWidget {
  const _FormacionView();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Formación y Certificaciones',
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: AppSizes.spacingSmall),
          Text(
            'Gestión de formación, cursos y certificaciones del personal sanitario',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppColors.textSecondaryLight,
            ),
          ),
          const SizedBox(height: AppSizes.spacing),
          const Expanded(
            child: _PlaceholderWidget(
              icon: Icons.school_outlined,
              message: 'Próximamente: gestión de formación y certificaciones',
            ),
          ),
        ],
      ),
    );
  }
}

class _PlaceholderWidget extends StatelessWidget {
  const _PlaceholderWidget({
    required this.icon,
    required this.message,
  });

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radius),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              icon,
              size: 64,
              color: AppColors.primary.withValues(alpha: 0.3),
            ),
            const SizedBox(height: AppSizes.spacing),
            Text(
              'Módulo en desarrollo',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondaryLight,
              ),
            ),
            const SizedBox(height: AppSizes.spacingSmall),
            Text(
              message,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppColors.textSecondaryLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
