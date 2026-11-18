import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/features/cuadrante/cuadrante_module/domain/entities/personal_con_turnos_entity.dart';
import 'package:ambutrack_web/features/personal/domain/entities/personal_entity.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Columna fija de la fila: nombre (1 línea) + "categoría · dotación"
class CuadrantePersonaCell extends StatelessWidget {
  const CuadrantePersonaCell({required this.persona, required this.nombresDotacion, super.key});

  final PersonalConTurnosEntity persona;

  /// id → nombre de dotación (vacío mientras carga)
  final Map<String, String> nombresDotacion;

  @override
  Widget build(BuildContext context) {
    final PersonalEntity p = persona.personal;
    final String detalle = _detalle();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: const BoxDecoration(border: Border(right: BorderSide(color: AppColors.gray200))),
      child: Tooltip(
        message: '${p.nombreCompleto}\n${p.categoriaServicio.nombre}${detalle.isEmpty ? '' : '\n$detalle'}',
        waitDuration: const Duration(milliseconds: 500),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              p.nombreCompleto.toUpperCase(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.gray900),
            ),
            const SizedBox(height: 3),
            Text(
              detalle.isEmpty ? p.categoriaServicio.nombre : detalle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(fontSize: 11, color: AppColors.gray500),
            ),
          ],
        ),
      ),
    );
  }

  /// "Categoría · Dotación" con lo que haya disponible
  String _detalle() {
    final String? categoria = persona.personal.categoria?.trim();
    final String? dotacion = nombresDotacion[_dotacionId()];
    return <String>[
      if (categoria != null && categoria.isNotEmpty) categoria,
      if (dotacion != null) dotacion,
    ].join(' · ');
  }

  /// Dotación de la ficha o, si no tiene, la más repetida en sus turnos de la semana
  String? _dotacionId() {
    final String? propia = persona.personal.dotacionId;
    if (propia != null && propia.isNotEmpty) {
      return propia;
    }
    final Map<String, int> conteo = <String, int>{};
    for (final TurnoEntity t in persona.turnos) {
      final String? id = t.idDotacion;
      if (id != null && id.isNotEmpty) {
        conteo[id] = (conteo[id] ?? 0) + 1;
      }
    }
    if (conteo.isEmpty) {
      return null;
    }
    return conteo.entries.reduce((MapEntry<String, int> a, MapEntry<String, int> b) => a.value >= b.value ? a : b).key;
  }
}
