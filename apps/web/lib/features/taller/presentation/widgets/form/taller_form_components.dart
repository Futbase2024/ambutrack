import 'package:ambutrack_web/core/widgets/gestion/form/gestion_form.dart';
import 'package:flutter/material.dart';

/// Devuelve el texto recortado del controller o `null` si está vacío
String? textOrNull(TextEditingController controller) {
  final String value = controller.text.trim();
  return value.isEmpty ? null : value;
}

/// Opciones de desplegable a partir de los valores de un enum
List<GestionOption<T>> gestionOptionsOf<T>(
  List<T> values,
  String Function(T) labelOf, {
  Color? Function(T)? colorOf,
}) {
  return values
      .map((T v) => GestionOption<T>(v, labelOf(v), color: colorOf?.call(v)))
      .toList(growable: false);
}

/// Bloque de datos generales común a Taller y Proveedor:
/// nombre, NIF, tipo, un campo extra (especialidad / forma de pago) y activo.
class TallerDatosGeneralesFields<T> extends StatelessWidget {
  const TallerDatosGeneralesFields({
    required this.nombre,
    required this.nombreHint,
    required this.nif,
    required this.tipo,
    required this.tipos,
    required this.tipoLabel,
    required this.onTipoChanged,
    required this.extra,
    required this.extraLabel,
    required this.extraHint,
    required this.activo,
    required this.activoText,
    required this.onActivoChanged,
    super.key,
  });

  final TextEditingController nombre;
  final String nombreHint;
  final TextEditingController nif;
  final T tipo;
  final List<GestionOption<T>> tipos;
  final String tipoLabel;
  final ValueChanged<T> onTipoChanged;
  final TextEditingController extra;
  final String extraLabel;
  final String extraHint;
  final bool activo;
  final String activoText;
  final ValueChanged<bool> onActivoChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        GestionFormRow(
          label: 'Nombre',
          required: true,
          child: GestionTextField(controller: nombre, hint: nombreHint, validator: GestionFormStyle.requerido),
        ),
        GestionFormColumns(
          children: <Widget>[
            GestionFormRow(
              label: tipoLabel,
              required: true,
              child: GestionDropdownField<T>(
                value: tipo,
                options: tipos,
                required: true,
                onChanged: (T? v) {
                  if (v != null) {
                    onTipoChanged(v);
                  }
                },
              ),
            ),
            GestionFormRow(
              label: 'NIF/CIF',
              child: GestionTextField(controller: nif, hint: 'B12345678'),
            ),
          ],
        ),
        GestionFormColumns(
          children: <Widget>[
            GestionFormRow(
              label: extraLabel,
              child: GestionTextField(controller: extra, hint: extraHint),
            ),
            GestionFormRow(
              label: 'Estado',
              child: GestionSwitchField(
                value: activo,
                text: activo ? activoText : 'Inactivo',
                onChanged: onActivoChanged,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
