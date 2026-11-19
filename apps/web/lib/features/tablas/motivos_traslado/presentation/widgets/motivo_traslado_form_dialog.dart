import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/utils/upper_case_text_formatter.dart';
import 'package:ambutrack_web/core/widgets/gestion/form/gestion_form.dart';
import 'package:ambutrack_web/core/widgets/handlers/crud_operation_handler.dart';
import 'package:ambutrack_web/core/widgets/loading/app_loading_indicator.dart';
import 'package:ambutrack_web/features/tablas/motivos_traslado/presentation/bloc/motivo_traslado_bloc.dart';
import 'package:ambutrack_web/features/tablas/motivos_traslado/presentation/bloc/motivo_traslado_event.dart';
import 'package:ambutrack_web/features/tablas/motivos_traslado/presentation/bloc/motivo_traslado_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
      child: GestionFormDialog(
        title: _isEditing ? 'Editar Motivo de Traslado' : 'Nuevo Motivo de Traslado',
        subtitle: _isEditing ? widget.motivo!.nombre : null,
        icon: Icons.assignment_outlined,
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
              hint: 'Ej: Consulta médica',
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
            required: true,
            multiline: true,
            child: GestionTextField(
              controller: _descripcionController,
              hint: 'Descripción del motivo de traslado',
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
