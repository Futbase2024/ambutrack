import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../bloc/alertas_caducidad_bloc.dart';
import '../bloc/alertas_caducidad_event.dart';
import '../bloc/alertas_caducidad_state.dart';

/// Card de resumen de alertas de caducidad para el Dashboard.
///
/// Muestra un resumen visual de las alertas agrupadas por severidad
/// y permite ver el detalle completo.
class AlertasDashboardCard extends StatelessWidget {
  const AlertasDashboardCard({
    this.usuarioId,
    super.key,
  });

  final String? usuarioId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AlertasCaducidadBloc>(
      create: (_) => getIt<AlertasCaducidadBloc>()
        ..add(const AlertasCaducidadEvent.started()),
      child: BlocBuilder<AlertasCaducidadBloc, AlertasCaducidadState>(
        builder: (BuildContext context, AlertasCaducidadState state) {
          return state.when(
            initial: () => const _LoadingCard(),
            loading: () => const _LoadingCard(),
            loaded: (List<AlertaCaducidadEntity> alertas, AlertasResumenEntity resumen, _, _, _) {
              if (resumen.total == 0) {
                return const _EmptyCard();
              }
              return _ResumenCard(resumen: resumen);
            },
            error: (String message, _, __) => _ErrorCard(message: message),
          );
        },
      ),
    );
  }
}

/// Card con indicador de carga.
class _LoadingCard extends StatelessWidget {
  const _LoadingCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Padding(
        padding: EdgeInsets.all(24),
        child: Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}

/// Card cuando no hay alertas.
class _EmptyCard extends StatelessWidget {
  const _EmptyCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_outline,
                color: AppColors.success,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Sin Alertas',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.gray900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'No hay cadecidades próximas',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: AppColors.gray600,
                    ),
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

/// Card de error.
class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline,
                color: AppColors.error,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Error al cargar',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.gray900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: AppColors.gray600,
                    ),
                    maxLines: 2,
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

/// Card con resumen de alertas.
class _ResumenCard extends StatelessWidget {
  const _ResumenCard({required this.resumen});

  final AlertasResumenEntity resumen;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Header
            Row(
              children: <Widget>[
                const Icon(
                  Icons.notification_important,
                  color: AppColors.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Alertas de Caducidad',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.gray900,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${resumen.total} Total',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Resumen por severidad
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: <Widget>[
                if (resumen.criticas > 0)
                  _SeveridadChip(
                    label: 'Críticas',
                    count: resumen.criticas,
                    color: AppColors.emergency,
                    icon: Icons.warning,
                  ),
                if (resumen.altas > 0)
                  _SeveridadChip(
                    label: 'Altas',
                    count: resumen.altas,
                    color: AppColors.error,
                    icon: Icons.error_outline,
                  ),
                if (resumen.medias > 0)
                  _SeveridadChip(
                    label: 'Medias',
                    count: resumen.medias,
                    color: AppColors.warning,
                    icon: Icons.info_outline,
                  ),
                if (resumen.bajas > 0)
                  _SeveridadChip(
                    label: 'Bajas',
                    count: resumen.bajas,
                    color: AppColors.info,
                    icon: Icons.info_outlined,
                  ),
              ],
            ),

            if (resumen.criticas > 0)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.emergency.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.emergency.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: <Widget>[
                      const Icon(
                        Icons.priority_high,
                        color: AppColors.emergency,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Tienes ${resumen.criticas} alerta(s) crítica(s) que requieren atención inmediata',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.emergency,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Chip de severidad para el resumen.
class _SeveridadChip extends StatelessWidget {
  const _SeveridadChip({
    required this.label,
    required this.count,
    required this.color,
    required this.icon,
  });

  final String label;
  final int count;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            icon,
            color: color,
            size: 16,
          ),
          const SizedBox(width: 6),
          Text(
            '$label: ',
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
          Text(
            count.toString(),
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
