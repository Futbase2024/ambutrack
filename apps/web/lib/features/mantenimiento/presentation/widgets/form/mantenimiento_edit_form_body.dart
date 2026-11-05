import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/widgets/gestion/form/gestion_form.dart';
import 'package:ambutrack_web/features/mantenimiento/presentation/widgets/form/mantenimiento_form_data.dart';
import 'package:ambutrack_web/features/mantenimiento/presentation/widgets/form/mantenimiento_form_fields.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Campos del formulario de edición completa de mantenimiento
class MantenimientoEditFormBody extends StatelessWidget {
  const MantenimientoEditFormBody({required this.data, required this.onChanged, super.key});

  final MantenimientoEditFormData data;

  /// Notifica cambios para que el diálogo se reconstruya
  final VoidCallback onChanged;

  void _set(VoidCallback change) {
    change();
    onChanged();
  }

  static String? _requerido(String? v) => (v == null || v.isEmpty) ? 'Este campo es obligatorio' : null;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const GestionFormSection(title: 'Información general', first: true),
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
                    onChanged: (DateTime? v) => _set(() => data.fecha = v ?? data.fecha),
                  ),
                ),
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
              ],
            ),
            Column(
              children: <Widget>[
                GestionFormRow(
                  label: 'Kilometraje',
                  required: true,
                  child: GestionIntField(controller: data.km, unit: 'km', required: true),
                ),
                GestionFormRow(
                  label: 'Estado',
                  required: true,
                  child: GestionDropdownField<EstadoMantenimiento>(
                    value: data.estado,
                    required: true,
                    options: MantenimientoFormOptions.estados,
                    onChanged: (EstadoMantenimiento? v) => _set(() => data.estado = v ?? data.estado),
                  ),
                ),
              ],
            ),
          ],
        ),
        GestionFormRow(
          label: 'Descripción',
          required: true,
          multiline: true,
          child: GestionTextField(controller: data.descripcion, maxLines: 2, validator: _requerido),
        ),
        const GestionFormSection(title: 'Detalles del servicio'),
        GestionFormRow(
          label: 'Trabajos',
          multiline: true,
          child: GestionTextField(controller: data.trabajos, hint: 'Trabajos realizados', maxLines: 3),
        ),
        GestionFormColumns(
          children: <Widget>[
            GestionFormRow(
              label: 'Taller',
              child: MantenimientoTallerField(
                value: data.taller,
                onChanged: (String? v) => _set(() => data.taller = v),
              ),
            ),
            GestionFormRow(
              label: 'Mecánico',
              child: GestionTextField(controller: data.mecanico, hint: 'Mecánico responsable'),
            ),
          ],
        ),
        GestionFormColumns(
          children: <Widget>[
            GestionFormRow(
              label: 'Nº de orden',
              child: GestionTextField(controller: data.numeroOrden),
            ),
            const SizedBox.shrink(),
          ],
        ),
        _FechasSection(data: data, onChanged: onChanged),
        const GestionFormSection(title: 'Costes'),
        GestionFormColumns(
          children: <Widget>[
            GestionFormRow(
              label: 'Mano de obra',
              child: GestionMoneyField(controller: data.costeManoObra),
            ),
            GestionFormRow(
              label: 'Repuestos',
              child: GestionMoneyField(controller: data.costeRepuestos),
            ),
            GestionFormRow(
              label: 'Total',
              required: true,
              labelWidth: 70,
              child: GestionMoneyField(controller: data.costeTotal, required: true),
            ),
          ],
        ),
        const GestionFormSection(title: 'Próximo mantenimiento sugerido'),
        GestionFormColumns(
          children: <Widget>[
            GestionFormRow(
              label: 'Kilómetros',
              child: GestionIntField(controller: data.proximoKm, unit: 'km'),
            ),
            GestionFormRow(
              label: 'Fecha sugerida',
              child: GestionDateField(
                value: data.proximaFechaSugerida,
                onChanged: (DateTime? v) => _set(() => data.proximaFechaSugerida = v),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Fechas del servicio y tiempo inoperativo
class _FechasSection extends StatelessWidget {
  const _FechasSection({required this.data, required this.onChanged});

  final MantenimientoEditFormData data;
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
        const GestionFormSection(title: 'Fechas'),
        GestionFormColumns(
          children: <Widget>[
            Column(
              children: <Widget>[
                GestionFormRow(
                  label: 'F. programada',
                  child: GestionDateField(
                    value: data.fechaProgramada,
                    onChanged: (DateTime? v) => _set(() => data.fechaProgramada = v),
                  ),
                ),
                GestionFormRow(
                  label: 'Fecha fin',
                  child: GestionDateField(
                    value: data.fechaFin,
                    onChanged: (DateTime? v) => _set(() => data.fechaFin = v),
                  ),
                ),
              ],
            ),
            Column(
              children: <Widget>[
                GestionFormRow(
                  label: 'Fecha inicio',
                  child: GestionDateField(
                    value: data.fechaInicio,
                    onChanged: (DateTime? v) => _set(() => data.fechaInicio = v),
                  ),
                ),
                GestionFormRow(
                  label: 'T. inoperativo',
                  child: GestionTextField(
                    controller: data.horasInoperativo,
                    hint: '0',
                    suffixText: 'h',
                    textAlign: TextAlign.end,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.allow(RegExp(r'[\d.,]'))],
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
