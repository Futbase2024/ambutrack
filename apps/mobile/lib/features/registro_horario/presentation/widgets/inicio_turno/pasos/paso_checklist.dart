import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_sizes.dart';
import '../../../cubit/inicio_turno_cubit.dart';
import '../../../cubit/inicio_turno_reglas.dart';
import '../../../cubit/inicio_turno_state.dart';
import '../inicio_turno_comunes.dart';

/// Paso 5: revisión rápida obligatoria (checklist corto)
///
/// Cada punto se marca OK o con incidencia; la incidencia exige una observación.
class PasoChecklist extends StatelessWidget {
  const PasoChecklist({required this.state, super.key});

  final InicioTurnoState state;

  @override
  Widget build(BuildContext context) {
    final InicioTurnoCubit cubit = context.read<InicioTurnoCubit>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        if (state.avisosMaterial.isNotEmpty) ...<Widget>[
          const TituloSeccionInicio('Material con caducidad'),
          AvisosInicioTurnoList(avisos: state.avisosMaterial),
        ],
        if (state.checklistNombres.isEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 24),
            child: Text(
              'No hay revisión rápida configurada. Puedes continuar.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.gray600),
            ),
          )
        else
          Row(
            children: <Widget>[
              const Expanded(child: TituloSeccionInicio('Revisión rápida')),
              TextButton.icon(
                onPressed: cubit.marcarTodoCorrecto,
                icon: const Icon(Icons.done_all_rounded, size: 18),
                label: const Text('Todo OK'),
                style: TextButton.styleFrom(foregroundColor: AppColors.success),
              ),
            ],
          ),
        for (int i = 0; i < state.checklistNombres.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _ItemChecklist(
              nombre: state.checklistNombres[i],
              respuesta: state.respuestas[i],
              observacion: state.observaciones[i] ?? '',
              onResponder: (bool ok) => cubit.responder(i, correcto: ok),
              onObservar: (String t) => cubit.observar(i, t),
            ),
          ),
        const SizedBox(height: 8),
        const Text(
          'El checklist completo de la ambulancia se sigue haciendo desde "Checklist" cuando toque.',
          style: TextStyle(fontSize: 12, color: AppColors.gray500),
        ),
      ],
    );
  }
}

class _ItemChecklist extends StatelessWidget {
  const _ItemChecklist({
    required this.nombre,
    required this.respuesta,
    required this.observacion,
    required this.onResponder,
    required this.onObservar,
  });

  final String nombre;
  final bool? respuesta;
  final String observacion;
  final ValueChanged<bool> onResponder;
  final ValueChanged<String> onObservar;

  @override
  Widget build(BuildContext context) {
    final Color borde = respuesta == null
        ? AppColors.gray300
        : respuesta!
        ? AppColors.success
        : AppColors.warning;
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 10, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        border: Border.all(color: borde),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(nombre, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              ),
              _BotonRespuesta(
                icono: Icons.check_rounded,
                color: AppColors.success,
                activo: respuesta ?? false,
                onTap: () => onResponder(true),
              ),
              const SizedBox(width: 6),
              _BotonRespuesta(
                icono: Icons.priority_high_rounded,
                color: AppColors.warning,
                activo: respuesta == false,
                onTap: () => onResponder(false),
              ),
            ],
          ),
          if (respuesta == false)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: TextFormField(
                initialValue: observacion,
                onChanged: onObservar,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(hintText: '¿Qué ocurre? (obligatorio)', isDense: true),
              ),
            ),
        ],
      ),
    );
  }
}

class _BotonRespuesta extends StatelessWidget {
  const _BotonRespuesta({required this.icono, required this.color, required this.activo, required this.onTap});

  final IconData icono;
  final Color color;
  final bool activo;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: activo ? color : color.withValues(alpha: 0.08), shape: BoxShape.circle),
        child: Icon(icono, size: 20, color: activo ? Colors.white : color),
      ),
    );
  }
}
