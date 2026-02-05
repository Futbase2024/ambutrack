import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/features/servicios/domain/entities/configuracion_modalidad.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'schedule_grid_expandido.dart';
import 'schedule_grid_plantilla.dart';

/// Widget coordinador que decide qué tipo de grilla de horarios mostrar
/// según la configuración de modalidad (plantilla vs expandido)
class ScheduleGrid extends StatelessWidget {
  const ScheduleGrid({
    required this.configuracion,
    required this.onPlantillaHorariosChanged,
    required this.onDiasProgramadosChanged,
    required this.tiempoEsperaCita,
    required this.tieneVuelta,
    super.key,
  });

  final ConfiguracionModalidad configuracion;
  final void Function(List<PlantillaHorario>) onPlantillaHorariosChanged;
  final void Function(List<DiaProgramado>) onDiasProgramadosChanged;
  final int tiempoEsperaCita; // Minutos de espera en la cita (para calcular vuelta)
  final bool tieneVuelta; // Si el servicio tiene viaje de vuelta

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingLarge),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radius),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Header con título e info
          _buildHeader(),
          const SizedBox(height: AppSizes.spacing),

          // Grilla según modo
          if (configuracion.esModoPlantilla)
            ScheduleGridPlantilla(
              configuracion: configuracion,
              plantillaHorarios: configuracion.plantillaHorarios ?? <PlantillaHorario>[],
              onPlantillaHorariosChanged: onPlantillaHorariosChanged,
              tiempoEsperaCita: tiempoEsperaCita,
              tieneVuelta: tieneVuelta,
            )
          else
            ScheduleGridExpandido(
              configuracion: configuracion,
              diasProgramados: configuracion.diasProgramados ?? <DiaProgramado>[],
              onDiasProgramadosChanged: onDiasProgramadosChanged,
              tiempoEsperaCita: tiempoEsperaCita,
              tieneVuelta: tieneVuelta,
            ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Icon(
              configuracion.esModoPlantilla
                  ? Icons.view_module_outlined
                  : Icons.calendar_view_month_outlined,
              color: AppColors.primary,
              size: 24,
            ),
            const SizedBox(width: AppSizes.spacingSmall),
            Text(
              configuracion.esModoPlantilla
                  ? 'Plantilla de Horarios'
                  : 'Programación de Servicios',
              style: GoogleFonts.inter(
                fontSize: AppSizes.fontLarge,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimaryLight,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSizes.spacingSmall),
        _InfoMessage(
          mensaje: configuracion.tipoRecurrencia.getInfoMessage(
            sinFechaFin: configuracion.sinFechaFin,
          ),
          esModoPlantilla: configuracion.esModoPlantilla,
        ),
      ],
    );
  }
}

/// Mensaje informativo sobre el tipo de grilla mostrada
class _InfoMessage extends StatelessWidget {
  const _InfoMessage({
    required this.mensaje,
    required this.esModoPlantilla,
  });

  final String mensaje;
  final bool esModoPlantilla;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingMedium),
      decoration: BoxDecoration(
        color: esModoPlantilla
            ? AppColors.info.withValues(alpha: 0.1)
            : AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        border: Border.all(
          color: esModoPlantilla
              ? AppColors.info.withValues(alpha: 0.3)
              : AppColors.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: <Widget>[
          Icon(
            Icons.info_outline,
            size: 18,
            color: esModoPlantilla ? AppColors.info : AppColors.primary,
          ),
          const SizedBox(width: AppSizes.spacingSmall),
          Expanded(
            child: Text(
              mensaje,
              style: GoogleFonts.inter(
                fontSize: AppSizes.fontSmall,
                color: AppColors.textPrimaryLight,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
