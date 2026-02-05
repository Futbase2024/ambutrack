import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/features/turnos/domain/entities/disponibilidad_entity.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

/// Widget que visualiza la disponibilidad como heat map
class DisponibilidadHeatMap extends StatelessWidget {
  const DisponibilidadHeatMap({
    required this.disponibilidades,
    this.onFranjaSelected,
    super.key,
  });

  final List<DisponibilidadEntity> disponibilidades;
  final void Function(DisponibilidadEntity)? onFranjaSelected;

  @override
  Widget build(BuildContext context) {
    if (disponibilidades.isEmpty) {
      return _buildEmpty();
    }

    // Agrupar franjas por día
    final Map<DateTime, List<DisponibilidadEntity>> franjasesPorDia =
        _agruparPorDia(disponibilidades);

    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingMedium),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radius),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _buildHeader(),
          const SizedBox(height: AppSizes.spacing),
          _buildLeyenda(),
          const SizedBox(height: AppSizes.spacing),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: franjasesPorDia.entries
                    .map(
                      (MapEntry<DateTime, List<DisponibilidadEntity>> entry) =>
                          _buildDiaRow(entry.key, entry.value),
                    )
                    .toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: <Widget>[
        const Icon(
          Icons.calendar_view_day,
          color: AppColors.primary,
          size: 24,
        ),
        const SizedBox(width: AppSizes.spacingSmall),
        Text(
          'Mapa de Disponibilidad',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimaryLight,
          ),
        ),
      ],
    );
  }

  Widget _buildLeyenda() {
    return Wrap(
      spacing: AppSizes.spacing,
      runSpacing: AppSizes.spacingSmall,
      children: NivelOcupacion.values
          .map(
            _buildLeyendaItem,
          )
          .toList(),
    );
  }

  Widget _buildLeyendaItem(NivelOcupacion nivel) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: _hexToColor(nivel.colorHex),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: AppSizes.spacingXs),
        Text(
          '${nivel.icon} ${nivel.displayText}',
          style: GoogleFonts.inter(
            fontSize: 12,
            color: AppColors.textSecondaryLight,
          ),
        ),
      ],
    );
  }

  Widget _buildDiaRow(DateTime dia, List<DisponibilidadEntity> franjas) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.spacingSmall),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Fecha del día
          SizedBox(
            width: 100,
            child: Text(
              DateFormat('dd/MM/yyyy\nEEEE', 'es').format(dia),
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimaryLight,
              ),
            ),
          ),
          const SizedBox(width: AppSizes.spacing),

          // Franjas del día
          Expanded(
            child: Wrap(
              spacing: 4,
              runSpacing: 4,
              children: franjas
                  .map(
                    _buildFranja,
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFranja(DisponibilidadEntity franja) {
    final Color color = _hexToColor(franja.nivelOcupacion.colorHex);

    return Tooltip(
      message: _buildTooltipMessage(franja),
      child: InkWell(
        onTap: onFranjaSelected != null ? () => onFranjaSelected!(franja) : null,
        borderRadius: BorderRadius.circular(4),
        child: Container(
          width: 60,
          height: 40,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            border: Border.all(color: color, width: 2),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                DateFormat('HH:mm').format(franja.horaInicio),
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
              Text(
                '${franja.cantidadPersonal}',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _buildTooltipMessage(DisponibilidadEntity franja) {
    final String horario =
        '${DateFormat('HH:mm').format(franja.horaInicio)} - ${DateFormat('HH:mm').format(franja.horaFin)}';

    return '''
$horario
${franja.nivelOcupacion.icon} ${franja.nivelOcupacion.displayText}
Personal asignado: ${franja.cantidadPersonal}
${franja.personalAsignado.isNotEmpty ? 'IDs: ${franja.personalAsignado.join(', ')}' : ''}
''';
  }

  Widget _buildEmpty() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingXl),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radius),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(
              Icons.calendar_view_day,
              size: 48,
              color: AppColors.textSecondaryLight,
            ),
            const SizedBox(height: AppSizes.spacing),
            Text(
              'No hay datos de disponibilidad',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondaryLight,
              ),
            ),
            const SizedBox(height: AppSizes.spacingSmall),
            Text(
              'Selecciona un rango de fechas para analizar',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppColors.textSecondaryLight,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Map<DateTime, List<DisponibilidadEntity>> _agruparPorDia(
    List<DisponibilidadEntity> franjas,
  ) {
    final Map<DateTime, List<DisponibilidadEntity>> grupos =
        <DateTime, List<DisponibilidadEntity>>{};

    for (final DisponibilidadEntity franja in franjas) {
      final DateTime dia = DateTime(
        franja.fecha.year,
        franja.fecha.month,
        franja.fecha.day,
      );

      if (!grupos.containsKey(dia)) {
        grupos[dia] = <DisponibilidadEntity>[];
      }
      grupos[dia]!.add(franja);
    }

    // Ordenar franjas dentro de cada día
    for (final List<DisponibilidadEntity> franjasDia in grupos.values) {
      franjasDia.sort(
        (DisponibilidadEntity a, DisponibilidadEntity b) =>
            a.horaInicio.compareTo(b.horaInicio),
      );
    }

    return grupos;
  }

  Color _hexToColor(String hexString) {
    final StringBuffer buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) {
      buffer.write('ff');
    }
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}
