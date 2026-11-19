import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/features/alertas_caducidad/presentation/bloc/alertas_caducidad_bloc.dart';
import 'package:ambutrack_web/features/alertas_caducidad/presentation/bloc/alertas_caducidad_event.dart';
import 'package:ambutrack_web/features/alertas_caducidad/presentation/bloc/alertas_caducidad_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';


/// Banner de alertas próximas a vencer (1 día)
///
/// Se muestra en el dashboard cuando hay documentos que caducan mañana.
/// Muestra el listado de vehículos/ítems con su tipo y fecha de caducidad.
class AlertasProximasBanner extends StatelessWidget {
  const AlertasProximasBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AlertasCaducidadBloc, AlertasCaducidadState>(
      buildWhen: (AlertasCaducidadState previous, AlertasCaducidadState current) {
        return current.maybeWhen(
          loaded: (List<AlertaCaducidadEntity> alertas, _, __, ___, ____) => true,
          orElse: () => false,
        );
      },
      builder: (BuildContext context, AlertasCaducidadState state) {
        return state.maybeWhen(
          loaded: (List<AlertaCaducidadEntity> alertas, _, __, ___, ____) {
            final List<AlertaCaducidadEntity> proximas = alertas
                .where((AlertaCaducidadEntity a) => a.diasRestantes == 1)
                .toList();

            if (proximas.isEmpty) {
              return const SizedBox.shrink();
            }

            return Column(
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.all(AppSizes.padding),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                border: Border.all(
                  color: AppColors.warning.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.warning.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.schedule_send_rounded,
                          size: 20,
                          color: AppColors.warning,
                        ),
                      ),
                      const SizedBox(width: AppSizes.spacingSmall),
                      Expanded(
                        child: Text(
                          '${proximas.length} documento${proximas.length == 1 ? '' : 's'} caduca${proximas.length == 1 ? '' : 'n'} mañana',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.gray900,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.spacingSmall),
                  ...proximas.map((AlertaCaducidadEntity alerta) {
                    return Padding(
                      padding: const EdgeInsets.only(top: AppSizes.spacingXs),
                      child: Row(
                        children: <Widget>[
                          const SizedBox(width: 36),
                          Icon(
                            _getTipoIcon(alerta.tipo),
                            size: 16,
                            color: AppColors.warning,
                          ),
                          const SizedBox(width: AppSizes.spacingSmall),
                          Expanded(
                            child: Text(
                              alerta.entidadNombre,
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: AppColors.gray700,
                              ),
                            ),
                          ),
                          Text(
                            _getTipoLabel(alerta.tipo),
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: AppColors.gray500,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: AppSizes.spacingSmall),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: () {
                        context.read<AlertasCaducidadBloc>().add(
                              const AlertasCaducidadEvent.refresh(),
                            );
                      },
                      icon: const Icon(Icons.refresh, size: 16),
                      label: Text(
                        'Actualizar',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppColors.warning,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        );
      },
          orElse: () => const SizedBox.shrink(),
        );
      },
    );
  }

  IconData _getTipoIcon(AlertaTipo tipo) {
    switch (tipo) {
      case AlertaTipo.seguro:
        return Icons.verified_user;
      case AlertaTipo.itv:
        return Icons.build;
      case AlertaTipo.homologacion:
        return Icons.description;
      case AlertaTipo.revisionTecnica:
        return Icons.handyman;
      case AlertaTipo.mantenimiento:
        return Icons.build_circle;
      case AlertaTipo.revision:
        return Icons.miscellaneous_services;
      case AlertaTipo.equipamiento:
        return Icons.medical_services;
    }
  }

  String _getTipoLabel(AlertaTipo tipo) {
    switch (tipo) {
      case AlertaTipo.seguro:
        return 'Seguro';
      case AlertaTipo.itv:
        return 'ITV';
      case AlertaTipo.homologacion:
        return 'Homologación';
      case AlertaTipo.revisionTecnica:
        return 'Revisión Técnica';
      case AlertaTipo.mantenimiento:
        return 'Mantenimiento';
      case AlertaTipo.revision:
        return 'Revisión';
      case AlertaTipo.equipamiento:
        return 'Equipamiento';
    }
  }
}
