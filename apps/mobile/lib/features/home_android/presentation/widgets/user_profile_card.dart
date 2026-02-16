import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Tarjeta de usuario mejorada para Home Dashboard
///
/// Características:
/// - Avatar circular con iniciales del usuario
/// - Información: nombre, categoría, DNI
/// - Diseño Material 3 con sombra suave
/// - Border radius 16dp
/// - Elevation 2dp
class UserProfileCard extends StatelessWidget {
  const UserProfileCard({
    super.key,
    required this.nombre,
    this.categoria,
    this.dni,
    this.onTap,
  });

  final String nombre;
  final String? categoria;
  final String? dni;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    // Obtener iniciales del nombre
    final iniciales = _getInitials(nombre);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Row(
          children: [
            // Avatar con iniciales
            _AvatarCircle(iniciales: iniciales),
            const SizedBox(width: 16),

            // Información del usuario
            Expanded(
              child: _UserInfo(
                nombre: nombre,
                categoria: categoria,
                dni: dni,
              ),
            ),

            // Flecha de navegación
            if (onTap != null)
              Icon(
                Icons.chevron_right,
                color: AppColors.primary.withValues(alpha: 0.4),
                size: 24,
              ),
          ],
        ),
      ),
    );
  }

  String _getInitials(String nombre) {
    if (nombre.isEmpty) return 'U';
    final partes = nombre.trim().split(' ');
    if (partes.length >= 2) {
      return (partes[0][0] + partes[1][0]).toUpperCase();
    }
    return nombre[0].toUpperCase();
  }
}

/// Widget del avatar circular con iniciales
class _AvatarCircle extends StatelessWidget {
  const _AvatarCircle({
    required this.iniciales,
  });

  final String iniciales;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.2),
          width: 2,
        ),
      ),
      child: Center(
        child: Text(
          iniciales,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }
}

/// Widget con la información del usuario
class _UserInfo extends StatelessWidget {
  const _UserInfo({
    required this.nombre,
    required this.categoria,
    required this.dni,
  });

  final String nombre;
  final String? categoria;
  final String? dni;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Nombre completo
        Text(
          nombre,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.gray900,
            letterSpacing: -0.2,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),

        // Categoría profesional
        if (categoria != null)
          Text(
            categoria!,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.gray600,
              fontWeight: FontWeight.w400,
            ),
            overflow: TextOverflow.ellipsis,
          ),

        // DNI (si hay categoría, se muestra en la misma línea)
        if (dni != null) ...[
          const SizedBox(height: 2),
          Text(
            'DNI: $dni',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.gray600.withValues(alpha: 0.8),
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }
}
