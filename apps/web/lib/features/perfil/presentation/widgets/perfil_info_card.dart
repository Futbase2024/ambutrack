import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/widgets/buttons/app_button.dart';
import '../../../auth/domain/entities/user_entity.dart';

/// Card que muestra la información detallada del perfil del usuario
class PerfilInfoCard extends StatelessWidget {
  const PerfilInfoCard({
    required this.user,
    required this.onEditarPerfil,
    required this.onCambiarPassword,
    super.key,
  });

  final UserEntity user;
  final VoidCallback onEditarPerfil;
  final VoidCallback onCambiarPassword;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _InformacionBasicaSection(user: user),
        const SizedBox(height: AppSizes.spacingLarge),
        _InformacionSesionSection(user: user),
        const SizedBox(height: AppSizes.spacingXl),
        _AccionesSection(
          onEditarPerfil: onEditarPerfil,
          onCambiarPassword: onCambiarPassword,
        ),
      ],
    );
  }
}

/// Sección de información básica
class _InformacionBasicaSection extends StatelessWidget {
  const _InformacionBasicaSection({required this.user});

  final UserEntity user;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingLarge),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
        border: Border.all(color: AppColors.gray200),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.gray900.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Información Básica',
            style: GoogleFonts.inter(
              fontSize: AppSizes.fontLarge,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: AppSizes.spacingLarge),
          _InfoRow(
            icon: Icons.person_outline,
            label: 'Nombre completo',
            value: user.displayName ?? 'Sin nombre',
          ),
          const SizedBox(height: AppSizes.spacing),
          _InfoRow(
            icon: Icons.email_outlined,
            label: 'Correo electrónico',
            value: user.email,
          ),
          const SizedBox(height: AppSizes.spacing),
          _InfoRow(
            icon: Icons.phone_outlined,
            label: 'Teléfono',
            value: user.phoneNumber ?? 'No registrado',
          ),
          if (user.dni != null) ...<Widget>[
            const SizedBox(height: AppSizes.spacing),
            _InfoRow(
              icon: Icons.badge_outlined,
              label: 'DNI',
              value: user.dni!,
            ),
          ],
          if (user.emailVerified) ...<Widget>[
            const SizedBox(height: AppSizes.spacing),
            Row(
              children: <Widget>[
                const Icon(
                  Icons.verified,
                  size: 20,
                  color: AppColors.success,
                ),
                const SizedBox(width: AppSizes.spacingSmall),
                Text(
                  'Email verificado',
                  style: GoogleFonts.inter(
                    fontSize: AppSizes.font,
                    color: AppColors.success,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// Sección de información de sesión
class _InformacionSesionSection extends StatelessWidget {
  const _InformacionSesionSection({required this.user});

  final UserEntity user;

  @override
  Widget build(BuildContext context) {
    final DateFormat dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingLarge),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
        border: Border.all(color: AppColors.gray200),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.gray900.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Información de Sesión',
            style: GoogleFonts.inter(
              fontSize: AppSizes.fontLarge,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: AppSizes.spacingLarge),
          _InfoRow(
            icon: Icons.badge_outlined,
            label: 'ID de usuario',
            value: user.uid,
          ),
          const SizedBox(height: AppSizes.spacing),
          _InfoRow(
            icon: Icons.business_outlined,
            label: 'Empresa',
            value: user.empresaNombre ?? 'No asignada',
          ),
          if (user.rol != null) ...<Widget>[
            const SizedBox(height: AppSizes.spacing),
            _RolRow(rol: user.rol!),
          ],
          if (user.activo != null) ...<Widget>[
            const SizedBox(height: AppSizes.spacing),
            _EstadoRow(activo: user.activo!),
          ],
          const SizedBox(height: AppSizes.spacing),
          _InfoRow(
            icon: Icons.calendar_today_outlined,
            label: 'Fecha de registro',
            value: dateFormat.format(user.createdAt),
          ),
          if (user.lastLoginAt != null) ...<Widget>[
            const SizedBox(height: AppSizes.spacing),
            _InfoRow(
              icon: Icons.login_outlined,
              label: 'Último acceso',
              value: dateFormat.format(user.lastLoginAt!),
            ),
          ],
        ],
      ),
    );
  }
}

/// Sección de acciones (botones)
class _AccionesSection extends StatelessWidget {
  const _AccionesSection({
    required this.onEditarPerfil,
    required this.onCambiarPassword,
  });

  final VoidCallback onEditarPerfil;
  final VoidCallback onCambiarPassword;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: AppButton(
            label: 'Editar Perfil',
            icon: Icons.edit_outlined,
            onPressed: onEditarPerfil,
          ),
        ),
        const SizedBox(width: AppSizes.spacing),
        Expanded(
          child: AppButton(
            label: 'Cambiar Contraseña',
            icon: Icons.lock_outlined,
            variant: AppButtonVariant.outline,
            onPressed: onCambiarPassword,
          ),
        ),
      ],
    );
  }
}

