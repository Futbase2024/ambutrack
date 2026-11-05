import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/widgets/gestion/form/gestion_form.dart';
import 'package:ambutrack_web/features/vehiculos/presentation/widgets/form/vehiculo_form_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Campos del formulario de vehículo
class VehiculoFormBody extends StatelessWidget {
  const VehiculoFormBody({required this.data, required this.onChanged, super.key});

  final VehiculoFormData data;

  /// Notifica cambios para que el diálogo se reconstruya
  final VoidCallback onChanged;

  void _set(VoidCallback change) {
    change();
    onChanged();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const GestionFormSection(title: 'Información básica', first: true),
        GestionFormColumns(
          children: <Widget>[
            Column(
              children: <Widget>[
                GestionFormRow(
                  label: 'Matrícula',
                  required: true,
                  child: GestionTextField(
                    controller: data.matricula,
                    hint: 'Ej: 1234ABC',
                    validator: GestionFormStyle.requerido,
                  ),
                ),
                GestionFormRow(
                  label: 'Marca',
                  required: true,
                  child: GestionTextField(
                    controller: data.marca,
                    hint: 'Ej: Mercedes-Benz',
                    validator: GestionFormStyle.requerido,
                  ),
                ),
                GestionFormRow(
                  label: 'Año',
                  required: true,
                  child: GestionTextField(
                    controller: data.anio,
                    hint: 'Ej: 2023',
                    keyboardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
                    validator: GestionFormStyle.requerido,
                  ),
                ),
                GestionFormRow(
                  label: 'Nº bastidor',
                  child: GestionTextField(controller: data.numeroSerie, hint: 'Ej: WDB9066331N123456'),
                ),
              ],
            ),
            Column(
              children: <Widget>[
                GestionFormRow(
                  label: 'Tipo',
                  required: true,
                  child: GestionTextField(
                    controller: data.tipo,
                    hint: 'Ej: Ambulancia SVA',
                    validator: GestionFormStyle.requerido,
                  ),
                ),
                GestionFormRow(
                  label: 'Modelo',
                  required: true,
                  child: GestionTextField(
                    controller: data.modelo,
                    hint: 'Ej: Sprinter',
                    validator: GestionFormStyle.requerido,
                  ),
                ),
                GestionFormRow(
                  label: 'Estado',
                  required: true,
                  child: GestionDropdownField<VehiculoEstado>(
                    value: data.estado,
                    options: VehiculoFormOptions.estados,
                    required: true,
                    onChanged: (VehiculoEstado? v) => _set(() => data.estado = v ?? data.estado),
                  ),
                ),
              ],
            ),
          ],
        ),
        const GestionFormSection(title: 'Capacidad y equipamiento'),
        GestionFormColumns(
          children: <Widget>[
            GestionFormRow(label: 'Camillas', child: GestionIntField(controller: data.camillas)),
            GestionFormRow(label: 'Asientos pac.', child: GestionIntField(controller: data.sentados)),
          ],
        ),
        const GestionFormSection(title: 'Kilometraje y mantenimiento'),
        GestionFormColumns(
          children: <Widget>[
            Column(
              children: <Widget>[
                GestionFormRow(label: 'Km actual', child: GestionIntField(controller: data.kmActual, unit: 'km')),
                GestionFormRow(
                  label: 'Últ. manten.',
                  child: GestionDateField(
                    value: data.fechaUltimoMantenimiento,
                    onChanged: (DateTime? v) => _set(() => data.fechaUltimoMantenimiento = v),
                  ),
                ),
              ],
            ),
            Column(
              children: <Widget>[
                GestionFormRow(
                  label: 'Km próx. manten.',
                  child: GestionIntField(controller: data.kmProxMantenimiento, unit: 'km'),
                ),
                GestionFormRow(
                  label: 'Próx. manten.',
                  child: GestionDateField(
                    value: data.proximoMantenimiento,
                    onChanged: (DateTime? v) => _set(() => data.proximoMantenimiento = v),
                  ),
                ),
              ],
            ),
          ],
        ),
        const GestionFormSection(title: 'Fechas y documentación'),
        GestionFormColumns(
          children: <Widget>[
            GestionFormRow(
              label: 'Adquisición',
              child: GestionDateField(
                value: data.fechaAdquisicion,
                onChanged: (DateTime? v) => _set(() => data.fechaAdquisicion = v),
              ),
            ),
            GestionFormRow(
              label: 'Próxima ITV',
              child: GestionDateField(
                value: data.fechaProximaItv,
                onChanged: (DateTime? v) => _set(() => data.fechaProximaItv = v),
              ),
            ),
          ],
        ),
        const GestionFormSection(title: 'Ubicación y observaciones'),
        GestionFormRow(
          label: 'Ubicación',
          child: GestionTextField(controller: data.ubicacion, hint: 'Ej: Base Central'),
        ),
        GestionFormRow(
          label: 'Observaciones',
          multiline: true,
          child: GestionTextField(controller: data.observaciones, hint: 'Notas adicionales', maxLines: 3),
        ),
      ],
    );
  }
}
