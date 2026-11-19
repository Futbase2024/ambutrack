import 'dart:async';

import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/dialogs/result_dialog.dart';
import 'package:ambutrack_web/core/widgets/gestion/form/gestion_form.dart';
import 'package:ambutrack_web/core/widgets/handlers/crud_operation_handler.dart';
import 'package:ambutrack_web/core/widgets/loading/app_loading_indicator.dart';
import 'package:ambutrack_web/features/ausencias/presentation/widgets/form/solicitud_documento_storage.dart';
import 'package:ambutrack_web/features/personal/domain/entities/personal_entity.dart';
import 'package:ambutrack_web/features/personal/domain/repositories/personal_repository.dart';
import 'package:ambutrack_web/features/vacaciones/presentation/bloc/vacaciones_bloc.dart';
import 'package:ambutrack_web/features/vacaciones/presentation/bloc/vacaciones_event.dart';
import 'package:ambutrack_web/features/vacaciones/presentation/bloc/vacaciones_state.dart';
import 'package:ambutrack_web/features/vacaciones/presentation/widgets/form/vacacion_form_body.dart';
import 'package:ambutrack_web/features/vacaciones/presentation/widgets/form/vacacion_form_data.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

/// Diálogo de formulario para crear/editar vacaciones
class VacacionFormDialog extends StatefulWidget {
  const VacacionFormDialog({super.key, this.vacacion});

  final VacacionesEntity? vacacion;

  @override
  State<VacacionFormDialog> createState() => _VacacionFormDialogState();
}

