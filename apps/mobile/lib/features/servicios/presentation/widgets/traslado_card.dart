import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:ambutrack_core/ambutrack_core.dart';
import '../../../../core/theme/app_colors.dart';
import 'estado_traslado_badge.dart';

/// Card para mostrar un traslado en la lista
class TrasladoCard extends StatelessWidget {
  const TrasladoCard({
    required this.traslado,
    required this.onTap,
    super.key,
  });

  final TrasladoEntity traslado;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Código + Estado
              Row(
                children: [
                  // Código del traslado
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      traslado.codigo,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Estado
                  Expanded(
                    child: EstadoTrasladoBadge(estado: traslado.estado),
                  ),
                  // Icono de prioridad si es alta
                  if (traslado.prioridad <= 3)
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppColors.highPriority.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.priority_high,
                        size: 16,
                        color: AppColors.highPriority,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),

              // Paciente
              _buildInfoRow(
                icon: Icons.person,
                label: 'Paciente',
                value: traslado.pacienteNombre ?? 'No especificado',
              ),
              const SizedBox(height: 8),

              // Fecha y hora
              Row(
                children: [
                  Expanded(
                    child: _buildInfoRow(
                      icon: Icons.calendar_today,
                      label: 'Fecha',
                      value: _formatFecha(traslado.fecha),
                      compact: true,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildInfoRow(
                      icon: Icons.access_time,
                      label: 'Hora',
                      value: traslado.horaProgramada.substring(0, 5),
                      compact: true,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Origen
              _buildInfoRow(
                icon: Icons.location_on,
                iconColor: AppColors.success,
                label: 'Origen',
                value: traslado.origenCompleto,
              ),
              const SizedBox(height: 8),

              // Destino
              _buildInfoRow(
                icon: Icons.place,
                iconColor: AppColors.emergency,
                label: 'Destino',
                value: traslado.destinoCompleto,
              ),

              // Requisitos especiales
              if (traslado.requiereEquipamientoEspecial) ...[
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    if (traslado.requiereCamilla)
                      _buildRequisitoChip(
                        icon: Icons.bed,
                        label: 'Camilla',
                      ),
                    if (traslado.requiereSillaRuedas)
                      _buildRequisitoChip(
                        icon: Icons.accessible,
                        label: 'Silla ruedas',
                      ),
                    if (traslado.requiereAyuda)
                      _buildRequisitoChip(
                        icon: Icons.people,
                        label: 'Ayuda',
                      ),
                    if (traslado.requiereAcompanante)
                      _buildRequisitoChip(
                        icon: Icons.person_add,
                        label: 'Acompañante',
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    Color? iconColor,
    bool compact = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: compact ? 16 : 18,
          color: iconColor ?? AppColors.gray600,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!compact)
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                  ),
                ),
              Text(
                value,
                style: TextStyle(
                  fontSize: compact ? 13 : 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.gray900,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRequisitoChip({
    required IconData icon,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.info.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: AppColors.info.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: AppColors.info,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.info,
            ),
          ),
        ],
      ),
    );
  }

  String _formatFecha(DateTime fecha) {
    final hoy = DateTime.now();
    final manana = DateTime.now().add(const Duration(days: 1));

    if (fecha.year == hoy.year &&
        fecha.month == hoy.month &&
        fecha.day == hoy.day) {
      return 'HOY';
    } else if (fecha.year == manana.year &&
        fecha.month == manana.month &&
        fecha.day == manana.day) {
      return 'MAÑANA';
    } else {
      return DateFormat('dd/MM/yyyy').format(fecha);
    }
  }
}
