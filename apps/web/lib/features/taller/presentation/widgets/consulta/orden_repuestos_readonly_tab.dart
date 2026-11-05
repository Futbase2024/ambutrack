import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/taller/presentation/bloc/repuesto_orden_bloc.dart';
import 'package:ambutrack_web/features/taller/presentation/bloc/repuesto_orden_event.dart';
import 'package:ambutrack_web/features/taller/presentation/bloc/repuesto_orden_state.dart';
import 'package:ambutrack_web/features/taller/presentation/widgets/ordenes/orden_ui_helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Pestaña "Repuestos" en solo lectura (pantallas de consulta)
class OrdenRepuestosReadonlyTab extends StatelessWidget {
  const OrdenRepuestosReadonlyTab({required this.ordenId, super.key});

  final String ordenId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<RepuestoOrdenBloc>(
      key: ValueKey<String>('repuestos_ro_$ordenId'),
      create: (BuildContext _) => getIt<RepuestoOrdenBloc>()..add(RepuestoOrdenLoadRequested(ordenId: ordenId)),
      child: BlocBuilder<RepuestoOrdenBloc, RepuestoOrdenState>(
        builder: (BuildContext context, RepuestoOrdenState state) {
          if (state is RepuestoOrdenError) {
            return GestionDetailBody(
              children: <Widget>[
                Text(state.message, style: const TextStyle(fontSize: 12.5, color: AppColors.error)),
              ],
            );
          }
          if (state is! RepuestoOrdenLoaded) {
            return const Center(
              child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
            );
          }
          return _RepuestosList(repuestos: state.repuestos);
        },
      ),
    );
  }
}

class _RepuestosList extends StatelessWidget {
  const _RepuestosList({required this.repuestos});

  final List<RepuestoOrdenEntity> repuestos;

  @override
  Widget build(BuildContext context) {
    final double total = repuestos.fold<double>(0, (double s, RepuestoOrdenEntity r) => s + r.precioTotal);
    return GestionDetailBody(
      children: <Widget>[
        const GestionDetailSection(title: 'Resumen'),
        GestionDetailField(label: 'Líneas', value: '${repuestos.length}'),
        GestionDetailField(label: 'Importe', value: GestionFormatters.moneda(total)),
        const GestionDetailSection(title: 'Repuestos'),
        if (repuestos.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text('Sin repuestos registrados', style: TextStyle(fontSize: 12.5, color: AppColors.gray500)),
          )
        else
          ...repuestos.map((RepuestoOrdenEntity r) => _RepuestoLine(repuesto: r)),
      ],
    );
  }
}

class _RepuestoLine extends StatelessWidget {
  const _RepuestoLine({required this.repuesto});

  final RepuestoOrdenEntity repuesto;

  @override
  Widget build(BuildContext context) {
    final String detalle = <String>[
      if (repuesto.referencia != null) repuesto.referencia!,
      if (repuesto.proveedorNombre != null) repuesto.proveedorNombre!,
      '${repuesto.cantidad} × ${GestionFormatters.moneda(repuesto.precioUnitario)}',
    ].join(' · ');
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.gray100))),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  repuesto.descripcion,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.gray800),
                ),
                Text(
                  detalle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 11.5, color: AppColors.gray500),
                ),
                const SizedBox(height: 2),
                GestionDotLabel(
                  label: repuesto.estado.displayName,
                  color: estadoRepuestoColor(repuesto.estado),
                  fontSize: 11.5,
                ),
              ],
            ),
          ),
          Text(
            GestionFormatters.moneda(repuesto.precioTotal),
            style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.gray800),
          ),
        ],
      ),
    );
  }
}
