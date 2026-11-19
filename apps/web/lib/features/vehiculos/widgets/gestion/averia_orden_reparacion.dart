import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/features/taller/presentation/bloc/orden_reparacion_bloc.dart';
import 'package:ambutrack_web/features/taller/presentation/bloc/orden_reparacion_state.dart';
import 'package:ambutrack_web/features/taller/presentation/bloc/taller_bloc.dart';
import 'package:ambutrack_web/features/taller/presentation/bloc/taller_state.dart';
import 'package:ambutrack_web/features/taller/presentation/widgets/ordenes/orden_form_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Equivalencia de la prioridad de la avería con la de la orden
PrioridadOrdenReparacion prioridadOrdenDesdeAveria(PrioridadIncidencia prioridad) {
  switch (prioridad) {
    case PrioridadIncidencia.baja:
      return PrioridadOrdenReparacion.baja;
    case PrioridadIncidencia.media:
      return PrioridadOrdenReparacion.normal;
    case PrioridadIncidencia.alta:
      return PrioridadOrdenReparacion.alta;
    case PrioridadIncidencia.critica:
      return PrioridadOrdenReparacion.urgente;
  }
}

/// Orden prerrellenada con los datos de la avería (vehículo, taller, km,
/// diagnóstico y prioridad) y vinculada a ella mediante `incidenciaId`.
OrdenReparacionEntity plantillaOrdenDesdeAveria(IncidenciaVehiculoEntity averia, List<TallerEntity> talleres) {
  final String? tallerNombre = averia.tallerResponsable;
  final String? tallerId = talleres.where((TallerEntity t) => t.nombre == tallerNombre).firstOrNull?.id;
  final DateTime ahora = DateTime.now();
  return OrdenReparacionEntity(
    id: '',
    empresaId: averia.empresaId,
    vehiculoId: averia.vehiculoId,
    tallerId: tallerId,
    incidenciaId: averia.id,
    prioridad: prioridadOrdenDesdeAveria(averia.prioridad),
    diagnostico: '${averia.titulo}\n\n${averia.descripcion}'.trim(),
    kilometrajeEntrada: averia.kilometrajeReporte?.round(),
    fechaEntrada: ahora,
    createdAt: ahora,
  );
}

/// Abre el formulario de orden a partir de la avería.
///
/// Devuelve la orden creada, o `null` si el usuario cancela o falla el guardado.
/// Requiere un [TallerBloc] en el contexto para resolver el taller de la avería.
Future<OrdenReparacionEntity?> crearOrdenDesdeAveria(BuildContext context, IncidenciaVehiculoEntity averia) async {
  final TallerState tallerState = context.read<TallerBloc>().state;
  final List<TallerEntity> talleres = tallerState is TallerLoaded ? tallerState.talleres : <TallerEntity>[];
  final OrdenReparacionBloc bloc = getIt<OrdenReparacionBloc>();
  try {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext _) => BlocProvider<OrdenReparacionBloc>.value(
        value: bloc,
        child: OrdenFormDialog(plantilla: plantillaOrdenDesdeAveria(averia, talleres)),
      ),
    );
    final OrdenReparacionState state = bloc.state;
    if (state is! OrdenReparacionOperationSuccess || state.operacion != OrdenOperacion.crear) {
      return null;
    }
    final List<OrdenReparacionEntity> vinculadas = state.ordenes
        .where((OrdenReparacionEntity o) => o.incidenciaId == averia.id)
        .toList()
      ..sort((OrdenReparacionEntity a, OrdenReparacionEntity b) => b.createdAt.compareTo(a.createdAt));
    return vinculadas.firstOrNull;
  } finally {
    await bloc.close();
  }
}

/// Avería actualizada tras crear su orden: pasa a "En reparación" (si aún no
/// estaba en reparación o resuelta) y toma el taller de la orden.
IncidenciaVehiculoEntity averiaTrasCrearOrden(IncidenciaVehiculoEntity averia, OrdenReparacionEntity orden) {
  final bool pendiente =
      averia.estado == EstadoIncidencia.reportada || averia.estado == EstadoIncidencia.enRevision;
  return averia.copyWith(
    estado: pendiente ? EstadoIncidencia.enReparacion : averia.estado,
    tallerResponsable: orden.tallerNombre ?? averia.tallerResponsable,
    updatedAt: DateTime.now(),
  );
}
