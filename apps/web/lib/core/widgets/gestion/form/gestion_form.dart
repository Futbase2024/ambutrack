/// Formularios estilo programa de gestión.
///
/// ```dart
/// GestionFormDialog(
///   title: 'Nueva ITV / Revisión',
///   formKey: _formKey,
///   onSave: _save,
///   children: [
///     GestionFormSection(title: 'Datos', first: true),
///     GestionFormColumns(children: [
///       GestionFormRow(label: 'Tipo', required: true, child: GestionDropdownField(...)),
///       GestionFormRow(label: 'Fecha', required: true, child: GestionDateField(...)),
///     ]),
///   ],
/// )
/// ```
library;

export 'gestion_form_dialog.dart';
export 'gestion_form_extra_fields.dart';
export 'gestion_form_fields.dart';
export 'gestion_form_layout.dart';
export 'gestion_form_style.dart';
export 'gestion_search_field.dart';
