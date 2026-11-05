import 'dart:async';

import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/core/services/auth_service.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/dialogs/result_dialog.dart';
import 'package:ambutrack_web/core/widgets/gestion/form/gestion_form.dart';
import 'package:ambutrack_web/core/widgets/handlers/crud_operation_handler.dart';
import 'package:ambutrack_web/core/widgets/loading/app_loading_indicator.dart';
import 'package:ambutrack_web/features/ausencias/presentation/bloc/ausencias_bloc.dart';
import 'package:ambutrack_web/features/ausencias/presentation/bloc/ausencias_event.dart';
import 'package:ambutrack_web/features/ausencias/presentation/bloc/ausencias_state.dart';
import 'package:ambutrack_web/features/ausencias/presentation/widgets/form/ausencia_form_body.dart';
import 'package:ambutrack_web/features/ausencias/presentation/widgets/form/ausencia_form_data.dart';
import 'package:ambutrack_web/features/ausencias/presentation/widgets/form/solicitud_documento_storage.dart';
import 'package:ambutrack_web/features/personal/domain/entities/personal_entity.dart';
import 'package:ambutrack_web/features/personal/domain/repositories/personal_repository.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Diálogo para crear/editar ausencias
class AusenciaFormDialog extends StatefulWidget {
  const AusenciaFormDialog({super.key, this.ausencia});

  final AusenciaEntity? ausencia;

  @override
  State<AusenciaFormDialog> createState() => _AusenciaFormDialogState();
}

