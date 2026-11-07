import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/core/utils/crud_operation_handler.dart';
import 'package:ambutrack_web/core/utils/upper_case_text_formatter.dart';
import 'package:ambutrack_web/core/widgets/gestion/form/gestion_form.dart';
import 'package:ambutrack_web/features/tablas/provincias/presentation/bloc/provincia_bloc.dart';
import 'package:ambutrack_web/features/tablas/provincias/presentation/bloc/provincia_event.dart';
import 'package:ambutrack_web/features/tablas/provincias/presentation/bloc/provincia_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Diálogo para crear/editar provincias
class ProvinciaFormDialog extends StatefulWidget {
  const ProvinciaFormDialog({super.key, this.provincia});

  final ProvinciaEntity? provincia;

  @override
  State<ProvinciaFormDialog> createState() => _ProvinciaFormDialogState();
}

class _ProvinciaFormDialogState extends State<ProvinciaFormDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late TextEditingController _codigoController;
  late TextEditingController _nombreController;


  List<ComunidadAutonomaEntity> _comunidades = <ComunidadAutonomaEntity>[];
  String? _comunidadId;
  bool _isSaving = false;
  bool _isLoadingComunidades = false;
  bool get _isEditing => widget.provincia != null;

  @override
  void initState() {
    super.initState();
    final ProvinciaEntity? p = widget.provincia;

    _codigoController = TextEditingController(text: p?.codigo ?? '');
    _nombreController = TextEditingController(text: p?.nombre ?? '');


    _loadComunidades();
  }

  Future<void> _loadComunidades() async {
    setState(() {
      _isLoadingComunidades = true;
    });

    try {
      final ComunidadAutonomaDataSource dataSource = getIt<ComunidadAutonomaDataSource>();
      final List<ComunidadAutonomaEntity> comunidades = await dataSource.getAll();

      if (mounted) {
        setState(() {
          _comunidades = comunidades;
          _isLoadingComunidades = false;

          // Si estamos editando, establecer el ID de la comunidad desde la provincia
          if (widget.provincia?.comunidadId != null) {
            _comunidadId = widget.provincia!.comunidadId;
          }
        });
      }
    } catch (e) {
      debugPrint('❌ Error al cargar comunidades autónomas: $e');
      if (mounted) {
        setState(() {
          _isLoadingComunidades = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _codigoController.dispose();
    _nombreController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProvinciaBloc, ProvinciaState>(
      listener: (BuildContext context, ProvinciaState state) {
        if (state is ProvinciaLoaded) {
          CrudOperationHandler.handleSuccess(
            context: context,
            isSaving: _isSaving,
            isEditing: _isEditing,
            entityName: 'Provincia',
            onComplete: () {
              if (mounted) {
                setState(() => _isSaving = false);
              }
            },
          );
        } else if (state is ProvinciaError) {
          CrudOperationHandler.handleError(
            context: context,
            isSaving: _isSaving,
            errorMessage: state.message,
            onComplete: () {
              if (mounted) {
                setState(() => _isSaving = false);
              }
            },
          );
        }
      },
      child: GestionFormDialog(
        title: _isEditing ? 'Editar Provincia' : 'Nueva Provincia',
        subtitle: _isEditing ? widget.provincia!.nombre : null,
        icon: Icons.location_city_outlined,
        size: GestionFormSize.small,
        formKey: _formKey,
        isEditing: _isEditing,
        isSaving: _isSaving,
        onSave: _onSave,
        children: <Widget>[
          const GestionFormSection(title: 'Datos', first: true),
          GestionFormRow(
            label: 'Código',
            child: GestionTextField(controller: _codigoController, hint: 'Ej: 01'),
          ),
          GestionFormRow(
            label: 'Nombre',
            required: true,
            child: GestionTextField(
              controller: _nombreController,
              hint: 'Ej: Madrid',
              inputFormatters: <TextInputFormatter>[UpperCaseTextFormatter()],
              validator: (String? value) {
                if (value == null || value.isEmpty) {
                  return 'El nombre es obligatorio';
                }
                return null;
              },
            ),
          ),
          const GestionFormSection(title: 'Ubicación'),
          GestionFormRow(
            label: 'Comunidad',
            child: GestionSearchField<String>(
              value: _comunidadId,
              hint: 'Selecciona una comunidad',
              loading: _isLoadingComunidades,
              options: _comunidades
                  .map(
                    (ComunidadAutonomaEntity comunidad) =>
                        GestionOption<String>(comunidad.id, comunidad.nombre),
                  )
                  .toList(),
              onChanged: (String? value) => setState(() => _comunidadId = value),
            ),
          ),
        ],
      ),
    );
  }

  void _onSave() {
    if (!_formKey.currentState!.validate()) {
      debugPrint('❌ ProvinciaFormDialog: Validación fallida');
      return;
    }

    debugPrint('👍 ProvinciaFormDialog: Validación exitosa, guardando provincia...');

    final String codigoText = _codigoController.text.trim();

    final ProvinciaEntity provincia = ProvinciaEntity(
      id: widget.provincia?.id ?? '',
      codigo: codigoText.isEmpty ? null : codigoText,
      nombre: _nombreController.text.trim(),
      comunidadId: _comunidadId, // Guardar el ID de la comunidad
      createdAt: widget.provincia?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    debugPrint('📦 ProvinciaFormDialog: ${_isEditing ? "Actualizando" : "Creando"} provincia - ${provincia.nombre}');

    // Mostrar loading overlay
    setState(() {
      _isSaving = true;
    });

    CrudOperationHandler.showLoadingOverlay(
      context: context,
      isEditing: _isEditing,
      entityName: 'Provincia',
    );

    if (_isEditing) {
      debugPrint('📝 ProvinciaFormDialog: Enviando evento ProvinciaUpdateRequested al BLoC...');
      context.read<ProvinciaBloc>().add(ProvinciaUpdateRequested(provincia));
    } else {
      debugPrint('➕ ProvinciaFormDialog: Enviando evento ProvinciaCreateRequested al BLoC...');
      context.read<ProvinciaBloc>().add(ProvinciaCreateRequested(provincia));
    }
  }
}
