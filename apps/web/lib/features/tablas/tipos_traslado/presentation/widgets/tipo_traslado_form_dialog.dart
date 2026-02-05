import 'package:ambutrack_core/ambutrack_core.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/core/widgets/dialogs/app_dialog.dart';
import 'package:ambutrack_web/core/widgets/handlers/crud_operation_handler.dart';
import 'package:ambutrack_web/core/widgets/loading/app_loading_indicator.dart';
import 'package:ambutrack_web/features/tablas/tipos_traslado/presentation/bloc/tipo_traslado_bloc.dart';
import 'package:ambutrack_web/features/tablas/tipos_traslado/presentation/bloc/tipo_traslado_event.dart';
import 'package:ambutrack_web/features/tablas/tipos_traslado/presentation/bloc/tipo_traslado_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';

/// Diálogo de formulario para crear/editar tipo de traslado
class TipoTrasladoFormDialog extends StatefulWidget {
  const TipoTrasladoFormDialog({super.key, this.tipo});

  final TipoTrasladoEntity? tipo;

  @override
  State<TipoTrasladoFormDialog> createState() => _TipoTrasladoFormDialogState();
}

class _TipoTrasladoFormDialogState extends State<TipoTrasladoFormDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late TextEditingController _nombreController;
  late TextEditingController _descripcionController;
  bool _activo = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(text: widget.tipo?.nombre);
    _descripcionController = TextEditingController(text: widget.tipo?.descripcion);
    _activo = widget.tipo?.activo ?? true;
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isEditing = widget.tipo != null;

    return BlocListener<TipoTrasladoBloc, TipoTrasladoState>(
      listener: (BuildContext context, TipoTrasladoState state) {
        if (state is TipoTrasladoLoaded) {
          CrudOperationHandler.handleSuccess(
            context: context,
            isSaving: _isSaving,
            isEditing: isEditing,
            entityName: 'Tipo de Traslado',
            onClose: () => setState(() => _isSaving = false),
          );
        } else if (state is TipoTrasladoError) {
          CrudOperationHandler.handleError(
            context: context,
            isSaving: _isSaving,
            isEditing: isEditing,
            entityName: 'Tipo de Traslado',
            errorMessage: state.message,
            onClose: () => setState(() => _isSaving = false),
          );
        }
      },
      child: AppDialog(
      title: isEditing ? 'Editar Tipo de Traslado' : 'Nuevo Tipo de Traslado',
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // Campo: Nombre
            _buildTextField(
              controller: _nombreController,
              label: 'Nombre *',
              hint: 'Ej: Urgente, Programado, etc.',
              maxLines: 1,
              validator: (String? value) {
                if (value == null || value.trim().isEmpty) {
                  return 'El nombre es obligatorio';
                }
                if (value.trim().length < 3) {
                  return 'El nombre debe tener al menos 3 caracteres';
                }
                return null;
              },
            ),
            const SizedBox(height: AppSizes.spacing),

            // Campo: Descripción
            _buildTextField(
              controller: _descripcionController,
              label: 'Descripción',
              hint: 'Descripción detallada del tipo de traslado (opcional)',
              maxLines: 3,
            ),
            const SizedBox(height: AppSizes.spacing),

            // Campo: Estado (Activo/Inactivo)
            _buildActivoSwitch(),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          style: TextButton.styleFrom(
            foregroundColor: AppColors.textSecondaryLight,
          ),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _onSave,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.paddingLarge,
              vertical: AppSizes.paddingMedium,
            ),
          ),
          child: Text(isEditing ? 'Guardar Cambios' : 'Crear Tipo'),
        ),
      ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required int maxLines,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimaryLight,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          textInputAction: maxLines == 1 ? TextInputAction.next : TextInputAction.newline,
          inputFormatters: label.contains('Nombre')
              ? <TextInputFormatter>[
                  UpperCaseTextFormatter(),
                ]
              : null,
          decoration: InputDecoration(
            hintText: hint,
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

  Widget _buildActivoSwitch() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingMedium),
      decoration: BoxDecoration(
        color: AppColors.gray50,
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Estado',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimaryLight,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _activo ? 'Activo' : 'Inactivo',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: _activo ? AppColors.success : AppColors.error,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: _activo,
            onChanged: (bool value) {
              setState(() => _activo = value);
            },
            activeTrackColor: AppColors.success,
          ),
        ],
      ),
    );
  }

  void _onSave() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final bool isEditing = widget.tipo != null;

    setState(() {
      _isSaving = true;
    });

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AppLoadingOverlay(
          message: isEditing ? 'Actualizando tipo de traslado...' : 'Creando tipo de traslado...',
          color: isEditing ? AppColors.secondary : AppColors.primary,
          icon: isEditing ? Icons.edit : Icons.add_circle_outline,
        );
      },
    );

    final TipoTrasladoEntity tipo = TipoTrasladoEntity(
      id: widget.tipo?.id ?? const Uuid().v4(),
      createdAt: widget.tipo?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
      nombre: _nombreController.text.trim(),
      descripcion: _descripcionController.text.trim().isEmpty
          ? null
          : _descripcionController.text.trim(),
      activo: _activo,
    );

    if (widget.tipo != null) {
      // Actualizar
      context.read<TipoTrasladoBloc>().add(TipoTrasladoUpdateRequested(tipo));
    } else {
      // Crear
      context.read<TipoTrasladoBloc>().add(TipoTrasladoCreateRequested(tipo));
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
