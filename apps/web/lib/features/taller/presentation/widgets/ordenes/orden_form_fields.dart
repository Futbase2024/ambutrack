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

/// Campos del formulario de orden de reparación
class OrdenFormFields extends StatelessWidget {
  const OrdenFormFields({
    required this.controllers,
    required this.selection,
    required this.callbacks,
    required this.vehiculos,
    required this.talleres,
    required this.isEditing,
    super.key,
  });

  final OrdenFormControllers controllers;
  final OrdenFormSelection selection;
  final OrdenFormCallbacks callbacks;
  final List<VehiculoEntity> vehiculos;
  final List<TallerEntity> talleres;
  final bool isEditing;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _VehiculoTallerRow(selection: selection, callbacks: callbacks, vehiculos: vehiculos, talleres: talleres),
        _vGap,
        _ClasificacionRow(selection: selection, callbacks: callbacks),
        _vGap,
        _TrabajoSection(controllers: controllers, isEditing: isEditing),
        _vGap,
        _CostesSection(controllers: controllers),
        _vGap,
        TallerActivoSwitch(
          value: selection.cubiertoSeguro,
          title: 'Cubierto por el seguro',
          activeText: 'La reparación la cubre el seguro',
          inactiveText: 'La reparación no la cubre el seguro',
          onChanged: callbacks.onSeguro,
        ),
        _vGap,
        TallerFormField(
          controller: controllers.observaciones,
          label: 'Observaciones',
          hint: 'Notas adicionales...',
          maxLines: 2,
        ),
      ],
    );
  }
}

class _VehiculoTallerRow extends StatelessWidget {
  const _VehiculoTallerRow({
    required this.selection,
    required this.callbacks,
    required this.vehiculos,
    required this.talleres,
  });

  final OrdenFormSelection selection;
  final OrdenFormCallbacks callbacks;
  final List<VehiculoEntity> vehiculos;
  final List<TallerEntity> talleres;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: _VehiculoField(
            vehiculoId: selection.vehiculoId,
            vehiculos: vehiculos,
            onChanged: callbacks.onVehiculo,
          ),
        ),
        _hGap,
        Expanded(
          child: AppSearchableDropdown<String>(
            value: selection.tallerId,
            label: 'Taller',
            hint: 'Buscar taller...',
            prefixIcon: Icons.construction,
            items: talleres
                .map((TallerEntity t) => AppSearchableDropdownItem<String>(value: t.id, label: t.nombre))
                .toList(growable: false),
            onChanged: callbacks.onTaller,
          ),
        ),
      ],
    );
  }
}

class _ClasificacionRow extends StatelessWidget {
  const _ClasificacionRow({required this.selection, required this.callbacks});

  final OrdenFormSelection selection;
  final OrdenFormCallbacks callbacks;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: AppDropdown<OrigenOrdenReparacion>(
            value: selection.origen,
            label: 'Origen *',
            clearable: false,
            items: _origenItems,
            onChanged: (OrigenOrdenReparacion? v) => v == null ? null : callbacks.onOrigen(v),
          ),
        ),
        _hGap,
        Expanded(
          child: AppDropdown<PrioridadOrdenReparacion>(
            value: selection.prioridad,
            label: 'Prioridad *',
            clearable: false,
            items: _prioridadItems,
            onChanged: (PrioridadOrdenReparacion? v) => v == null ? null : callbacks.onPrioridad(v),
          ),
        ),
        _hGap,
        Expanded(
          child: OrdenFechaField(label: 'Fecha entrada *', fecha: selection.fechaEntrada, onTap: callbacks.onPickFecha),
        ),
      ],
    );
  }
}

class _TrabajoSection extends StatelessWidget {
  const _TrabajoSection({required this.controllers, required this.isEditing});

  final OrdenFormControllers controllers;
  final bool isEditing;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _KmMecanicoRow(controllers: controllers, isEditing: isEditing),
        _vGap,
        TallerFormField(
          controller: controllers.diagnostico,
          label: 'Diagnóstico',
          hint: 'Descripción de la avería...',
          maxLines: 3,
        ),
        if (isEditing) ...<Widget>[
          _vGap,
          TallerFormField(controller: controllers.trabajos, label: 'Trabajos realizados', maxLines: 3),
        ],
      ],
    );
  }
}

class _CostesSection extends StatelessWidget {
  const _CostesSection({required this.controllers});

  final OrdenFormControllers controllers;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: OrdenNumberField(controller: controllers.horas, label: 'Horas mano obra'),
        ),
        _hGap,
        Expanded(
          child: OrdenNumberField(controller: controllers.costeManoObra, label: 'Coste mano obra (€)'),
        ),
        _hGap,
        Expanded(
          child: OrdenNumberField(controller: controllers.costeGrua, label: 'Coste grúa (€)'),
        ),
        _hGap,
        Expanded(
          child: OrdenNumberField(controller: controllers.garantia, label: 'Garantía (meses)', integer: true),
        ),
      ],
    );
  }
}

final List<AppDropdownItem<OrigenOrdenReparacion>> _origenItems = OrigenOrdenReparacion.values
    .map((OrigenOrdenReparacion o) => AppDropdownItem<OrigenOrdenReparacion>(value: o, label: o.displayName))
    .toList(growable: false);

final List<AppDropdownItem<PrioridadOrdenReparacion>> _prioridadItems = PrioridadOrdenReparacion.values
    .map(
      (PrioridadOrdenReparacion p) => AppDropdownItem<PrioridadOrdenReparacion>(
        value: p,
        label: p.displayName,
        icon: Icons.flag,
        iconColor: prioridadOrdenColor(p),
      ),
    )
    .toList(growable: false);

/// Selector de vehículo obligatorio con validación integrada en el Form
class _VehiculoField extends StatelessWidget {
  const _VehiculoField({required this.vehiculoId, required this.vehiculos, required this.onChanged});

  final String? vehiculoId;
  final List<VehiculoEntity> vehiculos;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return FormField<String>(
      initialValue: vehiculoId,
      validator: (_) => vehiculoId == null ? 'El vehículo es obligatorio' : null,
      builder: (FormFieldState<String> field) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          AppSearchableDropdown<String>(
            value: vehiculoId,
            label: 'Vehículo *',
            hint: 'Buscar matrícula...',
            prefixIcon: Icons.directions_car_outlined,
            items: vehiculos
                .map((VehiculoEntity v) => AppSearchableDropdownItem<String>(value: v.id, label: v.matricula))
                .toList(growable: false),
            onChanged: (String? v) {
              onChanged(v);
              field.didChange(v);
            },
          ),
          if (field.hasError) OrdenFieldError(message: field.errorText!),
        ],
      ),
    );
  }
}

/// Fila de kilometraje y mecánico
class _KmMecanicoRow extends StatelessWidget {
  const _KmMecanicoRow({required this.controllers, required this.isEditing});

  final OrdenFormControllers controllers;
  final bool isEditing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: OrdenNumberField(controller: controllers.kmEntrada, label: 'Km entrada', integer: true),
        ),
        _hGap,
        Expanded(
          child: isEditing
              ? OrdenNumberField(controller: controllers.kmSalida, label: 'Km salida', integer: true)
              : const SizedBox.shrink(),
        ),
        _hGap,
        Expanded(
          flex: 2,
          child: TallerFormField(
            controller: controllers.mecanico,
            label: 'Mecánico',
            hint: 'NOMBRE Y APELLIDOS',
            icon: Icons.engineering_outlined,
          ),
        ),
      ],
    );
  }
}
