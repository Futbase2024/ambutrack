import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/di/injection.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/utils/rol_label.dart';
import '../../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../../auth/presentation/bloc/auth_state.dart';
import '../../../../vehiculo/domain/repositories/incidencias_repository.dart';
import '../../cubit/incidencia_detalle_cubit.dart';
import 'incidencia_datos.dart';
import 'incidencia_gestion_form.dart';

/// Abre la ficha de una incidencia de vehículo desde su notificación
Future<void> showIncidenciaDetalleSheet(BuildContext context, NotificacionEntity notificacion) {
  final AuthState auth = context.read<AuthBloc>().state;
  final bool puedeGestionar = rolGestionaIncidencias(auth is AuthAuthenticated ? auth.user.rol : null);
  final String? id = notificacion.entidadId;
  final Object? matricula = notificacion.metadata['matricula'];

  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => BlocProvider<IncidenciaDetalleCubit>(
      create: (_) {
        final IncidenciaDetalleCubit cubit = IncidenciaDetalleCubit(getIt<IncidenciasRepository>());
        if (id != null) {
          cubit.cargar(id);
        }
        return cubit;
      },
      child: _IncidenciaDetalleSheet(
        matricula: matricula is String ? matricula : null,
        puedeGestionar: puedeGestionar,
        sinId: id == null,
      ),
    ),
  );
}

class _IncidenciaDetalleSheet extends StatelessWidget {
  const _IncidenciaDetalleSheet({required this.matricula, required this.puedeGestionar, required this.sinId});

  final String? matricula;
  final bool puedeGestionar;
  final bool sinId;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.88),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const _Asa(),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                  child: sinId
                      ? const _Mensaje('Esta notificación no tiene una incidencia asociada.')
                      : _Contenido(matricula: matricula, puedeGestionar: puedeGestionar),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Contenido extends StatelessWidget {
  const _Contenido({required this.matricula, required this.puedeGestionar});

  final String? matricula;
  final bool puedeGestionar;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<IncidenciaDetalleCubit, IncidenciaDetalleState>(
      builder: (BuildContext context, IncidenciaDetalleState state) {
        final IncidenciaVehiculoEntity? incidencia = state.incidencia;
        if (state.status == IncidenciaDetalleStatus.cargando) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 48),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (incidencia == null) {
          return _Mensaje(state.error ?? 'No se ha podido cargar la incidencia.');
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            IncidenciaDatos(incidencia: incidencia, matricula: matricula),
            const SizedBox(height: 20),
            if (puedeGestionar)
              IncidenciaGestionForm(incidencia: incidencia)
            else
              const _Mensaje('Solo mantenimiento, tráfico o administración pueden cambiar el estado.'),
          ],
        );
      },
    );
  }
}

class _Asa extends StatelessWidget {
  const _Asa();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 4,
      margin: const EdgeInsets.only(top: 10, bottom: 6),
      decoration: BoxDecoration(color: AppColors.gray300, borderRadius: BorderRadius.circular(2)),
    );
  }
}

class _Mensaje extends StatelessWidget {
  const _Mensaje(this.texto);

  final String texto;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppColors.gray100, borderRadius: BorderRadius.circular(12)),
      child: Text(texto, style: const TextStyle(fontSize: 14, color: AppColors.gray700, height: 1.4)),
    );
  }
}
