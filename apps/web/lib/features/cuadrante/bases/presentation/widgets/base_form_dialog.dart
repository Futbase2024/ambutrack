import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion/form/gestion_form.dart';
import 'package:ambutrack_web/features/cuadrante/bases/presentation/bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Diálogo de formulario para crear/editar una Base
class BaseFormDialog extends StatefulWidget {
  const BaseFormDialog({super.key, this.base});

  final BaseCentroEntity? base;

  @override
  State<BaseFormDialog> createState() => _BaseFormDialogState();
}

class _BaseFormDialogState extends State<BaseFormDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late TextEditingController _nombreController;
  late TextEditingController _direccionController;

  String _tipoSeleccionado = 'Permanente';
  bool _activo = true;

  bool get _isEditing => widget.base != null;

  static const List<GestionOption<String>> _tipos = <GestionOption<String>>[
    GestionOption<String>('Permanente', 'Permanente', color: AppColors.primary),
    GestionOption<String>('Temporal', 'Temporal', color: AppColors.warning),
  ];

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(text: widget.base?.nombre ?? '');
    _direccionController = TextEditingController(text: widget.base?.direccion ?? '');

    if (widget.base != null) {
      _tipoSeleccionado = widget.base!.tipo ?? 'Permanente';
      _activo = widget.base!.activo;
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _direccionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestionFormDialog(
      title: _isEditing ? 'Editar base' : 'Nueva base',
      subtitle: _isEditing ? widget.base!.nombre : null,
      icon: Icons.business_outlined,
      size: GestionFormSize.small,
      formKey: _formKey,
      isEditing: _isEditing,
      saveLabel: _isEditing ? 'Actualizar' : 'Crear',
      onSave: _onSave,
      children: <Widget>[
        const GestionFormSection(title: 'Datos', first: true),
        GestionFormRow(
          label: 'Nombre',
          required: true,
          child: GestionTextField(
            controller: _nombreController,
            hint: 'Ej: Base Central Madrid',
            validator: (String? value) =>
                (value == null || value.isEmpty) ? 'El nombre es obligatorio' : null,
          ),
        ),
        GestionFormRow(
          label: 'Dirección',
          multiline: true,
          child: GestionTextField(
            controller: _direccionController,
            hint: 'Calle, número, piso...',
            maxLines: 2,
          ),
        ),
        const GestionFormSection(title: 'Configuración'),
        GestionFormRow(
          label: 'Tipo',
          required: true,
          child: GestionDropdownField<String>(
            value: _tipoSeleccionado,
            options: _tipos,
            required: true,
            onChanged: (String? value) {
              if (value != null) {
                setState(() => _tipoSeleccionado = value);
              }
            },
          ),
        ),
        GestionFormRow(
          label: 'Activa',
          child: GestionSwitchField(
            value: _activo,
            text: _activo ? 'La base está operativa' : 'La base está desactivada',
            onChanged: (bool value) => setState(() => _activo = value),
          ),
        ),
      ],
    );
  }

  void _onSave() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final BaseCentroEntity base = BaseCentroEntity(
      id: widget.base?.id ?? '',
      codigo: widget.base?.codigo,
      nombre: _nombreController.text.trim(),
      direccion: _direccionController.text.trim().isEmpty ? null : _direccionController.text.trim(),
      tipo: _tipoSeleccionado,
      activo: _activo,
      createdAt: widget.base?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    debugPrint('💾 BaseFormDialog: ${_isEditing ? 'actualizando' : 'creando'} base ${base.nombre}');
    if (_isEditing) {
      context.read<BasesBloc>().add(BaseUpdateRequested(base));
    } else {
      context.read<BasesBloc>().add(BaseCreateRequested(base));
    }

    Navigator.of(context).pop();
  }
}
