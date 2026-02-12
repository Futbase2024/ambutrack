import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

/// Widget para vista diaria del cuadrante
/// Muestra todos los detalles de las asignaciones de un día específico
class CuadranteDiarioWidget extends StatelessWidget {
  const CuadranteDiarioWidget({
    required this.selectedDate,
    required this.asignaciones,
    required this.onDateChanged,
    super.key,
  });

  final DateTime selectedDate;
  final List<CuadranteAsignacionEntity> asignaciones;
  final void Function(DateTime) onDateChanged;

  @override
  Widget build(BuildContext context) {
    final List<CuadranteAsignacionEntity> asignacionesDelDia = asignaciones.where((CuadranteAsignacionEntity a) {
      return a.fecha.year == selectedDate.year &&
          a.fecha.month == selectedDate.month &&
          a.fecha.day == selectedDate.day;
    }).toList()

    // Ordenar por hora de inicio
    ..sort((CuadranteAsignacionEntity a, CuadranteAsignacionEntity b) {
      return a.horaInicio.compareTo(b.horaInicio);
    });

    return Container(
      margin: const EdgeInsets.all(AppSizes.spacing),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radius),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _buildHeader(),
          const Divider(height: 1, color: AppColors.gray200),
          Expanded(
            child: asignacionesDelDia.isEmpty
                ? _buildEmptyState()
                : _buildTimeline(asignacionesDelDia),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final DateFormat dateFormat = DateFormat('EEEE, d MMMM yyyy', 'es_ES');
    final String formattedDate = dateFormat.format(selectedDate);
    final String capitalizedDate = formattedDate[0].toUpperCase() + formattedDate.substring(1);

    return Container(
      padding: const EdgeInsets.all(AppSizes.padding),
      child: Row(
        children: <Widget>[
          const Icon(
            Icons.calendar_today,
            size: 24,
            color: AppColors.primary,
          ),
          const SizedBox(width: AppSizes.spacingSmall),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  capitalizedDate,
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimaryLight,
                  ),
                ),
                Text(
                  '${asignaciones.length} asignaciones programadas',
                  style: GoogleFonts.inter(
                    fontSize: 13,
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Icon(
            Icons.event_busy,
            size: 64,
            color: AppColors.gray400,
          ),
          const SizedBox(height: AppSizes.spacing),
          Text(
            'No hay asignaciones para este día',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondaryLight,
            ),
          ),
          const SizedBox(height: AppSizes.spacingSmall),
          Text(
            'Selecciona otro día o crea una nueva asignación',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppColors.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeline(List<CuadranteAsignacionEntity> asignacionesDelDia) {
    return ListView.separated(
      padding: const EdgeInsets.all(AppSizes.padding),
      itemCount: asignacionesDelDia.length,
      separatorBuilder: (BuildContext context, int index) => const SizedBox(height: AppSizes.spacing),
      itemBuilder: (BuildContext context, int index) {
        return _buildAsignacionCard(asignacionesDelDia[index]);
      },
    );
  }

  Widget _buildAsignacionCard(CuadranteAsignacionEntity asignacion) {
    final Color estadoColor = _getEstadoColor(asignacion.estado);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        border: Border.all(color: AppColors.gray200),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Header con horario, matrícula y estado
          Container(
            padding: const EdgeInsets.all(AppSizes.paddingMedium),
            decoration: BoxDecoration(
              color: estadoColor.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppSizes.radiusMedium),
                topRight: Radius.circular(AppSizes.radiusMedium),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // Primera fila: Tipo de turno (izquierda) + Emoji categoría (derecha)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Expanded(
                      child: Row(
                        children: <Widget>[
                          Icon(
                            Icons.access_time,
                            size: 18,
                            color: estadoColor,
                          ),
                          const SizedBox(width: AppSizes.spacingSmall),
                          Flexible(
                            child: Text(
                              _getTipoTurnoLabel(asignacion.tipoTurno),
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimaryLight,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (asignacion.cruzaMedianoche) ...<Widget>[
                            const SizedBox(width: AppSizes.spacingSmall),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.warning.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '24h',
                                style: GoogleFonts.inter(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.warning,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    // Emoji categoría
                    Text(
                      _getCategoriaEmoji(asignacion.categoriaPersonal),
                      style: const TextStyle(fontSize: 24),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.spacingSmall),
                // Segunda fila: Horario (izquierda) + Matrícula (derecha)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      '${asignacion.horaInicio} - ${asignacion.horaFin}',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimaryLight,
                      ),
                    ),
                    if (asignacion.matriculaVehiculo != null && asignacion.matriculaVehiculo!.isNotEmpty)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          const Text('🚑', style: TextStyle(fontSize: 18)),
                          const SizedBox(width: 4),
                          Text(
                            asignacion.matriculaVehiculo!,
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
                // Tercera fila: Estado
                const SizedBox(height: AppSizes.spacingSmall),
                _buildEstadoBadge(asignacion.estado),
              ],
            ),
          ),
          // Contenido
          Padding(
            padding: const EdgeInsets.all(AppSizes.paddingMedium),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // Personal
                _buildInfoRow(
                  icon: Icons.person,
                  label: 'Personal',
                  value: asignacion.nombrePersonal,
                  subtitle: asignacion.categoriaPersonal,
                ),
                const SizedBox(height: AppSizes.spacing),
                // Dotación
                _buildInfoRow(
                  icon: Icons.business,
                  label: 'Dotación',
                  value: asignacion.nombreDotacion,
                  subtitle: 'Unidad ${asignacion.numeroUnidad}',
                ),
                const SizedBox(height: AppSizes.spacing),
                // Tipo de turno
                _buildInfoRow(
                  icon: Icons.schedule,
                  label: 'Tipo de Turno',
                  value: _getTipoTurnoLabel(asignacion.tipoTurno),
                ),
                // Observaciones
                if (asignacion.observaciones != null && asignacion.observaciones!.isNotEmpty) ...<Widget>[
                  const SizedBox(height: AppSizes.spacing),
                  const Divider(color: AppColors.gray200),
                  const SizedBox(height: AppSizes.spacing),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Icon(
                        Icons.note,
                        size: 18,
                        color: AppColors.textSecondaryLight,
                      ),
                      const SizedBox(width: AppSizes.spacingSmall),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              'Observaciones',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondaryLight,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              asignacion.observaciones!,
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: AppColors.textPrimaryLight,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    String? subtitle,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Icon(
          icon,
          size: 18,
          color: AppColors.textSecondaryLight,
        ),
        const SizedBox(width: AppSizes.spacingSmall),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
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
              if (subtitle != null) ...<Widget>[
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEstadoBadge(EstadoAsignacion estado) {
    final Color color = _getEstadoColor(estado);
    final String label = _getEstadoLabel(estado);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha:  0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color, width: 1.5),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }

  Color _getEstadoColor(EstadoAsignacion estado) {
    switch (estado) {
      case EstadoAsignacion.planificada:
        return AppColors.warning;
      case EstadoAsignacion.confirmada:
        return AppColors.info;
      case EstadoAsignacion.activa:
        return AppColors.primary;
      case EstadoAsignacion.completada:
        return AppColors.success;
      case EstadoAsignacion.cancelada:
        return AppColors.error;
    }
  }

  String _getEstadoLabel(EstadoAsignacion estado) {
    switch (estado) {
      case EstadoAsignacion.planificada:
        return 'Planificada';
      case EstadoAsignacion.confirmada:
        return 'Confirmada';
      case EstadoAsignacion.activa:
        return 'Activa';
      case EstadoAsignacion.completada:
        return 'Completada';
      case EstadoAsignacion.cancelada:
        return 'Cancelada';
    }
  }

  String _getTipoTurnoLabel(TipoTurnoAsignacion tipoTurno) {
    switch (tipoTurno) {
      case TipoTurnoAsignacion.manana:
        return 'Mañana';
      case TipoTurnoAsignacion.tarde:
        return 'Tarde';
      case TipoTurnoAsignacion.noche:
        return 'Noche';
      case TipoTurnoAsignacion.personalizado:
        return 'Personalizado';
    }
  }

  /// Obtiene el emoji según la categoría del personal
  String _getCategoriaEmoji(String? categoria) {
    if (categoria == null || categoria.isEmpty) {
      return ''; // Sin emoji si no hay categoría
    }

    final String categoriaLower = categoria.toLowerCase();

    // Mapeo de categorías a emojis
    if (categoriaLower.contains('conductor')) {
      return '🚑';
    }
    if (categoriaLower.contains('médico') || categoriaLower.contains('medico')) {
      return '⚕️';
    }
    if (categoriaLower.contains('enfermero') || categoriaLower.contains('enfermera')) {
      return '🩺';
    }
    if (categoriaLower.contains('tes')) {
      return '🚑';
    }
    if (categoriaLower.contains('camillero')) {
      return '🏥';
    }
    if (categoriaLower.contains('administrativo') || categoriaLower.contains('oficina')) {
      return '💼';
    }

    return ''; // Sin emoji por defecto
  }
}
