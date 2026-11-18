import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../cubit/inicio_turno_cubit.dart';
import '../../../cubit/inicio_turno_state.dart';
import '../inicio_turno_comunes.dart';
import '../inicio_turno_resumen.dart';
import '../selector_plantilla_turno.dart';

/// Paso 1: turno del cuadrante o tipo de turno a crear desde la app
class PasoTurno extends StatelessWidget {
  const PasoTurno({required this.state, super.key});

  final InicioTurnoState state;

  @override
  Widget build(BuildContext context) {
    final InicioTurnoCubit cubit = context.read<InicioTurnoCubit>();
    if (state.turno != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const TituloSeccionInicio('Tu turno de hoy'),
          TurnoAsignadoCard(turno: state.turno!, vehiculo: state.vehiculoSeleccionado),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const SizedBox(height: 8),
        const SinTurnoAviso(),
        const TituloSeccionInicio('Tipo de turno'),
        SelectorPlantillaTurno(
          plantillas: state.plantillas,
          seleccionada: state.plantillaSeleccionada,
          onSeleccionar: cubit.seleccionarPlantilla,
        ),
      ],
    );
  }
}
