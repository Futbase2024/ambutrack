// Formulario compacto para equipamiento personal - Ver historial_medico_form_dialog.dart para referencia completa
import 'package:ambutrack_core/ambutrack_core.dart' hide PersonalEntity;
import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/core/widgets/buttons/app_button.dart';
import 'package:ambutrack_web/core/widgets/dialogs/app_dialog.dart';
import 'package:ambutrack_web/core/widgets/dropdowns/app_searchable_dropdown.dart';
import 'package:ambutrack_web/core/widgets/handlers/crud_operation_handler.dart';
import 'package:ambutrack_web/core/widgets/loading/app_loading_indicator.dart';
import 'package:ambutrack_web/features/personal/domain/entities/personal_entity.dart';
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

  @override
  Widget build(BuildContext context) {
    return BlocListener<EquipamientoPersonalBloc, EquipamientoPersonalState>(
      listener: (BuildContext context, EquipamientoPersonalState state) {
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
      },
      child: AppDialog(
        title: _isEditing ? 'Editar Equipamiento' : 'Agregar Equipamiento',
        content: _isLoading
            ? const Center(
                child: AppLoadingIndicator(
                  message: 'Cargando datos...',
                  size: 100,
                ),
              )
            : Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      // Personal (combo con búsqueda)
                      AppSearchableDropdown<PersonalEntity>(
                        value: _personalSeleccionado,
                        label: 'Personal *',
                        hint: 'Selecciona el personal',
                        prefixIcon: Icons.person,
                        searchHint: 'Buscar por nombre, DNI...',
                        items: _listaPersonal
                            .map(
                              (PersonalEntity p) => AppSearchableDropdownItem<PersonalEntity>(
                                value: p,
                                label: '${p.nombre} ${p.apellidos}${p.dni != null && p.dni!.isNotEmpty ? ' (${p.dni})' : ''}',
                                icon: Icons.person,
                                iconColor: p.activo ? AppColors.success : AppColors.gray400,
                              ),
                            )
                            .toList(),
                        onChanged: (PersonalEntity? value) {
                          setState(() {
                            _personalSeleccionado = value;
                          });
                        },
                        displayStringForOption: (PersonalEntity p) =>
                            '${p.nombre} ${p.apellidos}${p.dni != null && p.dni!.isNotEmpty ? ' (${p.dni})' : ''}',
                      ),
                      const SizedBox(height: AppSizes.spacing),

                      // Tipo de equipamiento
                      DropdownButtonFormField<String>(
                        initialValue: _tipoEquipamiento,
                        decoration: const InputDecoration(labelText: 'Tipo *'),
                        items: const <DropdownMenuItem<String>>[
                          DropdownMenuItem<String>(value: 'uniforme', child: Text('Uniforme')),
                          DropdownMenuItem<String>(value: 'epi', child: Text('EPI')),
                          DropdownMenuItem<String>(value: 'tecnologico', child: Text('Tecnológico')),
                          DropdownMenuItem<String>(value: 'sanitario', child: Text('Sanitario')),
                        ],
                        onChanged: (String? value) {
                          if (value != null) {
                            setState(() => _tipoEquipamiento = value);
                          }
                        },
                      ),
                      const SizedBox(height: AppSizes.spacing),

                      // Nombre del equipamiento
                      TextFormField(
                        controller: _nombreController,
                        decoration: const InputDecoration(labelText: 'Nombre del Equipamiento *'),
                        validator: (String? value) => value == null || value.isEmpty ? 'Requerido' : null,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: AppSizes.spacing),

                      // Talla
                      TextFormField(
                        controller: _tallaController,
                        decoration: const InputDecoration(labelText: 'Talla'),
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: AppSizes.spacing),

                      // Número de serie
                      TextFormField(
                        controller: _numeroSerieController,
                        decoration: const InputDecoration(labelText: 'Número de Serie'),
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: AppSizes.spacing),

                      // Estado
                      DropdownButtonFormField<String>(
                        initialValue: _estado,
                        decoration: const InputDecoration(labelText: 'Estado'),
                        items: const <DropdownMenuItem<String>>[
                          DropdownMenuItem<String>(value: 'nuevo', child: Text('Nuevo')),
                          DropdownMenuItem<String>(value: 'bueno', child: Text('Bueno')),
                          DropdownMenuItem<String>(value: 'regular', child: Text('Regular')),
                          DropdownMenuItem<String>(value: 'malo', child: Text('Malo')),
                        ],
                        onChanged: (String? value) {
                          if (value != null) {
                            setState(() => _estado = value);
                          }
                        },
                      ),
                      const SizedBox(height: AppSizes.spacing),

                      // Observaciones
                      TextFormField(
                        controller: _observacionesController,
                        decoration: const InputDecoration(labelText: 'Observaciones'),
                        maxLines: 3,
                        textInputAction: TextInputAction.newline,
                      ),
                    ],
                  ),
                ),
              ),
        actions: <Widget>[
          AppButton(
            onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
            label: 'Cancelar',
            variant: AppButtonVariant.text,
          ),
          AppButton(
            onPressed: _isSaving || _isLoading ? null : _onSave,
            label: _isEditing ? 'Actualizar' : 'Guardar',
            icon: _isEditing ? Icons.save : Icons.add,
          ),
        ],
      ),
    );
  }

  void _onSave() {
    if (!_formKey.currentState!.validate()) {
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
