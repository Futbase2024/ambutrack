import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/widgets/gestion/form/gestion_form.dart';
import 'package:ambutrack_web/features/ausencias/presentation/widgets/form/ausencia_form_data.dart';
import 'package:ambutrack_web/features/ausencias/presentation/widgets/form/solicitud_form_widgets.dart';
import 'package:ambutrack_web/features/personal/domain/entities/personal_entity.dart';
import 'package:flutter/material.dart';

/// Campos del formulario de ausencia
class AusenciaFormBody extends StatelessWidget {
  const AusenciaFormBody({
    required this.data,
    required this.isSaving,
    required this.onChanged,
    required this.onFechaInicio,
    required this.onFechaFin,
    required this.onSeleccionarArchivo,
    required this.onEliminarArchivo,
    super.key,
  });

  final AusenciaFormData data;
  final bool isSaving;

  /// Notifica cambios para que el diálogo se reconstruya
  final VoidCallback onChanged;
  final ValueChanged<DateTime?> onFechaInicio;
  final ValueChanged<DateTime?> onFechaFin;
  final VoidCallback onSeleccionarArchivo;
  final VoidCallback onEliminarArchivo;

  void _set(VoidCallback change) {
    change();
    onChanged();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const GestionFormSection(title: 'Solicitud', first: true),
        GestionFormRow(
          label: 'Empleado',
          required: true,
          child: GestionSearchField<String>(
            value: data.personal?.id,
            required: true,
            enabled: !isSaving,
            hint: 'Buscar por nombre o DNI',
            options: data.personalList
                .map((PersonalEntity p) => GestionOption<String>(p.id, '${p.nombreCompleto} - ${p.dni}'))
                .toList(),
            onChanged: (String? id) => _set(
              () => data.personal = data.personalList.where((PersonalEntity p) => p.id == id).firstOrNull,
            ),
          ),
        ),
        GestionFormColumns(
          children: <Widget>[
            GestionFormRow(
              label: 'Tipo',
              required: true,
              child: GestionDropdownField<String>(
                value: data.tipo?.id,
                required: true,
                options: data.tipos
                    .map(
                      (TipoAusenciaEntity t) =>
                          GestionOption<String>(t.id, t.nombre, color: AusenciaFormOptions.colorTipo(t.color)),
                    )
                    .toList(),
                onChanged: (String? id) => _set(
                  () => data.tipo = data.tipos.where((TipoAusenciaEntity t) => t.id == id).firstOrNull,
                ),
              ),
            ),
            GestionFormRow(
              label: 'Estado',
              required: true,
              child: GestionDropdownField<EstadoAusencia>(
                value: data.estado,
                required: true,
                options: AusenciaFormOptions.estados,
                onChanged: (EstadoAusencia? v) => _set(() => data.estado = v ?? data.estado),
              ),
            ),
          ],
        ),
        const GestionFormSection(title: 'Periodo'),
        GestionFormColumns(
          children: <Widget>[
            Column(
              children: <Widget>[
                GestionFormRow(
                  label: 'Desde',
                  required: true,
                  child: GestionDateField(
                    key: ValueKey<DateTime?>(data.fechaInicio),
                    value: data.fechaInicio,
                    required: true,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2030),
                    onChanged: onFechaInicio,
                  ),
                ),
                GestionFormRow(
                  label: 'Días',
                  child: GestionFormReadOnly(value: '${data.diasCalculados} días'),
                ),
              ],
            ),
            GestionFormRow(
              label: 'Hasta',
              required: true,
              child: GestionDateField(
                key: ValueKey<DateTime?>(data.fechaFin),
                value: data.fechaFin,
                required: true,
                firstDate: DateTime(2020),
                lastDate: DateTime(2030),
                onChanged: onFechaFin,
              ),
            ),
          ],
        ),
        const GestionFormSection(title: 'Detalles'),
        GestionFormRow(
          label: 'Motivo',
          required: true,
          multiline: true,
          child: GestionTextField(
            controller: data.motivo,
            hint: 'Motivo de la ausencia',
            maxLines: 2,
            validator: GestionFormStyle.requerido,
          ),
        ),
        GestionFormRow(
          label: 'Observaciones',
          multiline: true,
          child: GestionTextField(controller: data.observaciones, hint: 'Información adicional', maxLines: 3),
        ),
        const GestionFormSection(title: 'Documentación'),
        GestionFormRow(
          label: 'Documento',
          child: DocumentoAdjuntoField(
            nombreArchivo: data.nombreArchivo,
            tamanoBytes: data.archivo?.size,
            enabled: !isSaving,
            onSeleccionar: onSeleccionarArchivo,
            onEliminar: onEliminarArchivo,
          ),
        ),
      ],
    );
  }
}
