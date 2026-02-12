import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../bloc/registro_horario_state.dart';

/// Widget que muestra el estado actual del fichaje (Dentro/Fuera)
class EstadoActualWidget extends StatelessWidget {
  const EstadoActualWidget({
    super.key,
    required this.estadoActual,
    this.ultimoRegistro,
  });

  final EstadoFichaje estadoActual;
  final RegistroHorarioEntity? ultimoRegistro;

  @override
  Widget build(BuildContext context) {
    final estaAdentro = estadoActual == EstadoFichaje.dentro;
    final color = estaAdentro ? AppColors.success : AppColors.gray500;
    final backgroundColor = estaAdentro
        ? AppColors.success.withValues(alpha: 0.1)
        : AppColors.gray100;
    final icono = estaAdentro ? Icons.check_circle_rounded : Icons.cancel_rounded;
    final texto = estaAdentro ? 'DENTRO' : 'FUERA';

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: estaAdentro
              ? [Colors.white, AppColors.success.withValues(alpha: 0.05)]
              : [Colors.white, AppColors.gray50],
        ),
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        boxShadow: [
          BoxShadow(
            color: estaAdentro
                ? AppColors.success.withValues(alpha: 0.08)
                : AppColors.gray200.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Estado principal en una fila compacta
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                  ),
                  child: Icon(
                    icono,
                    color: color,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Estado Actual',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.gray600,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        texto,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: color,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Información del último fichaje
            if (ultimoRegistro != null) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                height: 1,
                color: AppColors.gray200,
              ),
              const SizedBox(height: 12),
              _buildUltimoFichajeInfo(context),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildUltimoFichajeInfo(BuildContext context) {
    if (ultimoRegistro == null) return const SizedBox.shrink();

    final tipo = ultimoRegistro!.tipo.toLowerCase() == 'entrada'
        ? 'Entrada'
        : 'Salida';
    final fecha = DateFormat('dd/MM/yyyy').format(ultimoRegistro!.fechaHora);
    final hora = DateFormat('HH:mm').format(ultimoRegistro!.fechaHora);

    // Calcular duración de la jornada si está dentro
    String? duracion;
    if (estadoActual == EstadoFichaje.dentro) {
      final diff = DateTime.now().difference(ultimoRegistro!.fechaHora);
      final horas = diff.inHours;
      final minutos = diff.inMinutes.remainder(60);
      duracion = '${horas}h ${minutos}m';
    }

    return Row(
      children: [
        // Último fichaje
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.schedule_rounded,
                    size: 14,
                    color: AppColors.gray500,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Último: ',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.gray600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    tipo,
                    style: TextStyle(
                      fontSize: 11,
                      color: ultimoRegistro!.tipo.toLowerCase() == 'entrada'
                          ? AppColors.success
                          : AppColors.error,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '$fecha a las $hora',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.gray700,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),

        // Duración de la jornada
        if (duracion != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.timer_rounded,
                  size: 16,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 4),
                Text(
                  duracion,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
