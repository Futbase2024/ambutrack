import 'package:ambutrack_web/core/widgets/gestion/form/gestion_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Cantidades del stock: total al crear; actual + unidades a sumar al editar
class StockVestuarioCantidades extends StatelessWidget {
  const StockVestuarioCantidades({
    required this.isEditing,
    required this.cantidadActual,
    required this.cantidadTotal,
    required this.cantidadAgregar,
    required this.stockMinimo,
    required this.onAgregarChanged,
    super.key,
  });

  final bool isEditing;
  final int cantidadActual;
  final TextEditingController cantidadTotal;
  final TextEditingController cantidadAgregar;
  final TextEditingController stockMinimo;
  final ValueChanged<String> onAgregarChanged;

  static String? _validarTotal(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'La cantidad es obligatoria';
    }
    final int? cantidad = int.tryParse(value);
    if (cantidad == null || cantidad < 0) {
      return 'Cantidad inválida';
    }
    return null;
  }

  static String? _validarAgregar(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Opcional al editar
    }
    final int? cantidad = int.tryParse(value);
    if (cantidad == null || cantidad < 0) {
      return 'Cantidad inválida';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        GestionFormColumns(
          children: <Widget>[
            if (isEditing)
              GestionFormRow(
                label: 'Cantidad actual',
                child: GestionFormReadOnly(value: '${cantidadTotal.text} uds.'),
              )
            else
              GestionFormRow(
                label: 'Cantidad total',
                required: true,
                child: _EnteroField(controller: cantidadTotal, validator: _validarTotal),
              ),
            GestionFormRow(
              label: 'Stock mínimo',
              child: _EnteroField(controller: stockMinimo, hint: '5'),
            ),
          ],
        ),
        if (isEditing)
          GestionFormColumns(
            children: <Widget>[
              GestionFormRow(
                label: 'Agregar uds.',
                child: _EnteroField(
                  controller: cantidadAgregar,
                  validator: _validarAgregar,
                  onChanged: onAgregarChanged,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 9),
                child: Text(
                  'Se suman al stock actual ($cantidadActual unidades)',
                  style: GestionFormStyle.hint.copyWith(fontSize: 12),
                ),
              ),
            ],
          ),
      ],
    );
  }
}

class _EnteroField extends StatelessWidget {
  const _EnteroField({required this.controller, this.hint = '0', this.validator, this.onChanged});

  final TextEditingController controller;
  final String hint;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return GestionTextField(
      controller: controller,
      hint: hint,
      suffixText: 'uds.',
      textAlign: TextAlign.end,
      keyboardType: TextInputType.number,
      inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
      validator: validator,
      onChanged: onChanged,
    );
  }
}
