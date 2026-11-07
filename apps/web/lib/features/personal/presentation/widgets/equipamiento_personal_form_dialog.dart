import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion/form/gestion_form.dart';
import 'package:ambutrack_web/core/widgets/handlers/crud_operation_handler.dart';
import 'package:ambutrack_web/core/widgets/loading/app_loading_indicator.dart';
import 'package:ambutrack_web/features/personal/domain/entities/personal_entity.dart';
import 'package:ambutrack_web/features/personal/presentation/widgets/form/personal_form_options.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../bloc/equipamiento_personal_bloc.dart';
import '../bloc/equipamiento_personal_event.dart';
import '../bloc/equipamiento_personal_state.dart';
import '../bloc/personal_bloc.dart';
import '../bloc/personal_event.dart';
import '../bloc/personal_state.dart';

/// Formulario de equipamiento personal
class EquipamientoPersonalFormDialog extends StatefulWidget {
  const EquipamientoPersonalFormDialog({super.key, this.item});

  final EquipamientoPersonalEntity? item;

  @override
  State<EquipamientoPersonalFormDialog> createState() => _EquipamientoPersonalFormDialogState();
}

class _EquipamientoPersonalFormDialogState extends State<EquipamientoPersonalFormDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _numeroSerieController = TextEditingController();
  final TextEditingController _tallaController = TextEditingController();
  final TextEditingController _observacionesController = TextEditingController();

  String _tipoEquipamiento = 'uniforme';
  String _estado = 'nuevo';
  DateTime? _fechaAsignacion;
  DateTime? _fechaDevolucion;
  bool _activo = true;
  bool _isSaving = false;
  bool _isLoading = true;

  PersonalEntity? _personalSeleccionado;
  List<PersonalEntity> _listaPersonal = <PersonalEntity>[];

  bool get _isEditing => widget.item != null;

  @override
  void initState() {
    super.initState();
    _loadPersonal();

    if (_isEditing) {
      _nombreController.text = widget.item!.nombreEquipamiento;
      _numeroSerieController.text = widget.item!.numeroSerie ?? '';
      _tallaController.text = widget.item!.talla ?? '';
      _observacionesController.text = widget.item!.observaciones ?? '';
      _tipoEquipamiento = widget.item!.tipoEquipamiento;
      _estado = widget.item!.estado ?? 'nuevo';
      _fechaAsignacion = widget.item!.fechaAsignacion;
      _fechaDevolucion = widget.item!.fechaDevolucion;
      _activo = widget.item!.activo;
    } else {
      _fechaAsignacion = DateTime.now();
    }
  }

  Future<void> _loadPersonal() async {
    final PersonalBloc personalBloc = getIt<PersonalBloc>()
    ..add(const PersonalLoadRequested());

    await for (final PersonalState state in personalBloc.stream) {
      if (state is PersonalLoaded) {
        if (mounted) {
          setState(() {
            _listaPersonal = state.personal;
            _isLoading = false;

            // Si es edición, buscar el personal seleccionado
            if (_isEditing) {
              _personalSeleccionado = _listaPersonal
                  .where((PersonalEntity p) => p.id == widget.item!.personalId)
                  .firstOrNull;
            }
          });
        }
        break;
      } else if (state is PersonalError) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
        break;
      }
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _numeroSerieController.dispose();
    _tallaController.dispose();
    _observacionesController.dispose();
    super.dispose();
  }

  static const List<GestionOption<String>> _tipos = <GestionOption<String>>[
    GestionOption<String>('uniforme', 'Uniforme', color: AppColors.primary),
    GestionOption<String>('epi', 'EPI', color: AppColors.warning),
    GestionOption<String>('tecnologico', 'Tecnológico', color: AppColors.info),
    GestionOption<String>('sanitario', 'Sanitario', color: AppColors.success),
  ];

  static const List<GestionOption<String>> _estados = <GestionOption<String>>[
    GestionOption<String>('nuevo', 'Nuevo', color: AppColors.success),
    GestionOption<String>('bueno', 'Bueno', color: AppColors.info),
    GestionOption<String>('regular', 'Regular', color: AppColors.warning),
    GestionOption<String>('malo', 'Malo', color: AppColors.error),
  ];

  void _onBlocState(BuildContext context, EquipamientoPersonalState state) {
    if (!_isSaving) {
      return;
    }
    if (state is EquipamientoPersonalLoaded) {
      CrudOperationHandler.handleSuccess(
        context: context,
        isSaving: _isSaving,
        isEditing: _isEditing,
        entityName: 'Equipamiento',
        onClose: () => setState(() => _isSaving = false),
      );
    } else if (state is EquipamientoPersonalError) {
      CrudOperationHandler.handleError(
        context: context,
        isSaving: _isSaving,
        isEditing: _isEditing,
        entityName: 'Equipamiento',
        errorMessage: state.message,
        onClose: () => setState(() => _isSaving = false),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<EquipamientoPersonalBloc, EquipamientoPersonalState>(
      listener: _onBlocState,
      child: GestionFormDialog(
        title: _isEditing ? 'Editar equipamiento' : 'Nuevo equipamiento',
        subtitle: _isEditing && _personalSeleccionado != null
            ? PersonalFormOptions.etiqueta(_personalSeleccionado!)
            : null,
        icon: Icons.inventory_2_outlined,
        formKey: _formKey,
        isEditing: _isEditing,
        isSaving: _isSaving,
        onSave: _onSave,
        children: <Widget>[
          const GestionFormSection(title: 'Asignación', first: true),
          GestionFormRow(
            label: 'Personal',
            required: true,
            child: GestionSearchField<String>(
              value: _personalSeleccionado?.id,
              required: true,
              loading: _isLoading,
              hint: 'Buscar por nombre o DNI',
              options: PersonalFormOptions.personal(_listaPersonal, conDni: true),
              onChanged: (String? id) => setState(
                () => _personalSeleccionado = PersonalFormOptions.buscar(_listaPersonal, id),
              ),
            ),
          ),
          const GestionFormSection(title: 'Equipamiento'),
          GestionFormColumns(
            children: <Widget>[
              GestionFormRow(
                label: 'Tipo',
                required: true,
                child: GestionDropdownField<String>(
                  value: _tipoEquipamiento,
                  options: _tipos,
                  required: true,
                  onChanged: (String? value) {
                    if (value != null) {
                      setState(() => _tipoEquipamiento = value);
                    }
                  },
                ),
              ),
              GestionFormRow(
                label: 'Estado',
                child: GestionDropdownField<String>(
                  value: _estado,
                  options: _estados,
                  onChanged: (String? value) {
                    if (value != null) {
                      setState(() => _estado = value);
                    }
                  },
                ),
              ),
            ],
          ),
          GestionFormRow(
            label: 'Nombre',
            required: true,
            child: GestionTextField(
              controller: _nombreController,
              hint: 'Nombre del equipamiento',
              validator: (String? value) => value == null || value.isEmpty ? 'Requerido' : null,
            ),
          ),
          GestionFormColumns(
            children: <Widget>[
              GestionFormRow(
                label: 'Talla',
                child: GestionTextField(controller: _tallaController),
              ),
              GestionFormRow(
                label: 'Nº de serie',
                child: GestionTextField(controller: _numeroSerieController),
              ),
            ],
          ),
          GestionFormRow(
            label: 'Observaciones',
            multiline: true,
            child: GestionTextField(controller: _observacionesController, maxLines: 3),
          ),
        ],
      ),
    );
  }

  void _onSave() {
    if (_isLoading || !_formKey.currentState!.validate()) {
      return;
    }

    if (_personalSeleccionado == null) {
      CrudOperationHandler.handleWarning(
        context: context,
        title: 'Personal Requerido',
        message: 'Debes seleccionar el personal al que se asignará el equipamiento.',
      );
      return;
    }

    setState(() => _isSaving = true);

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AppLoadingOverlay(
          message: _isEditing ? 'Actualizando equipamiento...' : 'Creando equipamiento...',
          color: _isEditing ? AppColors.secondary : AppColors.primary,
          icon: _isEditing ? Icons.edit : Icons.add_circle_outline,
        );
      },
    );

    final EquipamientoPersonalEntity entity = EquipamientoPersonalEntity(
      id: _isEditing ? widget.item!.id : const Uuid().v4(),
      personalId: _personalSeleccionado!.id,
      tipoEquipamiento: _tipoEquipamiento,
      nombreEquipamiento: _nombreController.text.trim(),
      fechaAsignacion: _fechaAsignacion!,
      fechaDevolucion: _fechaDevolucion,
      numeroSerie: _numeroSerieController.text.trim().isEmpty ? null : _numeroSerieController.text.trim(),
      talla: _tallaController.text.trim().isEmpty ? null : _tallaController.text.trim(),
      estado: _estado,
      observaciones: _observacionesController.text.trim().isEmpty ? null : _observacionesController.text.trim(),
      activo: _activo,
      createdAt: _isEditing ? widget.item!.createdAt : DateTime.now(),
      updatedAt: DateTime.now(),
    );

    if (_isEditing) {
      context.read<EquipamientoPersonalBloc>().add(EquipamientoPersonalUpdateRequested(entity));
    } else {
      context.read<EquipamientoPersonalBloc>().add(EquipamientoPersonalCreateRequested(entity));
    }
  }
}
