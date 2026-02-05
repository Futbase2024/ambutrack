import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/datasources/registros_horarios/registros_horarios_datasource.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';

/// Widget que muestra el historial de fichajes
class HistorialFichajesWidget extends StatelessWidget {
  const HistorialFichajesWidget({
    super.key,
    required this.historial,
  });

  final List<RegistroHorarioEntity> historial;

  @override
  Widget build(BuildContext context) {
    if (historial.isEmpty) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
          boxShadow: [
            BoxShadow(
              color: AppColors.gray200.withValues(alpha: 0.3),
              blurRadius: 15,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.gray100,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.history_rounded,
                  size: 32,
                  color: AppColors.gray400,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'No hay fichajes registrados',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.gray700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Tus fichajes aparecerán aquí',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.gray500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Título
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Row(
            children: [
              Icon(
                Icons.history_rounded,
                size: 18,
                color: AppColors.gray700,
              ),
              const SizedBox(width: 6),
              Text(
                'Historial de Fichajes',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.gray800,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                ),
                child: Text(
                  '${historial.length}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Lista de fichajes
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: historial.length,
          itemBuilder: (context, index) {
            return _buildFichajeCard(context, historial[index]);
          },
        ),
      ],
    );
  }

  Widget _buildFichajeCard(BuildContext context, RegistroHorarioEntity registro) {
    final esEntrada = registro.tipoFichaje == TipoFichaje.entrada;
    final color = esEntrada ? AppColors.success : AppColors.error;
    final backgroundColor = color.withValues(alpha: 0.08);
    final icono = esEntrada ? Icons.login_rounded : Icons.logout_rounded;
    final tipo = esEntrada ? 'ENTRADA' : 'SALIDA';

    final fecha = DateFormat('dd/MM/yyyy').format(registro.fechaHora);
    final hora = DateFormat('HH:mm:ss').format(registro.fechaHora);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        border: Border.all(
          color: color.withValues(alpha: 0.15),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.08),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icono tipo de fichaje
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    backgroundColor,
                    color.withValues(alpha: 0.15),
                  ],
                ),
                borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
              ),
              child: Icon(
                icono,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),

            // Información del fichaje
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badge tipo de fichaje
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: backgroundColor,
                      borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                    ),
                    child: Text(
                      tipo,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: color,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Fecha y hora
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today_rounded,
                        size: 13,
                        color: AppColors.gray600,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        fecha,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.gray700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Icon(
                        Icons.access_time_rounded,
                        size: 13,
                        color: AppColors.gray600,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        hora,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.gray800,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),

                  // Ubicación GPS
                  if (registro.latitud != null && registro.longitud != null) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.gray50,
                        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.location_on_rounded,
                                size: 12,
                                color: AppColors.gray600,
                              ),
                              const SizedBox(width: 5),
                              Expanded(
                                child: Text(
                                  '${registro.latitud!.toStringAsFixed(6)}, ${registro.longitud!.toStringAsFixed(6)}',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: AppColors.gray700,
                                    fontFamily: 'monospace',
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          if (registro.precisionGps != null) ...[
                            const SizedBox(height: 3),
                            Row(
                              children: [
                                Icon(
                                  Icons.my_location_rounded,
                                  size: 10,
                                  color: AppColors.gray500,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  'Precisión: ±${registro.precisionGps!.toStringAsFixed(0)}m',
                                  style: TextStyle(
                                    fontSize: 9,
                                    color: AppColors.gray600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],

                  // Observaciones
                  if (registro.observaciones != null &&
                      registro.observaciones!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                        border: Border.all(
                          color: AppColors.warning.withValues(alpha: 0.2),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.comment_rounded,
                            size: 12,
                            color: AppColors.warning,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              registro.observaciones!,
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.gray700,
                                fontStyle: FontStyle.italic,
                                height: 1.3,
                              ),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
