import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../bloc/alertas_caducidad_bloc.dart';
import '../bloc/alertas_caducidad_event.dart';
import '../bloc/alertas_caducidad_state.dart';

/// Badge de alertas de caducidad para el AppBar.
///
/// Muestra un contador con el total de alertas activas.
/// Al hacer clic, despliega un menú con las alertas más recientes.
class AlertasBadgeAppBar extends StatelessWidget {
  const AlertasBadgeAppBar({
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
          final int totalCount = state.maybeWhen(
            loaded: (_, AlertasResumenEntity resumen, _, _, _) => resumen.total,
            orElse: () => 0,
          );

          return IconButton(
            icon: Stack(
              clipBehavior: Clip.none,
              children: <Widget>[
                const Icon(Icons.notification_important_outlined),
                if (totalCount > 0)
                  Positioned(
                    right: -6,
                    top: -6,
                    child: _BadgeContador(count: totalCount),
                  ),
              ],
            ),
            tooltip: totalCount > 0
                ? '$totalCount alertas de caducidad'
                : 'Sin alertas',
            onPressed: () => _onPressed(context, state),
          );
        },
      ),
    );
  }

  /// Maneja el clic en el badge.
  void _onPressed(BuildContext context, AlertasCaducidadState state) {
    state.maybeWhen(
      loaded: (List<AlertaCaducidadEntity> alertas, AlertasResumenEntity resumen, _, _, _) {
        if (alertas.isEmpty) {
          _showEmptyDialog(context);
        } else {
          _showAlertasDialog(context, alertas, resumen);
        }
      },
      orElse: () {},
    );
  }

  /// Muestra el diálogo con las alertas.
  void _showAlertasDialog(
    BuildContext context,
    List<AlertaCaducidadEntity> alertas,
    AlertasResumenEntity resumen,
  ) {
    showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.white,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: <Widget>[
                    const Icon(
                      Icons.notification_important,
                      color: AppColors.primary,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Alertas de Caducidad',
                        style: GoogleFonts.inter(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.gray900,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(dialogContext).pop(),
                    ),
                  ],
                ),
              ),

              // Resumen
              if (resumen.total > 0)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: <Widget>[
                      if (resumen.criticas > 0)
                        _ResumenChip(
                          label: 'Críticas',
                          count: resumen.criticas,
                          color: AppColors.emergency,
                        ),
                      if (resumen.altas > 0)
                        _ResumenChip(
                          label: 'Altas',
                          count: resumen.altas,
                          color: AppColors.error,
                        ),
                      if (resumen.medias > 0)
                        _ResumenChip(
                          label: 'Medias',
                          count: resumen.medias,
                          color: AppColors.warning,
                        ),
                      if (resumen.bajas > 0)
                        _ResumenChip(
                          label: 'Bajas',
                          count: resumen.bajas,
                          color: AppColors.info,
                        ),
                    ],
                  ),
                ),

              // Lista de alertas
              Flexible(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  shrinkWrap: true,
                  itemCount: alertas.length > 10 ? 10 : alertas.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (BuildContext context, int index) {
                    final AlertaCaducidadEntity alerta = alertas[index];
                    return _AlertaTile(alerta: alerta);
                  },
                ),
              ),

              // Footer
              if (alertas.length > 10)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Mostrando las primeras 10 de ${alertas.length} alertas',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppColors.gray600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// Muestra diálogo cuando no hay alertas.
  void _showEmptyDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.white,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_outline,
                  size: 48,
                  color: AppColors.success,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '¡Todo en orden!',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.gray900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'No hay alertas de caducidad activas',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppColors.gray600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('Cerrar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Badge contador con animación.
class _BadgeContador extends StatelessWidget {
  const _BadgeContador({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor = _getBadgeColor(count);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white, width: 1.5),
      ),
      constraints: const BoxConstraints(minWidth: 18),
      child: Text(
        count > 99 ? '99+' : count.toString(),
        style: GoogleFonts.inter(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          height: 1,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Color _getBadgeColor(int count) {
    // Basado en severidad (simulado aquí, en real vendría del estado)
    if (count >= 10) {
      return AppColors.emergency;
    }
    if (count >= 5) {
      return AppColors.error;
    }
    return AppColors.warning;
  }
}

/// Tile para mostrar una alerta en la lista.
class _AlertaTile extends StatelessWidget {
  const _AlertaTile({required this.alerta});

  final AlertaCaducidadEntity alerta;

  @override
  Widget build(BuildContext context) {
    final Color severityColor = _getSeverityColor(alerta.severidad);
    final IconData severityIcon = _getSeverityIcon(alerta.tipo);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: severityColor.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          severityIcon,
          color: severityColor,
          size: 20,
        ),
      ),
      title: Text(
        alerta.entidadNombre,
        style: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.gray900,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        _getSubtitle(),
        style: GoogleFonts.inter(
          fontSize: 12,
          color: AppColors.gray600,
        ),
      ),
      trailing: _SeverityLabel(severidad: alerta.severidad),
    );
  }

  String _getSubtitle() {
    final String tipoLabel = _getTipoLabel(alerta.tipo);
    final int dias = alerta.diasRestantes;
    return '$tipoLabel • $dias días restantes';
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
      case AlertaTipo.revision:
        return 'Revisión';
      case AlertaTipo.mantenimiento:
        return 'Mantenimiento';
    }
  }

  Color _getSeverityColor(AlertaSeveridad severidad) {
    switch (severidad) {
      case AlertaSeveridad.critica:
        return AppColors.emergency;
      case AlertaSeveridad.alta:
        return AppColors.error;
      case AlertaSeveridad.media:
        return AppColors.warning;
      case AlertaSeveridad.baja:
        return AppColors.info;
    }
  }

  IconData _getSeverityIcon(AlertaTipo tipo) {
    switch (tipo) {
      case AlertaTipo.seguro:
        return Icons.security_outlined;
      case AlertaTipo.itv:
        return Icons.verified_user_outlined;
      case AlertaTipo.homologacion:
        return Icons.health_and_safety_outlined;
      case AlertaTipo.revisionTecnica:
        return Icons.build_outlined;
      case AlertaTipo.revision:
        return Icons.settings_outlined;
      case AlertaTipo.mantenimiento:
        return Icons.handyman_outlined;
    }
  }
}

/// Etiqueta de severidad.
class _SeverityLabel extends StatelessWidget {
  const _SeverityLabel({required this.severidad});

  final AlertaSeveridad severidad;

  @override
  Widget build(BuildContext context) {
    final Color color = _getSeverityColor(severidad);
    final String label = _getSeverityLabel(severidad);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Color _getSeverityColor(AlertaSeveridad severidad) {
    switch (severidad) {
      case AlertaSeveridad.critica:
        return AppColors.emergency;
      case AlertaSeveridad.alta:
        return AppColors.error;
      case AlertaSeveridad.media:
        return AppColors.warning;
      case AlertaSeveridad.baja:
        return AppColors.info;
    }
  }

  String _getSeverityLabel(AlertaSeveridad severidad) {
    switch (severidad) {
      case AlertaSeveridad.critica:
        return 'CRÍTICA';
      case AlertaSeveridad.alta:
        return 'ALTA';
      case AlertaSeveridad.media:
        return 'MEDIA';
      case AlertaSeveridad.baja:
        return 'BAJA';
    }
  }
}

/// Chip de resumen para el header del diálogo.
class _ResumenChip extends StatelessWidget {
  const _ResumenChip({
    required this.label,
    required this.count,
    required this.color,
  });

  final String label;
  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color),
      ),
      child: Text(
        '$label: $count',
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
