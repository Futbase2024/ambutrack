import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/features/servicios/servicios/presentation/formulario/models/modalidad_servicio.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Selector de tipo de modalidad (grid 2x3)
class ModalidadSelectorWidget extends StatelessWidget {
  const ModalidadSelectorWidget({
    super.key,
    required this.modalidad,
    required this.onModalidadChanged,
  });

  final ModalidadServicio modalidad;
  final void Function(ModalidadServicio) onModalidadChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Tipo de Recurrencia *',
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimaryLight,
          ),
        ),
        const SizedBox(height: 12),
        Column(
          children: <Widget>[
            // FILA 1: Serv. Único, Diario, Semanal
            Row(
              children: <Widget>[
                Expanded(
                  child: ModalidadCardWidget(
                    modalidad: ModalidadServicio.unico,
                    icon: Icons.event_note,
                    titulo: 'Serv. Único',
                    descripcion: 'Una sola fecha',
                    isSelected: modalidad == ModalidadServicio.unico,
                    onTap: () => onModalidadChanged(ModalidadServicio.unico),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ModalidadCardWidget(
                    modalidad: ModalidadServicio.diario,
                    icon: Icons.today,
                    titulo: 'Diario',
                    descripcion: 'Todos los días',
                    isSelected: modalidad == ModalidadServicio.diario,
                    onTap: () => onModalidadChanged(ModalidadServicio.diario),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ModalidadCardWidget(
                    modalidad: ModalidadServicio.semanal,
                    icon: Icons.calendar_view_week,
                    titulo: 'Semanal',
                    descripcion: 'Días fijos',
                    isSelected: modalidad == ModalidadServicio.semanal,
                    onTap: () => onModalidadChanged(ModalidadServicio.semanal),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // FILA 2: Días Alternos, Fechas Específicas, Mensual
            Row(
              children: <Widget>[
                Expanded(
                  child: ModalidadCardWidget(
                    modalidad: ModalidadServicio.diasAlternos,
                    icon: Icons.sync_alt,
                    titulo: 'Días Alternos',
                    descripcion: 'Cada N días',
                    isSelected: modalidad == ModalidadServicio.diasAlternos,
                    onTap: () => onModalidadChanged(ModalidadServicio.diasAlternos),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ModalidadCardWidget(
                    modalidad: ModalidadServicio.especifico,
                    icon: Icons.date_range,
                    titulo: 'Fechas Específicas',
                    descripcion: 'Fechas concretas',
                    isSelected: modalidad == ModalidadServicio.especifico,
                    onTap: () => onModalidadChanged(ModalidadServicio.especifico),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ModalidadCardWidget(
                    modalidad: ModalidadServicio.mensual,
                    icon: Icons.calendar_month,
                    titulo: 'Mensual',
                    descripcion: 'Días del mes',
                    isSelected: modalidad == ModalidadServicio.mensual,
                    onTap: () => onModalidadChanged(ModalidadServicio.mensual),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

/// Card individual de modalidad
class ModalidadCardWidget extends StatelessWidget {
  const ModalidadCardWidget({
    super.key,
    required this.modalidad,
    required this.icon,
    required this.titulo,
    required this.descripcion,
    required this.isSelected,
    required this.onTap,
  });

  final ModalidadServicio modalidad;
  final IconData icon;
  final String titulo;
  final String descripcion;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 75,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : Colors.white,
          borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.gray300,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: <Widget>[
            Icon(
              icon,
              size: 26,
              color: isSelected ? AppColors.primary : AppColors.textSecondaryLight,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    titulo,
                    style: GoogleFonts.inter(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? AppColors.primary : AppColors.textPrimaryLight,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    descripcion,
                    style: GoogleFonts.inter(
                      fontSize: 10.5,
                      color: AppColors.textSecondaryLight,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
