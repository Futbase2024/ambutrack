import 'dart:async';

import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/utils/upper_case_text_formatter.dart';
import 'package:ambutrack_web/core/widgets/gestion/form/gestion_form.dart';
import 'package:ambutrack_web/core/widgets/handlers/crud_operation_handler.dart';
import 'package:ambutrack_web/core/widgets/loading/app_loading_indicator.dart';
import 'package:ambutrack_web/features/tablas/protocolos_normativas/presentation/bloc/protocolo_normativa_bloc.dart';
import 'package:ambutrack_web/features/tablas/protocolos_normativas/presentation/bloc/protocolo_normativa_event.dart';
import 'package:ambutrack_web/features/tablas/protocolos_normativas/presentation/bloc/protocolo_normativa_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

/// Diálogo para crear/editar protocolos y normativas
class ProtocoloNormativaFormDialog extends StatefulWidget {
  const ProtocoloNormativaFormDialog({super.key, this.protocolo});

  final ProtocoloNormativaEntity? protocolo;

  @override
  State<ProtocoloNormativaFormDialog> createState() => _ProtocoloNormativaFormDialogState();
}

class _ProtocoloNormativaFormDialogState extends State<ProtocoloNormativaFormDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late final TextEditingController _tituloController;
  late final TextEditingController _codigoController;
  late final TextEditingController _versionController;
  late final TextEditingController _descripcionController;
  late final TextEditingController _urlController;

  CategoriaProtocolo _categoria = CategoriaProtocolo.protocoloAsistencial;
  DateTime? _fechaVigencia;
  bool _activo = true;
  bool _isSaving = false;
  bool get _isEditing => widget.protocolo != null;

  @override
  void initState() {
    super.initState();
    final ProtocoloNormativaEntity? p = widget.protocolo;
    _tituloController = TextEditingController(text: p?.titulo ?? '');
    _codigoController = TextEditingController(text: p?.codigo ?? '');
    _versionController = TextEditingController(text: p?.version ?? '');
    _descripcionController = TextEditingController(text: p?.descripcion ?? '');
    _urlController = TextEditingController(text: p?.urlDocumento ?? '');
    _categoria = p?.categoria ?? CategoriaProtocolo.protocoloAsistencial;
    _fechaVigencia = p?.fechaVigencia;
    _activo = p?.activo ?? true;
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _codigoController.dispose();
    _versionController.dispose();
    _descripcionController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  void _onBlocState(BuildContext context, ProtocoloNormativaState state) {
    if (state is ProtocoloNormativaLoaded && _isSaving) {
      CrudOperationHandler.handleSuccess(
        context: context,
        isSaving: _isSaving,
        isEditing: _isEditing,
        entityName: 'Protocolo',
        onClose: _resetSaving,
      );
    } else if (state is ProtocoloNormativaError && _isSaving) {
      CrudOperationHandler.handleError(
        context: context,
        isSaving: _isSaving,
        isEditing: _isEditing,
        entityName: 'Protocolo',
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

  static String? _validarUrl(String? value) {
    final String v = value?.trim() ?? '';
    if (v.isEmpty) {
      return null;
    }
    final Uri? uri = Uri.tryParse(v);
    final bool valida = uri != null && (uri.scheme == 'http' || uri.scheme == 'https') && uri.host.isNotEmpty;
    return valida ? null : 'Introduce una URL válida (http/https)';
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProtocoloNormativaBloc, ProtocoloNormativaState>(
      listener: _onBlocState,
      child: GestionFormDialog(
        title: _isEditing ? 'Editar Protocolo' : 'Nuevo Protocolo',
        subtitle: _isEditing ? widget.protocolo!.titulo : null,
        icon: Icons.gavel,
        formKey: _formKey,
        isEditing: _isEditing,
        isSaving: _isSaving,
        onSave: _onSave,
        children: <Widget>[
          const GestionFormSection(title: 'Identificación', first: true),
          GestionFormRow(
            label: 'Título',
            required: true,
            child: GestionTextField(
              controller: _tituloController,
              hint: 'Ej: Protocolo de soporte vital avanzado',
              validator: (String? v) => (v == null || v.trim().isEmpty) ? 'El título es obligatorio' : null,
            ),
          ),
          GestionFormRow(
            label: 'Código',
            child: GestionTextField(
              controller: _codigoController,
              hint: 'Ej: PROT-SVA-01',
              inputFormatters: <TextInputFormatter>[UpperCaseTextFormatter()],
            ),
          ),
          GestionFormRow(
            label: 'Categoría',
            required: true,
            child: GestionDropdownField<CategoriaProtocolo>(
              value: _categoria,
              required: true,
              options: CategoriaProtocolo.values
                  .map((CategoriaProtocolo c) => GestionOption<CategoriaProtocolo>(c, c.label))
                  .toList(),
              onChanged: (CategoriaProtocolo? v) => setState(() => _categoria = v ?? _categoria),
            ),
          ),
          GestionFormRow(
            label: 'Versión',
            child: GestionTextField(controller: _versionController, hint: 'Ej: 2.1'),
          ),
          GestionFormRow(
            label: 'Fecha vigencia',
            child: GestionDateField(
              value: _fechaVigencia,
              onChanged: (DateTime? v) => setState(() => _fechaVigencia = v),
            ),
          ),
          const GestionFormSection(title: 'Documento'),
          GestionFormRow(
            label: 'URL documento',
            child: GestionTextField(
              controller: _urlController,
              hint: 'https://...',
              keyboardType: TextInputType.url,
              validator: _validarUrl,
            ),
          ),
          GestionFormRow(
            label: 'Descripción',
            multiline: true,
            child: GestionTextField(controller: _descripcionController, maxLines: 3),
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

  String? _opcional(TextEditingController c) => c.text.trim().isEmpty ? null : c.text.trim();

  void _onSave() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final ProtocoloNormativaEntity protocolo = ProtocoloNormativaEntity(
      id: widget.protocolo?.id ?? const Uuid().v4(),
      createdAt: widget.protocolo?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
      titulo: _tituloController.text.trim(),
      codigo: _opcional(_codigoController),
      categoria: _categoria,
      version: _opcional(_versionController),
      fechaVigencia: _fechaVigencia,
      descripcion: _opcional(_descripcionController),
      urlDocumento: _opcional(_urlController),
      activo: _activo,
    );

    setState(() => _isSaving = true);

    unawaited(
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) => AppLoadingOverlay(
          message: _isEditing ? 'Actualizando protocolo...' : 'Creando protocolo...',
          color: _isEditing ? AppColors.secondary : AppColors.primary,
          icon: _isEditing ? Icons.edit : Icons.add_circle_outline,
        ),
      ),
    );

    final ProtocoloNormativaBloc bloc = context.read<ProtocoloNormativaBloc>();
    if (_isEditing) {
      bloc.add(ProtocoloNormativaUpdateRequested(protocolo));
    } else {
      bloc.add(ProtocoloNormativaCreateRequested(protocolo));
    }
  }
}
