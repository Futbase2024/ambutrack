import 'package:ambutrack_web/core/widgets/gestion/form/gestion_form.dart';
import 'package:ambutrack_web/features/ausencias/presentation/widgets/form/solicitud_form_widgets.dart';
import 'package:ambutrack_web/features/personal/domain/entities/personal_entity.dart';
import 'package:ambutrack_web/features/vacaciones/presentation/widgets/form/vacacion_form_data.dart';
import 'package:flutter/material.dart';

/// Campos del formulario de vacaciones
class VacacionFormBody extends StatelessWidget {
  const VacacionFormBody({
    required this.data,
    required this.isSaving,
    required this.onChanged,
    required this.onFechaInicio,
    required this.onFechaFin,
    required this.onSeleccionarArchivo,
    required this.onEliminarArchivo,
    super.key,
  });

  final VacacionFormData data;
  final bool isSaving;

  /// Notifica cambios para que el diálogo se reconstruya
  final VoidCallback onChanged;
  final ValueChanged<DateTime?> onFechaInicio;
  final ValueChanged<DateTime?> onFechaFin;
  final VoidCallback onSeleccionarArchivo;
  final VoidCallback onEliminarArchivo;

  /// Limita "Hasta" a partir de "Desde" (solo si el calendario abre en una fecha válida)
  DateTime? get _primeraFechaFin {
    final DateTime? inicio = data.fechaInicio;
    final DateTime inicial = data.fechaFin ?? DateTime.now();
    return inicio != null && !inicio.isAfter(inicial) ? inicio : null;
  }

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
                .map((PersonalEntity p) => GestionOption<String>(p.id, VacacionFormOptions.personalLabel(p)))
                .toList(),
            onChanged: (String? id) => _set(
              () => data.personal = data.personalList.where((PersonalEntity p) => p.id == id).firstOrNull,
            ),
          ),
        ),
        GestionFormColumns(
          children: <Widget>[
            GestionFormRow(
              label: 'Desde',
              required: true,
              child: GestionDateField(
                key: ValueKey<DateTime?>(data.fechaInicio),
                value: data.fechaInicio,
                required: true,
                onChanged: onFechaInicio,
              ),
            ),
            GestionFormRow(
              label: 'Hasta',
              required: true,
              child: GestionDateField(
                key: ValueKey<String>('fin-${data.fechaFin}-${data.fechaInicio}'),
                value: data.fechaFin,
                required: true,
                firstDate: _primeraFechaFin,
                onChanged: onFechaFin,
              ),
            ),
          ],
        ),
        GestionFormColumns(
          children: <Widget>[
            GestionFormRow(
              label: 'Estado',
              child: GestionDropdownField<String>(
                value: data.estado,
                options: VacacionFormOptions.estados,
                onChanged: (String? v) {
                  if (v != null) {
                    _set(() => data.estado = v);
                  }
                },
              ),
            ),
            const SizedBox.shrink(),
          ],
        ),
        GestionFormRow(
          label: 'Observaciones',
          multiline: true,
          child: GestionTextField(controller: data.observaciones, hint: 'Notas adicionales', maxLines: 3),
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