class _AusenciaFormDialogState extends State<AusenciaFormDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final AusenciaFormData _data = AusenciaFormData(original: widget.ausencia);
  bool _isSaving = false;
  bool _isLoading = true;

  bool get _isEditing => widget.ausencia != null;

  @override
  void initState() {
    super.initState();
    _loadTiposAusencia();
  }

  @override
  void dispose() {
    _data.dispose();
    super.dispose();
  }

  Future<void> _aviso(String title, String message, {ResultType type = ResultType.warning, String? details}) {
    return showResultDialog(context: context, title: title, message: message, type: type, details: details);
  }

  /// Seleccionar archivo (imagen o documento)
  Future<void> _seleccionarArchivo() async {
    try {
      final PlatformFile? file = await SolicitudDocumentoStorage.pickFile();
      if (file == null) {
        return;
      }
      // Validar tamaño (máximo 10 MB)
      if (file.size > SolicitudDocumentoStorage.maxBytes) {
        if (mounted) {
          await _aviso('Archivo demasiado grande', 'El archivo no debe superar los 10 MB.');
        }
        return;
      }
      setState(() {
        _data.archivo = file;
        _data.documentoAdjunto.text = file.name;
      });
      debugPrint('📎 Archivo seleccionado: ${file.name} (${(file.size / 1024).toStringAsFixed(2)} KB)');
    } catch (e) {
      debugPrint('❌ Error al seleccionar archivo: $e');
      if (mounted) {
        await _aviso('Error al seleccionar archivo', 'No se pudo leer el archivo.',
            type: ResultType.error, details: e.toString());
      }
    }
  }

  /// Eliminar archivo seleccionado
  void _eliminarArchivo() {
    setState(() {
      _data.archivo = null;
      _data.documentoAdjunto.clear();
      _data.nombreArchivoExistente = null;
    });
    debugPrint('🗑️ Archivo eliminado');
  }

  Future<void> _loadTiposAusencia() async {
    try {
      // Obtener usuario autenticado
      final String? currentUserId = getIt<AuthService>().currentUser?.id;

      // Cargar todo el personal
      final List<PersonalEntity> todosPersonal = await getIt<PersonalRepository>().getAll();

      if (!mounted) {
        return;
      }

      final List<PersonalEntity> personalFiltrado = AusenciaFormData.filtrarPersonal(todosPersonal, currentUserId);

      // Cargar tipos de ausencia desde el BLoC
      final AusenciasState state = context.read<AusenciasBloc>().state;
      if (state is! AusenciasLoaded) {
        // Si no hay datos, cargarlos y esperar
        context.read<AusenciasBloc>().add(const AusenciasLoadRequested());
        await Future<void>.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          await _loadTiposAusencia();
        }
        return;
      }

      setState(() {
        _data.personalList = personalFiltrado;
        _data.tipos = state.tiposAusencia;
        _isLoading = false;
        _cargarSeleccionEdicion();
      });
    } catch (e) {
      debugPrint('❌ Error al cargar datos del formulario: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        await _aviso('Error al cargar datos', 'No se pudieron cargar los datos del formulario.',
            type: ResultType.error, details: e.toString());
      }
    }
  }

  /// Si es edición, carga personal, tipo y días existentes (en create quedan vacíos)
  void _cargarSeleccionEdicion() {
    final AusenciaEntity? a = widget.ausencia;
    if (a == null) {
      return;
    }
    _data.personal = _data.personalList.firstWhere(
      (PersonalEntity p) => p.id == a.idPersonal,
      orElse: () =>
          _data.personalList.isNotEmpty ? _data.personalList.first : throw Exception('No hay personal disponible'),
    );
    _data.tipo = _data.tipos.firstWhere(
      (TipoAusenciaEntity t) => t.id == a.idTipoAusencia,
      orElse: () => _data.tipos.first,
    );
    _data.diasCalculados = a.diasAusencia;
  }

  void _calcularDias() {
    if (_data.fechaInicio != null && _data.fechaFin != null) {
      final int dias = _data.fechaFin!.difference(_data.fechaInicio!).inDays + 1;
      setState(() => _data.diasCalculados = dias > 0 ? dias : 0);
      debugPrint('📅 Días calculados: ${_data.diasCalculados}');
    }
  }

  void _onFechaInicio(DateTime? picked) {
    if (picked == null) {
      return;
    }
    setState(() {
      _data.fechaInicio = picked;
      // Si la fecha fin es anterior a la nueva fecha inicio, ajustarla
      if (_data.fechaFin != null && _data.fechaFin!.isBefore(picked)) {
        _data.fechaFin = picked;
      }
    });
    _calcularDias();
  }

  void _onFechaFin(DateTime? picked) {
    if (picked == null) {
      return;
    }
    setState(() {
      _data.fechaFin = picked;
      // Si la fecha inicio es posterior a la nueva fecha fin, ajustarla
      if (_data.fechaInicio != null && _data.fechaInicio!.isAfter(picked)) {
        _data.fechaInicio = picked;
      }
    });
    _calcularDias();
  }

  /// Validaciones adicionales a las de los campos; devuelve el mensaje de error o null
  String? _validarDatos() {
    if (_data.personal == null) {
      return 'Debes seleccionar un personal';
    }
    if (_data.fechaInicio == null || _data.fechaFin == null) {
      return 'Debes seleccionar fecha de inicio y fin';
    }
    if (_data.tipo == null) {
      return 'Debes seleccionar un tipo de ausencia';
    }
    if (_data.diasCalculados <= 0) {
      return 'El rango de fechas debe ser válido (mínimo 1 día)';
    }
    return null;
  }

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
          carpeta: 'ausencias',
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
    } else if (_isEditing && widget.ausencia!.documentoAdjunto != null) {
      // Si estamos editando y no hay archivo nuevo, mantener el existente
      documentoUrl = widget.ausencia!.documentoAdjunto;
    }

    final AusenciaEntity ausencia = _buildEntity(documentoUrl);
    if (mounted) {
      context.read<AusenciasBloc>().add(
            _isEditing ? AusenciaUpdateRequested(ausencia) : AusenciaCreateRequested(ausencia),
          );
    }
  }

  AusenciaEntity _buildEntity(String? documentoUrl) {
    final String motivo = _data.motivo.text.trim();
    final String observaciones = _data.observaciones.text.trim();
    return AusenciaEntity(
      id: widget.ausencia?.id ?? '',
      idPersonal: _data.personal!.id,
      idTipoAusencia: _data.tipo!.id,
      fechaInicio: _data.fechaInicio!,
      fechaFin: _data.fechaFin!,
      motivo: motivo.isEmpty ? null : motivo,
      estado: _data.estado,
      observaciones: observaciones.isEmpty ? null : observaciones,
      documentoAdjunto: documentoUrl,
      documentoStoragePath: widget.ausencia?.documentoStoragePath,
      fechaAprobacion: widget.ausencia?.fechaAprobacion,
      aprobadoPor: widget.ausencia?.aprobadoPor,
      activo: true,
      createdAt: widget.ausencia?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  void _showSavingOverlay() {
    unawaited(
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext _) => AppLoadingOverlay(
          message: _isEditing ? 'Actualizando ausencia...' : 'Creando ausencia...',
          color: _isEditing ? AppColors.secondary : AppColors.primary,
          icon: _isEditing ? Icons.edit : Icons.add_circle_outline,
        ),
      ),
    );
  }

  void _onBlocState(BuildContext context, AusenciasState state) {
    if (state is AusenciasLoaded) {
      CrudOperationHandler.handleSuccess(
        context: context,
        isSaving: _isSaving,
        isEditing: _isEditing,
        entityName: 'Ausencia',
        onClose: () => setState(() => _isSaving = false),
      );
    } else if (state is AusenciasError) {
      CrudOperationHandler.handleError(
        context: context,
        isSaving: _isSaving,
        isEditing: _isEditing,
        entityName: 'Ausencia',
        errorMessage: state.message,
        onClose: () => setState(() => _isSaving = false),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AusenciasBloc, AusenciasState>(
      listener: _onBlocState,
      child: GestionFormDialog(
        title: _isEditing ? 'Editar ausencia' : 'Nueva ausencia',
        subtitle: _isEditing ? _data.personal?.nombreCompleto : null,
        icon: Icons.event_busy_outlined,
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
            AusenciaFormBody(
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
