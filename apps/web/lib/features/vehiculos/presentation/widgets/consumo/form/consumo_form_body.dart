import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/widgets/gestion/form/gestion_form.dart';
import 'package:ambutrack_web/features/vehiculos/presentation/widgets/consumo/form/consumo_form_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Campos del formulario de consumo de combustible
class ConsumoFormBody extends StatelessWidget {
  const ConsumoFormBody({
    required this.data,
    required this.vehiculos,
    required this.isEditing,
    required this.minKm,
    required this.onChanged,
    super.key,
  });

  final ConsumoFormData data;
  final List<VehiculoEntity> vehiculos;
  final bool isEditing;

  /// Kilometraje mínimo admitido (último registrado)
  final double minKm;

  /// Notifica cambios para que el diálogo se reconstruya
  final VoidCallback onChanged;

  static final List<TextInputFormatter> _decimal = <TextInputFormatter>[
    FilteringTextInputFormatter.allow(RegExp(r'[\d.,]')),
  ];

  void _set(VoidCallback change) {
    change();
    onChanged();
  }

  String? _validarKm(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El kilometraje es obligatorio';
    }
    final int? km = GestionFormParse.entero(value);
    if (km == null || km <= 0) {
      return 'Ingresa un kilometraje válido';
    }
    if (!isEditing && km < minKm) {
      return 'KM no puede ser menor al último registrado (${GestionFormParse.formatEntero(minKm)})';
    }
    return null;
  }

  static FormFieldValidator<String> _positivo(String obligatorio, String invalido) {
    return (String? value) {
      if (value == null || value.trim().isEmpty) {
        return obligatorio;
      }
      final double? v = GestionFormParse.decimal(value);
      return (v == null || v <= 0) ? invalido : null;
    };
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const GestionFormSection(title: 'Repostaje', first: true),
        GestionFormRow(
          label: 'Vehículo',
          required: true,
          child: GestionSearchField<String>(
            value: data.vehiculoId,
            required: true,
            enabled: !isEditing,
            hint: 'Buscar por matrícula, marca o modelo',
            options: vehiculos
                .map((VehiculoEntity v) => GestionOption<String>(v.id, '${v.matricula} - ${v.marca} ${v.modelo}'))
                .toList(),
            onChanged: (String? v) => _set(() => data.vehiculoId = v),
          ),
        ),
        GestionFormColumns(
          children: <Widget>[
            GestionFormRow(
              label: 'Fecha',
              required: true,
              child: GestionDateField(
                value: data.fecha,
                required: true,
                firstDate: DateTime(2020),
                lastDate: DateTime.now().add(const Duration(days: 30)),
                onChanged: (DateTime? v) => _set(() => data.fecha = v),
              ),
            ),
            GestionFormRow(
              label: 'Kilometraje',
              required: true,
              child: GestionTextField(
                controller: data.kilometraje,
                hint: isEditing ? '0' : 'Mín. ${GestionFormParse.formatEntero(minKm)}',
                suffixText: 'km',
                textAlign: TextAlign.end,
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
                validator: _validarKm,
              ),
            ),
          ],
        ),
        GestionFormColumns(
          children: <Widget>[
            GestionFormRow(
              label: 'Combustible',
              required: true,
              child: GestionDropdownField<String>(
                value: data.tipoCombustible,
                required: true,
                options: ConsumoFormOptions.tipos(data.tipoCombustible),
                onChanged: (String? v) => _set(() => data.tipoCombustible = v),
              ),
            ),
            const SizedBox.shrink(),
          ],
        ),
        const GestionFormSection(title: 'Importe'),
        GestionFormColumns(
          children: <Widget>[
            GestionFormRow(
              label: 'Litros',
              required: true,
              child: GestionTextField(
                controller: data.litros,
                hint: '0,00',
                suffixText: 'L',
                textAlign: TextAlign.end,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: _decimal,
                validator: _positivo('Los litros son obligatorios', 'Ingresa una cantidad válida'),
              ),
            ),
            GestionFormRow(
              label: 'Precio/litro',
              child: GestionTextField(
                controller: data.precio,
                hint: '0,000',
                suffixText: '€/L',
                textAlign: TextAlign.end,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: _decimal,
              ),
            ),
          ],
        ),
        GestionFormColumns(
          children: <Widget>[
            GestionFormRow(
              label: 'Coste total',
              required: true,
              child: GestionTextField(
                controller: data.costo,
                hint: 'Litros × precio',
                suffixText: '€',
                textAlign: TextAlign.end,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: _decimal,
                validator: _positivo('El costo total es obligatorio', 'Ingresa un costo válido'),
              ),
            ),
            const SizedBox.shrink(),
          ],
        ),
        const GestionFormSection(title: 'Lugar'),
        GestionFormColumns(
          children: <Widget>[
            GestionFormRow(
              label: 'Estación',
              child: GestionTextField(controller: data.estacion, hint: 'Ej: Repsol, Cepsa, Shell'),
            ),
            GestionFormRow(
              label: 'Ubicación',
              child: GestionTextField(controller: data.ubicacion, hint: 'Ej: Madrid, Calle Mayor'),
            ),
          ],
        ),
      ],
    );
  }
}
