import 'dart:async';

import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/utils/upper_case_text_formatter.dart';
import 'package:ambutrack_web/core/widgets/gestion/form/gestion_form.dart';
import 'package:ambutrack_web/core/widgets/handlers/crud_operation_handler.dart';
import 'package:ambutrack_web/core/widgets/loading/app_loading_indicator.dart';
import 'package:ambutrack_web/features/tablas/tipos_paciente/presentation/bloc/tipo_paciente_bloc.dart';
import 'package:ambutrack_web/features/tablas/tipos_paciente/presentation/bloc/tipo_paciente_event.dart';
import 'package:ambutrack_web/features/tablas/tipos_paciente/presentation/bloc/tipo_paciente_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
      child: GestionFormDialog(
        title: _isEditing ? 'Editar Tipo de Paciente' : 'Nuevo Tipo de Paciente',
        subtitle: _isEditing ? widget.tipoPaciente!.nombre : null,
        icon: Icons.personal_injury_outlined,
        size: GestionFormSize.small,
        formKey: _formKey,
        isEditing: _isEditing,
        isSaving: _isSaving,
        onSave: _onSave,
        children: <Widget>[
          const GestionFormSection(title: 'Datos', first: true),
          GestionFormRow(
            label: 'Nombre',
            required: true,
            child: GestionTextField(
              controller: _nombreController,
              hint: 'Ej: Paciente Geriátrico',
              inputFormatters: <TextInputFormatter>[UpperCaseTextFormatter()],
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
          ),
          GestionFormRow(
            label: 'Descripción',
            multiline: true,
            child: GestionTextField(
              controller: _descripcionController,
              hint: 'Descripción detallada del tipo de paciente',
              maxLines: 3,
              validator: (String? value) {
                if (value != null && value.trim().isNotEmpty && value.trim().length < 5) {
                  return 'La descripción debe tener al menos 5 caracteres';
                }
                return null;
              },
            ),
          ),
          GestionFormRow(
            label: 'Estado',
            child: GestionSwitchField(
              value: _activo,
              text: _activo ? 'Activo' : 'Inactivo',
              onChanged: (bool value) => setState(() => _activo = value),
            ),
          ),
        ],
      ),
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
    unawaited(showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AppLoadingOverlay(
          message: _isEditing ? 'Actualizando tipo de paciente...' : 'Creando tipo de paciente...',
          color: _isEditing ? AppColors.secondary : AppColors.primary,
          icon: _isEditing ? Icons.edit : Icons.add_circle_outline,
        );
      },
    ));

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
