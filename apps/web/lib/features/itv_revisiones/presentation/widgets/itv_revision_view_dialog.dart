import 'package:ambutrack_core/ambutrack_core.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/core/widgets/buttons/app_button.dart';
import 'package:ambutrack_web/core/widgets/dialogs/app_dialog.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

/// Diálogo para ver detalles de ITV/Revisión
class ItvRevisionViewDialog extends StatelessWidget {
  const ItvRevisionViewDialog({required this.itvRevision, super.key});

  final ItvRevisionEntity itvRevision;

  @override
  Widget build(BuildContext context) {
    final Color resultadoColor = _getResultadoColor(itvRevision.resultado);

    return AppDialog(
      title: 'Detalles de ITV/Revisión\n${itvRevision.tipo.displayName}',
      icon: Icons.fact_check,
      maxWidth: 700,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _buildSection('Información General', Icons.info_outline, AppColors.primary, <Widget>[
            _buildDetailItem('Tipo', itvRevision.tipo.displayName),
            _buildDetailItem('Resultado', itvRevision.resultado.displayName, valueColor: resultadoColor),
            _buildDetailItem('Estado', itvRevision.estado.displayName),
            _buildDetailItem('Fecha', DateFormat('dd/MM/yyyy').format(itvRevision.fecha)),
            if (itvRevision.fechaVencimiento != null)
              _buildDetailItem('Vencimiento', DateFormat('dd/MM/yyyy').format(itvRevision.fechaVencimiento!)),
            _buildDetailItem('Kilometraje', '${itvRevision.kmVehiculo.toStringAsFixed(0)} km'),
            _buildDetailItem('Costo Total', '${itvRevision.costoTotal.toStringAsFixed(2)} €'),
          ]),
          if (itvRevision.taller != null || itvRevision.numeroDocumento != null) ...<Widget>[
            const SizedBox(height: AppSizes.spacing),
            _buildSection('Datos del Taller', Icons.garage, AppColors.secondary, <Widget>[
              if (itvRevision.taller != null) _buildDetailItem('Taller', itvRevision.taller!),
              if (itvRevision.numeroDocumento != null) _buildDetailItem('Nº Documento', itvRevision.numeroDocumento!),
            ]),
          ],
          if (itvRevision.observaciones != null && itvRevision.observaciones!.isNotEmpty) ...<Widget>[
            const SizedBox(height: AppSizes.spacing),
            _buildSection('Observaciones', Icons.notes, AppColors.warning, <Widget>[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSizes.padding),
                decoration: BoxDecoration(
                  color: AppColors.backgroundLight,
                  borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                ),
                child: Text(itvRevision.observaciones!, style: const TextStyle(fontSize: 14)),
              ),
            ]),
          ],
        ],
      ),
      actions: <Widget>[
        AppButton(
          label: 'Cerrar',
          onPressed: () => Navigator.of(context).pop(),
          variant: AppButtonVariant.secondary,
        ),
      ],
    );
  }

  Widget _buildSection(String title, IconData icon, Color color, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: AppSizes.paddingMedium),
            Text(title, style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: AppSizes.padding),
        ...children,
      ],
    );
  }

  Widget _buildDetailItem(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.paddingMedium),
      child: Row(
        children: <Widget>[
          SizedBox(
            width: 180,
            child: Text(label, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textSecondaryLight)),
          ),
          Expanded(
            child: Text(value, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: valueColor ?? AppColors.textPrimaryLight)),
          ),
        ],
      ),
    );
  }

  Color _getResultadoColor(ResultadoItvRevision resultado) {
    switch (resultado) {
      case ResultadoItvRevision.favorable:
        return AppColors.success;
      case ResultadoItvRevision.desfavorable:
        return AppColors.warning;
      case ResultadoItvRevision.negativo:
        return AppColors.error;
      case ResultadoItvRevision.pendiente:
        return AppColors.gray600;
    }
  }
}
