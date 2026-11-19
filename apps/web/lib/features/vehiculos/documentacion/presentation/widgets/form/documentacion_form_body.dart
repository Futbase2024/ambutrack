import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion/form/gestion_form.dart';
import 'package:ambutrack_web/features/vehiculos/documentacion/presentation/widgets/form/documentacion_archivo_field.dart';
import 'package:ambutrack_web/features/vehiculos/documentacion/presentation/widgets/form/documentacion_form_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Campos del formulario de documentación de vehículo
class DocumentacionFormBody extends StatelessWidget {
  const DocumentacionFormBody({
    required this.data,
    required this.isSaving,
    required this.onChanged,
    required this.onSeleccionarArchivo,
    required this.onVerArchivo,
    super.key,
  });

  final DocumentacionFormData data;
  final bool isSaving;

  /// Notifica cambios para que el diálogo se reconstruya
  final VoidCallback onChanged;
  final ValueChanged<int> onSeleccionarArchivo;
  final ValueChanged<String> onVerArchivo;

  void _set(VoidCallback change) {
    change();
    onChanged();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const GestionFormSection(title: 'Documento', first: true),
        GestionFormColumns(
          children: <Widget>[
            GestionFormRow(
              label: 'Tipo',
              child: GestionDropdownField<String>(
                value: data.tipoDocumentoId,
                hint: 'Selecciona el tipo',
                options: DocumentacionFormOptions.withValue(DocumentacionFormOptions.tipos, data.tipoDocumentoId),
                onChanged: (String? v) => _set(() => data.tipoDocumentoId = v),
              ),
            ),
            GestionFormRow(
              label: 'Estado',
              child: GestionDropdownField<String>(
                value: data.estado,
                options: DocumentacionFormOptions.withValue(DocumentacionFormOptions.estados, data.estado),
                onChanged: (String? v) => _set(() => data.estado = v ?? 'vigente'),
              ),
            ),
          ],
        ),
        GestionFormColumns(
          children: <Widget>[
            GestionFormRow(
              label: 'Nº póliza',
              required: true,
              child: GestionTextField(
                controller: data.numeroPoliza,
                hint: 'Póliza o licencia',
                inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.allow(RegExp('[a-zA-Z0-9-]'))],
                validator: (String? v) => (v == null || v.trim().isEmpty) ? 'El número es obligatorio' : null,
              ),
            ),
            GestionFormRow(
              label: 'Compañía',
              required: true,
              child: GestionTextField(
                controller: data.compania,
                hint: 'Ej: Mapfre, DGT',
                validator: (String? v) => (v == null || v.trim().isEmpty) ? 'La compañía es obligatoria' : null,
              ),
            ),
          ],
        ),
        const GestionFormSection(title: 'Vigencia'),
        GestionFormColumns(
          children: <Widget>[
            Column(
              children: <Widget>[
                GestionFormRow(
                  label: 'Emisión',
                  required: true,
                  child: GestionDateField(
                    value: data.fechaEmision,
                    required: true,
                    onChanged: (DateTime? v) => _set(() => data.fechaEmision = v),
                  ),
                ),
                GestionFormRow(label: 'Coste anual', child: GestionMoneyField(controller: data.costeAnual)),
              ],
            ),
            Column(
              children: <Widget>[
                GestionFormRow(
                  label: 'Vencimiento',
                  required: true,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      GestionDateField(
                        value: data.fechaVencimiento,
                        required: true,
                        onChanged: (DateTime? v) => _set(() => data.fechaVencimiento = v),
                      ),
                      _VencimientoPosteriorValidator(data: data),
                    ],
                  ),
                ),
                GestionFormRow(
                  label: 'Días de alerta',
                  child: GestionTextField(
                    controller: data.diasAlertaCtrl,
                    hint: '30',
                    suffixText: 'días',
                    textAlign: TextAlign.end,
                    keyboardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
                    onChanged: (String value) {
                      final int? days = int.tryParse(value);
                      if (days != null) {
                        _set(() => data.diasAlerta = days);
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
        GestionFormRow(
          label: 'Renovación',
          child: GestionCheckField(
            value: data.requiereRenovacion,
            text: 'Requiere renovación automática',
            onChanged: (bool v) => _set(() => data.requiereRenovacion = v),
          ),
        ),
        GestionFormRow(
          label: 'Observaciones',
          multiline: true,
          child: GestionTextField(controller: data.observaciones, hint: 'Notas adicionales', maxLines: 3),
        ),
        const GestionFormSection(title: 'Documentos escaneados'),
        for (final int numero in <int>[1, 2])
          GestionFormRow(
            label: 'Documento $numero',
            child: DocumentacionArchivoField(
              numero: numero,
              archivoSeleccionado: data.archivo(numero),
              nombreArchivoExistente: data.existente(numero),
              enabled: !isSaving,
              onSeleccionar: () => onSeleccionarArchivo(numero),
              onEliminar: () {
                _set(() => data.eliminarArchivo(numero));
                debugPrint('🗑️ Archivo $numero eliminado');
              },
              onVer: onVerArchivo,
            ),
          ),
      ],
    );
  }
}

/// Valida que el vencimiento no sea anterior a la emisión
class _VencimientoPosteriorValidator extends StatelessWidget {
  const _VencimientoPosteriorValidator({required this.data});

  final DocumentacionFormData data;

  @override
  Widget build(BuildContext context) {
    return FormField<void>(
      validator: (_) {
        final DateTime? emision = data.fechaEmision;
        final DateTime? vencimiento = data.fechaVencimiento;
        if (emision != null && vencimiento != null && vencimiento.isBefore(emision)) {
          return 'Debe ser posterior a emisión';
        }
        return null;
      },
      builder: (FormFieldState<void> state) {
        if (!state.hasError) {
          return const SizedBox.shrink();
        }
        return Padding(
          padding: const EdgeInsets.only(top: 4, left: 2),
          child: Text(
            state.errorText!,
            style: const TextStyle(fontSize: 11, color: AppColors.error),
          ),
        );
      },
    );
  }
}
