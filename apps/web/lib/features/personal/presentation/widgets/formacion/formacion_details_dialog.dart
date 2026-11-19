import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

/// Diálogo para ver detalles de una formación personal
class FormacionDetailsDialog extends StatelessWidget {
  const FormacionDetailsDialog({
    super.key,
    required this.formacion,
    required this.nombreEmpleado,
    required this.nombreFormacion,
  });

  final FormacionPersonalEntity formacion;
  final String nombreEmpleado;
  final String nombreFormacion;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Header
            Row(
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _getEstadoColor(formacion.estado).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getEstadoIcon(formacion.estado),
                    color: _getEstadoColor(formacion.estado),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Detalles de Formación',
                        style: GoogleFonts.inter(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimaryLight,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        nombreFormacion,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const Divider(height: 32),

            // Información principal
            _buildInfoRow(
              Icons.person,
              'Empleado',
              nombreEmpleado,
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              Icons.school,
              'Tipo',
              formacion.certificacionId != null ? 'Certificación' : 'Curso',
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              formacion.certificacionId != null ? Icons.verified : Icons.menu_book,
              'Nombre',
              nombreFormacion,
            ),
            const SizedBox(height: 16),

            // Fechas
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.backgroundLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Fechas',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimaryLight,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildFechaRow('Inicio', formacion.fechaInicio),
                  const SizedBox(height: 8),
                  _buildFechaRow('Fin', formacion.fechaFin),
                  const SizedBox(height: 8),
                  _buildFechaRow('Expiración', formacion.fechaExpiracion),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Horas y Estado
            Row(
              children: <Widget>[
                Expanded(
                  child: _buildStatCard(
                    Icons.schedule,
                    'Horas',
                    '${formacion.horasAcumuladas}h',
                    AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    Icons.info_outline,
                    'Estado',
                    _getEstadoLabel(formacion.estado),
                    _getEstadoColor(formacion.estado),
                  ),
                ),
              ],
            ),

            // Observaciones
            if (formacion.observaciones != null && formacion.observaciones!.isNotEmpty) ...<Widget>[
              const SizedBox(height: 16),
              Text(
                'Observaciones',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimaryLight,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.backgroundLight,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.gray300),
                ),
                child: Text(
                  formacion.observaciones!,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: AppColors.textPrimaryLight,
                    height: 1.4,
                  ),
                ),
              ),
            ],

            const SizedBox(height: 24),

            // Botón cerrar
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('Cerrar'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: <Widget>[
        Icon(icon, size: 18, color: AppColors.textSecondaryLight),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: AppColors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimaryLight,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFechaRow(String label, DateTime fecha) {
    return Row(
      children: <Widget>[
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: AppColors.textSecondaryLight,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            DateFormat('dd/MM/yyyy').format(fecha),
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimaryLight,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(IconData icon, String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(icon, size: 18, color: color),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Color _getEstadoColor(String estado) {
    switch (estado) {
      case 'vigente':
        return AppColors.success;
      case 'proxima_vencer':
        return AppColors.warning;
      case 'vencida':
        return AppColors.emergency;
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
        return Icons.error;
      default:
        return Icons.help_outline;
    }
  }

  String _getEstadoLabel(String estado) {
    switch (estado) {
      case 'vigente':
        return 'Vigente';
      case 'proxima_vencer':
        return 'Próxima a vencer';
      case 'vencida':
        return 'Vencida';
      default:
        return estado;
    }
  }
}
