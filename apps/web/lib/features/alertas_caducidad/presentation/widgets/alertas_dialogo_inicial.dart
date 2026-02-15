import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../bloc/alertas_caducidad_bloc.dart';
import '../bloc/alertas_caducidad_state.dart';

/// Diálogo de alertas críticas que se muestra al inicio de la aplicación.
///
/// Muestra directamente el contenido del diálogo con las alertas críticas.
class AlertasDialogoInicial extends StatelessWidget {
  const AlertasDialogoInicial({
    required this.usuarioId,
    super.key,
  });

  final String usuarioId;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AlertasCaducidadBloc, AlertasCaducidadState>(
      builder: (BuildContext context, AlertasCaducidadState state) {
        return state.maybeWhen(
          loaded: (List<AlertaCaducidadEntity> alertas, _, _, _, _) {
            final List<AlertaCaducidadEntity> criticas =
                alertas.where((AlertaCaducidadEntity a) => a.esCritica).toList();

            if (criticas.isEmpty) {
              // Si no hay alertas críticas, cerrar el diálogo automáticamente
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (context.mounted) {
                  Navigator.of(context).pop();
                }
              });
              return const SizedBox.shrink();
            }

            // Mostrar el diálogo con las alertas críticas
            return _DialogContent(criticas: criticas);
          },
          loading: () => const Center(
            child: CircularProgressIndicator(),
          ),
          orElse: () => const SizedBox.shrink(),
        );
      },
    );
  }
}

/// Contenido del diálogo de alertas críticas.
class _DialogContent extends StatelessWidget {
  const _DialogContent({required this.criticas});

  final List<AlertaCaducidadEntity> criticas;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 700),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            // Header con icono de advertencia
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.emergency.withValues(alpha: 0.1),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
              ),
              child: Row(
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: AppColors.emergency,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '⚠️ Alertas Críticas de Caducidad',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.gray900,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Mensaje descriptivo
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                'Tienes ${criticas.length} alerta(s) que requieren atención inmediata:',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppColors.gray700,
                  height: 1.4,
                ),
              ),
            ),

            // Lista de alertas críticas
            Flexible(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                shrinkWrap: true,
                itemCount: criticas.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (BuildContext context, int index) {
                  final AlertaCaducidadEntity alerta = criticas[index];
                  return _AlertaCriticaTile(alerta: alerta);
                },
              ),
            ),

            // Botón de acción
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(
                          color: AppColors.gray400,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'Cerrar',
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.gray700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        // TODO(team): Navegar a la página de alertas
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.emergency,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'Ver Detalles',
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
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

/// Tile para mostrar una alerta crítica en el diálogo.
class _AlertaCriticaTile extends StatelessWidget {
  const _AlertaCriticaTile({required this.alerta});

  final AlertaCaducidadEntity alerta;

  @override
  Widget build(BuildContext context) {
    final IconData icono = _getIcono(alerta.tipo);
    final int dias = alerta.diasRestantes;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.emergency.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icono,
          color: AppColors.emergency,
          size: 24,
        ),
      ),
      title: Text(
        alerta.entidadNombre,
        style: GoogleFonts.inter(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: AppColors.gray900,
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const SizedBox(height: 4),
          Text(
            _getTipoLabel(alerta.tipo),
            style: GoogleFonts.inter(
              fontSize: 12,
              color: AppColors.gray600,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _getDiasColor(dias),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              _getDiasTexto(dias),
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIcono(AlertaTipo tipo) {
    switch (tipo) {
      case AlertaTipo.seguro:
        return Icons.security;
      case AlertaTipo.itv:
        return Icons.verified_user;
      case AlertaTipo.homologacion:
        return Icons.health_and_safety;
      case AlertaTipo.revisionTecnica:
        return Icons.build;
      case AlertaTipo.revision:
        return Icons.settings;
      case AlertaTipo.mantenimiento:
        return Icons.handyman;
    }
  }

  String _getTipoLabel(AlertaTipo tipo) {
    switch (tipo) {
      case AlertaTipo.seguro:
        return 'Seguro';
      case AlertaTipo.itv:
        return 'Inspección Técnica (ITV)';
      case AlertaTipo.homologacion:
        return 'Homologación Sanitaria';
      case AlertaTipo.revisionTecnica:
        return 'Revisión Técnica';
      case AlertaTipo.revision:
        return 'Revisión';
      case AlertaTipo.mantenimiento:
        return 'Mantenimiento';
    }
  }

  Color _getDiasColor(int dias) {
    if (dias <= 3) {
      return AppColors.emergency;
    }
    if (dias <= 5) {
      return AppColors.error;
    }
    return AppColors.warning;
  }

  String _getDiasTexto(int dias) {
    if (dias == 0) {
      return 'VENCE HOY';
    }
    if (dias == 1) {
      return 'VENCE MAÑANA';
    }
    return 'VENCE EN $dias DÍAS';
  }
}
