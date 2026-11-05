import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion/form/gestion_form.dart';
import 'package:ambutrack_web/features/cuadrante/excepciones_festivos/presentation/bloc/excepciones_festivos_bloc_exports.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

/// Diálogo de formulario para crear/editar una Excepción/Festivo
class ExcepcionFestivoFormDialog extends StatefulWidget {
  const ExcepcionFestivoFormDialog({super.key, this.item});

  final ExcepcionFestivoEntity? item;

  @override
  State<ExcepcionFestivoFormDialog> createState() => _ExcepcionFestivoFormDialogState();
}

class _ExcepcionFestivoFormDialogState extends State<ExcepcionFestivoFormDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late TextEditingController _nombreController;
  late TextEditingController _descripcionController;

  DateTime _fecha = DateTime.now();
  String _tipo = ExcepcionFestivoEntity.tipoFestivo;
  bool _afectaDotaciones = true;
  bool _repetirAnualmente = false;
  bool _activo = true;

  bool get _isEditing => widget.item != null;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    final ExcepcionFestivoEntity? item = widget.item;

    _nombreController = TextEditingController(text: item?.nombre ?? '');
    _descripcionController = TextEditingController(text: item?.descripcion ?? '');

    if (item != null) {
      _fecha = item.fecha;
      _tipo = item.tipo;
      _afectaDotaciones = item.afectaDotaciones;
      _repetirAnualmente = item.repetirAnualmente;
      _activo = item.activo;
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestionFormDialog(
      title: _isEditing ? 'Editar excepción / festivo' : 'Nueva excepción / festivo',
      subtitle: _isEditing
          ? '${widget.item!.nombre} · ${DateFormat('dd/MM/yyyy').format(widget.item!.fecha)}'
          : null,
      icon: Icons.event_busy_outlined,
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
            hint: 'Ej: Navidad, Año Nuevo…',
            validator: (String? value) =>
                (value == null || value.trim().isEmpty) ? 'El nombre es requerido' : null,
          ),
        ),
        GestionFormRow(
          label: 'Fecha',
          required: true,
          child: GestionDateField(
            value: _fecha,
            required: true,
            firstDate: DateTime(2020),
            onChanged: (DateTime? picked) {
              if (picked != null && picked != _fecha) {
                setState(() => _fecha = picked);
              }
            },
          ),
        ),
        GestionFormRow(
          label: 'Tipo',
          required: true,
          child: GestionDropdownField<String>(
            value: _tipo,
            required: true,
            options: ExcepcionFestivoEntity.tiposValidos
                .map((String tipo) => GestionOption<String>(tipo, tipo, color: _tipoColor(tipo)))
                .toList(),
            onChanged: (String? value) {
              if (value != null) {
                setState(() => _tipo = value);
              }
            },
          ),
        ),
        GestionFormRow(
          label: 'Descripción',
          multiline: true,
          child: GestionTextField(
            controller: _descripcionController,
            hint: 'Información adicional',
            maxLines: 2,
          ),
        ),
        const GestionFormSection(title: 'Configuración'),
        GestionFormRow(
          label: 'Repetir',
          child: GestionCheckField(
            value: _repetirAnualmente,
            text: 'Repetir anualmente',
            onChanged: (bool value) => setState(() => _repetirAnualmente = value),
          ),
        ),
        GestionFormRow(
          label: 'Estado',
          child: GestionSwitchField(
            value: _activo,
            text: _activo ? 'Activa' : 'Inactiva',
            onChanged: (bool value) => setState(() => _activo = value),
          ),
        ),
      ],
    );
  }

  static Color _tipoColor(String tipo) {
    switch (tipo) {
      case 'FESTIVO':
        return AppColors.success;
      case 'EXCEPCION':
        return AppColors.warning;
      case 'ESPECIAL':
        return AppColors.info;
      default:
        return AppColors.gray400;
    }
  }

  void _onSave() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final ExcepcionFestivoEntity item = ExcepcionFestivoEntity(
      id: widget.item?.id ?? const Uuid().v4(),
      nombre: _nombreController.text.trim(),
      fecha: _fecha,
      tipo: _tipo,
      descripcion: _descripcionController.text.trim().isNotEmpty
          ? _descripcionController.text.trim()
          : null,
      afectaDotaciones: _afectaDotaciones,
      repetirAnualmente: _repetirAnualmente,
      activo: _activo,
      createdAt: widget.item?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
      createdBy: widget.item?.createdBy,
      updatedBy: widget.item?.updatedBy,
    );

    debugPrint('💾 Guardando excepción/festivo: ${item.nombre}');

    if (_isEditing) {
      context.read<ExcepcionesFestivosBloc>().add(ExcepcionFestivoUpdateRequested(item));
    } else {
      context.read<ExcepcionesFestivosBloc>().add(ExcepcionFestivoCreateRequested(item));
    }

    Navigator.of(context).pop();
  }
}
