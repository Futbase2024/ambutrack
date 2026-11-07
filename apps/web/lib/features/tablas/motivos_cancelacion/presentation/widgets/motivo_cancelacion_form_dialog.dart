import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/utils/upper_case_text_formatter.dart';
import 'package:ambutrack_web/core/widgets/gestion/form/gestion_form.dart';
import 'package:ambutrack_web/core/widgets/handlers/crud_operation_handler.dart';
import 'package:ambutrack_web/core/widgets/loading/app_loading_indicator.dart';
import 'package:ambutrack_web/features/tablas/motivos_cancelacion/presentation/bloc/motivo_cancelacion_bloc.dart';
import 'package:ambutrack_web/features/tablas/motivos_cancelacion/presentation/bloc/motivo_cancelacion_event.dart';
import 'package:ambutrack_web/features/tablas/motivos_cancelacion/presentation/bloc/motivo_cancelacion_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
      child: GestionFormDialog(
        title: _isEditing ? 'Editar Motivo de Cancelación' : 'Nuevo Motivo de Cancelación',
        subtitle: _isEditing ? widget.motivo!.nombre : null,
        icon: Icons.cancel_outlined,
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
              hint: 'Ej: Paciente rechaza el servicio',
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
              hint: 'Descripción detallada del motivo',
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
