import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/features/taller/presentation/bloc/orden_reparacion_bloc.dart';
import 'package:ambutrack_web/features/taller/presentation/bloc/repuesto_orden_bloc.dart';
import 'package:ambutrack_web/features/taller/presentation/bloc/repuesto_orden_event.dart';
import 'package:ambutrack_web/features/taller/presentation/widgets/ordenes/orden_detail_dialog.dart';
import 'package:ambutrack_web/features/taller/presentation/widgets/ordenes/orden_form_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Abre el formulario de creación/edición de una orden
Future<void> showOrdenFormDialog(BuildContext context, {OrdenReparacionEntity? orden}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext _) => BlocProvider<OrdenReparacionBloc>.value(
      value: context.read<OrdenReparacionBloc>(),
      child: OrdenFormDialog(orden: orden),
    ),
  );
}

/// Abre el detalle de una orden con su propio RepuestoOrdenBloc
Future<void> showOrdenDetailDialog(BuildContext context, OrdenReparacionEntity orden) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext _) => MultiBlocProvider(
      providers: <BlocProvider<dynamic>>[
        BlocProvider<OrdenReparacionBloc>.value(value: context.read<OrdenReparacionBloc>()),
        BlocProvider<RepuestoOrdenBloc>(
          create: (BuildContext _) => getIt<RepuestoOrdenBloc>()..add(RepuestoOrdenLoadRequested(ordenId: orden.id)),
        ),
      ],
      child: OrdenDetailDialog(orden: orden),
    ),
  );
}
