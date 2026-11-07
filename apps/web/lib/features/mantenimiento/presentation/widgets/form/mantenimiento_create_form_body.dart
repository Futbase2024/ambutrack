import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/widgets/gestion/form/gestion_form.dart';
import 'package:ambutrack_web/features/mantenimiento/presentation/widgets/form/mantenimiento_form_data.dart';
import 'package:ambutrack_web/features/mantenimiento/presentation/widgets/form/mantenimiento_form_fields.dart';
import 'package:flutter/material.dart';

/// Campos del formulario de programación de mantenimiento
class MantenimientoCreateFormBody extends StatelessWidget {
  const MantenimientoCreateFormBody({
    required this.data,
    required this.isEditing,
    required this.onChanged,
    super.key,
  });

  final MantenimientoCreateFormData data;
  final bool isEditing;

  /// Notifica cambios para que el diálogo se reconstruya
  final VoidCallback onChanged;

  void _set(VoidCallback change) {
    change();
    onChanged();
  }

  void _onVehiculo(VehiculoEntity? v) {
    _set(() {
      data.vehiculo = v;
      // Pre-rellenar con el kilometraje actual del vehículo si existe
      if (v != null && v.kmActual != null) {
        data.km.text = GestionFormParse.formatEntero(v.kmActual);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const GestionFormSection(title: 'Mantenimiento', first: true),
        GestionFormRow(
          label: 'Vehículo',
          required: true,
          child: MantenimientoVehiculoField(value: data.vehiculo, enabled: !isEditing, onChanged: _onVehiculo),
        ),
        GestionFormColumns(
          children: <Widget>[
            GestionFormRow(
              label: 'Tipo',
              required: true,
              child: GestionDropdownField<TipoMantenimiento>(
                value: data.tipo,
                required: true,
                options: MantenimientoFormOptions.tipos,
                onChanged: (TipoMantenimiento? v) => _set(() => data.tipo = v ?? data.tipo),
              ),
            ),
            GestionFormRow(
              label: 'Taller',
              child: MantenimientoTallerField(
                value: data.taller,
                onChanged: (String? v) => _set(() => data.taller = v),
              ),
            ),
          ],
        ),
        const GestionFormSection(title: 'Planificación'),
        GestionFormColumns(
          children: <Widget>[
            Column(
              children: <Widget>[
                GestionFormRow(
                  label: 'Fecha',
                  required: true,
                  child: GestionDateField(
                    value: data.fecha,
                    required: true,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2030),
                    onChanged: (DateTime? v) => _set(() => data.fecha = v ?? data.fecha),
                  ),
                ),
                GestionFormRow(
                  label: 'Kilometraje',
                  required: true,
                  child: GestionIntField(controller: data.km, unit: 'km', required: true),
                ),
              ],
            ),
            Column(
              children: <Widget>[
                GestionFormRow(
                  label: 'F. programada',
                  child: GestionDateField(
                    value: data.fechaProgramada,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2030),
                    onChanged: (DateTime? v) => _set(() => data.fechaProgramada = v),
                  ),
                ),
                GestionFormRow(
                  label: 'Coste total',
                  required: true,
                  child: GestionMoneyField(controller: data.coste, required: true),
                ),
              ],
            ),
          ],
        ),
        GestionFormRow(
          label: 'Descripción',
          required: true,
          multiline: true,
          child: GestionTextField(
            controller: data.descripcion,
            hint: 'Describe el mantenimiento a realizar',
            maxLines: 3,
            validator: (String? v) =>
                (v == null || v.trim().isEmpty) ? 'La descripción es obligatoria' : null,
          ),
        ),
      ],
    );
  }
}
