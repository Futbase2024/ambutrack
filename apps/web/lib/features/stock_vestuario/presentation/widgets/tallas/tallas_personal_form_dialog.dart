import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/utils/upper_case_text_formatter.dart';
import 'package:ambutrack_web/core/widgets/gestion/form/gestion_form.dart';
import 'package:flutter/material.dart';

/// Abre el formulario de tallas. Devuelve las tallas editadas o null si se cancela.
Future<TallasPersonalEntity?> editarTallasPersonal(
  BuildContext context, {
  required String personalId,
  required String trabajador,
  TallasPersonalEntity? tallas,
}) {
  return showDialog<TallasPersonalEntity>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext _) =>
        TallasPersonalFormDialog(personalId: personalId, trabajador: trabajador, tallas: tallas),
  );
}

/// Formulario de tallas del trabajador (siempre en MAYÚSCULAS)
class TallasPersonalFormDialog extends StatefulWidget {
  const TallasPersonalFormDialog({required this.personalId, required this.trabajador, this.tallas, super.key});

  final String personalId;
  final String trabajador;
  final TallasPersonalEntity? tallas;

  @override
  State<TallasPersonalFormDialog> createState() => _TallasPersonalFormDialogState();
}

class _TallasPersonalFormDialogState extends State<TallasPersonalFormDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final Map<String, TextEditingController> _c;
  late final TextEditingController _observaciones;

  static const List<String> _campos = <String>[
    'Camiseta',
    'Polo',
    'Sudadera',
    'Chaqueta',
    'Pantalón',
    'Calzado',
    'Guantes',
  ];

  @override
  void initState() {
    super.initState();
    final TallasPersonalEntity? t = widget.tallas;
    final List<String?> valores = <String?>[
      t?.camiseta,
      t?.polo,
      t?.sudadera,
      t?.chaqueta,
      t?.pantalon,
      t?.calzado,
      t?.guantes,
    ];
    _c = <String, TextEditingController>{
      for (int i = 0; i < _campos.length; i++) _campos[i]: TextEditingController(text: valores[i] ?? ''),
    };
    _observaciones = TextEditingController(text: t?.observaciones ?? '');
  }

  @override
  void dispose() {
    for (final TextEditingController c in _c.values) {
      c.dispose();
    }
    _observaciones.dispose();
    super.dispose();
  }

  String? _valor(TextEditingController c) {
    final String v = c.text.trim().toUpperCase();
    return v.isEmpty ? null : v;
  }

  void _guardar() {
    final String obs = _observaciones.text.trim();
    Navigator.of(context).pop(
      TallasPersonalEntity(
        personalId: widget.personalId,
        camiseta: _valor(_c['Camiseta']!),
        polo: _valor(_c['Polo']!),
        sudadera: _valor(_c['Sudadera']!),
        chaqueta: _valor(_c['Chaqueta']!),
        pantalon: _valor(_c['Pantalón']!),
        calzado: _valor(_c['Calzado']!),
        guantes: _valor(_c['Guantes']!),
        observaciones: obs.isEmpty ? null : obs,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestionFormDialog(
      title: 'Tallas del trabajador',
      subtitle: widget.trabajador,
      icon: Icons.straighten,
      formKey: _formKey,
      size: GestionFormSize.small,
      isEditing: widget.tallas != null,
      onSave: _guardar,
      children: <Widget>[
        const GestionFormSection(title: 'Tallas', first: true),
        GestionFormColumns(
          children: <Widget>[
            Column(children: <Widget>[for (final String k in _campos.sublist(0, 4)) _TallaFila(label: k, controller: _c[k]!)]),
            Column(children: <Widget>[for (final String k in _campos.sublist(4)) _TallaFila(label: k, controller: _c[k]!)]),
          ],
        ),
        const GestionFormSection(title: 'Observaciones'),
        GestionFormRow(
          label: 'Notas',
          labelWidth: 90,
          multiline: true,
          child: GestionTextField(controller: _observaciones, maxLines: 3, hint: 'Observaciones sobre tallas'),
        ),
      ],
    );
  }
}

class _TallaFila extends StatelessWidget {
  const _TallaFila({required this.label, required this.controller});

  final String label;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return GestionFormRow(
      label: label,
      labelWidth: 90,
      child: GestionTextField(
        controller: controller,
        hint: 'Ej. M, 42',
        maxLength: 10,
        inputFormatters: <UpperCaseTextFormatter>[UpperCaseTextFormatter()],
      ),
    );
  }
}
