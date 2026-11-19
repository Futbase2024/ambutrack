import 'dart:async';

import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/utils/upper_case_text_formatter.dart';
import 'package:ambutrack_web/core/widgets/gestion/form/gestion_form.dart';
import 'package:ambutrack_web/core/widgets/handlers/crud_operation_handler.dart';
import 'package:ambutrack_web/core/widgets/loading/app_loading_indicator.dart';
import 'package:ambutrack_web/features/tablas/localidades/presentation/bloc/localidad_bloc.dart';
import 'package:ambutrack_web/features/tablas/localidades/presentation/bloc/localidad_event.dart';
import 'package:ambutrack_web/features/tablas/localidades/presentation/bloc/localidad_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Diálogo para crear/editar localidades
class LocalidadFormDialog extends StatefulWidget {
  const LocalidadFormDialog({super.key, this.localidad});

  final LocalidadEntity? localidad;

  @override
  State<LocalidadFormDialog> createState() => _LocalidadFormDialogState();
}

class _LocalidadFormDialogState extends State<LocalidadFormDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late TextEditingController _codigoController;
  late TextEditingController _nombreController;
  late TextEditingController _codigoPostalController;


  List<ProvinciaEntity> _provincias = <ProvinciaEntity>[];
  String? _provinciaId;
  bool _isSaving = false;
  bool _isLoadingProvincias = false;
  bool get _isEditing => widget.localidad != null;

  @override
  void initState() {
    super.initState();
    final LocalidadEntity? l = widget.localidad;

    _codigoController = TextEditingController(text: l?.codigo ?? '');
    _nombreController = TextEditingController(text: l?.nombre ?? '');
    _codigoPostalController = TextEditingController(text: l?.codigoPostal ?? '');


    _loadProvincias();
  }

  Future<void> _loadProvincias() async {
    setState(() {
      _isLoadingProvincias = true;
    });

    try {
      final ProvinciaDataSource dataSource = getIt<ProvinciaDataSource>();
      final List<ProvinciaEntity> provincias = await dataSource.getAll();

      if (mounted) {
        setState(() {
          _provincias = provincias;
          _isLoadingProvincias = false;

          // Si estamos editando, establecer el ID de la provincia desde la localidad
          if (widget.localidad?.provinciaId != null) {
            _provinciaId = widget.localidad!.provinciaId;
          }
        });
      }
    } catch (e) {
      debugPrint('❌ Error al cargar provincias: $e');
      if (mounted) {
        setState(() {
          _isLoadingProvincias = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _codigoController.dispose();
    _nombreController.dispose();
    _codigoPostalController.dispose();
    super.dispose();
  }

  void _onBlocState(BuildContext context, LocalidadState state) {
    if (!_isSaving) {
      return;
    }
    if (state is LocalidadLoaded) {
      debugPrint('✅ LocalidadFormDialog: Localidad guardada exitosamente, cerrando diálogo');
      CrudOperationHandler.handleSuccess(
        context: context,
        isSaving: _isSaving,
        isEditing: _isEditing,
        entityName: 'Localidad',
        onClose: _resetSaving,
      );
    } else if (state is LocalidadError) {
      debugPrint('❌ LocalidadFormDialog: Error al guardar localidad - ${state.message}');
      CrudOperationHandler.handleError(
        context: context,
        isSaving: _isSaving,
        isEditing: _isEditing,
        entityName: 'Localidad',
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
    return BlocListener<LocalidadBloc, LocalidadState>(
      listener: _onBlocState,
      child: GestionFormDialog(
        title: _isEditing ? 'Editar Localidad' : 'Nueva Localidad',
        subtitle: _isEditing ? widget.localidad!.nombre : null,
        icon: Icons.location_on_outlined,
        size: GestionFormSize.small,
        formKey: _formKey,
        isEditing: _isEditing,
        isSaving: _isSaving,
        onSave: _onSave,
        children: <Widget>[
          const GestionFormSection(title: 'Datos', first: true),
          GestionFormRow(
            label: 'Código',
            child: GestionTextField(controller: _codigoController, hint: 'Ej: 28001'),
          ),
          GestionFormRow(
            label: 'Nombre',
            required: true,
            child: GestionTextField(
              controller: _nombreController,
              hint: 'Ej: Alcalá de Henares',
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
            label: 'Código postal',
            child: GestionTextField(controller: _codigoPostalController, hint: 'Ej: 28801'),
          ),
          const GestionFormSection(title: 'Ubicación'),
          GestionFormRow(
            label: 'Provincia',
            child: GestionSearchField<String>(
              value: _provinciaId,
              hint: 'Selecciona una provincia',
              loading: _isLoadingProvincias,
              options: _provincias
                  .map((ProvinciaEntity provincia) => GestionOption<String>(provincia.id, provincia.nombre))
                  .toList(),
              onChanged: (String? value) => setState(() => _provinciaId = value),
            ),
          ),
        ],
      ),
    );
  }

  void _onSave() {
    if (!_formKey.currentState!.validate()) {
      debugPrint('❌ LocalidadFormDialog: Validación fallida');
      return;
    }

    debugPrint('👍 LocalidadFormDialog: Validación exitosa, guardando localidad...');

    final String codigoText = _codigoController.text.trim();
    final String codigoPostalText = _codigoPostalController.text.trim();

    final LocalidadEntity localidad = LocalidadEntity(
      id: widget.localidad?.id ?? '',
      codigo: codigoText.isEmpty ? null : codigoText,
      nombre: _nombreController.text.trim(),
      provinciaId: _provinciaId, // Guardar el ID de la provincia
      codigoPostal: codigoPostalText.isEmpty ? null : codigoPostalText,
      createdAt: widget.localidad?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    debugPrint('📦 LocalidadFormDialog: ${_isEditing ? "Actualizando" : "Creando"} localidad - ${localidad.nombre}');

    // Mostrar loading overlay
    setState(() {
      _isSaving = true;
    });

    unawaited(showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AppLoadingOverlay(
          message: _isEditing ? 'Actualizando localidad...' : 'Creando localidad...',
          color: _isEditing ? AppColors.secondary : AppColors.primary,
          icon: _isEditing ? Icons.edit : Icons.add_location_alt,
        );
      },
    ));

    if (_isEditing) {
      debugPrint('📝 LocalidadFormDialog: Enviando evento LocalidadUpdateRequested al BLoC...');
      context.read<LocalidadBloc>().add(LocalidadUpdateRequested(localidad));
    } else {
      debugPrint('➕ LocalidadFormDialog: Enviando evento LocalidadCreateRequested al BLoC...');
      context.read<LocalidadBloc>().add(LocalidadCreateRequested(localidad));
    }
  }
}
