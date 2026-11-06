import 'dart:async';

import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/dialogs/professional_result_dialog.dart';
import '../bloc/equipamiento_bloc.dart';
import '../bloc/equipamiento_event.dart';
import '../bloc/equipamiento_state.dart';
import 'equipamiento_sheet_fields.dart';
import 'estado_dotacion.dart';

/// Abre el ModalSheet de registro de una línea
Future<void> mostrarEquipamientoLineaSheet(BuildContext context, StockVehiculoEntity linea) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (BuildContext _) => BlocProvider<EquipamientoBloc>.value(
      value: context.read<EquipamientoBloc>(),
      child: EquipamientoLineaSheet(linea: linea),
    ),
  );
}

/// Formulario del técnico: cantidad, caducidad, lote y observaciones
class EquipamientoLineaSheet extends StatefulWidget {
  const EquipamientoLineaSheet({required this.linea, super.key});

  final StockVehiculoEntity linea;

  @override
  State<EquipamientoLineaSheet> createState() => _EquipamientoLineaSheetState();
}

class _EquipamientoLineaSheetState extends State<EquipamientoLineaSheet> {
  late int _cantidad = widget.linea.cantidadActual;
  late DateTime? _caducidad = widget.linea.fechaCaducidad;
  late final TextEditingController _lote = TextEditingController(text: widget.linea.lote ?? '');
  late final TextEditingController _obs = TextEditingController(text: widget.linea.observaciones ?? '');
  bool _guardando = false;

  static final DateFormat _fecha = DateFormat('dd/MM/yyyy');

  @override
  void dispose() {
    _lote.dispose();
    _obs.dispose();
    super.dispose();
  }

  Future<void> _elegirFecha() async {
    final DateTime hoy = DateTime.now();
    final DateTime? f = await showDatePicker(
      context: context,
      initialDate: _caducidad ?? hoy,
      firstDate: DateTime(hoy.year - 5),
      lastDate: DateTime(hoy.year + 15),
      helpText: 'Fecha de caducidad',
    );
    if (f != null) {
      setState(() => _caducidad = f);
    }
  }

  void _guardar() {
    if (widget.linea.requiereCaducidad && _caducidad == null) {
      unawaited(showProfessionalResultDialog(
        context,
        title: 'Falta la caducidad',
        message: 'Este item requiere fecha de caducidad. Indícala antes de guardar.',
        icon: Icons.event_busy_rounded,
        iconColor: AppColors.warning,
      ));
      return;
    }
    setState(() => _guardando = true);
    context.read<EquipamientoBloc>().add(EquipamientoLineaGuardada(
          id: widget.linea.id,
          cantidad: _cantidad,
          fechaCaducidad: _caducidad,
          borrarCaducidad: _caducidad == null && widget.linea.fechaCaducidad != null,
          lote: _lote.text,
          observaciones: _obs.text,
        ));
  }

  void _onResultado(BuildContext context, EquipamientoState state) {
    if (!_guardando) {
      return;
    }
    setState(() => _guardando = false);
    if (state.resultado == EquipamientoResultado.exito) {
      final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
      Navigator.of(context).pop();
      messenger.showSnackBar(
        SnackBar(content: Text('${widget.linea.productoNombre ?? 'Item'} actualizado')),
      );
    } else {
      unawaited(showProfessionalResultDialog(
        context,
        title: 'No se pudo guardar',
        message: state.error ?? 'Error desconocido',
        icon: Icons.error_outline,
        iconColor: AppColors.error,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final StockVehiculoEntity l = widget.linea;
    return BlocListener<EquipamientoBloc, EquipamientoState>(
      listenWhen: (EquipamientoState a, EquipamientoState b) => a.operacion != b.operacion,
      listener: _onResultado,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                SheetCabecera(linea: l, estado: EstadoDotacion.of(l)),
                const SizedBox(height: 20),
                SheetCantidad(
                  cantidad: _cantidad,
                  requerida: l.cantidadMinima,
                  onChanged: (int v) => setState(() => _cantidad = v),
                ),
                const SizedBox(height: 16),
                SheetCaducidad(
                  texto: _caducidad == null ? null : _fecha.format(_caducidad!),
                  obligatoria: l.requiereCaducidad,
                  onElegir: _elegirFecha,
                  onQuitar: _caducidad == null ? null : () => setState(() => _caducidad = null),
                ),
                const SizedBox(height: 16),
                SheetTexto(controller: _lote, label: 'Nº de lote', action: TextInputAction.next),
                const SizedBox(height: 12),
                SheetTexto(
                  controller: _obs,
                  label: 'Observaciones',
                  maxLines: 3,
                  action: TextInputAction.newline,
                ),
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: _guardando ? null : _guardar,
                  icon: _guardando
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.save_rounded),
                  label: Text(_guardando ? 'Guardando...' : 'Guardar'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
