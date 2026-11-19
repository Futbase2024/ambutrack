import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/personal/domain/entities/personal_entity.dart';
import 'package:ambutrack_web/features/personal/presentation/bloc/personal_bloc.dart';
import 'package:ambutrack_web/features/personal/presentation/bloc/personal_state.dart';
import 'package:ambutrack_web/features/personal/presentation/bloc/vestuario_bloc.dart';
import 'package:ambutrack_web/features/personal/presentation/bloc/vestuario_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Pestaña "Asignaciones": prendas de este artículo entregadas al personal
class StockAsignacionesTab extends StatelessWidget {
  const StockAsignacionesTab({required this.stock, super.key});

  final StockVestuarioEntity stock;

  bool _coincide(VestuarioEntity v) =>
      v.prenda == stock.prenda &&
      v.talla == stock.talla &&
      v.marca == stock.marca &&
      v.color == stock.color;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VestuarioBloc, VestuarioState>(
      builder: (BuildContext context, VestuarioState state) {
        if (state is! VestuarioLoaded) {
          return const Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        }
        final List<VestuarioEntity> asignaciones = state.items.where(_coincide).toList()
          ..sort((VestuarioEntity a, VestuarioEntity b) => b.fechaEntrega.compareTo(a.fechaEntrega));
        final List<VestuarioEntity> vigentes =
            asignaciones.where((VestuarioEntity v) => v.estaAsignado).toList();
        return BlocBuilder<PersonalBloc, PersonalState>(
          builder: (BuildContext context, PersonalState personalState) {
            final Map<String, String> nombres = <String, String>{
              if (personalState is PersonalLoaded)
                for (final PersonalEntity p in personalState.personal) p.id: p.nombreCompleto,
            };
            return GestionDetailBody(
              children: <Widget>[
                const GestionDetailSection(title: 'Resumen'),
                GestionDetailField(label: 'Asignadas ahora', value: '${vigentes.length}'),
                GestionDetailField(label: 'Total histórico', value: '${asignaciones.length}'),
                const GestionDetailSection(title: 'Entregas'),
                if (asignaciones.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      'Este artículo no se ha entregado a ningún trabajador',
                      style: TextStyle(fontSize: 12.5, color: AppColors.gray500),
                    ),
                  )
                else
                  ...asignaciones.map(
                    (VestuarioEntity v) => _AsignacionMiniRow(
                      item: v,
                      trabajador: nombres[v.personalId] ?? 'Desconocido',
                    ),
                  ),
              ],
            );
          },
        );
      },
    );
  }
}

class _AsignacionMiniRow extends StatelessWidget {
  const _AsignacionMiniRow({required this.item, required this.trabajador});

  final VestuarioEntity item;
  final String trabajador;

  @override
  Widget build(BuildContext context) {
    const TextStyle base = TextStyle(fontSize: 12, color: AppColors.gray800);
    final bool asignado = item.estaAsignado;
    return Container(
      height: 30,
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.gray100)),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              '$trabajador x${item.cantidad ?? 1}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: base.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(width: 6),
          GestionDotLabel(
            label: asignado ? 'Asignado' : 'Devuelto',
            color: asignado ? AppColors.success : AppColors.inactive,
            fontSize: 11.5,
          ),
          const SizedBox(width: 8),
          Text(
            GestionFormatters.fecha(item.fechaEntrega),
            style: base.copyWith(color: AppColors.gray500, fontSize: 11.5),
          ),
        ],
      ),
    );
  }
}
