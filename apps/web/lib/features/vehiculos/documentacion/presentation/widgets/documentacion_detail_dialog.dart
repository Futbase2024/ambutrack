import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/core/widgets/buttons/app_button.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Diálogo de detalle para mostrar la información completa de un documento
class DocumentacionDetailDialog extends StatelessWidget {
  const DocumentacionDetailDialog({
    super.key,
    required this.documento,
  });

  final DocumentacionVehiculoEntity documento;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
      ),
      child: Container(
        width: 550,
        constraints: const BoxConstraints(maxWidth: 550),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _buildHeader(context),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSizes.paddingXl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    _buildTipoCard(),
                    const SizedBox(height: AppSizes.spacing),
                    _buildInfoSection(),
                    const SizedBox(height: AppSizes.spacing),
                    _buildFechasSection(),
                    const SizedBox(height: AppSizes.spacing),
                    _buildEstadoSection(),
                    if (documento.observaciones != null &&
                        documento.observaciones!.isNotEmpty) ...<Widget>[
                      const SizedBox(height: AppSizes.spacing),
                      _buildObservacionesSection(),
                    ],
                  ],
                ),
              ),
            ),
            _buildActions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingXl),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.05),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(AppSizes.radiusLarge),
          topRight: Radius.circular(AppSizes.radiusLarge),
        ),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
            ),
            child: const Icon(
              Icons.description_outlined,
              color: AppColors.primary,
              size: 32,
            ),
          ),
          const SizedBox(width: AppSizes.paddingMedium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  _getTipoLabel(),
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimaryLight,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  documento.numeroPoliza,
                  style: GoogleFonts.inter(
                    fontSize: AppSizes.fontMedium,
                    color: AppColors.textSecondaryLight,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
            color: AppColors.textSecondaryLight,
          ),
        ],
      ),
    );
  }

  Widget _buildTipoCard() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.padding),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: <Widget>[
          Icon(
            _getTipoIcon(),
            color: AppColors.primary,
            size: 24,
          ),
          const SizedBox(width: AppSizes.paddingMedium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  _getTipoLabel(),
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  documento.compania,
                  style: GoogleFonts.inter(
                    fontSize: AppSizes.fontSmall,
                    color: AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Información del Documento',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondaryLight,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: AppSizes.paddingMedium),
        Container(
          padding: const EdgeInsets.all(AppSizes.padding),
          decoration: BoxDecoration(
            color: AppColors.gray50,
            borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
            border: Border.all(color: AppColors.gray200),
          ),
          child: Column(
            children: <Widget>[
              _buildInfoRow(
                'Número de Póliza',
                documento.numeroPoliza,
                Icons.numbers,
              ),
              const Divider(height: 1, color: AppColors.gray200),
              _buildInfoRow(
                'Compañía/Entidad',
                documento.compania,
                Icons.business,
              ),
              if (documento.costeAnual != null) ...<Widget>[
                const Divider(height: 1, color: AppColors.gray200),
                _buildInfoRow(
                  'Coste Anual',
                  '${documento.costeAnual!.toStringAsFixed(2)} €',
                  Icons.euro,
                ),
              ],
              const Divider(height: 1, color: AppColors.gray200),
              _buildInfoRow(
                'Días de Alerta',
                '${documento.diasAlerta} días antes del vencimiento',
                Icons.notifications,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFechasSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Fechas Importantes',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondaryLight,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: AppSizes.paddingMedium),
        Container(
          padding: const EdgeInsets.all(AppSizes.padding),
          decoration: BoxDecoration(
            color: AppColors.gray50,
            borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
            border: Border.all(color: AppColors.gray200),
          ),
          child: Column(
            children: <Widget>[
              _buildDateRow(
                'Fecha de Emisión',
                documento.fechaEmision,
                Icons.event_available,
              ),
              const Divider(height: 1, color: AppColors.gray200),
              _buildDateRow(
                'Fecha de Vencimiento',
                documento.fechaVencimiento,
                Icons.event,
                isVencimiento: true,
              ),
              if (documento.fechaProximoVencimiento != null) ...<Widget>[
                const Divider(height: 1, color: AppColors.gray200),
                _buildDateRow(
                  'Próximo Vencimiento',
                  documento.fechaProximoVencimiento!,
                  Icons.update,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEstadoSection() {
    final Color estadoColor = _getEstadoColor();
    final int? diasRestantes = documento.diasRestantes;

    return Container(
      padding: const EdgeInsets.all(AppSizes.padding),
      decoration: BoxDecoration(
        color: estadoColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        border: Border.all(
          color: estadoColor.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: estadoColor.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getEstadoIcon(),
              color: estadoColor,
              size: 24,
            ),
          ),
          const SizedBox(width: AppSizes.paddingMedium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Estado Actual',
                  style: GoogleFonts.inter(
                    fontSize: AppSizes.fontSmall,
                    color: AppColors.textSecondaryLight,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: <Widget>[
                    Text(
                      documento.estadoFormateado,
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: estadoColor,
                      ),
                    ),
                    if (diasRestantes != null) ...<Widget>[
                      const SizedBox(width: AppSizes.paddingMedium),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: estadoColor,
                          borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                        ),
                        child: Text(
                          diasRestantes <= 0
                              ? 'Vencido'
                              : '$diasRestantes días',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildObservacionesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Observaciones',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondaryLight,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: AppSizes.paddingMedium),
        Container(
          padding: const EdgeInsets.all(AppSizes.padding),
          decoration: BoxDecoration(
            color: AppColors.gray50,
            borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
            border: Border.all(color: AppColors.gray200),
          ),
          child: Text(
            documento.observaciones!,
            style: GoogleFonts.inter(
              fontSize: AppSizes.fontMedium,
              color: AppColors.textPrimaryLight,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: <Widget>[
          Icon(icon, size: 18, color: AppColors.gray600),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: AppSizes.fontSmall,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondaryLight,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: GoogleFonts.inter(
                fontSize: AppSizes.fontMedium,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimaryLight,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateRow(
    String label,
    DateTime date,
    IconData icon, {
    bool isVencimiento = false,
  }) {
    final String formattedDate = '${date.day}/${date.month}/${date.year}';
    final bool isPast = date.isBefore(DateTime.now());

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: <Widget>[
          Icon(
            icon,
            size: 18,
            color: isVencimiento && isPast
                ? AppColors.error
                : AppColors.gray600,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: AppSizes.fontSmall,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondaryLight,
              ),
            ),
          ),
          Text(
            formattedDate,
            style: GoogleFonts.inter(
              fontSize: AppSizes.fontMedium,
              fontWeight: FontWeight.w600,
              color: isVencimiento && isPast
                  ? AppColors.error
                  : AppColors.textPrimaryLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingXl),
      decoration: const BoxDecoration(
        color: AppColors.gray50,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(AppSizes.radiusLarge),
          bottomRight: Radius.circular(AppSizes.radiusLarge),
        ),
      ),
      child: AppButton(
        label: 'Cerrar',
        onPressed: () => Navigator.of(context).pop(),
        icon: Icons.close,
        fullWidth: true,
      ),
    );
  }

  String _getTipoLabel() {
    switch (documento.tipoDocumentoId.toLowerCase()) {
      case 'seguro_rc':
      case 'seguro_todo_riesgo':
        return 'Seguro';
      case 'itv':
        return 'ITV';
      case 'permiso_municipal':
        return 'Permiso Municipal';
      case 'tarjeta_transporte':
        return 'Tarjeta de Transporte';
      default:
        return documento.tipoDocumentoId;
    }
  }

  IconData _getTipoIcon() {
    switch (documento.tipoDocumentoId.toLowerCase()) {
      case 'seguro_rc':
      case 'seguro_todo_riesgo':
        return Icons.security;
      case 'itv':
        return Icons.verified;
      case 'permiso_municipal':
        return Icons.admin_panel_settings;
      case 'tarjeta_transporte':
        return Icons.badge;
      default:
        return Icons.description;
    }
  }

  Color _getEstadoColor() {
    switch (documento.estado) {
      case 'vigente':
        return AppColors.success;
      case 'proxima_vencer':
        return AppColors.warning;
      case 'vencida':
        return AppColors.error;
      default:
        return AppColors.gray600;
    }
  }

  IconData _getEstadoIcon() {
    switch (documento.estado) {
      case 'vigente':
        return Icons.check_circle;
      case 'proxima_vencer':
        return Icons.warning;
      case 'vencida':
        return Icons.cancel;
      default:
        return Icons.help_outline;
    }
  }
}
