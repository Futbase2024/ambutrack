import 'package:ambutrack_core/ambutrack_core.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/core/widgets/buttons/app_button.dart';
import 'package:ambutrack_web/core/widgets/dialogs/app_dialog.dart';
import 'package:ambutrack_web/core/widgets/handlers/crud_operation_handler.dart';
import 'package:ambutrack_web/core/widgets/loading/app_loading_indicator.dart';
import 'package:ambutrack_web/features/tablas/tipos_paciente/presentation/bloc/tipo_paciente_bloc.dart';
import 'package:ambutrack_web/features/tablas/tipos_paciente/presentation/bloc/tipo_paciente_event.dart';
import 'package:ambutrack_web/features/tablas/tipos_paciente/presentation/bloc/tipo_paciente_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';

/// Diálogo para crear/editar tipos de paciente
class TipoPacienteFormDialog extends StatefulWidget {
  const TipoPacienteFormDialog({super.key, this.tipoPaciente});

  final TipoPacienteEntity? tipoPaciente;

  @override
  State<TipoPacienteFormDialog> createState() => _TipoPacienteFormDialogState();
}

class _TipoPacienteFormDialogState extends State<TipoPacienteFormDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late TextEditingController _nombreController;
  late TextEditingController _descripcionController;

  bool _activo = true;
  bool _isSaving = false;
  bool get _isEditing => widget.tipoPaciente != null;

  @override
  void initState() {
    super.initState();
    final TipoPacienteEntity? tipo = widget.tipoPaciente;

    _nombreController = TextEditingController(text: tipo?.nombre ?? '');
    _descripcionController = TextEditingController(text: tipo?.descripcion ?? '');
    _activo = tipo?.activo ?? true;
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TipoPacienteBloc, TipoPacienteState>(
      listener: (BuildContext context, TipoPacienteState state) {
        if (state is TipoPacienteLoaded) {
          debugPrint('✅ TipoPacienteFormDialog: Tipo de paciente guardado exitosamente');

          CrudOperationHandler.handleSuccess(
            context: context,
            isSaving: _isSaving,
            isEditing: _isEditing,
            entityName: 'Tipo de Paciente',
            onClose: () => setState(() => _isSaving = false),
          );
        } else if (state is TipoPacienteError) {
          debugPrint('❌ TipoPacienteFormDialog: Error al guardar - ${state.message}');

          CrudOperationHandler.handleError(
            context: context,
            isSaving: _isSaving,
            isEditing: _isEditing,
            entityName: 'Tipo de Paciente',
            errorMessage: state.message,
            onClose: () => setState(() => _isSaving = false),
          );
        }
      },
      child: AppDialog(
        title: _isEditing ? 'Editar Tipo de Paciente' : 'Nuevo Tipo de Paciente',
        icon: _isEditing ? Icons.edit : Icons.add_circle_outline,
        type: _isEditing ? AppDialogType.edit : AppDialogType.create,
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              _buildTextField(
                controller: _nombreController,
                label: 'Nombre',
                hint: 'Ej: Paciente Geriátrico',
                icon: Icons.label_outline,
                validator: (String? value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'El nombre es requerido';
                  }
                  if (value.trim().length < 3) {
                    return 'El nombre debe tener al menos 3 caracteres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSizes.spacing),

              _buildTextField(
                controller: _descripcionController,
                label: 'Descripción',
                hint: 'Descripción detallada del tipo de paciente',
                icon: Icons.description_outlined,
                maxLines: 3,
                validator: (String? value) {
                  if (value != null && value.trim().isNotEmpty && value.trim().length < 5) {
                    return 'La descripción debe tener al menos 5 caracteres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSizes.spacing),

              Container(
                padding: const EdgeInsets.all(AppSizes.paddingMedium),
                decoration: BoxDecoration(
                  color: AppColors.gray50,
                  borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                  border: Border.all(color: AppColors.gray200),
                ),
                child: Row(
                  children: <Widget>[
                    const Icon(Icons.toggle_on_outlined, size: 20, color: AppColors.primary),
                    const SizedBox(width: AppSizes.spacingSmall),
                    Expanded(
                      child: Text(
                        'Estado',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimaryLight,
                        ),
                      ),
                    ),
                    Switch(
                      value: _activo,
                      onChanged: (bool value) {
                        setState(() => _activo = value);
                      },
                      activeThumbColor: AppColors.success,
                    ),
                    Text(
                      _activo ? 'Activo' : 'Inactivo',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: _activo ? AppColors.success : AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
              ),
            ],
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
            label: _isEditing ? 'Actualizar' : 'Guardar',
            icon: _isEditing ? Icons.save : Icons.add,
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      textInputAction: maxLines == 1 ? TextInputAction.next : TextInputAction.newline,
      inputFormatters: label == 'Nombre'
          ? <TextInputFormatter>[
              UpperCaseTextFormatter(),
            ]
          : null,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, size: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      style: GoogleFonts.inter(fontSize: 14),
      validator: validator,
    );
  }

  void _onSave() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    // Mostrar loading overlay
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AppLoadingOverlay(
          message: _isEditing ? 'Actualizando tipo de paciente...' : 'Creando tipo de paciente...',
          color: _isEditing ? AppColors.secondary : AppColors.primary,
          icon: _isEditing ? Icons.edit : Icons.add_circle_outline,
        );
      },
    );

    final TipoPacienteEntity tipo = TipoPacienteEntity(
      id: _isEditing ? widget.tipoPaciente!.id : const Uuid().v4(),
      createdAt: widget.tipoPaciente?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
      nombre: _nombreController.text.trim(),
      descripcion: _descripcionController.text.trim().isEmpty
          ? null
          : _descripcionController.text.trim(),
      activo: _activo,
    );

    if (_isEditing) {
      context.read<TipoPacienteBloc>().add(TipoPacienteUpdateRequested(tipo));
    } else {
      context.read<TipoPacienteBloc>().add(TipoPacienteCreateRequested(tipo));
    }
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}
