import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../auth/domain/entities/user_entity.dart';

/// Header del perfil con avatar, nombre y badge de verificación
class PerfilHeader extends StatelessWidget {
  const PerfilHeader({
    required this.user,
    super.key,
  });

  final UserEntity user;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingXl),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            AppColors.primary,
            AppColors.primaryLight,
          ],
        ),
        borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: <Widget>[
          _AvatarSection(user: user),
          const SizedBox(height: AppSizes.spacingLarge),
          _NombreSection(user: user),
          const SizedBox(height: AppSizes.spacingSmall),
          _EmailSection(user: user),
          if (user.rol != null) ...<Widget>[
            const SizedBox(height: AppSizes.spacingSmall),
            _RolBadge(rol: user.rol!),
          ],
          if (user.emailVerified) ...<Widget>[
            const SizedBox(height: AppSizes.spacing),
            _VerificadoBadge(),
          ],
        ],
      ),
    );
  }
}

/// Sección del avatar (círculo con inicial o foto)
class _AvatarSection extends StatelessWidget {
  const _AvatarSection({required this.user});

  final UserEntity user;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        border: Border.all(
          color: Colors.white,
          width: 4,
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipOval(
        child: user.photoUrl != null && user.photoUrl!.isNotEmpty
            ? _FotoPerfilWidget(photoUrl: user.photoUrl!)
            : _InicialWidget(user: user),
      ),
    );
  }
}

/// Widget para mostrar la foto de perfil desde URL
class _FotoPerfilWidget extends StatelessWidget {
  const _FotoPerfilWidget({required this.photoUrl});

  final String photoUrl;

  @override
  Widget build(BuildContext context) {
    return Image.network(
      photoUrl,
      fit: BoxFit.cover,
      errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
        // Si falla la carga, mostrar ícono genérico
        return const ColoredBox(
          color: AppColors.gray100,
          child: Icon(
            Icons.person,
            size: 60,
            color: AppColors.gray500,
          ),
        );
      },
      loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
        if (loadingProgress == null) {
          return child;
        }
        return const ColoredBox(
          color: AppColors.gray100,
          child: Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
        );
      },
    );
  }
}

/// Widget para mostrar la inicial del nombre
class _InicialWidget extends StatelessWidget {
  const _InicialWidget({required this.user});

  final UserEntity user;

  String _getIniciales() {
    if (user.displayName != null && user.displayName!.isNotEmpty) {
      final List<String> parts = user.displayName!.trim().split(' ');
      if (parts.length >= 2) {
        return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
      }
      return parts[0][0].toUpperCase();
    }
    // Si no hay displayName, usar la primera letra del email
    return user.email[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.primaryLight,
      child: Center(
        child: Text(
          _getIniciales(),
          style: GoogleFonts.inter(
            fontSize: 48,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

/// Sección del nombre del usuario
class _NombreSection extends StatelessWidget {
  const _NombreSection({required this.user});

  final UserEntity user;

  @override
  Widget build(BuildContext context) {
    return Text(
      user.displayName ?? 'Usuario',
      style: GoogleFonts.inter(
        fontSize: AppSizes.fontTitle,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      textAlign: TextAlign.center,
    );
  }
}

/// Sección del email del usuario
class _EmailSection extends StatelessWidget {
  const _EmailSection({required this.user});

  final UserEntity user;

  @override
  Widget build(BuildContext context) {
    return Text(
      user.email,
      style: GoogleFonts.inter(
        fontSize: AppSizes.fontMedium,
        color: Colors.white.withValues(alpha: 0.9),
      ),
      textAlign: TextAlign.center,
    );
  }
}

/// Badge de rol del usuario
class _RolBadge extends StatelessWidget {
  const _RolBadge({required this.rol});

  final String rol;

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

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
        ),
      ),
      child: Text(
        _getDisplayRole(rol),
        style: GoogleFonts.inter(
          fontSize: AppSizes.fontSmall,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }
}

/// Badge de email verificado
class _VerificadoBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        border: Border.all(
          color: AppColors.success.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Icon(
            Icons.verified,
            size: 16,
            color: Colors.white,
          ),
          const SizedBox(width: 6),
          Text(
            'Email Verificado',
            style: GoogleFonts.inter(
              fontSize: AppSizes.fontSmall,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
