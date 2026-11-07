import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion/form/gestion_form.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

/// Formulario para crear/editar asignaciones de vehículos a turnos.
///
/// Devuelve la entidad con `Navigator.pop(entity)`; la vista lanza el evento.
class AsignacionFormDialog extends StatefulWidget {
  const AsignacionFormDialog({
    super.key,
    this.asignacion,
  });

  final AsignacionVehiculoTurnoEntity? asignacion;

  @override
  State<AsignacionFormDialog> createState() => _AsignacionFormDialogState();
}

class _AsignacionFormDialogState extends State<AsignacionFormDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _vehiculoIdController = TextEditingController();
  final TextEditingController _dotacionIdController = TextEditingController();
  final TextEditingController _plantillaTurnoIdController = TextEditingController();
  final TextEditingController _hospitalIdController = TextEditingController();
  final TextEditingController _baseIdController = TextEditingController();
  final TextEditingController _observacionesController = TextEditingController();

  DateTime _selectedFecha = DateTime.now();
  String _selectedEstado = 'planificada';

  static const List<GestionOption<String>> _estados = <GestionOption<String>>[
    GestionOption<String>('planificada', 'Planificada', color: AppColors.info),
    GestionOption<String>('confirmada', 'Confirmada', color: AppColors.success),
    GestionOption<String>('en_curso', 'En curso', color: AppColors.warning),
    GestionOption<String>('finalizada', 'Finalizada', color: AppColors.textSecondaryLight),
    GestionOption<String>('cancelada', 'Cancelada', color: AppColors.error),
  ];

  bool get _isEditing => widget.asignacion != null;

  @override
  void initState() {
    super.initState();
    if (widget.asignacion != null) {
      _vehiculoIdController.text = widget.asignacion!.vehiculoId;
      _dotacionIdController.text = widget.asignacion!.dotacionId;
      _plantillaTurnoIdController.text = widget.asignacion!.plantillaTurnoId ?? '';
      _hospitalIdController.text = widget.asignacion!.hospitalId ?? '';
      _baseIdController.text = widget.asignacion!.baseId ?? '';
      _observacionesController.text = widget.asignacion!.observaciones ?? '';
      _selectedFecha = widget.asignacion!.fecha;
      _selectedEstado = widget.asignacion!.estado;
    }
  }

  @override
  void dispose() {
    _vehiculoIdController.dispose();
    _dotacionIdController.dispose();
    _plantillaTurnoIdController.dispose();
    _hospitalIdController.dispose();
    _baseIdController.dispose();
    _observacionesController.dispose();
    super.dispose();
  }

  static String? _requerido(String? value) =>
      (value == null || value.isEmpty) ? 'Este campo es requerido' : null;

  @override
  Widget build(BuildContext context) {
    return GestionFormDialog(
      title: _isEditing ? 'Editar asignación' : 'Nueva asignación',
      subtitle: _isEditing ? DateFormat('dd/MM/yyyy').format(widget.asignacion!.fecha) : null,
      icon: Icons.assignment_ind_outlined,
      formKey: _formKey,
      isEditing: _isEditing,
      saveLabel: _isEditing ? 'Actualizar' : 'Crear',
      onSave: _onSave,
      children: <Widget>[
        const GestionFormSection(title: 'Asignación', first: true),
        GestionFormColumns(
          children: <Widget>[
            GestionFormRow(
              label: 'Fecha',
              required: true,
              child: GestionDateField(
                value: _selectedFecha,
                required: true,
                firstDate: DateTime(2020),
                lastDate: DateTime(2030),
                onChanged: (DateTime? picked) {
                  if (picked != null && picked != _selectedFecha) {
                    setState(() => _selectedFecha = picked);
                  }
                },
              ),
            ),
            GestionFormRow(
              label: 'Estado',
              child: GestionDropdownField<String>(
                value: _selectedEstado,
                options: _estados,
                onChanged: (String? value) {
                  if (value != null) {
                    setState(() => _selectedEstado = value);
                  }
                },
              ),
            ),
          ],
        ),
        GestionFormColumns(
          children: <Widget>[
            GestionFormRow(
              label: 'Vehículo ID',
              required: true,
              child: GestionTextField(
                controller: _vehiculoIdController,
                hint: 'ID del vehículo',
                validator: _requerido,
              ),
            ),
            GestionFormRow(
              label: 'Dotación ID',
              required: true,
              child: GestionTextField(
                controller: _dotacionIdController,
                hint: 'ID de la dotación',
                validator: _requerido,
              ),
            ),
          ],
        ),
        const GestionFormSection(title: 'Referencias opcionales'),
        GestionFormColumns(
          children: <Widget>[
            GestionFormRow(
              label: 'Plantilla ID',
              child: GestionTextField(controller: _plantillaTurnoIdController, hint: 'Opcional'),
            ),
            GestionFormRow(
              label: 'Hospital ID',
              child: GestionTextField(controller: _hospitalIdController, hint: 'Opcional'),
            ),
          ],
        ),
        GestionFormColumns(
          children: <Widget>[
            GestionFormRow(
              label: 'Base ID',
              child: GestionTextField(controller: _baseIdController, hint: 'Opcional'),
            ),
            const SizedBox.shrink(),
          ],
        ),
        GestionFormRow(
          label: 'Observaciones',
          multiline: true,
          child: GestionTextField(
            controller: _observacionesController,
            hint: 'Observaciones adicionales',
            maxLines: 3,
          ),
        ),
      ],
    );
  }

  void _onSave() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final bool isEditing = widget.asignacion != null;

    final AsignacionVehiculoTurnoEntity asignacion = AsignacionVehiculoTurnoEntity(
      id: isEditing ? widget.asignacion!.id : const Uuid().v4(),
      fecha: _selectedFecha,
      vehiculoId: _vehiculoIdController.text.trim(),
      dotacionId: _dotacionIdController.text.trim(),
      plantillaTurnoId: _plantillaTurnoIdController.text.trim().isEmpty
          ? null
          : _plantillaTurnoIdController.text.trim(),
      hospitalId: _hospitalIdController.text.trim().isEmpty ? null : _hospitalIdController.text.trim(),
      baseId: _baseIdController.text.trim().isEmpty ? null : _baseIdController.text.trim(),
      estado: _selectedEstado,
      observaciones: _observacionesController.text.trim().isEmpty
          ? null
          : _observacionesController.text.trim(),
      createdAt: isEditing ? widget.asignacion!.createdAt : DateTime.now(),
      updatedAt: DateTime.now(),
    );

    debugPrint('💾 AsignacionFormDialog: devolviendo asignación ${asignacion.id}');
    Navigator.of(context).pop(asignacion);
  }
}
