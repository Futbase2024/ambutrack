import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'helpers/alerta_helpers.dart';

/// Muestra un diálogo con el detalle completo de una alerta individual
Future<void> showAlertaDetalleDialog({
  required BuildContext context,
  required AlertaCaducidadEntity alerta,
  required VoidCallback onMarcarVisto,
}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext dialogContext) => _AlertaDetalleContent(
      alerta: alerta,
      onMarcarVisto: onMarcarVisto,
    ),
  );
}

/// Contenido del diálogo de detalle de alerta
class _AlertaDetalleContent extends StatelessWidget {
  const _AlertaDetalleContent({
    required this.alerta,
    required this.onMarcarVisto,
  });

  final AlertaCaducidadEntity alerta;
  final VoidCallback onMarcarVisto;

  @override
  Widget build(BuildContext context) {
    final AlertaTipoConfig tipoConfig = getAlertaTipoConfig(alerta.tipo);
    final Color diasColor = getDiasRestantesColor(alerta.diasRestantes);
    final String diasTexto = getDiasRestantesText(alerta.diasRestantes);
    final ({String label, Color color}) sevConfig = getSeveridadConfig(alerta.severidad);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
      ),
      child: Container(
        width: 480,
        constraints: const BoxConstraints(maxHeight: 560),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
          color: Colors.white,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            _DetalleHeader(tipoConfig: tipoConfig, entidadNombre: alerta.entidadNombre),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSizes.paddingXl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _InfoRow(
                      icon: tipoConfig.icon,
                      label: 'Tipo de alerta',
                      value: tipoConfig.label,
                      valueColor: tipoConfig.color,
                      valueBgColor: tipoConfig.color.withValues(alpha: 0.1),
                    ),
                    const SizedBox(height: AppSizes.spacing),
                    _InfoRow(
                      icon: Icons.business,
                      label: 'Entidad',
                      value: alerta.entidadNombre,
                    ),
                    const SizedBox(height: AppSizes.spacing),
                    _InfoRow(
                      icon: Icons.calendar_today,
                      label: 'Fecha de caducidad',
                      value: DateFormat('dd/MM/yyyy').format(alerta.fechaCaducidad),
                    ),
                    const SizedBox(height: AppSizes.spacing),
                    _InfoRow(
                      icon: Icons.timer_outlined,
                      label: 'Días restantes',
                      value: diasTexto,
                      valueColor: diasColor,
                      valueBgColor: diasColor.withValues(alpha: 0.1),
                    ),
                    const SizedBox(height: AppSizes.spacing),
                    _InfoRow(
                      icon: Icons.flag,
                      label: 'Severidad',
                      value: sevConfig.label,
                      valueColor: sevConfig.color,
                      valueBgColor: sevConfig.color.withValues(alpha: 0.1),
                    ),
                  ],
                ),
              ),
            ),
            const Divider(height: 1, color: AppColors.gray200),
            _DetalleFooter(
              tipoConfig: tipoConfig,
              onMarcarVisto: () {
                Navigator.of(context).pop();
                onMarcarVisto();
              },
              onNavegar: () {
                Navigator.of(context).pop();
                abrirDestinoAlerta(context, alerta);
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Header del diálogo de detalle
class _DetalleHeader extends StatelessWidget {
  const _DetalleHeader({
    required this.tipoConfig,
    required this.entidadNombre,
  });

  final AlertaTipoConfig tipoConfig;
  final String entidadNombre;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingXl),
      decoration: BoxDecoration(
        color: tipoConfig.color.withValues(alpha: 0.08),
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppSizes.radiusLarge),
        ),
      ),
      child: Row(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(AppSizes.paddingMedium),
            decoration: BoxDecoration(
              color: tipoConfig.color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              tipoConfig.icon,
              size: AppSizes.iconLarge,
              color: tipoConfig.color,
            ),
          ),
          const SizedBox(width: AppSizes.spacing),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Detalle de ${tipoConfig.label}',
                  style: GoogleFonts.inter(
                    fontSize: AppSizes.fontMedium,
                    fontWeight: FontWeight.w700,
                    color: AppColors.gray900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  entidadNombre,
                  style: GoogleFonts.inter(
                    fontSize: AppSizes.fontSmall,
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
    );
  }
}

/// Fila de información con icono, label y valor
class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
    this.valueBgColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;
  final Color? valueBgColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Icon(icon, size: AppSizes.iconMedium, color: AppColors.gray500),
        const SizedBox(width: AppSizes.spacingSmall),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: AppSizes.fontSmall,
            color: AppColors.gray600,
          ),
        ),
        const Spacer(),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: valueBgColor != null ? AppSizes.spacingSmall : 0,
            vertical: valueBgColor != null ? AppSizes.spacingXs : 0,
          ),
          decoration: BoxDecoration(
            color: valueBgColor,
            borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
          ),
          child: Text(
            value,
            style: GoogleFonts.inter(
              fontSize: AppSizes.fontSmall,
              fontWeight: FontWeight.w600,
              color: valueColor ?? AppColors.gray900,
            ),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}

/// Footer con botones de acción
class _DetalleFooter extends StatelessWidget {
  const _DetalleFooter({
    required this.tipoConfig,
    required this.onMarcarVisto,
    required this.onNavegar,
  });

  final AlertaTipoConfig tipoConfig;
  final VoidCallback onMarcarVisto;
  final VoidCallback onNavegar;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSizes.paddingXl),
      child: Row(
        children: <Widget>[
          Expanded(
            child: OutlinedButton.icon(
              onPressed: onMarcarVisto,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.warning,
                side: const BorderSide(color: AppColors.warning),
                padding: const EdgeInsets.symmetric(vertical: AppSizes.padding),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                ),
              ),
              icon: const Icon(Icons.visibility_off_outlined, size: AppSizes.iconMedium),
              label: Text(
                'Marcar como Visto',
                style: GoogleFonts.inter(
                  fontSize: AppSizes.fontSmall,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSizes.spacing),
          Expanded(
            child: FilledButton.icon(
              onPressed: onNavegar,
              style: FilledButton.styleFrom(
                backgroundColor: tipoConfig.color,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: AppSizes.padding),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                ),
              ),
              icon: const Icon(Icons.open_in_new, size: AppSizes.iconMedium),
              label: Text(
                'Ir a ${tipoConfig.label}',
                style: GoogleFonts.inter(
                  fontSize: AppSizes.fontSmall,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
