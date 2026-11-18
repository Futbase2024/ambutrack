import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_sizes.dart';
import '../../../../domain/services/validador_inicio_turno.dart';
import '../../../cubit/inicio_turno_cubit.dart';
import '../../../cubit/inicio_turno_reglas.dart';
import '../../../cubit/inicio_turno_state.dart';
import '../inicio_turno_comunes.dart';

/// Paso 6: resumen, ubicación respecto a la base y declaración de aptitud
class PasoResumen extends StatelessWidget {
  const PasoResumen({required this.state, super.key});

  final InicioTurnoState state;

  String get _turno => state.turno != null
      ? '${state.turno!.tipoTurno.nombre} ${state.turno!.horaInicio}-${state.turno!.horaFin}'
      : '${state.plantillaSeleccionada?.nombre ?? '-'} (nuevo)';

  String get _dotacion {
    final String rol = state.rol?.label ?? '-';
    final String? c = state.companero == null
        ? null
        : '${state.companero!.nombre} ${state.companero!.apellidos}'.trim().toUpperCase();
    return c == null ? rol : '$rol + $c';
  }

  int get _incidencias => state.respuestas.values.where((bool ok) => !ok).length;

  @override
  Widget build(BuildContext context) {
    final InicioTurnoCubit cubit = context.read<InicioTurnoCubit>();
    final AvisoInicioTurno? fuera = state.avisoFueraBase;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const TituloSeccionInicio('Resumen'),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.primarySurface,
            borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
          ),
          child: Column(
            children: <Widget>[
              _Linea(icono: Icons.event_available_rounded, texto: _turno),
              _Linea(icono: Icons.local_shipping_rounded, texto: state.vehiculoSeleccionado?.matricula ?? '-'),
              _Linea(icono: Icons.people_alt_rounded, texto: _dotacion),
              _Linea(
                icono: Icons.speed_rounded,
                texto: '${state.km ?? '-'} km · Combustible ${state.combustible?.label ?? '-'}',
              ),
              _Linea(
                icono: Icons.fact_check_rounded,
                texto: _incidencias == 0 ? 'Revisión correcta' : 'Revisión con $_incidencias incidencia(s)',
              ),
              _Linea(icono: Icons.place_rounded, texto: _textoUbicacion),
            ],
          ),
        ),
        if (fuera != null) ...<Widget>[
          AvisosInicioTurnoList(avisos: <AvisoInicioTurno>[fuera]),
          if (!fuera.bloquea)
            TextField(
              onChanged: cubit.cambiarMotivoFueraBase,
              textInputAction: TextInputAction.done,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Motivo de iniciar fuera de base',
                hintText: 'Ej: relevo en hospital, vehículo en taller...',
              ),
            ),
        ],
        const SizedBox(height: 12),
        CheckboxListTile(
          value: state.declaracion,
          onChanged: (bool? v) => cubit.cambiarDeclaracion(valor: v ?? false),
          controlAffinity: ListTileControlAffinity.leading,
          contentPadding: EdgeInsets.zero,
          activeColor: AppColors.primary,
          title: const Text(
            'Declaro que estoy en condiciones para el servicio',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: const Text('Descansado/a, sin alcohol ni medicación que me impida trabajar'),
        ),
      ],
    );
  }

  String get _textoUbicacion {
    final int? d = state.distanciaBase;
    if (d == null) {
      return 'Ubicación: sin comprobar';
    }
    final String base = state.ubicacionBase?.nombre ?? 'base';
    return state.fueraDeBase ? 'A $d m de $base (fuera de base)' : 'En $base ✓';
  }
}

class _Linea extends StatelessWidget {
  const _Linea({required this.icono, required this.texto});

  final IconData icono;
  final String texto;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: <Widget>[
          Icon(icono, size: 18, color: AppColors.primary),
          const SizedBox(width: 10),
          Expanded(child: Text(texto, style: const TextStyle(fontSize: 14, color: AppColors.gray900))),
        ],
      ),
    );
  }
}
