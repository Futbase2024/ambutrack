import 'dart:async';

import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/dialogs/result_dialog.dart';
import 'package:ambutrack_web/core/widgets/gestion/form/gestion_form.dart';
import 'package:ambutrack_web/core/widgets/handlers/crud_operation_handler.dart';
import 'package:ambutrack_web/core/widgets/loading/app_loading_indicator.dart';
import 'package:ambutrack_web/features/personal/domain/entities/personal_entity.dart';
import 'package:ambutrack_web/features/personal/presentation/bloc/historial_medico_bloc.dart';
import 'package:ambutrack_web/features/personal/presentation/bloc/historial_medico_event.dart';
import 'package:ambutrack_web/features/personal/presentation/bloc/historial_medico_state.dart';
import 'package:ambutrack_web/features/personal/presentation/widgets/form/historial_documento_selector.dart';
import 'package:ambutrack_web/features/personal/presentation/widgets/form/historial_medico_form_body.dart';
import 'package:ambutrack_web/features/personal/presentation/widgets/form/historial_medico_form_helpers.dart';
import 'package:ambutrack_web/features/personal/presentation/widgets/form/personal_form_options.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

/// Diálogo de formulario para crear/editar Historial Médico
class HistorialMedicoFormDialog extends StatefulWidget {
  const HistorialMedicoFormDialog({super.key, this.item});

  final HistorialMedicoEntity? item;

  @override
  State<HistorialMedicoFormDialog> createState() => _HistorialMedicoFormDialogState();
}

