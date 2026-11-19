import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/servicios/operativa/presentation/bloc/traslados_consulta_bloc.dart';
import 'package:ambutrack_web/features/servicios/operativa/presentation/bloc/traslados_consulta_state.dart';
import 'package:ambutrack_web/features/servicios/operativa/presentation/widgets/common/traslado_gestion_helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Banda con el recuento de traslados por estado
class EstadoResumenBanner extends StatelessWidget {
  const EstadoResumenBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TrasladosConsultaBloc, TrasladosConsultaState>(
      buildWhen: (TrasladosConsultaState _, TrasladosConsultaState curr) =>
          curr is TrasladosConsultaLoaded,
      builder: (BuildContext context, TrasladosConsultaState state) {
        final List<TrasladoEntity> traslados =
            state is TrasladosConsultaLoaded ? state.traslados : const <TrasladoEntity>[];
        final Map<String, int> counts = <String, int>{};
        for (final TrasladoEntity t in traslados) {
          counts.update(t.estado ?? '', (int v) => v + 1, ifAbsent: () => 1);
        }
        return Container(
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          alignment: Alignment.centerLeft,
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(bottom: BorderSide(color: AppColors.gray200)),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: <Widget>[
                for (final String estado in TrasladoGestion.todosLosEstados)
                  if ((counts[estado] ?? 0) > 0)
                    Padding(
                      padding: const EdgeInsets.only(right: 18),
                      child: GestionDotLabel(
                        label: '${TrasladoGestion.estadoLabel(estado)}: ${counts[estado]}',
                        color: TrasladoGestion.estadoColor(estado),
                      ),
                    ),
                if (traslados.isEmpty)
                  const Text(
                    'Sin traslados en la fecha seleccionada',
                    style: TextStyle(fontSize: 12.5, color: AppColors.gray500),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
