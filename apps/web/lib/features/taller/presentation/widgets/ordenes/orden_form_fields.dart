import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/widgets/gestion/form/gestion_form.dart';
import 'package:ambutrack_web/features/taller/presentation/widgets/form/taller_form_components.dart';
import 'package:ambutrack_web/features/taller/presentation/widgets/ordenes/orden_form_inputs.dart';
import 'package:ambutrack_web/features/taller/presentation/widgets/ordenes/orden_ui_helpers.dart';
import 'package:flutter/material.dart';

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
        const GestionFormSection(title: 'Entrada en taller', first: true),
        _EntradaSection(selection: selection, callbacks: callbacks, vehiculos: vehiculos, talleres: talleres),
        const GestionFormSection(title: 'Trabajo'),
        _TrabajoSection(controllers: controllers, isEditing: isEditing),
        const GestionFormSection(title: 'Costes'),
        _CostesSection(controllers: controllers, selection: selection, callbacks: callbacks),
        GestionFormRow(
          label: 'Observaciones',
          multiline: true,
          child: GestionTextField(controller: controllers.observaciones, hint: 'Notas adicionales', maxLines: 2),
        ),
      ],
    );
  }
}

class _EntradaSection extends StatelessWidget {
  const _EntradaSection({
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
    return GestionFormColumns(
      children: <Widget>[
        Column(
          children: <Widget>[
            GestionFormRow(
              label: 'Vehículo',
              required: true,
              child: GestionSearchField<String>(
                value: selection.vehiculoId,
                required: true,
                hint: 'Buscar matrícula',
                options: vehiculos
                    .map((VehiculoEntity v) => GestionOption<String>(v.id, v.matricula))
                    .toList(growable: false),
                onChanged: callbacks.onVehiculo,
              ),
            ),
            GestionFormRow(
              label: 'Origen',
              required: true,
              child: GestionDropdownField<OrigenOrdenReparacion>(
                value: selection.origen,
                required: true,
                options: _origenOptions,
                onChanged: (OrigenOrdenReparacion? v) => v == null ? null : callbacks.onOrigen(v),
              ),
            ),
            GestionFormRow(
              label: 'Fecha entrada',
              required: true,
              child: GestionDateField(
                value: selection.fechaEntrada,
                required: true,
                firstDate: DateTime(2020),
                lastDate: DateTime.now().add(const Duration(days: 365)),
                onChanged: (DateTime? v) => v == null ? null : callbacks.onFecha(v),
              ),
            ),
          ],
        ),
        Column(
          children: <Widget>[
            GestionFormRow(
              label: 'Taller',
              child: GestionSearchField<String>(
                value: selection.tallerId,
                hint: 'Buscar taller',
                options: talleres
                    .map((TallerEntity t) => GestionOption<String>(t.id, t.nombre))
                    .toList(growable: false),
                onChanged: callbacks.onTaller,
              ),
            ),
            GestionFormRow(
              label: 'Prioridad',
              required: true,
              child: GestionDropdownField<PrioridadOrdenReparacion>(
                value: selection.prioridad,
                required: true,
                options: _prioridadOptions,
                onChanged: (PrioridadOrdenReparacion? v) => v == null ? null : callbacks.onPrioridad(v),
              ),
            ),
          ],
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
        GestionFormColumns(
          children: <Widget>[
            GestionFormRow(
              label: 'Km entrada',
              child: GestionIntField(controller: controllers.kmEntrada, unit: 'km'),
            ),
            if (isEditing)
              GestionFormRow(
                label: 'Km salida',
                child: GestionIntField(controller: controllers.kmSalida, unit: 'km'),
              )
            else
              const SizedBox.shrink(),
          ],
        ),
        GestionFormRow(
          label: 'Mecánico',
          child: GestionTextField(controller: controllers.mecanico, hint: 'NOMBRE Y APELLIDOS'),
        ),
        GestionFormRow(
          label: 'Diagnóstico',
          multiline: true,
          child: GestionTextField(
            controller: controllers.diagnostico,
            hint: 'Descripción de la avería',
            maxLines: 3,
          ),
        ),
        if (isEditing)
          GestionFormRow(
            label: 'Trabajos',
            multiline: true,
            child: GestionTextField(controller: controllers.trabajos, hint: 'Trabajos realizados', maxLines: 3),
          ),
      ],
    );
  }
}

class _CostesSection extends StatelessWidget {
  const _CostesSection({required this.controllers, required this.selection, required this.callbacks});

  final OrdenFormControllers controllers;
  final OrdenFormSelection selection;
  final OrdenFormCallbacks callbacks;

  @override
  Widget build(BuildContext context) {
    return GestionFormColumns(
      children: <Widget>[
        Column(
          children: <Widget>[
            GestionFormRow(
              label: 'Horas M.O.',
              child: OrdenDecimalField(controller: controllers.horas, unit: 'h'),
            ),
            GestionFormRow(
              label: 'Coste M.O.',
              child: GestionMoneyField(controller: controllers.costeManoObra),
            ),
            GestionFormRow(
              label: 'Seguro',
              child: GestionSwitchField(
                value: selection.cubiertoSeguro,
                text: selection.cubiertoSeguro ? 'Cubierto por el seguro' : 'No cubierto',
                onChanged: callbacks.onSeguro,
              ),
            ),
          ],
        ),
        Column(
          children: <Widget>[
            GestionFormRow(
              label: 'Coste grúa',
              child: GestionMoneyField(controller: controllers.costeGrua),
            ),
            GestionFormRow(
              label: 'Garantía',
              child: GestionIntField(controller: controllers.garantia, unit: 'meses'),
            ),
          ],
        ),
      ],
    );
  }
}

final List<GestionOption<OrigenOrdenReparacion>> _origenOptions = gestionOptionsOf<OrigenOrdenReparacion>(
  OrigenOrdenReparacion.values,
  (OrigenOrdenReparacion o) => o.displayName,
);

final List<GestionOption<PrioridadOrdenReparacion>> _prioridadOptions = gestionOptionsOf<PrioridadOrdenReparacion>(
  PrioridadOrdenReparacion.values,
  (PrioridadOrdenReparacion p) => p.displayName,
  colorOf: prioridadOrdenColor,
);