/// Widget reutilizable para mostrar una fila de información
class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Icon(
          icon,
          size: 20,
          color: AppColors.primaryLight,
        ),
        const SizedBox(width: AppSizes.spacing),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: AppSizes.fontXs,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: GoogleFonts.inter(
                  fontSize: AppSizes.font,
                  color: AppColors.textPrimaryLight,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Widget para mostrar el rol del usuario con badge
class _RolRow extends StatelessWidget {
  const _RolRow({required this.rol});

  final String rol;

  @override
  Widget build(BuildContext context) {
    // Colores según rol
    final Color color = _getColorForRole(rol);
    final String displayRol = _getDisplayRole(rol);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Icon(
          Icons.admin_panel_settings_outlined,
          size: 20,
          color: AppColors.primaryLight,
        ),
        const SizedBox(width: AppSizes.spacing),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Rol',
                style: GoogleFonts.inter(
                  fontSize: AppSizes.fontXs,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: 4),
              Align(
                alignment: Alignment.centerLeft,
                child: IntrinsicWidth(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                    ),
                    child: Text(
                      displayRol,
                      style: GoogleFonts.inter(
                        fontSize: AppSizes.fontXs,
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _getColorForRole(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return AppColors.error;
      case 'coordinador':
        return AppColors.primary;
      case 'conductor':
        return AppColors.info;
      case 'sanitario':
        return AppColors.success;
      case 'jefe_personal':
        return AppColors.secondary;
      case 'gestor_flota':
        return AppColors.warning;
      default:
        return AppColors.textSecondaryLight;
    }
  }

  String _getDisplayRole(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return 'Administrador';
      case 'coordinador':
        return 'Coordinador';
      case 'conductor':
        return 'Conductor';
      case 'sanitario':
        return 'Sanitario';
      case 'jefe_personal':
        return 'Jefe de Personal';
      case 'gestor_flota':
        return 'Gestor de Flota';
      default:
        // Capitalizar primera letra y reemplazar guiones bajos por espacios
        return role.replaceAll('_', ' ').split(' ')
            .map((String word) => word.isEmpty ? '' : '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}')
            .join(' ');
    }
  }
}

/// Widget para mostrar el estado activo/inactivo
class _EstadoRow extends StatelessWidget {
  const _EstadoRow({required this.activo});

  final bool activo;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Icon(
          activo ? Icons.check_circle_outline : Icons.cancel_outlined,
          size: 20,
          color: activo ? AppColors.success : AppColors.error,
        ),
        const SizedBox(width: AppSizes.spacing),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Estado',
                style: GoogleFonts.inter(
                  fontSize: AppSizes.fontXs,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: 4),
              Align(
                alignment: Alignment.centerLeft,
                child: IntrinsicWidth(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: (activo ? AppColors.success : AppColors.error).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                    ),
                    child: Text(
                      activo ? 'Activo' : 'Inactivo',
                      style: GoogleFonts.inter(
                        fontSize: AppSizes.fontXs,
                        fontWeight: FontWeight.w600,
                        color: activo ? AppColors.success : AppColors.error,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
