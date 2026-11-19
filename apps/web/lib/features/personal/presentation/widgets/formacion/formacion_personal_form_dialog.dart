import 'dart:math';

import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/core/widgets/dialogs/result_dialog.dart';
import 'package:ambutrack_web/core/widgets/gestion/form/gestion_form.dart';
import 'package:ambutrack_web/core/widgets/handlers/crud_operation_handler.dart';
import 'package:ambutrack_web/core/widgets/loading/app_loading_indicator.dart';
import 'package:ambutrack_web/features/personal/domain/repositories/certificacion_repository.dart';
import 'package:ambutrack_web/features/personal/domain/repositories/curso_repository.dart';
import 'package:ambutrack_web/features/personal/domain/repositories/formacion_personal_repository.dart';
import 'package:ambutrack_web/features/personal/presentation/widgets/form/formacion_personal_form_body.dart';
import 'package:flutter/material.dart';

/// Diálogo para crear/editar formación personal
class FormacionPersonalFormDialog extends StatefulWidget {
  const FormacionPersonalFormDialog({super.key, this.item});

  final FormacionPersonalEntity? item;

  @override
  State<FormacionPersonalFormDialog> createState() => _FormacionPersonalFormDialogState();
}

class _FormacionPersonalFormDialogState extends State<FormacionPersonalFormDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _personalIdController = TextEditingController();
  final TextEditingController _observacionesController = TextEditingController();
  final TextEditingController _horasAcumuladasController = TextEditingController(text: '0');

  DateTime? _fechaInicio;
  DateTime? _fechaFin;
  DateTime? _fechaExpiracion;
  bool _isLoading = true;
  bool _isSaving = false;

  // Datos de catálogos
  final List<CertificacionEntity> _certificaciones = <CertificacionEntity>[];
  final List<CursoEntity> _cursos = <CursoEntity>[];
  final List<UserEntity> _usuarios = <UserEntity>[];

  CertificacionEntity? _certificacionSeleccionada;
  CursoEntity? _cursoSeleccionado;
  UserEntity? _usuarioSeleccionado;

  bool get _isEditing => widget.item != null;

  @override
  void initState() {
    super.initState();
    // Usar addPostFrameCallback para evitar acceder a context antes de tiempo
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });

    if (_isEditing) {
      _personalIdController.text = widget.item!.personalId;
      _observacionesController.text = widget.item!.observaciones ?? '';
      _horasAcumuladasController.text = widget.item!.horasAcumuladas.toString();
      _fechaInicio = widget.item!.fechaInicio;
      _fechaFin = widget.item!.fechaFin;
      _fechaExpiracion = widget.item!.fechaExpiracion;
    }
  }

  Future<void> _loadData() async {
    try {
      // Cargar certificaciones, cursos y usuarios en paralelo
      final List<Object?> results = await Future.wait(<Future<Object?>>[
        getIt<CertificacionRepository>().getActivas(),
        getIt<CursoRepository>().getActivos(),
        getIt<UsersDataSource>().getAll(),
      ]);

      if (!mounted) {
        return;
      }
      setState(() {
        if (results[0] is List<CertificacionEntity>) {
          _certificaciones.addAll(results[0] as List<CertificacionEntity>);
        }
        if (results[1] is List<CursoEntity>) {
          _cursos.addAll(results[1] as List<CursoEntity>);
        }
        if (results[2] is List<UserEntity>) {
          _usuarios.addAll(results[2] as List<UserEntity>);
        }
        _preseleccionarEdicion();
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('❌ FormacionPersonalFormDialog: error al cargar datos: $e');
      if (!mounted) {
        return;
      }
      setState(() {
        _isLoading = false;
      });
      await showResultDialog(
        context: context,
        title: 'Error al cargar datos',
        message: 'No se pudieron cargar empleados, certificaciones o cursos.',
        details: e.toString(),
        type: ResultType.error,
      );
    }
  }

  @override
  void dispose() {
    _personalIdController.dispose();
    _observacionesController.dispose();
    _horasAcumuladasController.dispose();
    super.dispose();
  }

  /// En edición, preselecciona empleado, certificación y curso guardados
  void _preseleccionarEdicion() {
    if (!_isEditing) {
      return;
    }
    final FormacionPersonalEntity item = widget.item!;
    _usuarioSeleccionado = _usuarios.where((UserEntity u) => u.id == item.personalId).firstOrNull;
    _certificacionSeleccionada =
        _certificaciones.where((CertificacionEntity c) => c.id == item.certificacionId).firstOrNull;
    if (_certificacionSeleccionada == null) {
      _cursoSeleccionado = _cursos.where((CursoEntity c) => c.id == item.cursoId).firstOrNull;
    }
  }

  void _onUsuarioChanged(String? id) {
    setState(() {
      _usuarioSeleccionado = _usuarios.where((UserEntity u) => u.id == id).firstOrNull;
      _personalIdController.text = _usuarioSeleccionado?.id ?? '';
    });
  }

  void _onCertificacionChanged(String? id) {
    setState(() {
      _certificacionSeleccionada = _certificaciones.where((CertificacionEntity c) => c.id == id).firstOrNull;
      _cursoSeleccionado = null;
    });
  }

  void _onCursoChanged(String? id) {
    setState(() {
      _cursoSeleccionado = _cursos.where((CursoEntity c) => c.id == id).firstOrNull;
      _certificacionSeleccionada = null;
    });
  }

  void _onFechaInicioChanged(DateTime? picked) {
    if (picked == null) {
      return;
    }
    setState(() {
      _fechaInicio = picked;
      // Auto-calcular fecha de expiración si es certificación
      if (_certificacionSeleccionada != null && _fechaExpiracion == null) {
        _fechaExpiracion = picked.add(
          Duration(days: _certificacionSeleccionada!.vigenciaMeses * 30),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestionFormDialog(
      title: _isEditing ? 'Editar formación' : 'Nueva formación',
      subtitle: _isEditing && _usuarioSeleccionado != null
          ? (_usuarioSeleccionado!.displayName ?? _usuarioSeleccionado!.email)
          : null,
      icon: Icons.school_outlined,
      formKey: _formKey,
      isEditing: _isEditing,
      isSaving: _isSaving,
      onSave: _saveFormacion,
      children: _isLoading
          ? const <Widget>[AppLoadingIndicator(message: 'Cargando datos...', size: 100)]
          : <Widget>[
              FormacionPersonalFormBody(
                usuarios: _usuarios,
                certificaciones: _certificaciones,
                cursos: _cursos,
                usuario: _usuarioSeleccionado,
                certificacion: _certificacionSeleccionada,
                curso: _cursoSeleccionado,
                fechaInicio: _fechaInicio,
                fechaFin: _fechaFin,
                fechaExpiracion: _fechaExpiracion,
                horas: _horasAcumuladasController,
                observaciones: _observacionesController,
                onUsuarioChanged: _onUsuarioChanged,
                onCertificacionChanged: _onCertificacionChanged,
                onCursoChanged: _onCursoChanged,
                onFechaInicioChanged: _onFechaInicioChanged,
                onFechaFinChanged: (DateTime? v) {
                  if (v != null) {
                    setState(() => _fechaFin = v);
                  }
                },
                onFechaExpiracionChanged: (DateTime? v) {
                  if (v != null) {
                    setState(() => _fechaExpiracion = v);
                  }
                },
              ),
            ],
    );
  }

  Future<void> _saveFormacion() async {
    if (_isLoading || !_formKey.currentState!.validate()) {
      return;
    }

    // Validar que se haya seleccionado certificación o curso
    if (_certificacionSeleccionada == null && _cursoSeleccionado == null) {
      await CrudOperationHandler.handleWarning(
        context: context,
        title: 'Formación requerida',
        message: 'Selecciona una certificación o un curso',
      );
      return;
    }

    // Validar fechas
    if (_fechaInicio == null || _fechaFin == null || _fechaExpiracion == null) {
      await CrudOperationHandler.handleWarning(
        context: context,
        title: 'Fechas incompletas',
        message: 'Completa todas las fechas',
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final FormacionPersonalRepository repository = getIt<FormacionPersonalRepository>();

      final FormacionPersonalEntity formacion = FormacionPersonalEntity(
        id: _isEditing ? widget.item!.id : _generateUuid(),
        personalId: _personalIdController.text,
        certificacionId: _certificacionSeleccionada?.id,
        cursoId: _cursoSeleccionado?.id,
        fechaInicio: _fechaInicio!,
        fechaFin: _fechaFin!,
        fechaExpiracion: _fechaExpiracion!,
        horasAcumuladas: int.tryParse(_horasAcumuladasController.text) ?? 0,
        estado: _calculateEstado(_fechaExpiracion!),
        observaciones: _observacionesController.text.isEmpty ? null : _observacionesController.text,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (_isEditing) {
        await repository.update(formacion);
      } else {
        await repository.create(formacion);
      }

      if (mounted) {
        // Cierra con true (se guardó correctamente) y muestra el resultado
        await CrudOperationHandler.handleSuccess(
          context: context,
          isSaving: false,
          isEditing: _isEditing,
          entityName: 'Formación',
        );
      }
    } catch (e) {
      debugPrint('❌ FormacionPersonalFormDialog: $e');
      if (!mounted) {
        return;
      }
      setState(() {
        _isSaving = false;
      });
      await showResultDialog(
        context: context,
        title: 'Error al Guardar',
        message: _isEditing ? 'No se pudo actualizar la formación.' : 'No se pudo crear la formación.',
        details: e.toString(),
        type: ResultType.error,
      );
    }
  }

  String _generateUuid() {
    // Generar un UUID simple (en producción usar uuid package)
    return '${DateTime.now().millisecondsSinceEpoch}-${Random().nextInt(10000)}';
  }

  String _calculateEstado(DateTime fechaExpiracion) {
    final DateTime now = DateTime.now();
    final DateTime thirtyDaysLater = now.add(const Duration(days: 30));

    if (fechaExpiracion.isBefore(now)) {
      return 'vencida';
    } else if (fechaExpiracion.isBefore(thirtyDaysLater) || fechaExpiracion.isAtSameMomentAs(thirtyDaysLater)) {
      return 'proxima_vencer';
    } else {
      return 'vigente';
    }
  }
}
