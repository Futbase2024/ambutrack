import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/di/injection.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../domain/repositories/turno_actual_repository.dart';
import '../../bloc/registro_horario_event.dart';
import '../../cubit/inicio_turno_cubit.dart';
import '../../cubit/inicio_turno_state.dart';
import 'inicio_turno_resumen.dart';
import 'selector_plantilla_turno.dart';
import 'selector_vehiculo_lista.dart';

/// Abre la hoja "Iniciar turno" y devuelve lo elegido (null si cancela)
Future<InicioTurnoSeleccion?> showIniciarTurnoSheet(
  BuildContext context, {
  required String idPersonal,
}) {
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
      create: (_) => InicioTurnoCubit(getIt<TurnoActualRepository>())..cargar(idPersonal),
      child: const IniciarTurnoSheet(),
    ),
  );
}

/// Hoja de inicio de turno
///
/// - Turno con vehículo → confirma directamente
/// - Turno sin vehículo → pide vehículo
/// - Sin turno → pide tipo de turno + vehículo (se crea desde la app)
class IniciarTurnoSheet extends StatelessWidget {
  const IniciarTurnoSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.85,
        child: BlocBuilder<InicioTurnoCubit, InicioTurnoState>(
          builder: (BuildContext context, InicioTurnoState state) {
            return Column(
              children: <Widget>[
                const _Cabecera(),
                Expanded(child: _Cuerpo(state: state)),
                _Acciones(state: state),
              ],
            );
          },
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
        return _Formulario(state: state);
    }
  }
}

class _Formulario extends StatelessWidget {
  const _Formulario({required this.state});

  final InicioTurnoState state;

  @override
  Widget build(BuildContext context) {
    final InicioTurnoCubit cubit = context.read<InicioTurnoCubit>();
    final bool sinTurno = state.turno == null;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      children: <Widget>[
        if (sinTurno) ...<Widget>[
          const SinTurnoAviso(),
          const _Titulo('Tipo de turno'),
          SelectorPlantillaTurno(
            plantillas: state.plantillas,
            seleccionada: state.plantillaSeleccionada,
            onSeleccionar: cubit.seleccionarPlantilla,
          ),
        ] else
          TurnoAsignadoCard(
            turno: state.turno!,
            vehiculo: state.tieneTurnoConVehiculo ? state.vehiculoSeleccionado : null,
            onCambiarVehiculo: state.tieneTurnoConVehiculo && !state.cambiandoVehiculo ? cubit.activarCambioVehiculo : null,
          ),
        if (state.mostrarSelectorVehiculo) ...<Widget>[
          const _Titulo('Vehículo'),
          SelectorVehiculoLista(
            vehiculos: state.vehiculosFiltrados,
            seleccionado: state.vehiculoSeleccionado,
            onSeleccionar: cubit.seleccionarVehiculo,
            onFiltrar: cubit.filtrar,
          ),
        ],
      ],
    );
  }
}

class _Titulo extends StatelessWidget {
  const _Titulo(this.texto);

  final String texto;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 10),
      child: Text(
        texto.toUpperCase(),
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.gray600, letterSpacing: 0.8),
      ),
    );
  }
}

class _Acciones extends StatelessWidget {
  const _Acciones({required this.state});

  final InicioTurnoState state;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppColors.gray200))),
      child: Row(
        children: <Widget>[
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Cancelar'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: FilledButton.icon(
              onPressed: state.puedeConfirmar ? () => _confirmar(context) : null,
              icon: const Icon(Icons.play_arrow_rounded),
              label: const Text('Iniciar turno'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmar(BuildContext context) {
    Navigator.of(context).pop(
      InicioTurnoSeleccion(
        turno: state.turno,
        vehiculo: state.vehiculoSeleccionado!,
        plantilla: state.plantillaSeleccionada,
      ),
    );
  }
}
