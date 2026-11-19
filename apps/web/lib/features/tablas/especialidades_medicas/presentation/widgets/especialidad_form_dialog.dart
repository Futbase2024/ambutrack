import 'dart:async';

import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/utils/upper_case_text_formatter.dart';
import '../../../../../core/widgets/gestion/form/gestion_form.dart';
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
  static const List<GestionOption<String>> _tiposEspecialidad = <GestionOption<String>>[
    GestionOption<String>('medica', 'Médica'),
    GestionOption<String>('quirurgica', 'Quirúrgica'),
    GestionOption<String>('diagnostica', 'Diagnóstica'),
    GestionOption<String>('apoyo', 'Apoyo'),
    GestionOption<String>('enfermeria', 'Enfermería'),
    GestionOption<String>('tecnica', 'Técnica'),
  ];

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
      child: GestionFormDialog(
        title: _isEditing ? 'Editar Especialidad' : 'Nueva Especialidad',
        subtitle: _isEditing ? widget.especialidad!.nombre : null,
        icon: Icons.medical_services_outlined,
        formKey: _formKey,
        isEditing: _isEditing,
        isSaving: _isSaving,
        onSave: _onSave,
        children: <Widget>[
          const GestionFormSection(title: 'Datos', first: true),
          GestionFormColumns(
            children: <Widget>[
              GestionFormRow(
                label: 'Nombre',
                required: true,
                child: GestionTextField(
                  controller: _nombreController,
                  hint: 'Ej: Medicina de Urgencias',
                  inputFormatters: <TextInputFormatter>[UpperCaseTextFormatter()],
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
              ),
              GestionFormRow(
                label: 'Tipo',
                required: true,
                child: GestionDropdownField<String>(
                  value: _tipoEspecialidad,
                  required: true,
                  options: _tiposEspecialidad,
                  onChanged: (String? value) {
                    if (value != null) {
                      setState(() => _tipoEspecialidad = value);
                    }
                  },
                ),
              ),
            ],
          ),
          GestionFormRow(
            label: 'Descripción',
            multiline: true,
            child: GestionTextField(
              controller: _descripcionController,
              hint: 'Descripción detallada de la especialidad',
              maxLines: 3,
              validator: (String? value) {
                if (value != null && value.trim().isNotEmpty && value.trim().length < 5) {
                  return 'La descripción debe tener al menos 5 caracteres';
                }
                return null;
              },
            ),
          ),
          const GestionFormSection(title: 'Configuración'),
          GestionFormColumns(
            children: <Widget>[
              GestionFormRow(
                label: 'Certificación',
                child: GestionSwitchField(
                  value: _requiereCertificacion,
                  text: _requiereCertificacion ? 'Requiere certificación' : 'No requiere certificación',
                  onChanged: (bool value) => setState(() => _requiereCertificacion = value),
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
          ),
        ],
      ),
    );
  }
}
