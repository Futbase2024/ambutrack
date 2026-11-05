import 'dart:math';

import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/dialogs/result_dialog.dart';
import 'package:ambutrack_web/core/widgets/gestion/form/gestion_form.dart';
import 'package:ambutrack_web/core/widgets/handlers/crud_operation_handler.dart';
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

  static const List<GestionOption<String>> _tipos = <GestionOption<String>>[
    GestionOption<String>('presencial', 'Presencial', color: AppColors.primary),
    GestionOption<String>('online', 'Online', color: AppColors.info),
    GestionOption<String>('mixto', 'Mixto', color: AppColors.secondary),
  ];

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
      if (!mounted) {
        return;
      }
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

  void _toggleCertificacion(String id, bool value) {
    setState(() {
      if (value) {
        _certificacionesSeleccionadas.add(id);
      } else {
        _certificacionesSeleccionadas.remove(id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestionFormDialog(
      title: _isEditing ? 'Editar curso' : 'Nuevo curso',
      subtitle: _isEditing ? widget.item!.nombre : null,
      icon: Icons.school_outlined,
      formKey: _formKey,
      isEditing: _isEditing,
      isSaving: _isSaving,
      onSave: _saveCurso,
      children: <Widget>[
        const GestionFormSection(title: 'Datos del curso', first: true),
        GestionFormRow(
          label: 'Nombre',
          required: true,
          child: GestionTextField(
            controller: _nombreController,
            hint: 'Ej: Curso TES Avanzado 2024',
            validator: (String? value) =>
                (value == null || value.isEmpty) ? 'Ingresa el nombre del curso' : null,
          ),
        ),
        GestionFormColumns(
          children: <Widget>[
            GestionFormRow(
              label: 'Tipo',
              required: true,
              child: GestionDropdownField<String>(
                value: _tipoCurso,
                options: _tipos,
                required: true,
                onChanged: (String? value) {
                  if (value != null) {
                    setState(() => _tipoCurso = value);
                  }
                },
              ),
            ),
            GestionFormRow(
              label: 'Duración',
              required: true,
              child: GestionTextField(
                controller: _duracionHorasController,
                hint: '0',
                suffixText: 'horas',
                textAlign: TextAlign.end,
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
                validator: _validarDuracion,
              ),
            ),
          ],
        ),
        GestionFormRow(
          label: 'Descripción',
          multiline: true,
          child: GestionTextField(controller: _descripcionController, maxLines: 3),
        ),
        GestionFormRow(
          label: 'Estado',
          child: GestionSwitchField(
            value: _isActive,
            text: _isActive ? 'Activo' : 'Inactivo (no se muestra en los formularios)',
            onChanged: (bool value) => setState(() => _isActive = value),
          ),
        ),
        if (_certificaciones.isNotEmpty) ...<Widget>[
          const GestionFormSection(title: 'Certificaciones que otorga'),
          for (final CertificacionEntity cert in _certificaciones)
            GestionCheckField(
              value: _certificacionesSeleccionadas.contains(cert.id),
              text: '${cert.codigo} - ${cert.nombre}',
              onChanged: (bool value) => _toggleCertificacion(cert.id, value),
            ),
        ],
      ],
    );
  }

  static String? _validarDuracion(String? value) {
    if (value == null || value.isEmpty) {
      return 'Requerido';
    }
    final int? horas = int.tryParse(value);
    if (horas == null || horas < 1) {
      return 'Mínimo 1 hora';
    }
    return null;
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
        await CrudOperationHandler.handleSuccess(
          context: context,
          isSaving: false,
          isEditing: _isEditing,
          entityName: 'Curso',
        );
      }
    } catch (e) {
      debugPrint('❌ CursoFormDialog: $e');
      if (!mounted) {
        return;
      }
      setState(() {
        _isSaving = false;
      });
      await showResultDialog(
        context: context,
        title: 'Error al Guardar',
        message: _isEditing ? 'No se pudo actualizar el curso.' : 'No se pudo crear el curso.',
        details: e.toString(),
        type: ResultType.error,
      );
    }
  }

  String _generateUuid() {
    return '${DateTime.now().millisecondsSinceEpoch}-${Random().nextInt(10000)}';
  }
}
