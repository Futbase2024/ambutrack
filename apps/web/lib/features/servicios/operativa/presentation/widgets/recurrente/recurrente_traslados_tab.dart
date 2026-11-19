import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/servicios/operativa/presentation/bloc/programacion_recurrente_bloc.dart';
import 'package:ambutrack_web/features/servicios/operativa/presentation/bloc/programacion_recurrente_state.dart';
import 'package:ambutrack_web/features/servicios/operativa/presentation/widgets/common/traslado_gestion_helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Pestaña con los próximos traslados generados del servicio recurrente
class RecurrenteTrasladosTab extends StatelessWidget {
  const RecurrenteTrasladosTab({required this.servicioId, super.key});

  final String servicioId;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProgramacionRecurrenteBloc, ProgramacionRecurrenteState>(
      builder: (BuildContext context, ProgramacionRecurrenteState state) {
        if (state.trasladosServicioId != servicioId || state.cargandoTraslados) {
          return const Center(child: CircularProgressIndicator(strokeWidth: 2));
        }
        final DateTime now = DateTime.now();
        final DateTime hoy = DateTime(now.year, now.month, now.day);
        final List<TrasladoEntity> proximos = state.traslados
            .where((TrasladoEntity t) => t.fecha == null || !t.fecha!.isBefore(hoy))
            .toList()
          ..sort((TrasladoEntity a, TrasladoEntity b) =>
              (a.fecha ?? hoy).compareTo(b.fecha ?? hoy));
        if (proximos.isEmpty) {
          return const GestionDetailEmpty(message: 'No hay traslados generados a partir de hoy');
        }
        return GestionDetailBody(
          children: <Widget>[
            GestionDetailSection(
              title: 'Próximos ${proximos.length} de ${state.traslados.length}',
            ),
            for (final TrasladoEntity t in proximos) _TrasladoLinea(traslado: t),
          ],
        );
      },
    );
  }
}

class _TrasladoLinea extends StatelessWidget {
  const _TrasladoLinea({required this.traslado});

  final TrasladoEntity traslado;

  @override
  Widget build(BuildContext context) {
    final TrasladoEntity t = traslado;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 5),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.gray100)),
      ),
      child: Row(
        children: <Widget>[
          SizedBox(
            width: 84,
            child: Text(
              GestionFormatters.fecha(t.fecha),
              style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w500),
            ),
          ),
          SizedBox(
            width: 44,
            child: Text(
              TrasladoGestion.hora(t.horaProgramada),
              style: const TextStyle(fontSize: 12.5, color: AppColors.gray600),
            ),
          ),
          SizedBox(
            width: 56,
            child: Text(
              TrasladoGestion.tipo(t),
              style: const TextStyle(fontSize: 12, color: AppColors.gray600),
            ),
          ),
          Expanded(child: TrasladoEstadoDot(estado: t.estado)),
        ],
      ),
    );
  }
}
