import 'dart:async';

import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/widgets/buttons/app_button.dart';
import '../../../../../core/widgets/dialogs/app_dialog.dart';
import '../../../../../core/widgets/handlers/crud_operation_handler.dart';
import '../../../../../core/widgets/loading/app_loading_indicator.dart';
import '../bloc/especialidad_bloc.dart';
import '../bloc/especialidad_event.dart';
import '../bloc/especialidad_state.dart';

/// Diálogo para crear/editar especialidad médica
class EspecialidadFormDialog extends StatefulWidget {

  const EspecialidadFormDialog({
    super.key,
    this.especialidad,
  });
  final EspecialidadEntity? especialidad;

  @override
  State<EspecialidadFormDialog> createState() => _EspecialidadFormDialogState();
}

class _EspecialidadFormDialogState extends State<EspecialidadFormDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late TextEditingController _nombreController;
  late TextEditingController _descripcionController;
  late bool _requiereCertificacion;
  late String _tipoEspecialidad;
  late bool _activo;

  bool _isSaving = false;
  bool get _isEditing => widget.especialidad != null;

  @override
  void initState() {
    super.initState();
    final EspecialidadEntity? especialidad = widget.especialidad;

    _nombreController = TextEditingController(text: especialidad?.nombre ?? '');
    _descripcionController =
        TextEditingController(text: especialidad?.descripcion ?? '');
    _requiereCertificacion = especialidad?.requiereCertificacion ?? true;
    _tipoEspecialidad = especialidad?.tipoEspecialidad ?? 'medica';
    _activo = especialidad?.activo ?? true;
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  Future<void> _onSave() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_isSaving) {
      return;
    }

    final EspecialidadEntity especialidad = EspecialidadEntity(
      id: widget.especialidad?.id ?? '',
      nombre: _nombreController.text.trim(),
      descripcion: _descripcionController.text.trim().isEmpty
          ? null
          : _descripcionController.text.trim(),
      requiereCertificacion: _requiereCertificacion,
      tipoEspecialidad: _tipoEspecialidad,
      activo: _activo,
      createdAt: widget.especialidad?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    setState(() => _isSaving = true);

    // Mostrar overlay de loading
    unawaited(
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) => AppLoadingOverlay(
          message: _isEditing
              ? 'Actualizando Especialidad Médica...'
              : 'Creando Especialidad Médica...',
        ),
      ),
    );

    if (_isEditing) {
      context.read<EspecialidadBloc>().add(
            EspecialidadUpdateRequested(especialidad),
          );
    } else {
      context.read<EspecialidadBloc>().add(
            EspecialidadCreateRequested(especialidad),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<EspecialidadBloc, EspecialidadState>(
      listener: (BuildContext context, EspecialidadState state) {
        if (!_isSaving) {
          return;
        }

        if (state is EspecialidadLoaded) {
          CrudOperationHandler.handleSuccess(
            context: context,
            isSaving: _isSaving,
            isEditing: _isEditing,
            entityName: 'Especialidad Médica',
            onClose: () {
              if (mounted) {
                setState(() => _isSaving = false);
              }
            },
          );
        } else if (state is EspecialidadError) {
          CrudOperationHandler.handleError(
            context: context,
            isSaving: _isSaving,
            isEditing: _isEditing,
            entityName: 'Especialidad Médica',
            errorMessage: state.message,
            onClose: () {
              if (mounted) {
                setState(() => _isSaving = false);
              }
            },
          );
        }
      },
      child: AppDialog(
        title: _isEditing ? 'Editar Especialidad' : 'Nueva Especialidad',
        content: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // Nombre
                TextFormField(
                  controller: _nombreController,
                  textInputAction: TextInputAction.next,
                  inputFormatters: <TextInputFormatter>[
                    UpperCaseTextFormatter(),
                  ],
                  decoration: InputDecoration(
                    labelText: 'Nombre *',
                    hintText: 'Ej: Medicina de Urgencias',
                    prefixIcon:
                        const Icon(Icons.medical_services, color: AppColors.gray400),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
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
                const SizedBox(height: 16),

                // Tipo de especialidad
                DropdownButtonFormField<String>(
                  initialValue: _tipoEspecialidad,
                  decoration: InputDecoration(
                    labelText: 'Tipo de Especialidad *',
                    prefixIcon: const Icon(Icons.category, color: AppColors.gray400),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  items: const <DropdownMenuItem<String>>[
                    DropdownMenuItem<String>(
                      value: 'medica',
                      child: Text('Médica'),
                    ),
                    DropdownMenuItem<String>(
                      value: 'quirurgica',
                      child: Text('Quirúrgica'),
                    ),
                    DropdownMenuItem<String>(
                      value: 'diagnostica',
                      child: Text('Diagnóstica'),
                    ),
                    DropdownMenuItem<String>(
                      value: 'apoyo',
                      child: Text('Apoyo'),
                    ),
                    DropdownMenuItem<String>(
                      value: 'enfermeria',
                      child: Text('Enfermería'),
                    ),
                    DropdownMenuItem<String>(
                      value: 'tecnica',
                      child: Text('Técnica'),
                    ),
                  ],
                  onChanged: (String? value) {
                    if (value != null) {
                      setState(() {
                        _tipoEspecialidad = value;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),

                // Descripción
                TextFormField(
                  controller: _descripcionController,
                  maxLines: 3,
                  textInputAction: TextInputAction.newline,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    labelText: 'Descripción',
                    hintText: 'Descripción detallada de la especialidad',
                    prefixIcon: const Icon(Icons.description, color: AppColors.gray400),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignLabelWithHint: true,
                  ),
                  validator: (String? value) {
                    if (value != null &&
                        value.trim().isNotEmpty &&
                        value.trim().length < 5) {
                      return 'La descripción debe tener al menos 5 caracteres';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Requiere certificación
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.gray50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.gray300),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: <Widget>[
                      const Icon(
                        Icons.verified_user,
                        color: AppColors.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              'Requiere Certificación',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimaryLight,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              'Indica si se necesita certificación específica',
                              style: TextStyle(
                                color: AppColors.textSecondaryLight,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: _requiereCertificacion,
                        onChanged: (bool value) {
                          setState(() {
                            _requiereCertificacion = value;
                          });
                        },
                        activeTrackColor: AppColors.primary,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Estado activo
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.gray50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.gray300),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: <Widget>[
                      Icon(
                        _activo ? Icons.check_circle : Icons.cancel,
                        color: _activo ? AppColors.success : AppColors.error,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            const Text(
                              'Estado',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimaryLight,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              _activo
                                  ? 'La especialidad está activa'
                                  : 'La especialidad está inactiva',
                              style: const TextStyle(
                                color: AppColors.textSecondaryLight,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: _activo,
                        onChanged: (bool value) {
                          setState(() {
                            _activo = value;
                          });
                        },
                        activeTrackColor: AppColors.success,
                      ),
                    ],
                  ),
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
            label: _isEditing ? 'Actualizar' : 'Crear',
            icon: _isEditing ? Icons.check : Icons.save,
          ),
        ],
      ),
    );
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
