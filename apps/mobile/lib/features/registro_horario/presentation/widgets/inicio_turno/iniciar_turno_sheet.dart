import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/di/injection.dart';
import '../../../../../core/services/preferencias_dispositivo_service.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../../auth/presentation/bloc/auth_state.dart';
import '../../../domain/repositories/turno_actual_repository.dart';
import '../../bloc/registro_horario_event.dart';
import '../../cubit/inicio_turno_cubit.dart';
import '../../cubit/inicio_turno_reglas.dart';
import '../../cubit/inicio_turno_state.dart';
import 'inicio_turno_comunes.dart';
import 'pasos/paso_checklist.dart';
import 'pasos/paso_dotacion.dart';
import 'pasos/paso_estado_vehiculo.dart';
import 'pasos/paso_resumen.dart';
import 'pasos/paso_turno.dart';
import 'pasos/paso_vehiculo.dart';

/// Abre el asistente "Iniciar turno" y devuelve lo elegido (null si cancela)
///
/// [latitud]/[longitud]: posición del fichaje, para comprobar la geocerca de la base.
Future<InicioTurnoSeleccion?> showIniciarTurnoSheet(
  BuildContext context, {
  required String idPersonal,
  double? latitud,
  double? longitud,
}) {
  final AuthState auth = context.read<AuthBloc>().state;
  final TPersonalEntity? personal = auth is AuthAuthenticated ? auth.personal : null;
  if (personal == null || personal.id != idPersonal) {
    return Future<InicioTurnoSeleccion?>.value();
  }
  return showModalBottomSheet<InicioTurnoSeleccion>(
    context: context,
    isScrollControlled: true,
    isDismissible: false,
    enableDrag: false,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => BlocProvider<InicioTurnoCubit>(
      create: (_) => InicioTurnoCubit(getIt<TurnoActualRepository>())
        ..cargar(personal, latitud: latitud, longitud: longitud),
      child: const IniciarTurnoSheet(),
    ),
  );
}

/// Asistente de entrada en turno:
/// turno → vehículo → dotación → km/combustible → revisión → confirmar
class IniciarTurnoSheet extends StatelessWidget {
  const IniciarTurnoSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
        child: SizedBox(
          height: MediaQuery.sizeOf(context).height * 0.9,
          child: BlocBuilder<InicioTurnoCubit, InicioTurnoState>(
            builder: (BuildContext context, InicioTurnoState state) {
              return Column(
                children: <Widget>[
                  const _Cabecera(),
                  if (state.status == InicioTurnoStatus.listo) IndicadorPasosInicio(actual: state.paso),
                  Expanded(child: _Cuerpo(state: state)),
                  _Acciones(state: state),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _Cabecera extends StatelessWidget {
  const _Cabecera();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 12),
      child: Row(
        children: <Widget>[
          Icon(Icons.play_circle_fill_rounded, color: AppColors.primary, size: 32),
          SizedBox(width: 12),
          Text(
            'Iniciar turno',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.gray900),
          ),
        ],
      ),
    );
  }
}

class _Cuerpo extends StatelessWidget {
  const _Cuerpo({required this.state});

  final InicioTurnoState state;

  @override
  Widget build(BuildContext context) {
    switch (state.status) {
      case InicioTurnoStatus.cargando:
        return const Center(child: CircularProgressIndicator());
      case InicioTurnoStatus.error:
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'No se pudo cargar tu turno.\n${state.error ?? ''}',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.error),
            ),
          ),
        );
      case InicioTurnoStatus.listo:
        return ListView(
          key: ValueKey<PasoInicioTurno>(state.paso),
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          children: <Widget>[_PasoActual(state: state)],
        );
    }
  }
}

class _PasoActual extends StatelessWidget {
  const _PasoActual({required this.state});

  final InicioTurnoState state;

  @override
  Widget build(BuildContext context) {
    switch (state.paso) {
      case PasoInicioTurno.turno:
        return PasoTurno(state: state);
      case PasoInicioTurno.vehiculo:
        return PasoVehiculo(state: state);
      case PasoInicioTurno.dotacion:
        return PasoDotacion(state: state);
      case PasoInicioTurno.estado:
        return PasoEstadoVehiculo(state: state);
      case PasoInicioTurno.checklist:
        return PasoChecklist(state: state);
      case PasoInicioTurno.resumen:
        return PasoResumen(state: state);
    }
  }
}

class _Acciones extends StatelessWidget {
  const _Acciones({required this.state});

  final InicioTurnoState state;

  void _confirmar(BuildContext context) {
    Navigator.of(context).pop(
      state.toSeleccion(modoDispositivo: getIt<PreferenciasDispositivoService>().modo.value),
    );
  }

  @override
  Widget build(BuildContext context) {
    final InicioTurnoCubit cubit = context.read<InicioTurnoCubit>();
    final bool listo = state.status == InicioTurnoStatus.listo;
    final bool primero = state.paso == PasoInicioTurno.turno;
    final bool ultimo = state.paso == PasoInicioTurno.resumen;
    final RoundedRectangleBorder forma = RoundedRectangleBorder(borderRadius: BorderRadius.circular(10));

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppColors.gray200))),
      child: Row(
        children: <Widget>[
          Expanded(
            child: OutlinedButton(
              onPressed: () => primero || !listo ? Navigator.of(context).pop() : cubit.anterior(),
              style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14), shape: forma),
              child: Text(primero || !listo ? 'Cancelar' : 'Atrás'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: FilledButton.icon(
              onPressed: listo && state.puedeAvanzar ? () => ultimo ? _confirmar(context) : cubit.siguiente() : null,
              icon: Icon(ultimo ? Icons.play_arrow_rounded : Icons.arrow_forward_rounded),
              label: Text(ultimo ? 'Iniciar turno' : 'Siguiente'),
              style: FilledButton.styleFrom(
                backgroundColor: ultimo ? AppColors.success : AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: forma,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
