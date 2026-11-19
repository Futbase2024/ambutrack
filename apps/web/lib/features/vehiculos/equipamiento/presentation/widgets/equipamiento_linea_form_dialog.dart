import 'dart:async';

import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion/form/gestion_form.dart';
import 'package:ambutrack_web/core/widgets/handlers/crud_operation_handler.dart';
import 'package:ambutrack_web/core/widgets/loading/app_loading_indicator.dart';
import 'package:ambutrack_web/features/vehiculos/equipamiento/presentation/bloc/equipamiento_vehiculo_bloc.dart';
import 'package:ambutrack_web/features/vehiculos/equipamiento/presentation/bloc/equipamiento_vehiculo_event.dart';
import 'package:ambutrack_web/features/vehiculos/equipamiento/presentation/bloc/equipamiento_vehiculo_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Formulario "Registrar": cantidad, caducidad, lote y observaciones de una línea
class EquipamientoLineaFormDialog extends StatefulWidget {
  const EquipamientoLineaFormDialog({required this.linea, super.key});

  final StockVehiculoEntity linea;

  @override
  State<EquipamientoLineaFormDialog> createState() => _EquipamientoLineaFormDialogState();
}

class _EquipamientoLineaFormDialogState extends State<EquipamientoLineaFormDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _cantidad;
  late final TextEditingController _lote;
  late final TextEditingController _observaciones;
  DateTime? _caducidad;
  bool _isSaving = false;

  StockVehiculoEntity get _l => widget.linea;

  @override
  void initState() {
    super.initState();
    _cantidad = TextEditingController(text: '${_l.cantidadActual}');
    _lote = TextEditingController(text: _l.lote ?? '');
    _observaciones = TextEditingController(text: _l.observaciones ?? '');
    _caducidad = _l.fechaCaducidad;
  }

  @override
  void dispose() {
    _cantidad.dispose();
    _lote.dispose();
    _observaciones.dispose();
    super.dispose();
  }

  void _onBlocState(BuildContext context, EquipamientoVehiculoState state) {
    if (!_isSaving) {
      return;
    }
    if (state.resultado == EquipamientoResultado.exito) {
      unawaited(CrudOperationHandler.handleSuccess(
        context: context,
        isSaving: _isSaving,
        isEditing: true,
        entityName: 'Línea de equipamiento',
        onClose: _reset,
      ));
    } else if (state.resultado == EquipamientoResultado.error) {
      unawaited(CrudOperationHandler.handleError(
        context: context,
        isSaving: _isSaving,
        isEditing: true,
        entityName: 'Línea de equipamiento',
        errorMessage: state.error ?? 'Error desconocido',
        onClose: _reset,
      ));
    }
  }

  void _reset() {
    if (mounted) {
      setState(() => _isSaving = false);
    }
  }

  void _onSave() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() => _isSaving = true);
    unawaited(showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext _) => const AppLoadingOverlay(
        message: 'Actualizando equipamiento...',
        color: AppColors.secondary,
        icon: Icons.edit,
      ),
    ));
    context.read<EquipamientoVehiculoBloc>().add(EquipamientoLineaUpdateRequested(
          id: _l.id,
          cantidad: int.parse(_cantidad.text),
          fechaCaducidad: _caducidad,
          borrarCaducidad: _caducidad == null && _l.fechaCaducidad != null,
          lote: _lote.text,
          observaciones: _observaciones.text,
        ));
  }

  static String? _validarCantidad(String? v) {
    final int? n = int.tryParse(v ?? '');
    return n == null || n < 0 ? 'Indica una cantidad (0 o más)' : null;
  }

  @override
  Widget build(BuildContext context) {
    final DateTime hoy = DateTime.now();
    final String requerida = _l.cantidadMinima == null ? '' : ' · Requerida: ${_l.cantidadMinima}';
    return BlocListener<EquipamientoVehiculoBloc, EquipamientoVehiculoState>(
      listenWhen: (EquipamientoVehiculoState a, EquipamientoVehiculoState b) => a.operacion != b.operacion,
      listener: _onBlocState,
      child: GestionFormDialog(
        title: 'Registrar equipamiento',
        subtitle: '${_l.productoNombre ?? ''}$requerida',
        icon: Icons.edit_note,
        size: GestionFormSize.small,
        formKey: _formKey,
        isEditing: true,
        isSaving: _isSaving,
        onSave: _onSave,
        children: <Widget>[
          const GestionFormSection(title: 'Dotación', first: true),
          GestionFormRow(
            label: 'Cantidad',
            required: true,
            child: GestionTextField(
              controller: _cantidad,
              textAlign: TextAlign.end,
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
              validator: _validarCantidad,
            ),
          ),
          GestionFormRow(
            label: 'Caducidad',
            required: _l.requiereCaducidad,
            child: GestionDateField(
              value: _caducidad,
              required: _l.requiereCaducidad,
              firstDate: DateTime(hoy.year - 5),
              lastDate: DateTime(hoy.year + 15),
              onChanged: (DateTime? v) => setState(() => _caducidad = v),
            ),
          ),
          GestionFormRow(
            label: 'Nº de lote',
            child: GestionTextField(controller: _lote, hint: 'Ej: LOT123456'),
          ),
          GestionFormRow(
            label: 'Observaciones',
            multiline: true,
            child: GestionTextField(
              controller: _observaciones,
              hint: 'Estado, ubicación en el vehículo...',
              maxLines: 3,
            ),
          ),
        ],
      ),
    );
  }
}
