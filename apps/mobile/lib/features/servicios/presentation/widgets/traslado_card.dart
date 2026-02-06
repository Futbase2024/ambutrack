import 'package:flutter/material.dart';

import 'package:ambutrack_core/ambutrack_core.dart';
import '../../../../core/theme/app_colors.dart';
import 'estado_traslado_badge.dart';

/// Card profesional para mostrar un traslado en la lista
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
    final estadoColor = _getColorFromHex(traslado.estado.colorHex);

    // Color del borde según tipo de traslado
    final bool esIda = traslado.tipoTraslado.toUpperCase() == 'IDA';
    final Color colorBorde = esIda ? AppColors.primary : AppColors.emergency;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(
                  color: colorBorde,
                  width: 5,
                ),
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // FILA 1: Hora + Código + Estado | Requisitos
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // IZQUIERDA 50%: Hora + Código + Estado
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Hora compacta
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    estadoColor,
                                    estadoColor.withValues(alpha: 0.8),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: estadoColor.withValues(alpha: 0.3),
                                    blurRadius: 4,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                              ),
                              child: Text(
                                traslado.horaProgramada.substring(0, 5),
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            // Código y Estado compactos
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    traslado.codigo,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.gray700,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  EstadoTrasladoBadge(estado: traslado.estado),
                                ],
                              ),
                            ),
                            // Prioridad
                            if (traslado.prioridad <= 3)
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.highPriority,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.priority_high,
                                  size: 20,
                                  color: Colors.white,
                                ),
                              ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 10),

                      // DERECHA 50%: Requisitos
                      Expanded(
                        child: traslado.requiereEquipamientoEspecial
                            ? Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                alignment: WrapAlignment.end,
                                children: [
                                  if (traslado.requiereCamilla)
                                    _buildRequisitoChipCompacto(Icons.bed),
                                  if (traslado.requiereSillaRuedas)
                                    _buildRequisitoChipCompacto(Icons.accessible),
                                  if (traslado.requiereAyuda)
                                    _buildRequisitoChipCompacto(Icons.people),
                                  if (traslado.requiereAcompanante)
                                    _buildRequisitoChipCompacto(Icons.person_add),
                                ],
                              )
                            : const SizedBox.shrink(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // Paciente compacto
                  Row(
                    children: [
                      Icon(
                        Icons.person,
                        size: 22,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 7),
                      Expanded(
                        child: Text(
                          traslado.pacienteNombre ?? 'No especificado',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.gray900,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // FILA 2: Origen | Destino (50/50)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // IZQUIERDA 50%: Origen
                      Expanded(
                        child: _buildUbicacionCompacta(
                          icono: Icons.trip_origin,
                          color: AppColors.success,
                          label: 'ORIGEN',
                          direccion: traslado.origenCompleto,
                          poblacion: traslado.poblacionOrigen,
                        ),
                      ),
                      const SizedBox(width: 10),
                      // DERECHA 50%: Destino
                      Expanded(
                        child: _buildUbicacionCompacta(
                          icono: Icons.location_on,
                          color: AppColors.emergency,
                          label: 'DESTINO',
                          direccion: traslado.destinoCompleto,
                          poblacion: traslado.poblacionDestino,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUbicacionCompacta({
    required IconData icono,
    required Color color,
    required String label,
    required String direccion,
    String? poblacion,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icono,
            size: 22,
            color: color,
          ),
        ),
        const SizedBox(width: 7),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: color,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                direccion,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.gray900,
                  height: 1.2,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (poblacion != null && poblacion.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  poblacion,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: color,
                    letterSpacing: 0.3,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRequisitoChipCompacto(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.info.withValues(alpha: 0.15),
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        size: 22,
        color: AppColors.info,
      ),
    );
  }

  Color _getColorFromHex(String hexColor) {
    final hex = hexColor.replaceAll('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }
}
