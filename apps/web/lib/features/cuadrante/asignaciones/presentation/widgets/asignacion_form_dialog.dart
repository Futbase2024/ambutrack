import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/core/widgets/buttons/app_button.dart';
import 'package:ambutrack_web/core/widgets/dialogs/app_dialog.dart';
import 'package:ambutrack_web/core/widgets/dropdowns/app_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';

/// Formulario para crear/editar asignaciones de vehículos a turnos
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

  final List<String> _estados = <String>[
    'planificada',
    'confirmada',
    'en_curso',
    'finalizada',
    'cancelada',
  ];

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

  @override
  Widget build(BuildContext context) {
    final bool isEditing = widget.asignacion != null;

    return AppDialog(
      title: isEditing ? 'Editar Asignación' : 'Nueva Asignación',
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              _buildDateField(),
              const SizedBox(height: AppSizes.spacing),
              _buildTextField(
                controller: _vehiculoIdController,
                label: 'Vehículo ID',
                hint: 'ID del vehículo',
                icon: Icons.directions_car,
                required: true,
              ),
              const SizedBox(height: AppSizes.spacing),
              _buildTextField(
                controller: _dotacionIdController,
                label: 'Dotación ID',
                hint: 'ID de la dotación',
                icon: Icons.assignment,
                required: true,
              ),
              const SizedBox(height: AppSizes.spacing),
              _buildTextField(
                controller: _plantillaTurnoIdController,
                label: 'Plantilla Turno ID',
                hint: 'ID de la plantilla de turno (opcional)',
                icon: Icons.access_time,
              ),
              const SizedBox(height: AppSizes.spacing),
              _buildTextField(
                controller: _hospitalIdController,
                label: 'Hospital ID',
                hint: 'ID del hospital (opcional)',
                icon: Icons.local_hospital,
              ),
              const SizedBox(height: AppSizes.spacing),
              _buildTextField(
                controller: _baseIdController,
                label: 'Base ID',
                hint: 'ID de la base (opcional)',
                icon: Icons.home_work,
              ),
              const SizedBox(height: AppSizes.spacing),
              _buildEstadoDropdown(),
              const SizedBox(height: AppSizes.spacing),
              _buildTextField(
                controller: _observacionesController,
                label: 'Observaciones',
                hint: 'Observaciones adicionales',
                icon: Icons.notes,
                maxLines: 3,
              ),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        AppButton(
          onPressed: () => Navigator.of(context).pop(),
          label: 'Cancelar',
          variant: AppButtonVariant.text,
        ),
        AppButton(
          onPressed: _onSave,
          label: isEditing ? 'Actualizar' : 'Crear',
        ),
      ],
    );
  }

  Widget _buildDateField() {
    return InkWell(
      onTap: () => _selectDate(context),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Fecha',
          prefixIcon: const Icon(Icons.calendar_today, color: AppColors.primary),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
          ),
        ),
        child: Text(
          _formatDate(_selectedFecha),
          style: GoogleFonts.inter(
            fontSize: 14,
            color: AppColors.textPrimaryLight,
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool required = false,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      textInputAction: maxLines == 1 ? TextInputAction.next : TextInputAction.newline,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: AppColors.primary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        ),
      ),
      validator: required
          ? (String? value) {
              if (value == null || value.isEmpty) {
                return 'Este campo es requerido';
              }
              return null;
            }
          : null,
    );
  }

  Widget _buildEstadoDropdown() {
    return AppDropdown<String>(
      value: _selectedEstado,
      label: 'Estado',
      hint: 'Selecciona el estado',
      prefixIcon: Icons.info_outline,
      items: _estados.map((String estado) {
        return AppDropdownItem<String>(
          value: estado,
          label: _getEstadoLabel(estado),
          icon: _getEstadoIcon(estado),
          iconColor: _getEstadoColor(estado),
        );
      }).toList(),
      onChanged: (String? value) {
        if (value != null) {
          setState(() {
            _selectedEstado = value;
          });
        }
      },
    );
  }

  String _getEstadoLabel(String estado) {
    switch (estado) {
      case 'planificada':
        return 'Planificada';
      case 'confirmada':
        return 'Confirmada';
      case 'en_curso':
        return 'En Curso';
      case 'finalizada':
        return 'Finalizada';
      case 'cancelada':
        return 'Cancelada';
      default:
        return estado;
    }
  }

  IconData _getEstadoIcon(String estado) {
    switch (estado) {
      case 'planificada':
        return Icons.event_note;
      case 'confirmada':
        return Icons.check_circle_outline;
      case 'en_curso':
        return Icons.play_circle_outline;
      case 'finalizada':
        return Icons.done_all;
      case 'cancelada':
        return Icons.cancel_outlined;
      default:
        return Icons.help_outline;
    }
  }

  Color _getEstadoColor(String estado) {
    switch (estado) {
      case 'planificada':
        return AppColors.info;
      case 'confirmada':
        return AppColors.success;
      case 'en_curso':
        return AppColors.warning;
      case 'finalizada':
        return AppColors.textSecondaryLight;
      case 'cancelada':
        return AppColors.error;
      default:
        return AppColors.textSecondaryLight;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedFecha,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (picked != null && picked != _selectedFecha) {
      setState(() {
        _selectedFecha = picked;
      });
    }
  }

  void _onSave() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final bool isEditing = widget.asignacion != null;

    final AsignacionVehiculoTurnoEntity asignacion =
        AsignacionVehiculoTurnoEntity(
      id: isEditing ? widget.asignacion!.id : const Uuid().v4(),
      fecha: _selectedFecha,
      vehiculoId: _vehiculoIdController.text.trim(),
      dotacionId: _dotacionIdController.text.trim(),
      plantillaTurnoId: _plantillaTurnoIdController.text.trim().isEmpty
          ? null
          : _plantillaTurnoIdController.text.trim(),
      hospitalId: _hospitalIdController.text.trim().isEmpty
          ? null
          : _hospitalIdController.text.trim(),
      baseId: _baseIdController.text.trim().isEmpty
          ? null
          : _baseIdController.text.trim(),
      estado: _selectedEstado,
      observaciones: _observacionesController.text.trim().isEmpty
          ? null
          : _observacionesController.text.trim(),
      createdAt:
          isEditing ? widget.asignacion!.createdAt : DateTime.now(),
      updatedAt: DateTime.now(),
    );

    Navigator.of(context).pop(asignacion);
  }
}
