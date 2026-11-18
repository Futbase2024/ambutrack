import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion/form/gestion_form.dart';
import 'package:ambutrack_web/core/widgets/handlers/crud_operation_handler.dart';
import 'package:ambutrack_web/core/widgets/loading/app_loading_indicator.dart';
import 'package:ambutrack_web/features/personal/domain/entities/personal_entity.dart';
import 'package:ambutrack_web/features/personal/domain/repositories/personal_repository.dart';
import 'package:ambutrack_web/features/personal/presentation/bloc/documento_personal_bloc.dart';
import 'package:ambutrack_web/features/personal/presentation/bloc/documento_personal_event.dart';
import 'package:ambutrack_web/features/personal/presentation/bloc/documento_personal_state.dart';
import 'package:ambutrack_web/features/personal/presentation/widgets/form/personal_form_options.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

/// Formulario de alta/edición de un documento del personal
class DocumentoPersonalFormDialog extends StatefulWidget {
  const DocumentoPersonalFormDialog({super.key, this.item});

  final DocumentoPersonalEntity? item;

  @override
  State<DocumentoPersonalFormDialog> createState() => _DocumentoPersonalFormDialogState();
}

class _DocumentoPersonalFormDialogState extends State<DocumentoPersonalFormDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _nombre = TextEditingController(text: widget.item?.nombre);
  late final TextEditingController _numero = TextEditingController(text: widget.item?.numero);
  late final TextEditingController _archivo = TextEditingController(text: widget.item?.archivoUrl);
  late final TextEditingController _observaciones = TextEditingController(text: widget.item?.observaciones);

  late String? _personalId = widget.item?.personalId;
  late TipoDocumentoPersonal _tipo = widget.item?.tipo ?? TipoDocumentoPersonal.dni;
  late DateTime? _fechaEmision = widget.item?.fechaEmision;
  late DateTime? _fechaCaducidad = widget.item?.fechaCaducidad;

  List<PersonalEntity> _personal = <PersonalEntity>[];
  bool _isLoading = true;
  bool _isSaving = false;

  bool get _isEditing => widget.item != null;

  static final List<GestionOption<TipoDocumentoPersonal>> _tipos = TipoDocumentoPersonal.values
      .map((TipoDocumentoPersonal t) => GestionOption<TipoDocumentoPersonal>(t, t.label))
      .toList();

  @override
  void initState() {
    super.initState();
    _loadPersonal();
  }

  @override
  void dispose() {
    _nombre.dispose();
    _numero.dispose();
    _archivo.dispose();
    _observaciones.dispose();
    super.dispose();
  }

  Future<void> _loadPersonal() async {
    try {
      final List<PersonalEntity> personal = await getIt<PersonalRepository>().getAll();
      if (mounted) {
        setState(() => _personal = personal);
      }
    } catch (e) {
      debugPrint('❌ DocumentoPersonalFormDialog: error al cargar personal: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _onBlocState(BuildContext context, DocumentoPersonalState state) {
    if (!_isSaving) {
      return;
    }
    if (state is DocumentoPersonalLoaded) {
      CrudOperationHandler.handleSuccess(
        context: context,
        isSaving: _isSaving,
        isEditing: _isEditing,
        entityName: 'Documento',
        onClose: () => setState(() => _isSaving = false),
      );
    } else if (state is DocumentoPersonalError) {
      CrudOperationHandler.handleError(
        context: context,
        isSaving: _isSaving,
        isEditing: _isEditing,
        entityName: 'Documento',
        errorMessage: state.message,
        onClose: () => setState(() => _isSaving = false),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<DocumentoPersonalBloc, DocumentoPersonalState>(
      listener: _onBlocState,
      child: GestionFormDialog(
        title: _isEditing ? 'Editar documento' : 'Nuevo documento',
        subtitle: _isEditing ? widget.item!.personalNombre : null,
        icon: Icons.folder_outlined,
        formKey: _formKey,
        isEditing: _isEditing,
        isSaving: _isSaving,
        onSave: _onSave,
        children: <Widget>[
          const GestionFormSection(title: 'Trabajador', first: true),
          GestionFormRow(
            label: 'Personal',
            required: true,
            child: GestionSearchField<String>(
              value: _personalId,
              required: true,
              loading: _isLoading,
              hint: 'Buscar por nombre o DNI',
              options: PersonalFormOptions.personal(_personal, conDni: true),
              onChanged: (String? id) => setState(() => _personalId = id),
            ),
          ),
          const GestionFormSection(title: 'Documento'),
          GestionFormColumns(
            children: <Widget>[
              GestionFormRow(
                label: 'Tipo',
                required: true,
                child: GestionDropdownField<TipoDocumentoPersonal>(
                  value: _tipo,
                  options: _tipos,
                  required: true,
                  onChanged: (TipoDocumentoPersonal? v) => setState(() => _tipo = v ?? _tipo),
                ),
              ),
              GestionFormRow(label: 'Número', child: GestionTextField(controller: _numero)),
            ],
          ),
          GestionFormRow(
            label: 'Descripción',
            child: GestionTextField(controller: _nombre, hint: 'P. ej. Carnet C1, Técnico en Emergencias...'),
          ),
          GestionFormColumns(
            children: <Widget>[
              GestionFormRow(
                label: 'F. emisión',
                child: GestionDateField(
                  value: _fechaEmision,
                  onChanged: (DateTime? v) => setState(() => _fechaEmision = v),
                ),
              ),
              GestionFormRow(
                label: 'F. caducidad',
                child: GestionDateField(
                  value: _fechaCaducidad,
                  onChanged: (DateTime? v) => setState(() => _fechaCaducidad = v),
                ),
              ),
            ],
          ),
          GestionFormRow(
            label: 'URL archivo',
            child: GestionTextField(controller: _archivo, hint: 'https://... (opcional)'),
          ),
          GestionFormRow(
            label: 'Observaciones',
            multiline: true,
            child: GestionTextField(controller: _observaciones, maxLines: 3),
          ),
        ],
      ),
    );
  }

  String? _text(TextEditingController c) => c.text.trim().isEmpty ? null : c.text.trim();

  DocumentoPersonalEntity _buildEntity() {
    return DocumentoPersonalEntity(
      id: widget.item?.id ?? const Uuid().v4(),
      empresaId: widget.item?.empresaId ?? '',
      personalId: _personalId!,
      tipo: _tipo,
      nombre: _text(_nombre),
      numero: _text(_numero),
      fechaEmision: _fechaEmision,
      fechaCaducidad: _fechaCaducidad,
      archivoUrl: _text(_archivo),
      observaciones: _text(_observaciones),
    );
  }

  void _onSave() {
    if (_isLoading || !_formKey.currentState!.validate() || _personalId == null) {
      return;
    }
    final DateTime? emision = _fechaEmision;
    final DateTime? caducidad = _fechaCaducidad;
    if (emision != null && caducidad != null && caducidad.isBefore(emision)) {
      CrudOperationHandler.handleWarning(
        context: context,
        title: 'Fechas no válidas',
        message: 'La fecha de caducidad no puede ser anterior a la fecha de emisión.',
      );
      return;
    }

    setState(() => _isSaving = true);
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext _) => AppLoadingOverlay(
        message: _isEditing ? 'Actualizando documento...' : 'Creando documento...',
        color: _isEditing ? AppColors.secondary : AppColors.primary,
        icon: _isEditing ? Icons.edit : Icons.add_circle_outline,
      ),
    );
    final DocumentoPersonalEntity entity = _buildEntity();
    context.read<DocumentoPersonalBloc>().add(_isEditing ? DocumentoPersonalUpdateRequested(entity) : DocumentoPersonalCreateRequested(entity));
  }
}
