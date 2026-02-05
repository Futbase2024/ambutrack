import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/features/cuadrante/cuadrante_visual/domain/entities/personal_drag_data.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Tarjeta de personal arrastrable
class DraggablePersonalCard extends StatelessWidget {
  const DraggablePersonalCard({
    required this.personalId,
    required this.nombre,
    required this.rol,
    this.avatarUrl,
    this.onDragStarted,
    this.onDragEnd,
    super.key,
  });

  final String personalId;
  final String nombre;
  final String rol;
  final String? avatarUrl;
  final VoidCallback? onDragStarted;
  final VoidCallback? onDragEnd;

  @override
  Widget build(BuildContext context) {
    final PersonalDragData dragData = PersonalDragData(
      personalId: personalId,
      nombre: nombre,
      rol: rol,
      avatarUrl: avatarUrl,
    );

    return Draggable<PersonalDragData>(
      data: dragData,
      onDragStarted: onDragStarted,
      onDragEnd: (_) => onDragEnd?.call(),
      // Widget que se muestra mientras se arrastra
      feedback: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        child: Opacity(
          opacity: 0.8,
          child: _buildCardContent(isDragging: true),
        ),
      ),
      // Widget que queda en su lugar mientras se arrastra
      childWhenDragging: Opacity(
        opacity: 0.3,
        child: _buildCardContent(isDragging: false),
      ),
      // Widget normal cuando no se arrastra
      child: _buildCardContent(isDragging: false),
    );
  }

  Widget _buildCardContent({required bool isDragging}) {
    return Container(
      width: 280,
      padding: const EdgeInsets.all(AppSizes.paddingSmall),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        border: Border.all(
          color: _getRolColor().withValues(alpha: 0.3),
          width: 2,
        ),
        boxShadow: isDragging
            ? <BoxShadow>[
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ]
            : <BoxShadow>[
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Row(
        children: <Widget>[
          // Avatar/Icono
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _getRolColor().withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
            ),
            child: Icon(
              _getRolIcon(),
              color: _getRolColor(),
              size: 28,
            ),
          ),
          const SizedBox(width: AppSizes.spacingSmall),

          // Datos
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  nombre,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimaryLight,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Row(
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: _getRolColor().withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        _getRolLabel(),
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: _getRolColor(),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Icono de arrastre
          const Icon(
            Icons.drag_indicator,
            color: AppColors.gray400,
            size: 20,
          ),
        ],
      ),
    );
  }

  /// Obtiene el color según el rol
  Color _getRolColor() {
    switch (rol.toLowerCase()) {
      case 'conductor':
        return AppColors.primary;
      case 'tes':
        return AppColors.success;
      case 'tecnico':
        return AppColors.warning;
      default:
        return AppColors.gray500;
    }
  }

  /// Obtiene el icono según el rol
  IconData _getRolIcon() {
    switch (rol.toLowerCase()) {
      case 'conductor':
        return Icons.drive_eta;
      case 'tes':
        return Icons.medical_services;
      case 'tecnico':
        return Icons.build;
      default:
        return Icons.person;
    }
  }

  /// Obtiene la etiqueta del rol
  String _getRolLabel() {
    switch (rol.toLowerCase()) {
      case 'conductor':
        return 'Conductor';
      case 'tes':
        return 'TES';
      case 'tecnico':
        return 'Técnico';
      default:
        return rol;
    }
  }
}
