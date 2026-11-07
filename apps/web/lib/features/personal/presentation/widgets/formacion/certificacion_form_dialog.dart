import 'dart:math';

import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/core/utils/upper_case_text_formatter.dart';
import 'package:ambutrack_web/core/widgets/dialogs/result_dialog.dart';
import 'package:ambutrack_web/core/widgets/gestion/form/gestion_form.dart';
import 'package:ambutrack_web/core/widgets/handlers/crud_operation_handler.dart';
import 'package:ambutrack_web/features/personal/domain/repositories/certificacion_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Diálogo para crear/editar certificaciones
class CertificacionFormDialog extends StatefulWidget {
  const CertificacionFormDialog({super.key, this.item});

  final CertificacionEntity? item;

  @override
  State<CertificacionFormDialog> createState() => _CertificacionFormDialogState();
}

class _CertificacionFormDialogState extends State<CertificacionFormDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _codigoController = TextEditingController();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();
  final TextEditingController _vigenciaMesesController = TextEditingController(text: '12');
  final TextEditingController _horasRequeridasController = TextEditingController(text: '0');

  bool _isSaving = false;
  bool _isActive = true;

  bool get _isEditing => widget.item != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _codigoController.text = widget.item!.codigo;
      _nombreController.text = widget.item!.nombre;
      _descripcionController.text = widget.item!.descripcion ?? '';
      _vigenciaMesesController.text = widget.item!.vigenciaMeses.toString();
      _horasRequeridasController.text = widget.item!.horasRequeridas.toString();
      _isActive = widget.item!.activa;
    }
  }

  @override
  void dispose() {
    _codigoController.dispose();
    _nombreController.dispose();
    _descripcionController.dispose();
    _vigenciaMesesController.dispose();
    _horasRequeridasController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestionFormDialog(
      title: _isEditing ? 'Editar certificación' : 'Nueva certificación',
      subtitle: _isEditing ? '${widget.item!.codigo} · ${widget.item!.nombre}' : null,
      icon: Icons.workspace_premium_outlined,
      formKey: _formKey,
      isEditing: _isEditing,
      isSaving: _isSaving,
      onSave: _saveCertificacion,
      children: <Widget>[
        const GestionFormSection(title: 'Datos de la certificación', first: true),
        GestionFormColumns(
          children: <Widget>[
            GestionFormRow(
              label: 'Código',
              required: true,
              child: GestionTextField(
                controller: _codigoController,
                hint: 'Ej: SVA, ACLS',
                inputFormatters: <TextInputFormatter>[
                  UpperCaseTextFormatter(),
                  LengthLimitingTextInputFormatter(10),
                ],
                validator: _validarCodigo,
              ),
            ),
            GestionFormRow(
              label: 'Estado',
              child: GestionSwitchField(
                value: _isActive,
                text: _isActive ? 'Activa' : 'Inactiva',
                onChanged: (bool value) => setState(() => _isActive = value),
              ),
            ),
          ],
        ),
        GestionFormRow(
          label: 'Nombre',
          required: true,
          child: GestionTextField(
            controller: _nombreController,
            hint: 'Ej: Soporte Vital Avanzado',
            validator: (String? value) => (value == null || value.isEmpty) ? 'Ingresa el nombre' : null,
          ),
        ),
        GestionFormRow(
          label: 'Descripción',
          multiline: true,
          child: GestionTextField(controller: _descripcionController, maxLines: 3),
        ),
        const GestionFormSection(title: 'Requisitos'),
        GestionFormColumns(
          children: <Widget>[
            GestionFormRow(
              label: 'Vigencia',
              required: true,
              child: _NumeroField(
                controller: _vigenciaMesesController,
                unit: 'meses',
                validator: (String? v) => _validarMinimo(v, 1, 'Mínimo 1 mes'),
              ),
            ),
            GestionFormRow(
              label: 'Horas req.',
              required: true,
              child: _NumeroField(
                controller: _horasRequeridasController,
                unit: 'horas',
                validator: (String? v) => _validarMinimo(v, 0, 'Mínimo 0'),
              ),
            ),
          ],
        ),
        const Text(
          'Las certificaciones inactivas no se muestran en los formularios.',
          style: GestionFormStyle.hint,
        ),
      ],
    );
  }

  static String? _validarCodigo(String? value) {
    if (value == null || value.isEmpty) {
      return 'Ingresa el código';
    }
    if (value.length < 2) {
      return 'El código debe tener al menos 2 caracteres';
    }
    return null;
  }

  static String? _validarMinimo(String? value, int minimo, String mensaje) {
    if (value == null || value.isEmpty) {
      return 'Requerido';
    }
    final int? n = int.tryParse(value);
    if (n == null || n < minimo) {
      return mensaje;
    }
    return null;
  }

  Future<void> _saveCertificacion() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final CertificacionRepository repository = getIt<CertificacionRepository>();

      final CertificacionEntity certificacion = CertificacionEntity(
        id: _isEditing ? widget.item!.id : _generateUuid(),
        codigo: _codigoController.text.toUpperCase(),
        nombre: _nombreController.text,
        descripcion: _descripcionController.text.isEmpty ? null : _descripcionController.text,
        vigenciaMeses: int.parse(_vigenciaMesesController.text),
        horasRequeridas: int.parse(_horasRequeridasController.text),
        activa: _isActive,
        createdAt: _isEditing ? widget.item!.createdAt : DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (_isEditing) {
        await repository.update(certificacion);
      } else {
        await repository.create(certificacion);
      }

      if (mounted) {
        await CrudOperationHandler.handleSuccess(
          context: context,
          isSaving: false,
          isEditing: _isEditing,
          entityName: 'Certificación',
        );
      }
    } catch (e) {
      debugPrint('❌ CertificacionFormDialog: $e');
      if (!mounted) {
        return;
      }
      setState(() {
        _isSaving = false;
      });
      await showResultDialog(
        context: context,
        title: 'Error al Guardar',
        message: _isEditing ? 'No se pudo actualizar la certificación.' : 'No se pudo crear la certificación.',
        details: e.toString(),
        type: ResultType.error,
      );
    }
  }

  String _generateUuid() {
    return '${DateTime.now().millisecondsSinceEpoch}-${Random().nextInt(10000)}';
  }
}

/// Entero sin signo alineado a la derecha con unidad
class _NumeroField extends StatelessWidget {
  const _NumeroField({required this.controller, required this.unit, required this.validator});

  final TextEditingController controller;
  final String unit;
  final FormFieldValidator<String> validator;

  @override
  Widget build(BuildContext context) {
    return GestionTextField(
      controller: controller,
      hint: '0',
      suffixText: unit,
      textAlign: TextAlign.end,
      keyboardType: TextInputType.number,
      inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
      validator: validator,
    );
  }
}
