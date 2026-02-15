import 'dart:math';

import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/dialogs/app_dialog.dart';
import 'package:ambutrack_web/features/personal/domain/repositories/certificacion_repository.dart';
import 'package:ambutrack_web/features/personal/domain/repositories/curso_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Diálogo para crear/editar cursos
class CursoFormDialog extends StatefulWidget {
  const CursoFormDialog({super.key, this.item});

  final CursoEntity? item;

  @override
  State<CursoFormDialog> createState() => _CursoFormDialogState();
}

class _CursoFormDialogState extends State<CursoFormDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();
  final TextEditingController _duracionHorasController = TextEditingController(text: '0');

  bool _isSaving = false;
  bool _isActive = true;
  String _tipoCurso = 'presencial';

  // Para asociar certificaciones
  final List<CertificacionEntity> _certificaciones = <CertificacionEntity>[];
  final List<String> _certificacionesSeleccionadas = <String>[];

  bool get _isEditing => widget.item != null;

  @override
  void initState() {
    super.initState();
    _loadCertificaciones();

    if (_isEditing) {
      _nombreController.text = widget.item!.nombre;
      _descripcionController.text = widget.item!.descripcion ?? '';
      _duracionHorasController.text = widget.item!.duracionHoras.toString();
      _tipoCurso = widget.item!.tipo;
      _isActive = widget.item!.activo;
      _certificacionesSeleccionadas.addAll(widget.item!.certificaciones);
    }
  }

  Future<void> _loadCertificaciones() async {
    try {
      final List<CertificacionEntity> certificaciones = await getIt<CertificacionRepository>().getActivas();
      setState(() {
        _certificaciones.addAll(certificaciones);
      });
    } catch (e) {
      debugPrint('Error al cargar certificaciones: $e');
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _descripcionController.dispose();
    _duracionHorasController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppDialog(
      title: _isEditing ? 'Editar Curso' : 'Nuevo Curso',
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              // Nombre
              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(
                  labelText: 'Nombre del Curso *',
                  hintText: 'Ej: Curso TES Avanzado 2024',
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.words,
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingresa el nombre del curso';
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

              // Tipo de curso
              DropdownButtonFormField<String>(
                initialValue: _tipoCurso,
                decoration: const InputDecoration(
                  labelText: 'Tipo de Curso *',
                  border: OutlineInputBorder(),
                ),
                items: const <DropdownMenuItem<String>>[
                  DropdownMenuItem<String>(
                    value: 'presencial',
                    child: Text('Presencial'),
                  ),
                  DropdownMenuItem<String>(
                    value: 'online',
                    child: Text('Online'),
                  ),
                  DropdownMenuItem<String>(
                    value: 'mixto',
                    child: Text('Mixto'),
                  ),
                ],
                onChanged: (String? value) {
                  if (value != null) {
                    setState(() {
                      _tipoCurso = value;
                    });
                  }
                },
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return 'Selecciona el tipo';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Duración
              TextFormField(
                controller: _duracionHorasController,
                decoration: const InputDecoration(
                  labelText: 'Duración *',
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
                  if (horas == null || horas < 1) {
                    return 'Mínimo 1 hora';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Certificaciones que otorga
              if (_certificaciones.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Text(
                      'Certificaciones que otorga:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ..._certificaciones.map((CertificacionEntity cert) {
                      return CheckboxListTile(
                        title: Text('${cert.codigo} - ${cert.nombre}'),
                        value: _certificacionesSeleccionadas.contains(cert.id),
                        onChanged: (bool? value) {
                          setState(() {
                            if (value == true) {
                              _certificacionesSeleccionadas.add(cert.id);
                            } else {
                              _certificacionesSeleccionadas.remove(cert.id);
                            }
                          });
                        },
                        controlAffinity: ListTileControlAffinity.leading,
                        contentPadding: EdgeInsets.zero,
                      );
                    }),
                    const SizedBox(height: 8),
                  ],
                ),

              // Activo
              SwitchListTile(
                title: const Text('Curso Activo'),
                subtitle: const Text('Los inactivos no se muestran en los formularios'),
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
          onPressed: _isSaving ? null : _saveCurso,
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

  Future<void> _saveCurso() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final CursoRepository repository = getIt<CursoRepository>();

      final CursoEntity curso = CursoEntity(
        id: _isEditing ? widget.item!.id : _generateUuid(),
        nombre: _nombreController.text,
        descripcion: _descripcionController.text.isEmpty ? null : _descripcionController.text,
        tipo: _tipoCurso,
        duracionHoras: int.parse(_duracionHorasController.text),
        certificaciones: _certificacionesSeleccionadas,
        activo: _isActive,
        createdAt: _isEditing ? widget.item!.createdAt : DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (_isEditing) {
        await repository.update(curso);
      } else {
        await repository.create(curso);
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
