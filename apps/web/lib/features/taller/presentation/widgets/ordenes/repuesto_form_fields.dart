import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/core/widgets/dropdowns/app_dropdown.dart';
import 'package:ambutrack_web/core/widgets/dropdowns/app_searchable_dropdown.dart';
import 'package:ambutrack_web/features/taller/presentation/widgets/form/taller_form_components.dart';
import 'package:ambutrack_web/features/taller/presentation/widgets/ordenes/orden_form_inputs.dart';
import 'package:ambutrack_web/features/taller/presentation/widgets/ordenes/orden_ui_helpers.dart';
import 'package:flutter/material.dart';

const SizedBox _hGap = SizedBox(width: AppSizes.spacingMedium);
const SizedBox _vGap = SizedBox(height: AppSizes.spacingMedium);

final List<AppDropdownItem<EstadoRepuesto>> _estadoItems = EstadoRepuesto.values
    .map(
      (EstadoRepuesto e) => AppDropdownItem<EstadoRepuesto>(
        value: e,
        label: e.displayName,
        icon: Icons.circle,
        iconColor: estadoRepuestoColor(e),
      ),
    )
    .toList(growable: false);

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
        TallerFormField(
          controller: descripcion,
          label: 'Descripción *',
          hint: 'Filtro de aceite',
          icon: Icons.inventory_2_outlined,
          isRequired: true,
        ),
        _vGap,
        Row(
          children: <Widget>[
            Expanded(
              child: TallerFormField(controller: referencia, label: 'Referencia', hint: 'REF-12345'),
            ),
            _hGap,
            Expanded(
              child: _ProveedorDropdown(proveedores: proveedores, value: proveedorId, onChanged: onProveedor),
            ),
          ],
        ),
        _vGap,
        _CantidadPrecioEstadoRow(cantidad: cantidad, precio: precio, estado: estado, onEstado: onEstado),
        _vGap,
        TallerFormField(controller: observaciones, label: 'Observaciones', maxLines: 2),
      ],
    );
  }
}

class _CantidadField extends StatelessWidget {
  const _CantidadField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      textInputAction: TextInputAction.next,
      decoration: const InputDecoration(labelText: 'Cantidad *', isDense: true, border: OutlineInputBorder()),
      validator: (String? v) => (parseEntero(v ?? '') ?? 0) > 0 ? null : 'Debe ser mayor que 0',
    );
  }
}

class _PrecioField extends StatelessWidget {
  const _PrecioField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      textInputAction: TextInputAction.next,
      decoration: const InputDecoration(
        labelText: 'Precio unitario (€) *',
        isDense: true,
        border: OutlineInputBorder(),
      ),
      validator: (String? v) {
        final double? precio = parseDecimal(v ?? '');
        return precio == null || precio < 0 ? 'Precio no válido' : null;
      },
    );
  }
}

class _ProveedorDropdown extends StatelessWidget {
  const _ProveedorDropdown({required this.proveedores, required this.value, required this.onChanged});

  final List<ProveedorTallerEntity> proveedores;
  final String? value;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return AppSearchableDropdown<String>(
      value: value,
      label: 'Proveedor',
      hint: 'Buscar proveedor...',
      prefixIcon: Icons.local_shipping_outlined,
      items: proveedores
          .map((ProveedorTallerEntity p) => AppSearchableDropdownItem<String>(value: p.id, label: p.nombre))
          .toList(growable: false),
      onChanged: onChanged,
    );
  }
}

class _CantidadPrecioEstadoRow extends StatelessWidget {
  const _CantidadPrecioEstadoRow({
    required this.cantidad,
    required this.precio,
    required this.estado,
    required this.onEstado,
  });

  final TextEditingController cantidad;
  final TextEditingController precio;
  final EstadoRepuesto estado;
  final ValueChanged<EstadoRepuesto> onEstado;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(child: _CantidadField(controller: cantidad)),
        _hGap,
        Expanded(child: _PrecioField(controller: precio)),
        _hGap,
        Expanded(
          child: AppDropdown<EstadoRepuesto>(
            value: estado,
            label: 'Estado',
            clearable: false,
            items: _estadoItems,
            onChanged: (EstadoRepuesto? v) => v == null ? null : onEstado(v),
          ),
        ),
      ],
    );
  }
}
