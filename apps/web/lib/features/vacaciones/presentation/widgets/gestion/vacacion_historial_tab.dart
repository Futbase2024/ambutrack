import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/vacaciones/presentation/widgets/gestion/vacacion_gestion_columns.dart';
import 'package:flutter/material.dart';

/// Pestaña "Historial" de la ficha: resumen y vacaciones del mismo trabajador en el año cargado
class VacacionHistorialTab extends StatelessWidget {
  const VacacionHistorialTab({required this.vacacion, required this.todas, super.key});

  final VacacionesEntity vacacion;
  final List<VacacionesEntity> todas;

  @override
  Widget build(BuildContext context) {
    final List<VacacionesEntity> propias = todas
        .where((VacacionesEntity v) => v.idPersonal == vacacion.idPersonal)
        .toList()
      ..sort((VacacionesEntity a, VacacionesEntity b) => a.fechaInicio.compareTo(b.fechaInicio));
    int dias(String estado) => propias
        .where((VacacionesEntity v) => v.estado == estado)
        .fold<int>(0, (int s, VacacionesEntity v) => s + v.diasSolicitados);

    return GestionDetailBody(
      children: <Widget>[
        const GestionDetailSection(title: 'Resumen del año'),
        GestionDetailField(label: 'Solicitudes', value: '${propias.length}'),
        GestionDetailField(label: 'Días aprobados', value: '${dias('aprobada')}'),
        GestionDetailField(label: 'Días pendientes', value: '${dias('pendiente')}'),
        GestionDetailField(label: 'Días rechazados', value: '${dias('rechazada')}'),
        const GestionDetailSection(title: 'Periodos'),
        ...propias.map(
          (VacacionesEntity v) => _VacacionMiniRow(vacacion: v, actual: v.id == vacacion.id),
        ),
      ],
    );
  }
}

class _VacacionMiniRow extends StatelessWidget {
  const _VacacionMiniRow({required this.vacacion, required this.actual});

  final VacacionesEntity vacacion;
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
          Expanded(
            child: Text(
              '${GestionFormatters.fecha(vacacion.fechaInicio)} – ${GestionFormatters.fecha(vacacion.fechaFin)}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: base,
            ),
          ),
          SizedBox(width: 44, child: Text('${vacacion.diasSolicitados} d', style: base)),
          VacacionEstadoDot(estado: vacacion.estado, fontSize: 11.5),
        ],
      ),
    );
  }
}