class _VacacionFormDialogState extends State<VacacionFormDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final PersonalRepository _personalRepository = getIt<PersonalRepository>();
  late final VacacionFormData _data = VacacionFormData(original: widget.vacacion);

  bool _isSaving = false;
  bool _isLoading = true;

  bool get _isEditing => widget.vacacion != null;

  @override
  void initState() {
    super.initState();
    _loadPersonal();
  }

  @override
  void dispose() {
    _data.dispose();
    super.dispose();
  }

  Future<void> _aviso(String title, String message, {ResultType type = ResultType.warning, String? details}) {
    return showResultDialog(context: context, title: title, message: message, type: type, details: details);
  }

  /// Carga la lista de personal desde el repositorio
  Future<void> _loadPersonal() async {
    try {
      final List<PersonalEntity> personal = await _personalRepository.getAll();
      if (mounted) {
        setState(() {
          _data.personalList = personal.where((PersonalEntity p) => p.activo).toList();
          _isLoading = false;
          // Si estamos editando, buscar el personal seleccionado
          if (widget.vacacion != null) {
            _data.personal = _data.personalList.firstWhere(
              (PersonalEntity p) => p.id == widget.vacacion!.idPersonal,
              orElse: () => _data.personalList.first,
            );
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        debugPrint('Error al cargar personal: $e');
      }
    }
  }

  void _onFechaInicio(DateTime? picked) {
    if (picked == null) {
      return;
    }
    setState(() {
      _data.fechaInicio = picked;
      // Si la fecha fin es anterior a la de inicio, la ajustamos
      if (_data.fechaFin != null && _data.fechaFin!.isBefore(picked)) {
        _data.fechaFin = picked;
      }
    });
  }

  void _onFechaFin(DateTime? picked) {
    if (picked != null) {
      setState(() => _data.fechaFin = picked);
    }
  }

  /// Selecciona un archivo para adjuntar
  Future<void> _seleccionarArchivo() async {
    try {
      final PlatformFile? file = await SolicitudDocumentoStorage.pickFile();
      if (file == null) {
        return;
      }
      // Validar tamaño (máximo 10 MB)
      if (file.size > SolicitudDocumentoStorage.maxBytes) {
        if (mounted) {
          await _aviso('Archivo demasiado grande', 'El archivo es demasiado grande. Máximo: 10 MB.');
        }
        return;
      }
      setState(() {
        _data.archivo = file;
        _data.documentoAdjunto.text = file.name;
      });
      debugPrint('📄 Archivo seleccionado: ${file.name}');
    } catch (e) {
      debugPrint('❌ Error al seleccionar archivo: $e');
      if (mounted) {
        await _aviso('Error al seleccionar archivo', 'No se pudo leer el archivo.',
            type: ResultType.error, details: e.toString());
      }
    }
  }

  /// Elimina el archivo seleccionado
  void _eliminarArchivo() {
    setState(() {
      _data.archivo = null;
      _data.nombreArchivoExistente = null;
      _data.documentoAdjunto.clear();
    });
    debugPrint('🗑️ Archivo eliminado');
  }

  /// Validaciones adicionales a las de los campos; devuelve el mensaje de error o null
  String? _validarDatos() {
    if (_data.personal == null) {
      return 'Debes seleccionar un trabajador';
    }
    if (_data.fechaInicio == null || _data.fechaFin == null) {
      return 'Debes seleccionar las fechas de inicio y fin';
    }
    if (_data.fechaFin!.isBefore(_data.fechaInicio!)) {
      return 'La fecha de fin no puede ser anterior a la de inicio';
    }
    return null;
  }

  /// Guarda la vacación
  Future<void> _onSave() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    final String? error = _validarDatos();
    if (error != null) {
      await _aviso('Datos incompletos', error);
      return;
    }

    setState(() => _isSaving = true);
    _showSavingOverlay();

    // Subir archivo a Supabase Storage si hay uno nuevo seleccionado
    String? documentoUrl;
    if (_data.archivo != null) {
      try {
        documentoUrl = await SolicitudDocumentoStorage.subir(
          file: _data.archivo!,
          carpeta: 'vacaciones',
          personalId: _data.personal!.id,
        );
      } catch (e) {
        // Error al subir archivo, cancelar guardado
        debugPrint('❌ Error al subir archivo a Storage: $e');
        if (mounted) {
          Navigator.of(context).pop(); // Cerrar loading
          setState(() => _isSaving = false);
          await _aviso('Error al subir el archivo', 'No se pudo subir el documento adjunto.',
              type: ResultType.error, details: e.toString());
        }
        return;
      }
    } else if (_isEditing && widget.vacacion!.documentoAdjunto != null) {
      // Si estamos editando y no hay archivo nuevo, mantener el existente
      documentoUrl = widget.vacacion!.documentoAdjunto;
    }

    final VacacionesEntity vacacion = _buildEntity(documentoUrl);
    if (mounted) {
      context.read<VacacionesBloc>().add(
            _isEditing ? VacacionesUpdateRequested(vacacion) : VacacionesCreateRequested(vacacion),
          );
    }
  }

  VacacionesEntity _buildEntity(String? documentoUrl) {
    // Calcular días solicitados
    final int diasSolicitados = _data.fechaFin!.difference(_data.fechaInicio!).inDays + 1;
    final String observaciones = _data.observaciones.text.trim();
    return VacacionesEntity(
      id: widget.vacacion?.id ?? const Uuid().v4(),
      idPersonal: _data.personal!.id,
      fechaInicio: _data.fechaInicio!,
      fechaFin: _data.fechaFin!,
      diasSolicitados: diasSolicitados,
      estado: _data.estado,
      observaciones: observaciones.isEmpty ? null : observaciones,
      documentoAdjunto: documentoUrl,
      fechaSolicitud: widget.vacacion?.fechaSolicitud,
      aprobadoPor: widget.vacacion?.aprobadoPor,
      fechaAprobacion: widget.vacacion?.fechaAprobacion,
      activo: widget.vacacion?.activo ?? true,
      createdAt: widget.vacacion?.createdAt,
      updatedAt: widget.vacacion?.updatedAt,
    );
  }

  void _showSavingOverlay() {
    unawaited(
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext _) => AppLoadingOverlay(
          message: _isEditing ? 'Actualizando vacaciones...' : 'Creando vacaciones...',
          color: _isEditing ? AppColors.secondary : AppColors.primary,
          icon: _isEditing ? Icons.edit : Icons.add_circle_outline,
        ),
      ),
    );
  }

  void _onBlocState(BuildContext context, VacacionesState state) {
    // Solo actuar si estamos guardando
    if (!_isSaving) {
      return;
    }
    if (state is VacacionesLoaded) {
      debugPrint('✅ VacacionFormDialog: Vacación guardada, estado VacacionesLoaded recibido');
      CrudOperationHandler.handleSuccess(
        context: context,
        isSaving: _isSaving,
        isEditing: _isEditing,
        entityName: 'Vacación',
        onClose: () => setState(() => _isSaving = false),
      );
    } else if (state is VacacionesError) {
      debugPrint('❌ VacacionFormDialog: Error al guardar vacación');
      CrudOperationHandler.handleError(
        context: context,
        isSaving: _isSaving,
        isEditing: _isEditing,
        entityName: 'Vacación',
        errorMessage: state.message,
        onClose: () => setState(() => _isSaving = false),
      );
    } else if (state is VacacionesLoading) {
      debugPrint('🔄 VacacionFormDialog: Estado VacacionesLoading - Recargando datos...');
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<VacacionesBloc, VacacionesState>(
      listener: _onBlocState,
      child: GestionFormDialog(
        title: _isEditing ? 'Editar vacaciones' : 'Nuevas vacaciones',
        subtitle: _isEditing && _data.personal != null ? VacacionFormOptions.personalLabel(_data.personal!) : null,
        icon: Icons.beach_access_outlined,
        formKey: _formKey,
        isEditing: _isEditing,
        isSaving: _isSaving,
        onSave: _isLoading ? () {} : _onSave,
        children: <Widget>[
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: Center(child: AppLoadingIndicator(message: 'Cargando datos...', size: 80)),
            )
          else
            VacacionFormBody(
              data: _data,
              isSaving: _isSaving,
              onChanged: () => setState(() {}),
              onFechaInicio: _onFechaInicio,
              onFechaFin: _onFechaFin,
              onSeleccionarArchivo: _seleccionarArchivo,
              onEliminarArchivo: _eliminarArchivo,
            ),
        ],
      ),
    );
  }
}
