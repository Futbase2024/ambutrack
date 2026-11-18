import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_sizes.dart';
import '../../../cubit/inicio_turno_cubit.dart';
import '../../../cubit/inicio_turno_reglas.dart';
import '../../../cubit/inicio_turno_state.dart';
import '../../../../domain/services/validador_inicio_turno.dart';
import '../inicio_turno_comunes.dart';

/// Paso 4: km iniciales (+ foto opcional) y nivel de combustible
class PasoEstadoVehiculo extends StatefulWidget {
  const PasoEstadoVehiculo({required this.state, super.key});

  final InicioTurnoState state;

  @override
  State<PasoEstadoVehiculo> createState() => _PasoEstadoVehiculoState();
}

class _PasoEstadoVehiculoState extends State<PasoEstadoVehiculo> {
  late final TextEditingController _km = TextEditingController(text: widget.state.km?.toString() ?? '');

  @override
  void dispose() {
    _km.dispose();
    super.dispose();
  }

  Future<void> _hacerFoto() async {
    final InicioTurnoCubit cubit = context.read<InicioTurnoCubit>();
    try {
      final XFile? foto = await ImagePicker().pickImage(
        source: ImageSource.camera,
        maxWidth: 1280,
        imageQuality: 70,
      );
      if (foto != null) {
        final Uint8List bytes = await foto.readAsBytes();
        cubit.cambiarFoto(bytes);
      }
    } catch (e) {
      debugPrint('⚠️ [PasoEstadoVehiculo] No se pudo hacer la foto: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final InicioTurnoState state = widget.state;
    final InicioTurnoCubit cubit = context.read<InicioTurnoCubit>();
    final double? kmAnterior = state.vehiculoSeleccionado?.kmActual;
    final AvisoInicioTurno? avisoKm = state.avisoKm;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const TituloSeccionInicio('Kilómetros iniciales'),
        TextField(
          controller: _km,
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.done,
          inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
          onChanged: cubit.cambiarKm,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, letterSpacing: 1),
          decoration: InputDecoration(
            hintText: kmAnterior != null && kmAnterior > 0 ? '${kmAnterior.round()}' : '000000',
            suffixText: 'km',
            helperText: kmAnterior != null && kmAnterior > 0 ? 'Último registrado: ${kmAnterior.round()} km' : null,
            prefixIcon: const Icon(Icons.speed_rounded),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppSizes.radiusMedium)),
          ),
        ),
        if (avisoKm != null) AvisosInicioTurnoList(avisos: <AvisoInicioTurno>[avisoKm]),
        const SizedBox(height: 12),
        _FotoKm(foto: state.fotoKm, onHacer: _hacerFoto, onQuitar: () => cubit.cambiarFoto(null)),
        const TituloSeccionInicio('Combustible'),
        Row(
          children: <Widget>[
            for (final NivelCombustible n in NivelCombustible.values)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: _BotonCombustible(
                    nivel: n,
                    seleccionado: state.combustible == n,
                    onTap: () => cubit.seleccionarCombustible(n),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _FotoKm extends StatelessWidget {
  const _FotoKm({required this.foto, required this.onHacer, required this.onQuitar});

  final Uint8List? foto;
  final VoidCallback onHacer;
  final VoidCallback onQuitar;

  @override
  Widget build(BuildContext context) {
    if (foto == null) {
      return TextButton.icon(
        onPressed: onHacer,
        icon: const Icon(Icons.photo_camera_outlined),
        label: const Text('Foto del cuentakilómetros (opcional)'),
      );
    }
    return Row(
      children: <Widget>[
        ClipRRect(
          borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
          child: Image.memory(foto!, width: 72, height: 72, fit: BoxFit.cover),
        ),
        const SizedBox(width: 12),
        const Expanded(child: Text('Foto añadida', style: TextStyle(fontWeight: FontWeight.w600))),
        TextButton(onPressed: onHacer, child: const Text('Repetir')),
        IconButton(onPressed: onQuitar, icon: const Icon(Icons.delete_outline, color: AppColors.error)),
      ],
    );
  }
}

class _BotonCombustible extends StatelessWidget {
  const _BotonCombustible({required this.nivel, required this.seleccionado, required this.onTap});

  final NivelCombustible nivel;
  final bool seleccionado;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: seleccionado ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
          border: Border.all(color: seleccionado ? AppColors.primary : AppColors.gray300),
        ),
        child: Column(
          children: <Widget>[
            Icon(
              Icons.local_gas_station_rounded,
              size: 20,
              color: seleccionado ? Colors.white : AppColors.gray600,
            ),
            const SizedBox(height: 4),
            Text(
              nivel.label,
              style: TextStyle(fontWeight: FontWeight.w700, color: seleccionado ? Colors.white : AppColors.gray800),
            ),
          ],
        ),
      ),
    );
  }
}
