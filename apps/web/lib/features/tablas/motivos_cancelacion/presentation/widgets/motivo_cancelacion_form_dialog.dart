import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/core/widgets/buttons/app_button.dart';
import 'package:ambutrack_web/core/widgets/dialogs/app_dialog.dart';
import 'package:ambutrack_web/core/widgets/handlers/crud_operation_handler.dart';
import 'package:ambutrack_web/core/widgets/loading/app_loading_indicator.dart';
import 'package:ambutrack_web/features/tablas/motivos_cancelacion/presentation/bloc/motivo_cancelacion_bloc.dart';
import 'package:ambutrack_web/features/tablas/motivos_cancelacion/presentation/bloc/motivo_cancelacion_event.dart';
import 'package:ambutrack_web/features/tablas/motivos_cancelacion/presentation/bloc/motivo_cancelacion_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';

/// Diálogo para crear/editar motivos de cancelación
class MotivoCancelacionFormDialog extends StatefulWidget {
  const MotivoCancelacionFormDialog({super.key, this.motivo});

  final MotivoCancelacionEntity? motivo;

  @override
  State<MotivoCancelacionFormDialog> createState() =>
      _MotivoCancelacionFormDialogState();
}

class _MotivoCancelacionFormDialogState
    extends State<MotivoCancelacionFormDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late TextEditingController _nombreController;
  late TextEditingController _descripcionController;

  bool _activo = true;
  bool _isSaving = false;
  bool get _isEditing => widget.motivo != null;

  @override
  void initState() {
    super.initState();
    final MotivoCancelacionEntity? m = widget.motivo;

    _nombreController = TextEditingController(text: m?.nombre ?? '');
    _descripcionController = TextEditingController(text: m?.descripcion ?? '');
    _activo = m?.activo ?? true;
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<MotivoCancelacionBloc, MotivoCancelacionState>(
      listener: (BuildContext context, MotivoCancelacionState state) {
        if (state is MotivoCancelacionLoaded) {
          debugPrint(
              '✅ MotivoCancelacionFormDialog: Motivo guardado exitosamente');

          CrudOperationHandler.handleSuccess(
            context: context,
            isSaving: _isSaving,
            isEditing: _isEditing,
            entityName: 'Motivo de Cancelación',
            onClose: () => setState(() => _isSaving = false),
          );
        } else if (state is MotivoCancelacionError) {
          debugPrint(
              '❌ MotivoCancelacionFormDialog: Error al guardar motivo - ${state.message}');

          CrudOperationHandler.handleError(
            context: context,
            isSaving: _isSaving,
            isEditing: _isEditing,
            entityName: 'Motivo de Cancelación',
            errorMessage: state.message,
            onClose: () => setState(() => _isSaving = false),
          );
        }
      },
      child: AppDialog(
        title: _isEditing
            ? 'Editar Motivo de Cancelación'
            : 'Nuevo Motivo de Cancelación',
        icon: _isEditing ? Icons.edit : Icons.add_circle_outline,
        type: _isEditing ? AppDialogType.edit : AppDialogType.create,
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // Nombre
              _buildTextField(
                controller: _nombreController,
                label: 'Nombre',
                hint: 'Ej: Paciente rechaza el servicio',
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

              // Descripción
              _buildTextField(
                controller: _descripcionController,
                label: 'Descripción',
                hint: 'Descripción detallada del motivo',
                icon: Icons.description_outlined,
                maxLines: 3,
                validator: (String? value) {
                  if (value != null &&
                      value.trim().isNotEmpty &&
                      value.trim().length < 5) {
                    return 'La descripción debe tener al menos 5 caracteres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSizes.spacing),

              // Estado (Activo/Inactivo)
              Container(
                padding: const EdgeInsets.all(AppSizes.paddingMedium),
                decoration: BoxDecoration(
                  color: AppColors.gray50,
                  borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                  border: Border.all(color: AppColors.gray200),
                ),
                child: Row(
                  children: <Widget>[
                    Icon(
                      _activo ? Icons.check_circle : Icons.cancel,
                      color: _activo ? AppColors.success : AppColors.error,
                      size: 20,
                    ),
                    const SizedBox(width: AppSizes.spacingSmall),
                    Expanded(
                      child: Text(
                        'Estado',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimaryLight,
                        ),
                      ),
                    ),
                    Switch(
                      value: _activo,
                      onChanged: (bool value) {
                        setState(() => _activo = value);
                      },
                      activeTrackColor: AppColors.success,
                    ),
                    Text(
                      _activo ? 'Activo' : 'Inactivo',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: _activo ? AppColors.success : AppColors.error,
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
            onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
            label: 'Cancelar',
            variant: AppButtonVariant.text,
          ),
          AppButton(
            onPressed: _isSaving ? null : _onSave,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimaryLight,
          ),
        ),
        const SizedBox(height: AppSizes.spacingXs),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          textInputAction:
              maxLines == 1 ? TextInputAction.next : TextInputAction.newline,
          inputFormatters: label == 'Nombre'
              ? <TextInputFormatter>[
                  UpperCaseTextFormatter(),
                ]
              : null,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon:
                Icon(icon, size: 20, color: AppColors.textSecondaryLight),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
              borderSide: const BorderSide(color: AppColors.gray300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
              borderSide: const BorderSide(color: AppColors.gray300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
              borderSide:
                  const BorderSide(color: AppColors.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
              borderSide: const BorderSide(color: AppColors.error),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
              borderSide: const BorderSide(color: AppColors.error, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSizes.paddingMedium,
              vertical: AppSizes.paddingMedium,
            ),
            filled: true,
            fillColor: Colors.white,
          ),
          style: GoogleFonts.inter(
            fontSize: 14,
            color: AppColors.textPrimaryLight,
          ),
          validator: validator,
        ),
      ],
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
      builder: (BuildContext dialogContext) {
        return AppLoadingOverlay(
          message: _isEditing
              ? 'Actualizando motivo de cancelación...'
              : 'Creando motivo de cancelación...',
          color: _isEditing ? AppColors.secondary : AppColors.primary,
          icon: _isEditing ? Icons.edit : Icons.add_circle_outline,
        );
      },
    );

    final MotivoCancelacionEntity motivo = MotivoCancelacionEntity(
      id: _isEditing ? widget.motivo!.id : const Uuid().v4(),
      nombre: _nombreController.text.trim(),
      descripcion: _descripcionController.text.trim().isEmpty
          ? null
          : _descripcionController.text.trim(),
      activo: _activo,
      createdAt: _isEditing ? widget.motivo!.createdAt : DateTime.now(),
      updatedAt: DateTime.now(),
    );

    if (_isEditing) {
      debugPrint('🔄 Actualizando motivo de cancelación: ${motivo.nombre}');
      context
          .read<MotivoCancelacionBloc>()
          .add(MotivoCancelacionUpdateRequested(motivo));
    } else {
      debugPrint('➕ Creando nuevo motivo de cancelación: ${motivo.nombre}');
      context
          .read<MotivoCancelacionBloc>()
          .add(MotivoCancelacionCreateRequested(motivo));
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
