import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/widgets/dialogs/professional_result_dialog.dart';
import '../../cubit/incidencia_detalle_cubit.dart';
import 'incidencia_datos.dart';

/// Cambio de estado de la incidencia con nota (solución aplicada)
class IncidenciaGestionForm extends StatefulWidget {
  const IncidenciaGestionForm({super.key, required this.incidencia});

  final IncidenciaVehiculoEntity incidencia;

  @override
  State<IncidenciaGestionForm> createState() => _IncidenciaGestionFormState();
}

class _IncidenciaGestionFormState extends State<IncidenciaGestionForm> {
  late EstadoIncidencia _estado = widget.incidencia.estado;
  late final TextEditingController _nota = TextEditingController(text: widget.incidencia.solucionAplicada ?? '');

  @override
  void dispose() {
    _nota.dispose();
    super.dispose();
  }

  bool get _hayCambios =>
      _estado != widget.incidencia.estado || _nota.text.trim() != (widget.incidencia.solucionAplicada ?? '').trim();

  Future<void> _guardar() async {
    final IncidenciaDetalleCubit cubit = context.read<IncidenciaDetalleCubit>();
    final bool ok = await cubit.actualizar(_estado, _nota.text);
    if (!mounted) {
      return;
    }
    final NavigatorState navigator = Navigator.of(context);
    await showProfessionalResultDialog(
      context,
      title: ok ? 'Incidencia actualizada' : 'Error al actualizar',
      message: ok
          ? 'La incidencia ha pasado a "${_estado.nombre}".'
          : cubit.state.error ?? 'No se ha podido actualizar la incidencia.',
      icon: ok ? Icons.check_circle_outline : Icons.error_outline,
      iconColor: ok ? AppColors.success : AppColors.error,
    );
    if (ok && mounted) {
      navigator.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool guardando =
        context.select((IncidenciaDetalleCubit c) => c.state.status == IncidenciaDetalleStatus.guardando);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text(
          'Cambiar estado',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.gray900),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: <Widget>[
            for (final EstadoIncidencia e in EstadoIncidencia.values)
              ChoiceChip(
                label: Text(e.nombre),
                selected: _estado == e,
                selectedColor: colorEstadoIncidencia(e).withValues(alpha: 0.18),
                labelStyle: TextStyle(
                  fontWeight: _estado == e ? FontWeight.w700 : FontWeight.w500,
                  color: _estado == e ? colorEstadoIncidencia(e) : AppColors.gray700,
                ),
                onSelected: guardando ? null : (_) => setState(() => _estado = e),
              ),
          ],
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _nota,
          enabled: !guardando,
          minLines: 2,
          maxLines: 5,
          textInputAction: TextInputAction.newline,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            labelText: 'Nota / solución aplicada',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: guardando || !_hayCambios ? null : _guardar,
            icon: guardando
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.save),
            label: const Text('Actualizar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ),
      ],
    );
  }
}
