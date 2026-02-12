import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/core/widgets/buttons/app_button.dart';
import 'package:ambutrack_web/core/widgets/dialogs/app_dialog.dart';
import 'package:ambutrack_web/core/widgets/handlers/crud_operation_handler.dart';
import 'package:ambutrack_web/core/widgets/loading/app_loading_indicator.dart';
import 'package:ambutrack_web/features/tablas/motivos_traslado/presentation/bloc/motivo_traslado_bloc.dart';
import 'package:ambutrack_web/features/tablas/motivos_traslado/presentation/bloc/motivo_traslado_event.dart';
import 'package:ambutrack_web/features/tablas/motivos_traslado/presentation/bloc/motivo_traslado_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';

/// Diálogo para crear/editar motivos de traslado
class MotivoTrasladoFormDialog extends StatefulWidget {
  /// Constructor
  const MotivoTrasladoFormDialog({super.key, this.motivo});

  /// Motivo a editar (null para crear nuevo)
  final MotivoTrasladoEntity? motivo;

  @override
  State<MotivoTrasladoFormDialog> createState() => _MotivoTrasladoFormDialogState();
}

class _MotivoTrasladoFormDialogState extends State<MotivoTrasladoFormDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late TextEditingController _nombreController;
  late TextEditingController _descripcionController;

  bool _activo = true;
  bool _isSaving = false;
  bool get _isEditing => widget.motivo != null;

  @override
  void initState() {
    super.initState();
    final MotivoTrasladoEntity? m = widget.motivo;

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
    return BlocListener<MotivoTrasladoBloc, MotivoTrasladoState>(
      listener: (BuildContext context, MotivoTrasladoState state) {
        if (state is MotivoTrasladoLoaded) {
          CrudOperationHandler.handleSuccess(
            context: context,
            isSaving: _isSaving,
            isEditing: _isEditing,
            entityName: 'Motivo de Traslado',
            onClose: () {
              if (mounted) {
                setState(() {
                  _isSaving = false;
                });
              }
            },
          );
        } else if (state is MotivoTrasladoError) {
          CrudOperationHandler.handleError(
            context: context,
            isSaving: _isSaving,
            isEditing: _isEditing,
            entityName: 'Motivo de Traslado',
            errorMessage: state.message,
            onClose: () {
              if (mounted) {
                setState(() {
                  _isSaving = false;
                });
              }
            },
          );
        }
      },
      child: AppDialog(
        title: _isEditing ? 'Editar Motivo de Traslado' : 'Nuevo Motivo de Traslado',
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
                hint: 'Ej: Consulta médica',
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
                hint: 'Descripción del motivo de traslado',
                icon: Icons.description_outlined,
                maxLines: 3,
                validator: (String? value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'La descripción es requerida';
                  }
                  if (value.trim().length < 5) {
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
            icon: _isEditing ? Icons.check : Icons.save,
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
          textInputAction: maxLines == 1 ? TextInputAction.next : TextInputAction.newline,
          inputFormatters: label == 'Nombre'
              ? <TextInputFormatter>[
                  UpperCaseTextFormatter(),
                ]
              : null,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, size: 20, color: AppColors.textSecondaryLight),
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
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
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
          message: _isEditing ? 'Actualizando motivo de traslado...' : 'Creando motivo de traslado...',
          icon: _isEditing ? Icons.edit : Icons.add_circle_outline,
          color: AppColors.primary,
        );
      },
    );

    final MotivoTrasladoEntity motivo = MotivoTrasladoEntity(
      id: _isEditing ? widget.motivo!.id : const Uuid().v4(),
      nombre: _nombreController.text.trim(),
      descripcion: _descripcionController.text.trim(),
      activo: _activo,
      createdAt: _isEditing ? widget.motivo!.createdAt : DateTime.now(),
      updatedAt: DateTime.now(),
    );

    if (_isEditing) {
      debugPrint('🔄 Actualizando motivo: ${motivo.nombre}');
      context.read<MotivoTrasladoBloc>().add(MotivoTrasladoUpdateRequested(motivo));
    } else {
      debugPrint('➕ Creando nuevo motivo: ${motivo.nombre}');
      context.read<MotivoTrasladoBloc>().add(MotivoTrasladoCreateRequested(motivo));
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
