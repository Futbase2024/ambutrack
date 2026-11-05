import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/widgets/gestion/form/gestion_form.dart';
import 'package:ambutrack_web/features/personal/domain/entities/personal_entity.dart';
import 'package:ambutrack_web/features/personal/presentation/widgets/form/personal_form_options.dart';
import 'package:ambutrack_web/features/personal/presentation/widgets/form/vestuario_stock_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Campos del formulario de asignación de vestuario
class VestuarioFormBody extends StatelessWidget {
  const VestuarioFormBody({
    required this.isEditing,
    required this.personalList,
    required this.selectedPersonal,
    required this.prendas,
    required this.prenda,
    required this.tallas,
    required this.talla,
    required this.stock,
    required this.cantidad,
    required this.fechaEntrega,
    required this.observaciones,
    required this.onPersonalChanged,
    required this.onPrendaChanged,
    required this.onTallaChanged,
    required this.onFechaChanged,
    super.key,
  });

  final bool isEditing;
  final List<PersonalEntity> personalList;
  final PersonalEntity? selectedPersonal;
  final List<String> prendas;
  final String? prenda;
  final List<String> tallas;
  final String? talla;
  final StockVestuarioEntity? stock;
  final TextEditingController cantidad;
  final DateTime fechaEntrega;
  final TextEditingController observaciones;
  final ValueChanged<String?> onPersonalChanged;
  final ValueChanged<String?> onPrendaChanged;
  final ValueChanged<String?> onTallaChanged;
  final ValueChanged<DateTime> onFechaChanged;

  static String? _validarCantidad(String? value) {
    if (value == null || value.isEmpty) {
      return 'La cantidad es obligatoria';
    }
    final int? n = int.tryParse(value);
    if (n == null || n <= 0) {
      return 'Ingrese una cantidad válida';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const GestionFormSection(title: 'Asignación', first: true),
        GestionFormRow(
          label: 'Personal',
          required: true,
          child: GestionSearchField<String>(
            value: selectedPersonal?.id,
            required: true,
            enabled: !isEditing,
            hint: 'Buscar personal...',
            options: PersonalFormOptions.personal(personalList),
            onChanged: onPersonalChanged,
          ),
        ),
        const GestionFormSection(title: 'Prenda (desde stock)'),
        GestionFormColumns(
          children: <Widget>[
            GestionFormRow(
              label: 'Prenda',
              required: true,
              child: GestionSearchField<String>(
                value: prenda,
                required: true,
                enabled: prendas.isNotEmpty,
                hint: 'Selecciona una prenda',
                options: prendas.map((String p) => GestionOption<String>(p, p)).toList(),
                onChanged: onPrendaChanged,
              ),
            ),
            GestionFormRow(
              label: 'Talla',
              required: true,
              child: GestionDropdownField<String>(
                // Se recrea al cambiar la prenda para reflejar la talla reiniciada
                key: ValueKey<String>('talla|$prenda|${tallas.join(',')}'),
                value: tallas.contains(talla) ? talla : null,
                required: true,
                enabled: prenda != null && tallas.isNotEmpty,
                hint: prenda == null ? 'Primero elige prenda' : 'Selecciona una talla',
                options: tallas.map((String t) => GestionOption<String>(t, t)).toList(),
                onChanged: onTallaChanged,
              ),
            ),
          ],
        ),
        if (stock != null) GestionFormRow(label: 'Stock', child: VestuarioStockInfo(stock: stock!)),
        const GestionFormSection(title: 'Entrega'),
        GestionFormColumns(
          children: <Widget>[
            GestionFormRow(
              label: 'Cantidad',
              required: true,
              child: GestionTextField(
                controller: cantidad,
                hint: '1',
                textAlign: TextAlign.end,
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
                validator: _validarCantidad,
              ),
            ),
            GestionFormRow(
              label: 'Fecha entrega',
              required: true,
              child: GestionDateField(
                value: fechaEntrega,
                required: true,
                firstDate: DateTime(2020),
                onChanged: (DateTime? picked) {
                  if (picked != null) {
                    onFechaChanged(picked);
                  }
                },
              ),
            ),
          ],
        ),
        GestionFormRow(
          label: 'Observaciones',
          multiline: true,
          child: GestionTextField(
            controller: observaciones,
            maxLines: 3,
            hint: 'Observaciones adicionales (opcional)',
          ),
        ),
      ],
    );
  }
}
