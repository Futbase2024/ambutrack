import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_sizes.dart';
import '../../../cubit/inicio_turno_cubit.dart';
import '../../../cubit/inicio_turno_reglas.dart';
import '../../../cubit/inicio_turno_state.dart';
import '../inicio_turno_comunes.dart';
import 'selector_companero_sheet.dart';

/// Paso 3: rol en la dotación + compañero (opcional) + documentación personal
class PasoDotacion extends StatelessWidget {
  const PasoDotacion({required this.state, super.key});

  final InicioTurnoState state;

  /// Personas ya en servicio con el vehículo: sugerencias de compañero
  List<TPersonalEntity> get _sugeridos {
    final Set<String> ids = state.ocupantes.map((OcupanteVehiculoEntity o) => o.personalId).toSet();
    return state.personalActivo.where((TPersonalEntity p) => ids.contains(p.id)).toList();
  }

  Future<void> _buscarCompanero(BuildContext context) async {
    final InicioTurnoCubit cubit = context.read<InicioTurnoCubit>();
    final TPersonalEntity? elegido = await showSelectorCompanero(context, personal: state.personalActivo);
    if (elegido != null) {
      cubit.seleccionarCompanero(elegido);
    }
  }

  @override
  Widget build(BuildContext context) {
    final InicioTurnoCubit cubit = context.read<InicioTurnoCubit>();
    final TPersonalEntity? companero = state.companero;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const TituloSeccionInicio('Tu rol hoy'),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: <Widget>[
            for (final RolDotacion rol in RolDotacion.values)
              ChoiceChip(
                label: Text(rol.label),
                selected: state.rol == rol,
                onSelected: (_) => cubit.seleccionarRol(rol),
                selectedColor: AppColors.primarySurface,
                labelStyle: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: state.rol == rol ? AppColors.primary : AppColors.gray700,
                ),
              ),
          ],
        ),
        AvisosInicioTurnoList(avisos: state.avisosPersonal),
        const TituloSeccionInicio('Compañero (opcional)'),
        if (companero != null)
          _CompaneroCard(companero: companero, onQuitar: () => cubit.seleccionarCompanero(null))
        else ...<Widget>[
          for (final TPersonalEntity p in _sugeridos)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _SugerenciaCompanero(personal: p, onTap: () => cubit.seleccionarCompanero(p)),
            ),
          OutlinedButton.icon(
            onPressed: state.personalActivo.isEmpty ? null : () => _buscarCompanero(context),
            icon: const Icon(Icons.person_add_alt_1_rounded),
            label: const Text('Añadir compañero'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ],
    );
  }
}

class _CompaneroCard extends StatelessWidget {
  const _CompaneroCard({required this.companero, required this.onQuitar});

  final TPersonalEntity companero;
  final VoidCallback onQuitar;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.primarySurface,
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: <Widget>[
          const Icon(Icons.people_alt_rounded, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '${companero.nombre} ${companero.apellidos}'.trim().toUpperCase(),
              style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.gray900),
            ),
          ),
          IconButton(
            onPressed: onQuitar,
            tooltip: 'Quitar compañero',
            icon: const Icon(Icons.close_rounded, color: AppColors.gray600),
          ),
        ],
      ),
    );
  }
}

class _SugerenciaCompanero extends StatelessWidget {
  const _SugerenciaCompanero({required this.personal, required this.onTap});

  final TPersonalEntity personal;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      tileColor: AppColors.success.withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusMedium)),
      leading: const Icon(Icons.local_shipping_rounded, color: AppColors.success),
      title: Text(
        '${personal.nombre} ${personal.apellidos}'.trim().toUpperCase(),
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: const Text('Ya está en servicio con este vehículo'),
      trailing: const Icon(Icons.add_circle_outline_rounded, color: AppColors.success),
    );
  }
}
