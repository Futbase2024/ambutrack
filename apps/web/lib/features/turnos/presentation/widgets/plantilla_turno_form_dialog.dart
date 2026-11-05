import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion/form/gestion_form.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

/// Diálogo para crear o editar una plantilla de turno
class PlantillaTurnoFormDialog extends StatefulWidget {
  const PlantillaTurnoFormDialog({
    super.key,
    this.plantilla,
    required this.onSave,
  });

  final PlantillaTurnoEntity? plantilla;
  final void Function(PlantillaTurnoEntity) onSave;

  @override
  State<PlantillaTurnoFormDialog> createState() => _PlantillaTurnoFormDialogState();
}

class _PlantillaTurnoFormDialogState extends State<PlantillaTurnoFormDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();
  final TextEditingController _horaInicioController = TextEditingController();
  final TextEditingController _horaFinController = TextEditingController();
  final TextEditingController _colorController = TextEditingController();
  final TextEditingController _observacionesController = TextEditingController();

  TipoTurno _tipoTurno = TipoTurno.manana;
  int _duracionDias = 1;
  bool _activo = true;
  bool _useCustomColor = false;

  bool get _isEditing => widget.plantilla != null;

  static final RegExp _horaRegExp = RegExp(r'^\d{2}:\d{2}$');
  static final RegExp _hexRegExp = RegExp(r'^#[0-9A-Fa-f]{6}$');

  @override
  void initState() {
    super.initState();

    if (widget.plantilla != null) {
      final PlantillaTurnoEntity p = widget.plantilla!;
      _nombreController.text = p.nombre;
      _descripcionController.text = p.descripcion ?? '';
      _horaInicioController.text = p.horaInicio;
      _horaFinController.text = p.horaFin;
      _colorController.text = p.color ?? '';
      _observacionesController.text = p.observaciones ?? '';
      _tipoTurno = p.tipoTurno;
      _duracionDias = p.duracionDias;
      _activo = p.activo;
      _useCustomColor = p.color != null && p.color!.isNotEmpty;
    } else {
      // Valores por defecto para nueva plantilla
      _horaInicioController.text = _tipoTurno.horaInicio;
      _horaFinController.text = _tipoTurno.horaFin;
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _descripcionController.dispose();
    _horaInicioController.dispose();
    _horaFinController.dispose();
    _colorController.dispose();
    _observacionesController.dispose();
    super.dispose();
  }

  static Color? _hexToColor(String hex) {
    if (!_hexRegExp.hasMatch(hex)) {
      return null;
    }
    return Color(int.parse(hex.substring(1), radix: 16) + 0xFF000000);
  }

  static String? _validarHora(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Requerido';
    }
    if (!_horaRegExp.hasMatch(value)) {
      return 'Formato HH:mm';
    }
    return null;
  }

  String? _validarColor(String? value) {
    if (_useCustomColor && (value == null || value.trim().isEmpty)) {
      return 'Requerido si usa color personalizado';
    }
    if (_useCustomColor && !_hexRegExp.hasMatch(value!)) {
      return 'Formato: #RRGGBB';
    }
    return null;
  }

  void _onTipoChanged(TipoTurno? value) {
    if (value == null) {
      return;
    }
    setState(() {
      _tipoTurno = value;
      // Actualizar horarios por defecto
      if (_horaInicioController.text.isEmpty || _horaFinController.text.isEmpty) {
        _horaInicioController.text = value.horaInicio;
        _horaFinController.text = value.horaFin;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestionFormDialog(
      title: _isEditing ? 'Editar plantilla de turno' : 'Nueva plantilla de turno',
      subtitle: _isEditing ? widget.plantilla!.nombre : null,
      icon: Icons.schedule_outlined,
      formKey: _formKey,
      isEditing: _isEditing,
      saveLabel: _isEditing ? 'Guardar' : 'Crear',
      onSave: _guardar,
      children: <Widget>[
        const GestionFormSection(title: 'Plantilla', first: true),
        GestionFormRow(
          label: 'Nombre',
          required: true,
          child: GestionTextField(
            controller: _nombreController,
            hint: 'Ej: Turno Mañana Estándar',
            validator: (String? value) =>
                (value == null || value.trim().isEmpty) ? 'El nombre es obligatorio' : null,
          ),
        ),
        GestionFormRow(
          label: 'Descripción',
          multiline: true,
          child: GestionTextField(controller: _descripcionController, hint: 'Opcional', maxLines: 2),
        ),
        const GestionFormSection(title: 'Horario'),
        GestionFormColumns(
          children: <Widget>[
            Column(
              children: <Widget>[
                GestionFormRow(
                  label: 'Tipo de turno',
                  child: GestionDropdownField<TipoTurno>(
                    value: _tipoTurno,
                    options: TipoTurno.values
                        .map((TipoTurno t) => GestionOption<TipoTurno>(t, t.nombre, color: _hexToColor(t.colorHex)))
                        .toList(),
                    onChanged: _onTipoChanged,
                  ),
                ),
                GestionFormRow(
                  label: 'Hora inicio',
                  required: true,
                  child: GestionTextField(controller: _horaInicioController, hint: 'HH:mm', validator: _validarHora),
                ),
              ],
            ),
            Column(
              children: <Widget>[
                GestionFormRow(
                  label: 'Duración',
                  child: GestionDropdownField<int>(
                    value: _duracionDias,
                    options: List<int>.generate(7, (int i) => i + 1)
                        .map((int d) => GestionOption<int>(d, d == 1 ? '1 día' : '$d días'))
                        .toList(),
                    onChanged: (int? value) {
                      if (value != null) {
                        setState(() => _duracionDias = value);
                      }
                    },
                  ),
                ),
                GestionFormRow(
                  label: 'Hora fin',
                  required: true,
                  child: GestionTextField(controller: _horaFinController, hint: 'HH:mm', validator: _validarHora),
                ),
              ],
            ),
          ],
        ),
        const GestionFormSection(title: 'Otros'),
        GestionFormColumns(
          children: <Widget>[
            GestionFormRow(
              label: 'Color',
              child: GestionCheckField(
                value: _useCustomColor,
                text: 'Usar color personalizado',
                onChanged: (bool value) => setState(() => _useCustomColor = value),
              ),
            ),
            if (_useCustomColor)
              GestionFormRow(
                label: 'Color (hex)',
                required: true,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: GestionTextField(
                        controller: _colorController,
                        hint: '#RRGGBB',
                        validator: _validarColor,
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _ColorSwatch(color: _hexToColor(_colorController.text.trim())),
                  ],
                ),
              )
            else
              const SizedBox.shrink(),
          ],
        ),
        GestionFormRow(
          label: 'Observaciones',
          multiline: true,
          child: GestionTextField(controller: _observacionesController, hint: 'Opcional', maxLines: 3),
        ),
        GestionFormRow(
          label: 'Estado',
          child: GestionSwitchField(
            value: _activo,
            text: _activo ? 'Activo' : 'Inactivo',
            onChanged: (bool value) => setState(() => _activo = value),
          ),
        ),
      ],
    );
  }

  /// Guarda la plantilla
  void _guardar() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final PlantillaTurnoEntity plantilla = PlantillaTurnoEntity(
      id: widget.plantilla?.id ?? const Uuid().v4(),
      nombre: _nombreController.text.trim(),
      descripcion: _descripcionController.text.trim().isEmpty ? null : _descripcionController.text.trim(),
      tipoTurno: _tipoTurno,
      horaInicio: _horaInicioController.text.trim(),
      horaFin: _horaFinController.text.trim(),
      color: _useCustomColor && _colorController.text.trim().isNotEmpty ? _colorController.text.trim() : null,
      duracionDias: _duracionDias,
      observaciones: _observacionesController.text.trim().isEmpty ? null : _observacionesController.text.trim(),
      activo: _activo,
    );

    debugPrint('💾 PlantillaTurnoFormDialog: guardando plantilla ${plantilla.nombre}');
    widget.onSave(plantilla);
    Navigator.of(context).pop();
  }
}

/// Muestra del color personalizado (36x36, borde gray300, radio 6)
class _ColorSwatch extends StatelessWidget {
  const _ColorSwatch({required this.color});

  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: color ?? AppColors.gray50,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.gray300),
      ),
      child: color == null ? const Icon(Icons.color_lens_outlined, size: 16, color: AppColors.gray400) : null,
    );
  }
}
