import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/widgets/gestion/form/gestion_form.dart';
import 'package:ambutrack_web/features/taller/presentation/widgets/form/taller_form_components.dart';
import 'package:ambutrack_web/features/taller/presentation/widgets/ordenes/orden_form_inputs.dart';
import 'package:ambutrack_web/features/taller/presentation/widgets/ordenes/orden_ui_helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

final List<GestionOption<EstadoRepuesto>> _estadoOptions = gestionOptionsOf<EstadoRepuesto>(
  EstadoRepuesto.values,
  (EstadoRepuesto e) => e.displayName,
  colorOf: estadoRepuestoColor,
);

/// Campos del formulario de repuesto
class RepuestoFormFields extends StatelessWidget {
  const RepuestoFormFields({
    super.key,
    required this.descripcion,
    required this.referencia,
    required this.cantidad,
    required this.precio,
    required this.observaciones,
    required this.proveedores,
    required this.proveedorId,
    required this.estado,
    required this.onProveedor,
    required this.onEstado,
  });

  final TextEditingController descripcion;
  final TextEditingController referencia;
  final TextEditingController cantidad;
  final TextEditingController precio;
  final TextEditingController observaciones;
  final List<ProveedorTallerEntity> proveedores;
  final String? proveedorId;
  final EstadoRepuesto estado;
  final ValueChanged<String?> onProveedor;
  final ValueChanged<EstadoRepuesto> onEstado;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const GestionFormSection(title: 'Repuesto', first: true),
        GestionFormRow(
          label: 'Descripción',
          required: true,
          child: GestionTextField(
            controller: descripcion,
            hint: 'Filtro de aceite',
            validator: GestionFormStyle.requerido,
          ),
        ),
        GestionFormColumns(
          children: <Widget>[
            GestionFormRow(
              label: 'Referencia',
              child: GestionTextField(controller: referencia, hint: 'REF-12345'),
            ),
            GestionFormRow(
              label: 'Proveedor',
              child: GestionSearchField<String>(
                value: proveedorId,
                hint: 'Buscar proveedor',
                options: proveedores
                    .map((ProveedorTallerEntity p) => GestionOption<String>(p.id, p.nombre))
                    .toList(growable: false),
                onChanged: onProveedor,
              ),
            ),
          ],
        ),
        const GestionFormSection(title: 'Cantidad y precio'),
        GestionFormColumns(
          children: <Widget>[
            GestionFormRow(
              label: 'Cantidad',
              required: true,
              child: _CantidadField(controller: cantidad),
            ),
            GestionFormRow(
              label: 'Precio unidad',
              required: true,
              child: GestionMoneyField(controller: precio, required: true),
            ),
          ],
        ),
        GestionFormColumns(
          children: <Widget>[
            GestionFormRow(
              label: 'Estado',
              child: GestionDropdownField<EstadoRepuesto>(
                value: estado,
                options: _estadoOptions,
                onChanged: (EstadoRepuesto? v) => v == null ? null : onEstado(v),
              ),
            ),
            const SizedBox.shrink(),
          ],
        ),
        GestionFormRow(
          label: 'Observaciones',
          multiline: true,
          child: GestionTextField(controller: observaciones, maxLines: 2),
        ),
      ],
    );
  }
}

class _CantidadField extends StatelessWidget {
  const _CantidadField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return GestionTextField(
      controller: controller,
      hint: '1',
      textAlign: TextAlign.end,
      keyboardType: TextInputType.number,
      inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
      validator: (String? v) => (parseEntero(v ?? '') ?? 0) > 0 ? null : 'Debe ser mayor que 0',
    );
  }
}