class _HistorialMedicoFormDialogState extends State<HistorialMedicoFormDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _observacionesController = TextEditingController();
  final TextEditingController _restriccionesController = TextEditingController();
  final TextEditingController _centroMedicoController = TextEditingController();
  final TextEditingController _nombreMedicoController = TextEditingController();

  DateTime? _fechaReconocimiento;
  DateTime? _fechaCaducidad;
  String _aptitud = AptitudMedica.apto;
  bool _activo = true;
  bool _isSaving = false;
  bool _isLoading = true;

  // Variables para Personal
  PersonalEntity? _personalSeleccionado;
  List<PersonalEntity> _personalList = <PersonalEntity>[];

  // Variables para manejo de archivos
  PlatformFile? _archivoSeleccionado;
  String? _nombreArchivoExistente;

  bool get _isEditing => widget.item != null;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      // Cargar personal activo ordenado
      final List<PersonalEntity> personalActivo = await HistorialMedicoFormHelpers.cargarPersonalActivo();

      if (mounted) {
        setState(() {
          _personalList = personalActivo;
          _isLoading = false;

          // Si es edición, cargar datos existentes
          if (_isEditing) {
            _loadItemData();
          }
        });
      }
    } catch (e) {
      debugPrint('❌ Error al cargar datos del formulario: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        await showResultDialog(
          context: context,
          title: 'Error al cargar datos',
          message: 'No se pudo cargar la lista de personal.',
          details: e.toString(),
          type: ResultType.error,
        );
      }
    }
  }

  void _loadItemData() {
    final HistorialMedicoEntity item = widget.item!;
    _fechaReconocimiento = item.fechaReconocimiento;
    _fechaCaducidad = item.fechaCaducidad;
    _aptitud = item.aptitud;
    _observacionesController.text = item.observaciones ?? '';
    _restriccionesController.text = item.restricciones ?? '';
    _centroMedicoController.text = item.centroMedico ?? '';
    _nombreMedicoController.text = item.nombreMedico ?? '';
    _nombreArchivoExistente = item.documentoUrl;
    _activo = item.activo;

    // Buscar el personal seleccionado
    _personalSeleccionado = PersonalFormOptions.buscar(_personalList, item.personalId);
    if (_personalSeleccionado == null) {
      debugPrint('⚠️ Personal no encontrado en la lista: ${item.personalId}');
    }
  }

  /// Seleccionar archivo (imagen o documento)
  Future<void> _seleccionarArchivo() async {
    final PlatformFile? file = await HistorialMedicoFormHelpers.elegirArchivo(context);
    if (file != null && mounted) {
      setState(() => _archivoSeleccionado = file);
    }
  }

  /// Eliminar archivo seleccionado
  void _eliminarArchivo() {
    setState(() {
      _archivoSeleccionado = null;
      _nombreArchivoExistente = null;
    });
    debugPrint('🗑️ Archivo eliminado');
  }

  /// Ver documento existente en nueva pestaña
  void _verDocumento() {
    if (_nombreArchivoExistente != null && _nombreArchivoExistente!.isNotEmpty) {
      HistorialMedicoFormHelpers.abrir(_nombreArchivoExistente!);
    }
  }

  @override
  void dispose() {
    _observacionesController.dispose();
    _restriccionesController.dispose();
    _centroMedicoController.dispose();
    _nombreMedicoController.dispose();
    super.dispose();
  }

  void _onBlocState(BuildContext context, HistorialMedicoState state) {
    if (!_isSaving) {
      return;
    }
    if (state is HistorialMedicoLoaded) {
      CrudOperationHandler.handleSuccess(
        context: context,
        isSaving: _isSaving,
        isEditing: _isEditing,
        entityName: 'Reconocimiento Médico',
        onClose: () => setState(() => _isSaving = false),
      );
    } else if (state is HistorialMedicoError) {
      CrudOperationHandler.handleError(
        context: context,
        isSaving: _isSaving,
        isEditing: _isEditing,
        entityName: 'Reconocimiento Médico',
        errorMessage: state.message,
        onClose: () => setState(() => _isSaving = false),
      );
    }
  }

  void _onFechaReconocimientoChanged(DateTime? picked) {
    if (picked != null && picked != _fechaReconocimiento) {
      setState(() {
        _fechaReconocimiento = picked;
        // Si aún no hay fecha de caducidad, sugerir 1 año después
        _fechaCaducidad ??= DateTime(
          picked.year + 1,
          picked.month,
          picked.day,
        );
      });
    }
  }

  void _onFechaCaducidadChanged(DateTime? picked) {
    if (picked != null && picked != _fechaCaducidad) {
      setState(() => _fechaCaducidad = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<HistorialMedicoBloc, HistorialMedicoState>(
      listener: _onBlocState,
      child: GestionFormDialog(
        title: _isEditing ? 'Editar reconocimiento médico' : 'Nuevo reconocimiento médico',
        subtitle: _isEditing && _personalSeleccionado != null ? _personalSeleccionado!.nombreCompleto : null,
        icon: Icons.health_and_safety_outlined,
        size: GestionFormSize.large,
        formKey: _formKey,
        isEditing: _isEditing,
        isSaving: _isSaving,
        onSave: _onSave,
        children: _isLoading
            ? const <Widget>[AppLoadingIndicator(message: 'Cargando datos...', size: 100)]
            : <Widget>[
                HistorialMedicoFormBody(
                  personalList: _personalList,
                  personal: _personalSeleccionado,
                  fechaReconocimiento: _fechaReconocimiento,
                  fechaCaducidad: _fechaCaducidad,
                  aptitud: _aptitud,
                  activo: _activo,
                  centroMedico: _centroMedicoController,
                  nombreMedico: _nombreMedicoController,
                  observaciones: _observacionesController,
                  restricciones: _restriccionesController,
                  documento: HistorialDocumentoSelector(
                    nombreArchivo: _archivoSeleccionado?.name ?? _nombreArchivoExistente,
                    tamanoBytes: _archivoSeleccionado?.size,
                    puedeVer: _nombreArchivoExistente != null && _nombreArchivoExistente!.isNotEmpty,
                    enabled: !_isSaving,
                    onSeleccionar: _seleccionarArchivo,
                    onEliminar: _eliminarArchivo,
                    onVer: _verDocumento,
                  ),
                  onPersonalChanged: (String? id) => setState(
                    () => _personalSeleccionado = PersonalFormOptions.buscar(_personalList, id),
                  ),
                  onFechaReconocimientoChanged: _onFechaReconocimientoChanged,
                  onFechaCaducidadChanged: _onFechaCaducidadChanged,
                  onAptitudChanged: (String v) => setState(() => _aptitud = v),
                  onActivoChanged: (bool v) => setState(() => _activo = v),
                ),
              ],
      ),
    );
  }

  Future<void> _onSave() async {
    if (_isLoading || !_formKey.currentState!.validate()) {
      return;
    }

    // Validar personal seleccionado
    if (_personalSeleccionado == null) {
      await CrudOperationHandler.handleWarning(
        context: context,
        title: 'Personal requerido',
        message: 'Debes seleccionar un personal',
      );
      return;
    }

    if (_fechaReconocimiento == null || _fechaCaducidad == null) {
      await CrudOperationHandler.handleWarning(
        context: context,
        title: 'Fechas requeridas',
        message: 'Por favor seleccione las fechas requeridas',
      );
      return;
    }

    setState(() => _isSaving = true);

    // Mostrar loading overlay
    unawaited(
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AppLoadingOverlay(
            message: _isEditing ? 'Actualizando reconocimiento médico...' : 'Creando reconocimiento médico...',
            color: _isEditing ? AppColors.secondary : AppColors.primary,
            icon: _isEditing ? Icons.edit : Icons.add_circle_outline,
          );
        },
      ),
    );

    // Subir archivo a Supabase Storage si hay uno nuevo seleccionado
    String? documentoUrl;
    if (_archivoSeleccionado != null) {
      documentoUrl = await _subirArchivoStorage();
      if (documentoUrl == null) {
        // Error al subir archivo, cancelar guardado
        if (mounted) {
          Navigator.of(context).pop(); // Cerrar loading
          setState(() => _isSaving = false);
        }
        return;
      }
    } else if (_isEditing && widget.item!.documentoUrl != null) {
      // Si estamos editando y no hay archivo nuevo, mantener el existente
      documentoUrl = widget.item!.documentoUrl;
    }

    // Crear entidad
    final HistorialMedicoEntity entity = HistorialMedicoEntity(
      id: _isEditing ? widget.item!.id : const Uuid().v4(),
      personalId: _personalSeleccionado!.id,
      fechaReconocimiento: _fechaReconocimiento!,
      fechaCaducidad: _fechaCaducidad!,
      aptitud: _aptitud,
      observaciones: _texto(_observacionesController),
      restricciones: _texto(_restriccionesController),
      centroMedico: _texto(_centroMedicoController),
      nombreMedico: _texto(_nombreMedicoController),
      documentoUrl: documentoUrl,
      activo: _activo,
      createdAt: _isEditing ? widget.item!.createdAt : DateTime.now(),
      updatedAt: DateTime.now(),
    );

    // Disparar evento BLoC
    if (mounted) {
      if (_isEditing) {
        context.read<HistorialMedicoBloc>().add(HistorialMedicoUpdateRequested(entity));
      } else {
        context.read<HistorialMedicoBloc>().add(HistorialMedicoCreateRequested(entity));
      }
    }
  }

  /// Texto recortado o null si está vacío
  static String? _texto(TextEditingController c) => c.text.trim().isEmpty ? null : c.text.trim();

  /// Sube el archivo seleccionado a Supabase Storage
  Future<String?> _subirArchivoStorage() async {
    if (_archivoSeleccionado == null) {
      return null;
    }

    try {
      return await HistorialMedicoFormHelpers.subir(_archivoSeleccionado!, _personalSeleccionado!.id);
    } catch (e) {
      debugPrint('❌ Error al subir archivo a Storage: $e');

      if (mounted) {
        await showResultDialog(
          context: context,
          title: 'Error al subir el archivo',
          message: 'No se pudo subir el documento. El reconocimiento no se ha guardado.',
          details: e.toString(),
          type: ResultType.error,
        );
      }

      return null;
    }
  }
}
