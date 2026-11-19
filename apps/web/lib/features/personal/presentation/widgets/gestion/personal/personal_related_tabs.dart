import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/personal/presentation/bloc/equipamiento_personal_bloc.dart';
import 'package:ambutrack_web/features/personal/presentation/bloc/equipamiento_personal_event.dart';
import 'package:ambutrack_web/features/personal/presentation/bloc/equipamiento_personal_state.dart';
import 'package:ambutrack_web/features/personal/presentation/bloc/vestuario_bloc.dart';
import 'package:ambutrack_web/features/personal/presentation/bloc/vestuario_event.dart';
import 'package:ambutrack_web/features/personal/presentation/bloc/vestuario_state.dart';
import 'package:ambutrack_web/features/personal/presentation/widgets/gestion/common/personal_gestion_common.dart';
import 'package:ambutrack_web/features/personal/presentation/widgets/gestion/equipamiento/equipamiento_gestion_columns.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Fila compacta de las pestañas relacionadas: texto · indicador · fecha
class PersonalMiniRow extends StatelessWidget {
  const PersonalMiniRow({
    required this.title,
    required this.dotLabel,
    required this.dotColor,
    required this.date,
    super.key,
  });

  final String title;
  final String dotLabel;
  final Color dotColor;
  final DateTime? date;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30,
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.gray100)),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 5,
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.gray800),
            ),
          ),
          Expanded(
            flex: 3,
            child: GestionDotLabel(label: dotLabel, color: dotColor, fontSize: 11.5),
          ),
          Text(
            GestionFormatters.fecha(date),
            style: const TextStyle(fontSize: 11.5, color: AppColors.gray500),
          ),
        ],
      ),
    );
  }
}

/// Pestaña "Equipamiento" de la ficha del empleado
class PersonalEquipamientoTab extends StatelessWidget {
  const PersonalEquipamientoTab({required this.personalId, super.key});

  final String personalId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<EquipamientoPersonalBloc>(
      create: (BuildContext _) =>
          getIt<EquipamientoPersonalBloc>()..add(EquipamientoPersonalLoadByPersonalRequested(personalId)),
      child: BlocBuilder<EquipamientoPersonalBloc, EquipamientoPersonalState>(
        builder: (BuildContext context, EquipamientoPersonalState state) {
          if (state is EquipamientoPersonalError) {
            return GestionDetailBody(children: <Widget>[GestionDetailMessage(state.message)]);
          }
          if (state is! EquipamientoPersonalLoaded) {
            return const GestionDetailLoading();
          }
          final List<EquipamientoPersonalEntity> items = List<EquipamientoPersonalEntity>.of(state.items)
            ..sort((EquipamientoPersonalEntity a, EquipamientoPersonalEntity b) =>
                b.fechaAsignacion.compareTo(a.fechaAsignacion));
          final int asignados = items.where((EquipamientoPersonalEntity e) => e.estaAsignado).length;
          return GestionDetailBody(
            children: <Widget>[
              const GestionDetailSection(title: 'Resumen'),
              GestionDetailField(label: 'Asignado', value: '$asignados'),
              GestionDetailField(label: 'Devuelto', value: '${items.length - asignados}'),
              const GestionDetailSection(title: 'Equipamiento'),
              if (items.isEmpty)
                const GestionDetailMessage('Este empleado no tiene equipamiento registrado')
              else
                ...items.map(
                  (EquipamientoPersonalEntity e) => PersonalMiniRow(
                    title: e.nombreEquipamiento,
                    dotLabel: equipamientoTipoLabel(e.tipoEquipamiento),
                    dotColor: e.estaAsignado ? equipamientoTipoColor(e.tipoEquipamiento) : AppColors.inactive,
                    date: e.fechaAsignacion,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

/// Pestaña "Vestuario" de la ficha del empleado
class PersonalVestuarioTab extends StatelessWidget {
  const PersonalVestuarioTab({required this.personalId, super.key});

  final String personalId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<VestuarioBloc>(
      create: (BuildContext _) => getIt<VestuarioBloc>()..add(VestuarioLoadByPersonalRequested(personalId)),
      child: BlocBuilder<VestuarioBloc, VestuarioState>(
        builder: (BuildContext context, VestuarioState state) {
          if (state is VestuarioError) {
            return GestionDetailBody(children: <Widget>[GestionDetailMessage(state.message)]);
          }
          if (state is! VestuarioLoaded) {
            return const GestionDetailLoading();
          }
          final List<VestuarioEntity> items = List<VestuarioEntity>.of(state.items)
            ..sort((VestuarioEntity a, VestuarioEntity b) => b.fechaEntrega.compareTo(a.fechaEntrega));
          final int asignadas = items.where((VestuarioEntity v) => v.estaAsignado).length;
          return GestionDetailBody(
            children: <Widget>[
              const GestionDetailSection(title: 'Resumen'),
              GestionDetailField(label: 'Prendas en uso', value: '$asignadas'),
              GestionDetailField(label: 'Devueltas', value: '${items.length - asignadas}'),
              const GestionDetailSection(title: 'Prendas entregadas'),
              if (items.isEmpty)
                const GestionDetailMessage('Este empleado no tiene vestuario registrado')
              else
                ...items.map(
                  (VestuarioEntity v) => PersonalMiniRow(
                    title: '${v.prenda} · ${v.talla}',
                    dotLabel: v.estaAsignado ? 'En uso' : 'Devuelta',
                    dotColor: v.estaAsignado ? AppColors.success : AppColors.inactive,
                    date: v.fechaEntrega,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
