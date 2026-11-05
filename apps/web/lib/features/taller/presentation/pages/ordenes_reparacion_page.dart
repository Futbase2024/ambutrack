import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/core/widgets/headers/page_header.dart';
import 'package:ambutrack_web/features/taller/presentation/bloc/orden_reparacion_bloc.dart';
import 'package:ambutrack_web/features/taller/presentation/bloc/orden_reparacion_event.dart';
import 'package:ambutrack_web/features/taller/presentation/bloc/orden_reparacion_state.dart';
import 'package:ambutrack_web/features/taller/presentation/widgets/ordenes/orden_dialogs.dart';
import 'package:ambutrack_web/features/taller/presentation/widgets/ordenes/orden_reparacion_table.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Página de gestión de Órdenes de Reparación del taller
class OrdenesReparacionPage extends StatelessWidget {
  const OrdenesReparacionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocProvider<OrdenReparacionBloc>(
        create: (BuildContext _) => getIt<OrdenReparacionBloc>()..add(const OrdenReparacionLoadRequested()),
        child: const _OrdenesReparacionView(),
      ),
    );
  }
}

class _OrdenesReparacionView extends StatelessWidget {
  const _OrdenesReparacionView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSizes.paddingXl,
          AppSizes.paddingXl,
          AppSizes.paddingXl,
          AppSizes.paddingLarge,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            BlocBuilder<OrdenReparacionBloc, OrdenReparacionState>(
              builder: (BuildContext context, OrdenReparacionState state) {
                final List<OrdenReparacionEntity> ordenes = state is OrdenReparacionLoaded
                    ? state.ordenes
                    : <OrdenReparacionEntity>[];
                return PageHeader(
                  config: PageHeaderConfig(
                    icon: Icons.build,
                    title: 'Órdenes de Reparación',
                    subtitle: 'Entrada de vehículos en taller, reparaciones, repuestos y costes',
                    addButtonLabel: 'Nueva Orden',
                    stats: _stats(ordenes),
                    onAdd: () => showOrdenFormDialog(context),
                  ),
                );
              },
            ),
            const SizedBox(height: AppSizes.spacingXl),
            const Expanded(child: OrdenReparacionTable()),
          ],
        ),
      ),
    );
  }

  List<HeaderStat> _stats(List<OrdenReparacionEntity> ordenes) {
    int contar(bool Function(OrdenReparacionEntity) test) => ordenes.where(test).length;
    final int activas = contar((OrdenReparacionEntity o) => o.estado.isActiva);
    final int esperando = contar((OrdenReparacionEntity o) => o.estado == EstadoOrdenReparacion.esperandoRepuestos);
    final int terminadas = contar(
      (OrdenReparacionEntity o) =>
          o.estado == EstadoOrdenReparacion.finalizada || o.estado == EstadoOrdenReparacion.cerrada,
    );
    return <HeaderStat>[
      HeaderStat(value: ordenes.length.toString(), icon: Icons.build),
      HeaderStat(value: activas.toString(), icon: Icons.car_repair, color: AppColors.info),
      HeaderStat(value: esperando.toString(), icon: Icons.hourglass_top, color: AppColors.warning),
      HeaderStat(value: terminadas.toString(), icon: Icons.task_alt, color: AppColors.success),
    ];
  }
}
