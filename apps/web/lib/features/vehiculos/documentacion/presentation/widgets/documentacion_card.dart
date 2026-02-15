import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:flutter/material.dart';

/// Widget de tarjeta para mostrar un documento de vehículo en una lista
class DocumentacionCard extends StatelessWidget {
  const DocumentacionCard({
    super.key,
    required this.documento,
    required this.onTap,
    required this.onDelete,
    required this.onEdit,
    required this.onRenovar,
  });

  final DocumentacionVehiculoEntity documento;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onEdit;
  final VoidCallback onRenovar;

  @override
  Widget build(BuildContext context) {
    final String tipoDocLabel = documento.tipoDocumentoNombre ?? _getTipoDocLabel(documento.tipoDocumentoId);
    final String vehiculoInfo = documento.vehiculoMatricula != null
        ? '${documento.vehiculoMatricula}'
        : 'Vehículo no asignado';
    final Color estadoColor = _getEstadoColor(documento.estado);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: estadoColor.withValues(alpha: 0.3),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // Icono del tipo de documento
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: estadoColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                  ),
                  child: Icon(
                    _getTipoDocIcon(documento.tipoDocumentoId),
                    color: estadoColor,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                // Contenido principal
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      // Fila superior: título y estado
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              tipoDocLabel,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.gray900,
                                letterSpacing: -0.3,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          _buildEstadoBadge(estadoColor),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Vehículo
                      Row(
                        children: <Widget>[
                          const Icon(
                            Icons.directions_car_outlined,
                            size: 16,
                            color: AppColors.gray500,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              vehiculoInfo,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: AppColors.gray700,
                                letterSpacing: -0.2,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      // Compañía
                      Row(
                        children: <Widget>[
                          const Icon(
                            Icons.business_outlined,
                            size: 16,
                            color: AppColors.gray500,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              documento.compania,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: AppColors.gray600,
                                letterSpacing: -0.2,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Fila inferior: vencimiento y acciones
                      Row(
                        children: <Widget>[
                          // Vencimiento
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.gray50,
                              borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                const Icon(
                                  Icons.calendar_today_outlined,
                                  size: 14,
                                  color: AppColors.gray600,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  _formatDate(documento.fechaVencimiento),
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.gray800,
                                    letterSpacing: -0.2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Días restantes
                          if (documento.diasRestantes != null)
                            _buildDiasBadge(documento.diasRestantes!),
                          const Spacer(),
                          // Acciones
                          _buildActionButton(
                            icon: Icons.visibility_outlined,
                            color: AppColors.info,
                            tooltip: 'Ver',
                            onTap: onTap,
                          ),
                          const SizedBox(width: 4),
                          _buildActionButton(
                            icon: Icons.edit_outlined,
                            color: AppColors.secondaryLight,
                            tooltip: 'Editar',
                            onTap: onEdit,
                          ),
                          const SizedBox(width: 4),
                          _buildActionButton(
                            icon: Icons.refresh_outlined,
                            color: AppColors.warning,
                            tooltip: 'Renovar',
                            onTap: onRenovar,
                          ),
                          const SizedBox(width: 4),
                          _buildActionButton(
                            icon: Icons.delete_outline,
                            color: AppColors.error,
                            tooltip: 'Eliminar',
                            onTap: onDelete,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEstadoBadge(Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            _getEstadoIcon(documento.estado),
            size: 12,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            documento.estadoFormateado,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiasBadge(int diasRestantes) {
    final Color badgeColor = _getVencimientoColor(diasRestantes);
    final String label = diasRestantes <= 0
        ? 'Vencido'
        : diasRestantes == 1
            ? '1 día'
            : '$diasRestantes días';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            diasRestantes <= 0 ? Icons.error_outline : Icons.access_time,
            size: 12,
            color: Colors.white,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        child: Container(
          padding: const EdgeInsets.all(8),
          child: Icon(
            icon,
            size: 18,
            color: color,
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  IconData _getTipoDocIcon(String tipoDocId) {
    final String tipo = tipoDocId.toLowerCase();
    if (tipo.contains('seguro')) {
      return Icons.security_outlined;
    } else if (tipo.contains('itv')) {
      return Icons.verified_user_outlined;
    } else if (tipo.contains('permiso')) {
      return Icons.description_outlined;
    } else if (tipo.contains('licencia') || tipo.contains('tarjeta')) {
      return Icons.badge_outlined;
    }
    return Icons.insert_drive_file_outlined;
  }

  String _getTipoDocLabel(String tipoDocId) {
    switch (tipoDocId.toLowerCase()) {
      case 'seguro':
      case 'seguro_rc':
      case 'seguro_todo_riesgo':
        return 'Seguro';
      case 'itv':
        return 'ITV';
      case 'permiso':
      case 'permiso_municipal':
        return 'Permiso Municipal';
      case 'licencia':
      case 'tarjeta_transporte':
        return 'Tarjeta de Transporte';
      default:
        return tipoDocId;
    }
  }

  Color _getEstadoColor(String estado) {
    switch (estado) {
      case 'vigente':
        return AppColors.success;
      case 'proxima_vencer':
        return AppColors.warning;
      case 'vencida':
      case 'vencido':
        return AppColors.error;
      default:
        return AppColors.gray600;
    }
  }

  IconData _getEstadoIcon(String estado) {
    switch (estado) {
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

  Color _getVencimientoColor(int diasRestantes) {
    if (diasRestantes <= 0) {
      return AppColors.error;
    } else if (diasRestantes <= 7) {
      return AppColors.warning;
    } else if (diasRestantes <= 30) {
      return AppColors.info;
    } else {
      return AppColors.success;
    }
  }
}
