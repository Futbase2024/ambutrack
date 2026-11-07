import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/taller/presentation/bloc/orden_reparacion_bloc.dart';
import 'package:ambutrack_web/features/taller/presentation/bloc/orden_reparacion_state.dart';
import 'package:ambutrack_web/features/taller/presentation/widgets/ordenes/orden_ui_helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Pestaña "Órdenes" de la ficha del taller: actividad y últimas órdenes
class TallerOrdenesTab extends StatelessWidget {
  const TallerOrdenesTab({required this.tallerId, super.key});

  final String tallerId;

  static const int _maxUltimas = 15;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OrdenReparacionBloc, OrdenReparacionState>(
      builder: (BuildContext context, OrdenReparacionState state) {
        if (state is! OrdenReparacionLoaded) {
          return const Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        }
        final List<OrdenReparacionEntity> ordenes = state.ordenes
            .where((OrdenReparacionEntity o) => o.tallerId == tallerId)
            .toList()
          ..sort((OrdenReparacionEntity a, OrdenReparacionEntity b) =>
              b.fechaEntrada.compareTo(a.fechaEntrada));

        return GestionDetailBody(
          children: <Widget>[
            const GestionDetailSection(title: 'Actividad'),
            _ActividadResumen(ordenes: ordenes),
            GestionDetailSection(
              title: ordenes.length > _maxUltimas
                  ? 'Últimas $_maxUltimas órdenes'
                  : 'Órdenes',
            ),
            if (ordenes.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'Este taller no tiene órdenes de reparación',
                  style: TextStyle(fontSize: 12.5, color: AppColors.gray500),
                ),
              )
            else
              ...ordenes.take(_maxUltimas).map(
                    (OrdenReparacionEntity o) => _OrdenMiniRow(orden: o),
                  ),
          ],
        );
      },
    );
  }
}

class _ActividadResumen extends StatelessWidget {
  const _ActividadResumen({required this.ordenes});

  final List<OrdenReparacionEntity> ordenes;

  @override
  Widget build(BuildContext context) {
    final int year = DateTime.now().year;
    final List<OrdenReparacionEntity> delAnio = ordenes
        .where((OrdenReparacionEntity o) =>
            o.fechaEntrada.year == year && o.estado != EstadoOrdenReparacion.anulada)
        .toList();
    final int abiertas =
        ordenes.where((OrdenReparacionEntity o) => o.estado.isActiva).length;
    final double importe = delAnio.fold<double>(
      0,
      (double sum, OrdenReparacionEntity o) => sum + o.costoTotal,
    );

    return Column(
      children: <Widget>[
        GestionDetailField(label: 'Abiertas', value: '$abiertas'),
        GestionDetailField(label: 'Órdenes $year', value: '${delAnio.length}'),
        GestionDetailField(label: 'Importe $year', value: GestionFormatters.moneda(importe)),
        GestionDetailField(label: 'Total histórico', value: '${ordenes.length}'),
        GestionDetailField(
          label: 'Última entrada',
          value: ordenes.isEmpty ? null : GestionFormatters.fecha(ordenes.first.fechaEntrada),
        ),
      ],
    );
  }
}

class _OrdenMiniRow extends StatelessWidget {
  const _OrdenMiniRow({required this.orden});

  final OrdenReparacionEntity orden;

  @override
  Widget build(BuildContext context) {
    const TextStyle base = TextStyle(fontSize: 12, color: AppColors.gray800);
    return Container(
      height: 30,
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.gray100)),
      ),
      child: Row(
        children: <Widget>[
          SizedBox(
            width: 92,
            child: Text(
              orden.numeroOrden.isEmpty ? GestionFormatters.vacio : orden.numeroOrden,
              style: base.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          SizedBox(
            width: 72,
            child: Text(GestionFormatters.texto(orden.vehiculoMatricula), style: base),
          ),
          Expanded(
            child: GestionDotLabel(
              label: orden.estado.displayName,
              color: estadoOrdenColor(orden.estado),
              fontSize: 11.5,
            ),
          ),
          Text(
            GestionFormatters.fecha(orden.fechaEntrada),
            style: base.copyWith(color: AppColors.gray500, fontSize: 11.5),
          ),
        ],
      ),
    );
  }
}
