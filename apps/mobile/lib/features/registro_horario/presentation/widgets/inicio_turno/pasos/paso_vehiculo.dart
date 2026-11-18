import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/widgets/dialogs/dialogs.dart';
import '../../../cubit/inicio_turno_cubit.dart';
import '../../../cubit/inicio_turno_reglas.dart';
import '../../../cubit/inicio_turno_state.dart';
import '../escaner_qr_vehiculo_page.dart';
import '../inicio_turno_comunes.dart';
import '../inicio_turno_resumen.dart';
import '../selector_vehiculo_lista.dart';

/// Paso 2: vehículo (QR o lista) + avisos de documentación y ocupación
class PasoVehiculo extends StatelessWidget {
  const PasoVehiculo({required this.state, super.key});

  final InicioTurnoState state;

  Future<void> _escanear(BuildContext context) async {
    final InicioTurnoCubit cubit = context.read<InicioTurnoCubit>();
    final String? codigo = await escanearQrVehiculo(context);
    if (codigo == null || !context.mounted) {
      return;
    }
    if (!await cubit.seleccionarPorCodigo(codigo) && context.mounted) {
      await showProfessionalResultDialog(
        context,
        title: 'Vehículo no encontrado',
        message: 'El código leído no corresponde a ningún vehículo operativo. Elígelo de la lista.',
        icon: Icons.qr_code_2_rounded,
        iconColor: AppColors.warning,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final InicioTurnoCubit cubit = context.read<InicioTurnoCubit>();
    final VehiculoEntity? vehiculo = state.vehiculoSeleccionado;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () => _escanear(context),
          icon: const Icon(Icons.qr_code_scanner_rounded, size: 28),
          label: const Text('Escanear QR del vehículo', style: TextStyle(fontSize: 16)),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: const BorderSide(color: AppColors.primary, width: 1.5),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        if (state.turno != null && vehiculo != null && !state.cambiandoVehiculo) ...<Widget>[
          const TituloSeccionInicio('Vehículo de tu turno'),
          TurnoAsignadoCard(
            turno: state.turno!,
            vehiculo: vehiculo,
            onCambiarVehiculo: cubit.activarCambioVehiculo,
          ),
        ],
        if (state.cargandoOcupacion)
          const Padding(
            padding: EdgeInsets.only(top: 12),
            child: LinearProgressIndicator(minHeight: 2),
          ),
        AvisosInicioTurnoList(avisos: state.avisosVehiculo),
        if (state.mostrarSelectorVehiculo || state.turno == null) ...<Widget>[
          const TituloSeccionInicio('O elige de la lista'),
          SelectorVehiculoLista(
            vehiculos: state.vehiculosFiltrados,
            seleccionado: vehiculo,
            onSeleccionar: cubit.seleccionarVehiculo,
            onFiltrar: cubit.filtrar,
          ),
        ],
      ],
    );
  }
}
