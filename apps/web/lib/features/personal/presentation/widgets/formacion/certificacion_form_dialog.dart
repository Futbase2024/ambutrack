import 'dart:math';

import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/dialogs/app_dialog.dart';
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
    return AppDialog(
      title: _isEditing ? 'Editar Certificación' : 'Nueva Certificación',
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              // Código
              TextFormField(
                controller: _codigoController,
                decoration: const InputDecoration(
                  labelText: 'Código *',
                  hintText: 'Ej: SVA, ACLS, PHTLS',
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.characters,
                inputFormatters: <TextInputFormatter>[
                  UpperCaseTextFormatter(),
                  LengthLimitingTextInputFormatter(10),
                ],
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingresa el código';
                  }
                  if (value.length < 2) {
                    return 'El código debe tener al menos 2 caracteres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Nombre
              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(
                  labelText: 'Nombre *',
                  hintText: 'Ej: Soporte Vital Avanzado',
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.words,
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingresa el nombre';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Descripción
              TextFormField(
                controller: _descripcionController,
                decoration: const InputDecoration(
                  labelText: 'Descripción',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 16),

              // Vigencia y Horas
              Row(
                children: <Widget>[
                  Expanded(
                    child: TextFormField(
                      controller: _vigenciaMesesController,
                      decoration: const InputDecoration(
                        labelText: 'Vigencia (meses) *',
                        border: OutlineInputBorder(),
                        suffixText: 'meses',
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      validator: (String? value) {
                        if (value == null || value.isEmpty) {
                          return 'Requerido';
                        }
                        final int? meses = int.tryParse(value);
                        if (meses == null || meses < 1) {
                          return 'Mínimo 1 mes';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _horasRequeridasController,
                      decoration: const InputDecoration(
                        labelText: 'Horas Req.',
                        border: OutlineInputBorder(),
                        suffixText: 'horas',
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      validator: (String? value) {
                        if (value == null || value.isEmpty) {
                          return 'Requerido';
                        }
                        final int? horas = int.tryParse(value);
                        if (horas == null || horas < 0) {
                          return 'Mínimo 0';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Activa
              SwitchListTile(
                title: const Text('Certificación Activa'),
                subtitle: const Text('Las inactivas no se muestran en los formularios'),
                value: _isActive,
                onChanged: (bool value) {
                  setState(() {
                    _isActive = value;
                  });
                },
              ),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _isSaving ? null : _saveCertificacion,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
          child: _isSaving
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text('Guardar'),
        ),
      ],
    );
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
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      setState(() {
        _isSaving = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  String _generateUuid() {
    return '${DateTime.now().millisecondsSinceEpoch}-${Random().nextInt(10000)}';
  }
}

/// Formatter para convertir texto a mayúsculas
class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}
