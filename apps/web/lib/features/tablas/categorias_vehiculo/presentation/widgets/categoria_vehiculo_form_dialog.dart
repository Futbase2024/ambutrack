import 'dart:async';

import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/utils/upper_case_text_formatter.dart';
import 'package:ambutrack_web/core/widgets/gestion/form/gestion_form.dart';
import 'package:ambutrack_web/core/widgets/handlers/crud_operation_handler.dart';
import 'package:ambutrack_web/core/widgets/loading/app_loading_indicator.dart';
import 'package:ambutrack_web/features/tablas/categorias_vehiculo/presentation/bloc/categoria_vehiculo_bloc.dart';
import 'package:ambutrack_web/features/tablas/categorias_vehiculo/presentation/bloc/categoria_vehiculo_event.dart';
import 'package:ambutrack_web/features/tablas/categorias_vehiculo/presentation/bloc/categoria_vehiculo_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

/// Diálogo para crear/editar categorías de vehículo
class CategoriaVehiculoFormDialog extends StatefulWidget {
  const CategoriaVehiculoFormDialog({super.key, this.categoriaVehiculo});

  final CategoriaVehiculoEntity? categoriaVehiculo;

  @override
  State<CategoriaVehiculoFormDialog> createState() => _CategoriaVehiculoFormDialogState();
}

class _CategoriaVehiculoFormDialogState extends State<CategoriaVehiculoFormDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late final TextEditingController _nombreController;
  late final TextEditingController _descripcionController;
  late final TextEditingController _ordenController;

  bool _activo = true;
  bool _isSaving = false;
  bool get _isEditing => widget.categoriaVehiculo != null;

  @override
  void initState() {
    super.initState();
    final CategoriaVehiculoEntity? t = widget.categoriaVehiculo;
    _nombreController = TextEditingController(text: t?.nombre ?? '');
    _descripcionController = TextEditingController(text: t?.descripcion ?? '');
    _ordenController = TextEditingController(text: t?.orden?.toString() ?? '');
    _activo = t?.activo ?? true;
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _descripcionController.dispose();
    _ordenController.dispose();
    super.dispose();
  }

  void _onBlocState(BuildContext context, CategoriaVehiculoState state) {
    if (state is CategoriaVehiculoLoaded && _isSaving) {
      CrudOperationHandler.handleSuccess(
        context: context,
        isSaving: _isSaving,
        isEditing: _isEditing,
        entityName: 'Categoría de Vehículo',
        onClose: _resetSaving,
      );
    } else if (state is CategoriaVehiculoError && _isSaving) {
      CrudOperationHandler.handleError(
        context: context,
        isSaving: _isSaving,
        isEditing: _isEditing,
        entityName: 'Categoría de Vehículo',
        errorMessage: state.message,
        onClose: _resetSaving,
      );
    }
  }

  void _resetSaving() {
    if (mounted) {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CategoriaVehiculoBloc, CategoriaVehiculoState>(
      listener: _onBlocState,
      child: GestionFormDialog(
        title: _isEditing ? 'Editar Categoría de Vehículo' : 'Nueva Categoría de Vehículo',
        subtitle: _isEditing ? widget.categoriaVehiculo!.nombre : null,
        icon: Icons.local_shipping_outlined,
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
              hint: 'Ej: SVB, SVA, Colectiva',
              inputFormatters: <TextInputFormatter>[UpperCaseTextFormatter()],
              validator: (String? value) {
                if (value == null || value.isEmpty) {
                  return 'El nombre es obligatorio';
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
              hint: 'Ej: Soporte Vital Básico',
              maxLines: 3,
            ),
          ),
          GestionFormRow(
            label: 'Orden',
            child: GestionIntField(controller: _ordenController),
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

    final String ordenText = _ordenController.text.trim();
    final int? orden = ordenText.isEmpty ? null : int.tryParse(ordenText);

    final CategoriaVehiculoEntity tipo = CategoriaVehiculoEntity(
      id: widget.categoriaVehiculo?.id ?? const Uuid().v4(),
      createdAt: widget.categoriaVehiculo?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
      nombre: _nombreController.text.trim(),
      descripcion: _descripcionController.text.trim().isEmpty ? null : _descripcionController.text.trim(),
      activo: _activo,
      orden: orden,
    );

    setState(() => _isSaving = true);

    unawaited(
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AppLoadingOverlay(
            message: _isEditing ? 'Actualizando categoría de vehículo...' : 'Creando categoría de vehículo...',
            color: AppColors.primary,
            icon: _isEditing ? Icons.edit : Icons.add,
          );
        },
      ),
    );

    if (_isEditing) {
      debugPrint('🔄 Actualizando categoría de vehículo: ${tipo.nombre}');
      context.read<CategoriaVehiculoBloc>().add(CategoriaVehiculoUpdateRequested(tipo));
    } else {
      debugPrint('➕ Creando nuevo categoría de vehículo: ${tipo.nombre}');
      context.read<CategoriaVehiculoBloc>().add(CategoriaVehiculoCreateRequested(tipo));
    }
  }
}
