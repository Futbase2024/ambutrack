import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/ausencias/presentation/widgets/gestion/ausencia_gestion_columns.dart';
import 'package:flutter/material.dart';

/// Pestaña "Historial" de la ficha: resumen y ausencias del mismo trabajador
class AusenciaHistorialTab extends StatelessWidget {
  const AusenciaHistorialTab({
    required this.ausencia,
    required this.todas,
    required this.lookup,
    super.key,
  });

  final AusenciaEntity ausencia;
  final List<AusenciaEntity> todas;
  final AusenciaLookup lookup;

  static const int _maxUltimas = 15;

  @override
  Widget build(BuildContext context) {
    final List<AusenciaEntity> propias = todas
        .where((AusenciaEntity a) => a.idPersonal == ausencia.idPersonal)
        .toList()
      ..sort((AusenciaEntity a, AusenciaEntity b) => b.fechaInicio.compareTo(a.fechaInicio));
    final int year = DateTime.now().year;
    final List<AusenciaEntity> aprobadasAnio = propias
        .where((AusenciaEntity a) => a.fechaInicio.year == year && a.estado == EstadoAusencia.aprobada)
        .toList();
    final int diasAnio = aprobadasAnio.fold<int>(0, (int s, AusenciaEntity a) => s + a.diasAusencia);
    final int pendientes = propias.where((AusenciaEntity a) => a.estado == EstadoAusencia.pendiente).length;

    return GestionDetailBody(
      children: <Widget>[
        const GestionDetailSection(title: 'Resumen'),
        GestionDetailField(label: 'Total registros', value: '${propias.length}'),
        GestionDetailField(label: 'Pendientes', value: '$pendientes'),
        GestionDetailField(label: 'Aprobadas $year', value: '${aprobadasAnio.length}'),
        GestionDetailField(label: 'Días aprob. $year', value: '$diasAnio'),
        GestionDetailSection(
          title: propias.length > _maxUltimas ? 'Últimas $_maxUltimas ausencias' : 'Ausencias',
        ),
        ...propias.take(_maxUltimas).map(
              (AusenciaEntity a) => _AusenciaMiniRow(
                ausencia: a,
                tipo: lookup.tipoNombre(a.idTipoAusencia),
                actual: a.id == ausencia.id,
              ),
            ),
      ],
    );
  }
}

class _AusenciaMiniRow extends StatelessWidget {
  const _AusenciaMiniRow({required this.ausencia, required this.tipo, required this.actual});

  final AusenciaEntity ausencia;
  final String tipo;
  final bool actual;

  @override
  Widget build(BuildContext context) {
    final TextStyle base = TextStyle(
      fontSize: 12,
      color: AppColors.gray800,
      fontWeight: actual ? FontWeight.w700 : FontWeight.w400,
    );
    return Container(
      height: 30,
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.gray100)),
      ),
      child: Row(
        children: <Widget>[
          SizedBox(width: 78, child: Text(GestionFormatters.fecha(ausencia.fechaInicio), style: base)),
          SizedBox(width: 40, child: Text('${ausencia.diasAusencia} d', style: base)),
          Expanded(
            child: Text(tipo, maxLines: 1, overflow: TextOverflow.ellipsis, style: base),
          ),
          const SizedBox(width: 6),
          GestionDotLabel(
            label: ausenciaEstadoLabel(ausencia.estado),
            color: ausenciaEstadoColor(ausencia.estado),
            fontSize: 11.5,
          ),
        ],
      ),
    );
  }
}
